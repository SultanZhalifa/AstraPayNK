import '../../core/engine/astra_score_engine.dart';
import '../models/transaction_model.dart';
import '../models/active_modal.dart';

enum Persona { budi, sari, andi, rini }

/// A single point on the score-history chart.
class ScorePoint {
  final DateTime month;
  final int score;
  const ScorePoint(this.month, this.score);
}

/// A potential QRIS payer for the live "Terima QRIS" demo.
class QrisPayer {
  final String name;
  final double amount;
  const QrisPayer(this.name, this.amount);
}

/// Immutable identity + seed state for a demo persona. AppState clones the
/// mutable bits (transactions / modal) so "Reset Demo" restores cleanly.
class PersonaSeed {
  final Persona persona;
  final String name;
  final String phone;
  final String businessName;
  final String businessCategory;
  final String accountTier; // Basic / Plus / Preferred
  final DateTime joinDate;
  final bool isVerified;

  final double balance;
  final int points;
  final int previousScore;
  final double monthlyQrisVolume;

  final List<ScoreSignal> signals;
  final List<ScorePoint> history;
  final List<QrisPayer> qrisPayers;

  // Built fresh each time (kept as builders so resets give a clean copy).
  final List<TransactionModel> Function() seedTransactions;
  final ActiveModal? Function() seedModal;

  const PersonaSeed({
    required this.persona,
    required this.name,
    required this.phone,
    required this.businessName,
    required this.businessCategory,
    required this.accountTier,
    required this.joinDate,
    required this.isVerified,
    required this.balance,
    required this.points,
    required this.previousScore,
    required this.monthlyQrisVolume,
    required this.signals,
    required this.history,
    required this.qrisPayers,
    required this.seedTransactions,
    required this.seedModal,
  });

  String get initials => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0])
      .take(2)
      .join()
      .toUpperCase();

  /// Ilustrasi arus kas QRIS 7 hari terakhir (Rupiah/hari), diturunkan dari
  /// rata-rata volume bulanan — untuk dashboard arus kas ala AstraPay Biz.
  List<double> get weeklyCashflow {
    final daily = monthlyQrisVolume / 30;
    const pattern = [0.8, 1.05, 0.9, 1.15, 1.3, 1.45, 1.05];
    return pattern.map((m) => daily * m).toList();
  }
}

class Personas {
  Personas._();

  static List<ScorePoint> _history(List<int> scores) {
    final now = DateTime(2026, 6);
    return List.generate(scores.length, (i) {
      final m = DateTime(now.year, now.month - (scores.length - 1 - i));
      return ScorePoint(m, scores[i]);
    });
  }

  static final PersonaSeed budi = PersonaSeed(
    persona: Persona.budi,
    name: 'Budi Santoso',
    phone: '081234567890',
    businessName: 'Budi Ojek Express',
    businessCategory: 'Driver Ojek Online',
    accountTier: 'Plus',
    joinDate: DateTime(2024, 3, 15),
    isVerified: true,
    balance: 847500,
    points: 12750,
    previousScore: 558,
    monthlyQrisVolume: 4500000,
    signals: const [
      ScoreSignal(
        key: 'fif',
        label: 'Ketepatan Bayar Angsuran FIF',
        weight: 0.35,
        value: 0.60,
        description: 'Angsuran motor FIF tepat waktu 9 dari 12 bulan terakhir.',
      ),
      ScoreSignal(
        key: 'qris',
        label: 'Volume & Konsistensi QRIS',
        weight: 0.30,
        value: 0.50,
        description: 'Rata-rata 14 transaksi QRIS/minggu, arus kas stabil.',
      ),
      ScoreSignal(
        key: 'topup',
        label: 'Keteraturan Top-up',
        weight: 0.15,
        value: 0.50,
        description: 'Top-up 3-4x per minggu, frekuensi transaksi konsisten.',
      ),
      ScoreSignal(
        key: 'tenure',
        label: 'Tenure & Kelengkapan Akun',
        weight: 0.10,
        value: 0.42,
        description: 'Akun aktif 2+ tahun, tier Plus (belum Preferred).',
      ),
      ScoreSignal(
        key: 'growth',
        label: 'Tren Pertumbuhan',
        weight: 0.10,
        value: 0.55,
        description: 'Pendapatan QRIS naik 12% dalam 3 bulan terakhir.',
      ),
    ],
    history: _historyBudi,
    qrisPayers: const [
      QrisPayer('Pak Ahmad', 35000),
      QrisPayer('Ibu Sari', 28000),
      QrisPayer('Mas Deni', 42000),
      QrisPayer('Bu Ratna', 55000),
      QrisPayer('Pak Joko', 30000),
      QrisPayer('Mba Ani', 38000),
      QrisPayer('Pak Hasan', 25000),
      QrisPayer('Ibu Wati', 45000),
    ],
    seedModal: _budiModal,
    seedTransactions: _budiTx,
  );

