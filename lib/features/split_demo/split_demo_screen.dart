import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/animated_counter.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/svg_icon.dart';
import '../../shared/widgets/sub_app_bar.dart';

/// The live "bayar sambil jualan" demo: simulate incoming QRIS payments and
/// watch the auto split-repayment, balance, AstraScore and points update across
/// the whole app in real time. This is the functional heart of the prototype.
class TerimaQrisScreen extends StatefulWidget {
  const TerimaQrisScreen({super.key});

  @override
  State<TerimaQrisScreen> createState() => _TerimaQrisScreenState();
}

class _TerimaQrisScreenState extends State<TerimaQrisScreen>
    with SingleTickerProviderStateMixin {
  final List<QrisSplitEvent> _events = [];
  double _sumGross = 0, _sumSplit = 0, _sumNet = 0;
  bool _auto = false;
  bool _busy = false;
  Timer? _timer;

  late final AnimationController _pulse = AnimationController(
    duration: const Duration(milliseconds: 1100),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _receiveOne() async {
    if (_busy) return;
    _busy = true;
    final app = context.read<AppState>();
    final ev = await app.receiveQris();
    if (!mounted) return;
    setState(() {
      _events.insert(0, ev);
      _sumGross += ev.gross;
      _sumSplit += ev.split;
      _sumNet += ev.net;
    });
    final msg = app.lastEventMessage;
    if (msg != null) {
      app.consumeEvents();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(msg)));
      }
    }
    _busy = false;
  }

  void _toggleAuto() {
    setState(() => _auto = !_auto);
    if (_auto) {
      _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        final app = context.read<AppState>();
        // auto-stop once the active modal is fully repaid
        if (app.activeModal != null && app.activeModal!.isPaidOff) {
          _stopAuto();
          return;
        }
        _receiveOne();
      });
    } else {
      _timer?.cancel();
    }
  }

  void _stopAuto() {
    _timer?.cancel();
    if (mounted) setState(() => _auto = false);
  }

  void _resetSession() {
    setState(() {
      _events.clear();
      _sumGross = _sumSplit = _sumNet = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              SubAppBar(
                title: 'Terima QRIS',
                trailing: IconButton(
                  onPressed: _resetSession,
                  icon: const AppIcon(SvgIcons.refresh,
                      size: 19, color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                  children: [
                    _qrCard(app),
                    const SizedBox(height: 14),
                    _controls(app),
                    const SizedBox(height: 16),
                    _sessionStats(),
                    const SizedBox(height: 14),
                    _modalLive(app),
                    const SizedBox(height: 18),
                    if (_events.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('Live Feed',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          if (_auto)
                            FadeTransition(
                              opacity: _pulse,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.successSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('● LIVE',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._events.map(_eventCard),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== QR receiver hero =====
  Widget _qrCard(AppState app) {
    return GlassCard(
      gradient: AppColors.heroGradient,
      border: Border.all(color: Colors.transparent),
      shadow: AppColors.softShadow(AppColors.primary, opacity: 0.28),
      child: Column(
        children: [
          Row(
            children: [
              const AppIcon(SvgIcons.store, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  app.seed.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('QRIS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: CustomPaint(painter: _QrPainter()),
          ),
          const SizedBox(height: 12),
          Text(
            'Tunjukkan QR untuk menerima pembayaran',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ===== Controls =====
  Widget _controls(AppState app) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(SvgIcons.percent, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('Porsi Split Repayment',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (!app.hasActiveObligation)
                const Text('tanpa modal aktif',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [0.10, 0.15, 0.20].map((r) {
              final sel = (app.splitRate - r).abs() < 0.001;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.read<AppState>().setSplitRate(r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('${(r * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _primaryBtn(
                  label: 'Simulasi QRIS Masuk',
                  icon: SvgIcons.plus,
                  onTap: _busy ? null : _receiveOne,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _toggleBtn(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryBtn(
      {required String label,
      required String icon,
      required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow(AppColors.primary, opacity: 0.28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn() {
    return GestureDetector(
      onTap: _toggleAuto,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _auto ? AppColors.errorSoft : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _auto ? AppColors.error : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(_auto ? SvgIcons.clock : SvgIcons.lightning,
                size: 17, color: _auto ? AppColors.error : AppColors.primary),
            const SizedBox(width: 6),
            Text(_auto ? 'Stop' : 'Auto',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _auto ? AppColors.error : AppColors.primary)),
          ],
        ),
      ),
    );
  }

  // ===== Session stats =====
  Widget _sessionStats() {
    return Row(
      children: [
        _miniStat('QRIS Masuk', _sumGross, AppColors.success),
        const SizedBox(width: 10),
        _miniStat('Ke Cicilan', _sumSplit, AppColors.accentDark),
        const SizedBox(width: 10),
        _miniStat('Ke Saldo', _sumNet, AppColors.primary),
      ],
    );
  }

  Widget _miniStat(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: color)),
            const SizedBox(height: 4),
            FittedBox(
              child: AnimatedCounter(
                value: value,
                prefix: 'Rp',
                groupThousands: true,
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Live modal + score =====
  Widget _modalLive(AppState app) {
    final m = app.activeModal;
    if (m == null) {
      return const InfoNote(
        color: AppColors.info,
        icon: AppIcon(SvgIcons.info, size: 18, color: AppColors.info),
        text:
            'Belum ada Modal Jalan aktif — seluruh QRIS masuk penuh ke saldo. Cairkan Modal Jalan dulu untuk melihat "bayar sambil jualan".',
      );
    }
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Cicilan Modal Jalan',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: m.isPaidOff
                      ? AppColors.successSoft
                      : AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  m.isPaidOff
                      ? 'LUNAS'
                      : '${(m.progress * 100).toStringAsFixed(0)}% lunas',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: m.isPaidOff
                          ? AppColors.success
                          : AppColors.accentDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: m.progress),
              duration: const Duration(milliseconds: 450),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 9,
                backgroundColor: AppColors.surfaceAlt,
                valueColor: AlwaysStoppedAnimation(
                    m.isPaidOff ? AppColors.success : AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sisa ${Formatters.currency(m.remaining)}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  const AppIcon(SvgIcons.score,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Skor ',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  AnimatedCounter(
                    value: app.score.score.toDouble(),
                    duration: const Duration(milliseconds: 500),
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                  if (app.scoreDelta > 0)
                    Text('  +${app.scoreDelta}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _eventCard(QrisSplitEvent e) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Center(
                      child: AppIcon(SvgIcons.qris,
                          size: 18, color: AppColors.success)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.payer,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('QRIS Masuk · ${Formatters.time(e.time)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text('+${Formatters.currency(e.gross)}',
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success)),
              ],
            ),
            if (e.appliedToModal) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _breakdownChip(
                        SvgIcons.split,
                        'Cicilan ${Formatters.currency(e.split)}',
                        AppColors.accentDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _breakdownChip(SvgIcons.wallet,
                        'Saldo ${Formatters.currency(e.net)}', AppColors.primary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _breakdownChip(String icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}

/// Lightweight decorative QR (finder patterns + deterministic modules).
class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const n = 11;
    final cell = size.width / n;
    final p = Paint()..color = AppColors.textPrimary;
    final rng = math.Random(7);

    void finder(int gx, int gy) {
      final r = Rect.fromLTWH(gx * cell, gy * cell, cell * 3, cell * 3);
      canvas.drawRect(r, p);
      canvas.drawRect(
          r.deflate(cell * 0.65), Paint()..color = Colors.white);
      canvas.drawRect(r.deflate(cell * 1.2), p);
    }

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final inFinder = (x < 3 && y < 3) ||
            (x > n - 4 && y < 3) ||
            (x < 3 && y > n - 4);
        if (inFinder) continue;
        if (rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell + 1, y * cell + 1, cell - 2, cell - 2),
            p,
          );
        }
      }
    }
    finder(0, 0);
    finder(n - 3, 0);
    finder(0, n - 3);
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => false;
}
