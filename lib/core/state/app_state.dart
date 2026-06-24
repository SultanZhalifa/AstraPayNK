import 'dart:math';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../engine/astra_score_engine.dart';
import '../services/astrapay_service.dart';
import '../services/mock_astrapay_service.dart';
import '../../shared/data/personas.dart';
import '../../shared/models/active_modal.dart';
import '../../shared/models/transaction_model.dart';

/// A settled QRIS payment + its auto-split breakdown, used by the live demo.
class QrisSplitEvent {
  final String referenceNo;
  final String payer;
  final double gross;
  final double mdr;
  final double split;
  final double net;
  final DateTime time;
  final bool appliedToModal;

  const QrisSplitEvent({
    required this.referenceNo,
    required this.payer,
    required this.gross,
    required this.mdr,
    required this.split,
    required this.net,
    required this.time,
    required this.appliedToModal,
  });
}

/// Single source of truth for the prototype. Holds the live, mutable state of
/// the active persona and exposes the actions that drive the whole journey:
/// scoring, Modal Jalan disbursement, "bayar sambil jualan" split-repayment,
/// and the AstraPoints loop. Everything recomputes through [AstraScoreEngine],
/// so screens stay in sync automatically (provider / ChangeNotifier).
class AppState extends ChangeNotifier {
  AppState({AstraPayService? service})
      : service = service ?? MockAstraPayService(),
        _engine = const AstraScoreEngine() {
    _load(Persona.budi);
  }

  final AstraPayService service;
  final AstraScoreEngine _engine;
  final Random _rng = Random();

  // ===== Persona identity =====
  late PersonaSeed _seed;
  PersonaSeed get seed => _seed;
  Persona get persona => _seed.persona;

  // ===== Mutable live state =====
  double _balance = 0;
  int _points = 0;
  int _previousScore = 0;
  double _splitRate = AppConstants.defaultSplitPercentage;
  bool _dataConsent = true;

  late List<ScoreSignal> _signals;
  late List<TransactionModel> _transactions;
  ActiveModal? _activeModal;
  late ScoreResult _result;

  int _txSeq = 0;

  // Transient UI events (consumed then cleared by the UI).
  String? lastEventMessage;
  bool justLeveledUp = false;
  bool justEligible = false;

  // ===== Getters =====
  double get balance => _balance;
  int get points => _points;
  double get splitRate => _splitRate;
  bool get dataConsent => _dataConsent;
  List<ScoreSignal> get signals => List.unmodifiable(_signals);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<ScorePoint> get history => _seed.history;
  ActiveModal? get activeModal => _activeModal;
  ScoreResult get score => _result;
  int get previousScore => _previousScore;
  int get scoreDelta => _result.score - _previousScore;
  bool get scoreUp => scoreDelta >= 0;

  /// Whether the merchant currently owes on a Modal Jalan.
  bool get hasActiveObligation =>
      _activeModal != null && !_activeModal!.isPaidOff;

  /// Plafon still available to draw (zero while an obligation is open).
  double get availableToDraw => hasActiveObligation ? 0 : _result.plafon;

  String get environment => service.environment;

  // ===== Lifecycle =====
  void _load(Persona p) {
    _seed = Personas.all[p]!;
    _balance = _seed.balance;
    _points = _seed.points;
    _previousScore = _seed.previousScore;
    _splitRate = AppConstants.defaultSplitPercentage;
    _signals = _seed.signals.map((s) => s.copyWith()).toList();
    _transactions = _seed.seedTransactions();
    _activeModal = _seed.seedModal();
    _dataConsent = true;
    _txSeq = 0;
    _evaluate();
  }

  void switchPersona(Persona p) {
    if (p == _seed.persona) return;
    _load(p);
    notifyListeners();
  }

  void resetDemo() {
    _load(_seed.persona);
    lastEventMessage = 'Demo direset ke kondisi awal';
    notifyListeners();
  }

  void setSplitRate(double rate) {
    _splitRate = rate;
    if (_activeModal != null) _activeModal!.splitRate = rate;
    notifyListeners();
  }

  void setConsent(bool value) {
    _dataConsent = value;
    notifyListeners();
  }

  void _evaluate() {
    _result = _engine.evaluate(
      signals: _signals,
      monthlyQrisVolume: _seed.monthlyQrisVolume,
    );
  }

  void _nudge(String key, double delta) {
    final i = _signals.indexWhere((s) => s.key == key);
    if (i == -1) return;
    final v = (_signals[i].value + delta).clamp(0.0, 0.98);
    _signals[i] = _signals[i].copyWith(value: v);
  }

  String _nextId(String prefix) => '$prefix-${++_txSeq}-${_rng.nextInt(9999)}';

  void _insertTx(TransactionModel tx) => _transactions.insert(0, tx);

  // ===== Action: disburse Modal Jalan =====
  Future<void> disburseModal({
    required double amount,
    required int tenorDays,
  }) async {
    final fee = (amount * _result.serviceFeeRate);
    final res = await service.disburseModal(
      amount: amount,
      tenorDays: tenorDays,
      serviceFee: fee,
    );
    _activeModal = ActiveModal(
      id: 'MDL-${DateTime.now().millisecondsSinceEpoch % 100000}',
      referenceNo: res.referenceNo,
      partner: res.partner,
      amount: res.amount,
      tenorDays: res.tenorDays,
      serviceFee: res.serviceFee,
      splitRate: _splitRate,
      disbursedAt: res.disbursedAt,
      dueDate: res.dueDate,
      amountPaid: 0,
    );
    _balance += amount;
    _insertTx(TransactionModel(
      id: _nextId('TRX'),
      type: TransactionType.modalCair,
      description: 'Pencairan Modal Jalan (${res.partner})',
      amount: amount,
      date: res.disbursedAt,
      isCredit: true,
    ));
    notifyListeners();
  }