  static final PersonaSeed sari = PersonaSeed(
    persona: Persona.sari,
    name: 'Sari Wulandari',
    phone: '081298765432',
    businessName: 'Warung Sembako Bu Sari',
    businessCategory: 'Warung Kelontong',
    accountTier: 'Preferred',
    joinDate: DateTime(2022, 8, 10),
    isVerified: true,
    balance: 1250000,
    points: 28400,
    previousScore: 672,
    monthlyQrisVolume: 9000000,
    signals: const [
      ScoreSignal(
        key: 'fif',
        label: 'Ketepatan Bayar Angsuran FIF',
        weight: 0.35,
        value: 0.80,
        description: 'Angsuran FIF lunas tepat waktu 12 dari 12 bulan.',
      ),
      ScoreSignal(
        key: 'qris',
        label: 'Volume & Konsistensi QRIS',
        weight: 0.30,
        value: 0.72,
        description: 'Rata-rata 40+ transaksi QRIS/minggu, sangat konsisten.',
      ),
      ScoreSignal(
        key: 'topup',
        label: 'Keteraturan Top-up',
        weight: 0.15,
        value: 0.68,
        description: 'Top-up rutin & pembayaran tagihan lewat AstraPay.',
      ),
      ScoreSignal(
        key: 'tenure',
        label: 'Tenure & Kelengkapan Akun',
        weight: 0.10,
        value: 0.70,
        description: 'Akun aktif 3+ tahun, status Preferred.',
      ),
      ScoreSignal(
        key: 'growth',
        label: 'Tren Pertumbuhan',
        weight: 0.10,
        value: 0.66,
        description: 'Omzet QRIS tumbuh stabil menjelang musim ramai.',
      ),
    ],
    history: _historySari,
    qrisPayers: const [
      QrisPayer('Bu Yanti', 62000),
      QrisPayer('Pak Eko', 45000),
      QrisPayer('Mba Tina', 30000),
      QrisPayer('Bu Lilis', 88000),
      QrisPayer('Pak Rudi', 25000),
      QrisPayer('Anak Kos', 18000),
      QrisPayer('Bu Nani', 53000),
      QrisPayer('Pak Surya', 41000),
    ],
    seedModal: _noModal,
    seedTransactions: _sariTx,
  );

  static final PersonaSeed andi = PersonaSeed(
    persona: Persona.andi,
    name: 'Andi Pratama',
    phone: '085711223344',
    businessName: 'Andi Kurir & Antar',
    businessCategory: 'Kurir / Driver',
    accountTier: 'Basic',
    joinDate: DateTime(2025, 11, 20),
    isVerified: true,
    balance: 235000,
    points: 3200,
    previousScore: 470,
    monthlyQrisVolume: 2800000,
    signals: const [
      ScoreSignal(
        key: 'fif',
        label: 'Ketepatan Bayar Angsuran FIF',
        weight: 0.35,
        value: 0.40,
        description: 'Angsuran FIF baru berjalan 5 bulan, 1x terlambat.',
      ),
      ScoreSignal(
        key: 'qris',
        label: 'Volume & Konsistensi QRIS',
        weight: 0.30,
        value: 0.35,
        description: 'QRIS mulai dipakai, volume masih naik-turun.',
      ),
      ScoreSignal(
        key: 'topup',
        label: 'Keteraturan Top-up',
        weight: 0.15,
        value: 0.32,
        description: 'Top-up belum rutin, sesekali saja.',
      ),
      ScoreSignal(
        key: 'tenure',
        label: 'Tenure & Kelengkapan Akun',
        weight: 0.10,
        value: 0.25,
        description: 'Akun baru 7 bulan, tier Basic.',
      ),
      ScoreSignal(
        key: 'growth',
        label: 'Tren Pertumbuhan',
        weight: 0.10,
        value: 0.42,
        description: 'Transaksi mulai meningkat sejak 2 bulan terakhir.',
      ),
    ],
    history: _historyAndi,
    qrisPayers: const [
      QrisPayer('Order COD', 40000),
      QrisPayer('Ongkir Antar', 22000),
      QrisPayer('Pak Beni', 35000),
      QrisPayer('Titip Paket', 15000),
      QrisPayer('Bu Mira', 28000),
      QrisPayer('Mas Galih', 33000),
    ],
    seedModal: _noModal,
    seedTransactions: _andiTx,
  );

