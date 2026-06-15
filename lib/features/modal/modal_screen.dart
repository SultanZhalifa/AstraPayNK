import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/models/active_modal.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/svg_icon.dart';
import '../home/dashboard_view.dart' show levelColor;
import 'pencairan_flow_screen.dart';

class ModalScreen extends StatefulWidget {
  const ModalScreen({super.key});

  @override
  State<ModalScreen> createState() => _ModalScreenState();
}

class _ModalScreenState extends State<ModalScreen> {
  double _amount = 1000000;
  int _tenor = 14;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pad = Responsive.pagePadding(context);

    return SafeArea(
      bottom: false,
      child: ResponsiveCenter(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 110),
          children: [
            const Text('Modal Jalan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Modal kerja produktif dari jejak transaksimu',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 18),
            if (app.hasActiveObligation)
              _activeState(app)
            else if (app.score.eligible)
              _simulator(context, app)
            else
              _lockedState(app),
          ],
        ),
      ),
    );
  }

  // ===== Active obligation =====
  Widget _activeState(AppState app) {
    final m = app.activeModal!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          gradient: AppColors.accentGradient,
          border: Border.all(color: Colors.transparent),
          shadow: AppColors.softShadow(AppColors.accent, opacity: 0.26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppIcon(SvgIcons.handCoins, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Modal Aktif',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text(m.referenceNo,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sisa cicilan',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(Formatters.currency(m.remaining),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Jatuh tempo',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12)),
                      Text(Formatters.date(m.dueDate),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: m.progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sudah dibayar ${(m.progress * 100).toStringAsFixed(0)}% (${Formatters.currency(m.amountPaid)})',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9), fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _detailCard(m),
        const SizedBox(height: 14),
        const InfoNote(
          icon: AppIcon(SvgIcons.split, size: 18, color: AppColors.primary),
          text:
              'Cicilan berjalan otomatis: setiap pembayaran QRIS yang masuk langsung menyisihkan porsi cicilan. Buka "Terima QRIS" untuk melihatnya bekerja.',
        ),
      ],
    );
  }

  Widget _detailCard(ActiveModal m) {
    return GlassCard(
      child: Column(
        children: [
          _row('Pokok Modal', Formatters.currency(m.amount)),
          _row('Biaya Layanan', Formatters.currency(m.serviceFee)),
          _row('Total Pengembalian', Formatters.currency(m.totalRepayment)),
          _row('Tenor', '${m.tenorDays} hari'),
          _row('Split Repayment', '${(m.splitRate * 100).toStringAsFixed(0)}% per QRIS'),
          _row('Penyalur', m.partner),
        ],
      ),
    );
  }

  // ===== Eligible: simulator =====
  Widget _simulator(BuildContext context, AppState app) {
    final plafon = app.score.plafon;
    if (_amount > plafon) _amount = plafon;
    if (_amount < AppConstants.modalMin) _amount = AppConstants.modalMin;
    final feeRate = app.score.serviceFeeRate;
    final fee = _amount * feeRate;
    final total = _amount + fee;
    final daily = total / _tenor;
    final lc = levelColor(app.score.level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plafon
        GlassCard(
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Center(
                    child: AppIcon(SvgIcons.checkCircle,
                        size: 24, color: AppColors.success)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Plafon Tersedia',
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary)),
                    Text(Formatters.currency(plafon),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: lc.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Skor ${app.score.score}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: lc)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Plafon dihitung dari AstraScore + rata-rata arus kas QRIS bulananmu.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
          ),
        ),
        const SizedBox(height: 22),
        const Text('Atur Pencairan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        // Amount
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nominal Modal',
                  style:
                      TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(Formatters.currency(_amount),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              Slider(
                value: _amount.clamp(AppConstants.modalMin, plafon),
                min: AppConstants.modalMin,
                max: plafon,
                divisions: (((plafon - AppConstants.modalMin) /
                            AppConstants.modalStep)
                        .round())
                    .clamp(1, 1000),
                onChanged: (v) => setState(() => _amount =
                    (v / AppConstants.modalStep).round() *
                        AppConstants.modalStep),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Formatters.compactCurrency(AppConstants.modalMin),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                  Text(Formatters.compactCurrency(plafon),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Tenor
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tenor',
                  style:
                      TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Row(
                children: AppConstants.tenorOptions.map((d) {
                  final sel = _tenor == d;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tenor = d),
                      child: AnimatedContainer(
                        duration: AppConstants.fast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color:
                              sel ? AppColors.primarySoft : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? AppColors.primary : AppColors.border,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text('$d',
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: sel
                                        ? AppColors.primary
                                        : AppColors.textPrimary)),
                            Text('hari',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: sel
                                        ? AppColors.primary
                                        : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Breakdown
        GlassCard(
          child: Column(
            children: [
              _row('Nominal Modal', Formatters.currency(_amount)),
              _row('Biaya Layanan (${(feeRate * 100).toStringAsFixed(1)}%)',
                  Formatters.currency(fee)),
              const Divider(height: 20),
              _row('Total Pengembalian', Formatters.currency(total),
                  bold: true),
              _row('Estimasi cicilan/hari', '±${Formatters.currency(daily)}',
                  valueColor: AppColors.accentDark),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ditagih otomatis ${(app.splitRate * 100).toStringAsFixed(0)}% dari tiap QRIS masuk',
                  style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GradientButton(
          text: 'Cairkan Modal Jalan',
          gradient: AppColors.successGradient,
          glowColor: AppColors.success,
          icon: const AppIcon(SvgIcons.lightning, size: 19, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  PencairanFlowScreen(amount: _amount, tenor: _tenor),
            ));
          },
        ),
      ],
    );
  }

  // ===== Locked =====
  Widget _lockedState(AppState app) {
    final need = AppConstants.eligibleScore - app.score.score;
    final progress = (app.score.score - AppConstants.scoreMin) /
        (AppConstants.eligibleScore - AppConstants.scoreMin);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                    child: AppIcon(SvgIcons.lock,
                        size: 28, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 14),
              const Text('Modal Jalan belum terbuka',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'AstraScore-mu $need poin lagi menuju ${AppConstants.eligibleScore} untuk membuka Modal Jalan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text('Skor ${app.score.score} / ${AppConstants.eligibleScore}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Cara menaikkan skor',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _tip(SvgIcons.motorcycle, 'Bayar angsuran FIF tepat waktu',
            'Sinyal disiplin kredit paling kuat (bobot 35%).'),
        _tip(SvgIcons.qris, 'Terima lebih banyak QRIS',
            'Tunjukkan arus kas yang konsisten (bobot 30%).'),
        _tip(SvgIcons.plus, 'Top-up & transaksi rutin',
            'Aktivitas teratur menaikkan kepercayaan (bobot 15%).'),
      ],
    );
  }

  Widget _tip(String icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                  child: AppIcon(icon, size: 19, color: AppColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