  // ===== Action: receive an incoming QRIS payment (the live demo) =====
  Future<QrisSplitEvent> receiveQris({QrisPayer? payer, double? amount}) async {
    final pool = _seed.qrisPayers;
    final chosen = payer ?? pool[_rng.nextInt(pool.length)];
    final gross = amount ?? chosen.amount;

    final applies = hasActiveObligation;
    final effectiveRate = applies ? _activeModal!.splitRate : 0.0;
    final res = await service.receiveQrisPayment(
      amount: gross,
      payerName: chosen.name,
      splitRate: effectiveRate,
    );

    double split = 0;
    if (applies) {
      final wantSplit = gross * effectiveRate;
      split = min(wantSplit, _activeModal!.remaining);
      _activeModal!.amountPaid += split;
    }
    final mdr = res.mdrFee;
    final net = gross - mdr - split;
    _balance += net;

    // Cash-flow signals improve a little with healthy QRIS activity.
    _nudge('qris', 0.004);
    _nudge('growth', 0.002);

    final wasBelowEligible = !_result.eligible;
    final prevLevel = _result.level;

    _insertTx(TransactionModel(
      id: _nextId('QR'),
      type: TransactionType.qrisIncoming,
      description: 'Pembayaran QRIS - ${chosen.name}',
      amount: gross,
      date: res.settledAt,
      isCredit: true,
      splitInfo: split > 0
          ? '${(effectiveRate * 100).toStringAsFixed(0)}% (Rp${split.toStringAsFixed(0)}) untuk cicilan Modal Jalan'
          : null,
    ));

    // Collect every celebration that fires from this one settlement so none
    // gets silently overwritten when several land at once (e.g. on-time payoff
    // AND a level-up in the same QRIS).
    final events = <String>[];

    if (split > 0) {
      _insertTx(TransactionModel(
        id: _nextId('SP'),
        type: TransactionType.splitRepayment,
        description: 'Auto-split cicilan Modal Jalan',
        amount: split,
        date: res.settledAt,
        isCredit: false,
      ));
      _points += AppConstants.pointsPerQrisSplit;

      // On-time full payoff: strong discipline signal + loyalty bonus.
      if (_activeModal!.isPaidOff) {
        _nudge('fif', 0.06);
        _nudge('growth', 0.03);
        _points += AppConstants.pointsPerOnTimeRepayment;
        events.add(
            'Modal Jalan lunas tepat waktu! +${AppConstants.pointsPerOnTimeRepayment} AstraPoints');
      }
    }

    _evaluate();

    if (wasBelowEligible && _result.eligible) {
      justEligible = true;
      events.add('Selamat! Skormu kini membuka Modal Jalan ${_formatPlafon()}');
    }
    if (_leveledUp(prevLevel, _result.level)) {
      justLeveledUp = true;
      _points += AppConstants.pointsPerLevelUp;
      events.add(
          'Naik kelas ke ${_result.level}! +${AppConstants.pointsPerLevelUp} AstraPoints');
    }

    if (events.isNotEmpty) lastEventMessage = events.join(' · ');

    notifyListeners();

    return QrisSplitEvent(
      referenceNo: res.referenceNo,
      payer: chosen.name,
      gross: gross,
      mdr: mdr,
      split: split,
      net: net,
      time: res.settledAt,
      appliedToModal: split > 0,
    );
  }

  // ===== Action: redeem an AstraPoints reward =====
  bool redeemReward(int cost, String title) {
    if (_points < cost) return false;
    _points -= cost;
    lastEventMessage = 'Berhasil menukar: $title';
    notifyListeners();
    return true;
  }

  void awardScoreBoostDemo() {
    // "Bayar angsuran FIF tepat waktu" simulation from the score screen.
    final prevLevel = _result.level;
    final wasBelowEligible = !_result.eligible;
    _nudge('fif', 0.05);
    _nudge('topup', 0.03);
    _points += AppConstants.pointsPerScoreBoost;
    _evaluate();

    final events = <String>['AstraScore diperbarui dari aktivitas terbarumu'];
    if (wasBelowEligible && _result.eligible) {
      justEligible = true;
      events.add('Modal Jalan kini terbuka — plafon ${_formatPlafon()}');
    }
    if (_leveledUp(prevLevel, _result.level)) {
      justLeveledUp = true;
      _points += AppConstants.pointsPerLevelUp;
      events.add(
          'Naik kelas ke ${_result.level}! +${AppConstants.pointsPerLevelUp} AstraPoints');
    }
    lastEventMessage = events.join(' · ');
    notifyListeners();
  }

  /// Level ordering, used to award the loyalty bonus only on an *upward* move.
  static const List<String> _levelOrder = [
    'Pemula',
    'Berkembang',
    'Mandiri',
    'Bintang'
  ];
  bool _leveledUp(String from, String to) =>
      _levelOrder.indexOf(to) > _levelOrder.indexOf(from);

  void consumeEvents() {
    lastEventMessage = null;
    justLeveledUp = false;
    justEligible = false;
  }

  String _formatPlafon() {
    final p = _result.plafon;
    if (p >= 1000000) {
      final jt = p / 1000000;
      final s = jt.toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
      return 'Rp$s jt';
    }
    return 'Rp${(p / 1000).toStringAsFixed(0)} rb';
  }
}