  static final PersonaSeed rini = PersonaSeed(
    persona: Persona.rini,
    name: 'Rini Kusuma',
    phone: '082145678901',
    businessName: 'Bengkel Motor Rini Jaya',
    businessCategory: 'Bengkel Motor',
    accountTier: 'Plus',
    joinDate: DateTime(2023, 9, 5),
    isVerified: true,
    balance: 642000,
    points: 9800,
    previousScore: 558,
    monthlyQrisVolume: 6500000,
    signals: const [
      ScoreSignal(
        key: 'fif',
        label: 'Ketepatan Bayar Angsuran FIF',
        weight: 0.35,
        value: 0.55,
        description: 'Angsuran motor FIF tepat waktu 10 dari 12 bulan terakhir.',
      ),
      ScoreSignal(
        key: 'qris',
        label: 'Volume & Konsistensi QRIS',
        weight: 0.30,
        value: 0.50,
        description: 'Pemasukan servis & sparepart via QRIS, arus kas naik-turun.',
      ),
      ScoreSignal(
        key: 'topup',
        label: 'Keteraturan Top-up',
        weight: 0.15,
        value: 0.48,
        description: 'Top-up cukup rutin untuk belanja stok sparepart.',
      ),
      ScoreSignal(
        key: 'tenure',
        label: 'Tenure & Kelengkapan Akun',
        weight: 0.10,
        value: 0.45,
        description: 'Akun aktif hampir 3 tahun, tier Plus.',
      ),
      ScoreSignal(
        key: 'growth',
        label: 'Tren Pertumbuhan',
        weight: 0.10,
        value: 0.60,
        description: 'Jumlah pelanggan bengkel naik dalam 3 bulan terakhir.',
      ),
    ],
    history: _historyRini,
    qrisPayers: const [
      QrisPayer('Servis - Pak Budi', 85000),
      QrisPayer('Ganti Oli - Mas Eko', 55000),
      QrisPayer('Sparepart - Bu Tina', 120000),
      QrisPayer('Tambal Ban', 25000),
      QrisPayer('Servis Rutin - Joko', 95000),
      QrisPayer('Kampas Rem - Andi', 70000),
    ],
    seedModal: _noModal,
    seedTransactions: _riniTx,
  );

  static final Map<Persona, PersonaSeed> all = {
    Persona.budi: budi,
    Persona.sari: sari,
    Persona.andi: andi,
    Persona.rini: rini,
  };

  // ===== History data =====
  static final List<ScorePoint> _historyBudi =
      _history([430, 470, 505, 540, 558, 593]);
  static final List<ScorePoint> _historySari =
      _history([610, 640, 660, 672, 688, 704]);
  static final List<ScorePoint> _historyAndi =
      _history([420, 435, 452, 463, 470, 498]);
  static final List<ScorePoint> _historyRini =
      _history([505, 520, 532, 545, 558, 572]);

  // ===== Seed modals =====
  static ActiveModal? _noModal() => null;

  static ActiveModal _budiModal() {
    final now = DateTime.now();
    return ActiveModal(
      id: 'MDL-2026-0481',
      referenceNo: 'DISB-880241733',
      partner: 'FINATRA',
      amount: 1000000,
      tenorDays: 14,
      serviceFee: 25000,
      splitRate: 0.15,
      disbursedAt: now.subtract(const Duration(days: 6)),
      dueDate: now.add(const Duration(days: 8)),
      amountPaid: 384000,
    );
  }

  // ===== Seed transactions =====
  static List<TransactionModel> _budiTx() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'TRX-B01',
        type: TransactionType.qrisIncoming,
        description: 'Pembayaran ojek - Pak Ahmad',
        amount: 35000,
        date: now.subtract(const Duration(minutes: 12)),
        isCredit: true,
        splitInfo: '15% (Rp5.250) untuk cicilan Modal Jalan',
      ),
      TransactionModel(
        id: 'TRX-B02',
        type: TransactionType.splitRepayment,
        description: 'Auto-split cicilan Modal Jalan',
        amount: 5250,
        date: now.subtract(const Duration(minutes: 12)),
        isCredit: false,
      ),
      TransactionModel(
        id: 'TRX-B03',
        type: TransactionType.qrisIncoming,
        description: 'Pembayaran ojek - Ibu Sari',
        amount: 28000,
        date: now.subtract(const Duration(hours: 1, minutes: 30)),
        isCredit: true,
        splitInfo: '15% (Rp4.200) untuk cicilan Modal Jalan',
      ),
      TransactionModel(
        id: 'TRX-B04',
        type: TransactionType.topUp,
        description: 'Top Up via Indomaret',
        amount: 100000,
        date: now.subtract(const Duration(hours: 5)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-B05',
        type: TransactionType.modalCair,
        description: 'Pencairan Modal Jalan (FINATRA)',
        amount: 1000000,
        date: now.subtract(const Duration(days: 6)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-B06',
        type: TransactionType.angsuranFif,
        description: 'Angsuran motor Honda Beat - FIF',
        amount: 850000,
        date: now.subtract(const Duration(days: 9)),
        isCredit: false,
      ),
    ];
  }

  static List<TransactionModel> _sariTx() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'TRX-S01',
        type: TransactionType.qrisIncoming,
        description: 'Belanja sembako - Bu Yanti',
        amount: 62000,
        date: now.subtract(const Duration(minutes: 8)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-S02',
        type: TransactionType.qrisIncoming,
        description: 'Belanja sembako - Pak Eko',
        amount: 45000,
        date: now.subtract(const Duration(minutes: 40)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-S03',
        type: TransactionType.ppob,
        description: 'Token Listrik PLN',
        amount: 100000,
        date: now.subtract(const Duration(hours: 3)),
        isCredit: false,
      ),
      TransactionModel(
        id: 'TRX-S04',
        type: TransactionType.angsuranFif,
        description: 'Angsuran motor Vario - FIF',
        amount: 720000,
        date: now.subtract(const Duration(days: 3)),
        isCredit: false,
      ),
      TransactionModel(
        id: 'TRX-S05',
        type: TransactionType.topUp,
        description: 'Top Up via Bank BCA',
        amount: 500000,
        date: now.subtract(const Duration(days: 4)),
        isCredit: true,
      ),
    ];
  }

  static List<TransactionModel> _andiTx() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'TRX-A01',
        type: TransactionType.qrisIncoming,
        description: 'Ongkir antar - Order COD',
        amount: 40000,
        date: now.subtract(const Duration(minutes: 25)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-A02',
        type: TransactionType.angsuranFif,
        description: 'Angsuran motor Beat - FIF',
        amount: 680000,
        date: now.subtract(const Duration(days: 2)),
        isCredit: false,
      ),
      TransactionModel(
        id: 'TRX-A03',
        type: TransactionType.topUp,
        description: 'Top Up via GoPay',
        amount: 50000,
        date: now.subtract(const Duration(days: 2)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-A04',
        type: TransactionType.qrisIncoming,
        description: 'Titip paket - Bu Mira',
        amount: 28000,
        date: now.subtract(const Duration(days: 3)),
        isCredit: true,
      ),
    ];
  }

  static List<TransactionModel> _riniTx() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'TRX-R01',
        type: TransactionType.qrisIncoming,
        description: 'Servis motor - Pak Budi',
        amount: 85000,
        date: now.subtract(const Duration(minutes: 18)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-R02',
        type: TransactionType.qrisIncoming,
        description: 'Sparepart - Bu Tina',
        amount: 120000,
        date: now.subtract(const Duration(hours: 2, minutes: 10)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-R03',
        type: TransactionType.topUp,
        description: 'Top Up via Bank Mandiri',
        amount: 300000,
        date: now.subtract(const Duration(hours: 6)),
        isCredit: true,
      ),
      TransactionModel(
        id: 'TRX-R04',
        type: TransactionType.angsuranFif,
        description: 'Angsuran motor Vario - FIF',
        amount: 750000,
        date: now.subtract(const Duration(days: 4)),
        isCredit: false,
      ),
      TransactionModel(
        id: 'TRX-R05',
        type: TransactionType.ppob,
        description: 'Beli stok sparepart (supplier)',
        amount: 250000,
        date: now.subtract(const Duration(days: 5)),
        isCredit: false,
      ),
    ];
  }
}
