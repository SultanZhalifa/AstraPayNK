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

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  static const _rewards = [
    _Reward('Cashback Servis Motor', 'Diskon 50% servis di bengkel Astra', 5000),
    _Reward('Gratis Biaya Modal Jalan', 'Bebas biaya layanan 1x pencairan', 8000),
    _Reward('Voucher Pulsa 25rb', 'Pulsa semua operator', 3000),
    _Reward('Cashback Top-up 10%', 'Maks. cashback Rp10.000', 2000),
    _Reward('Diskon Angsuran FIF', 'Potongan Rp50.000 angsuran berikutnya', 10000),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              const SubAppBar(title: 'AstraPoints'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                  children: [
                    _balance(app),
                    const SizedBox(height: 16),
                    _earn(),
                    const SizedBox(height: 22),
                    const Text('Tukar Poin',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ..._rewards.map((r) => _rewardCard(context, app, r)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balance(AppState app) {
    return GlassCard(
      gradient: AppColors.pointsGradient,
      border: Border.all(color: Colors.transparent),
      shadow: AppColors.softShadow(AppColors.points, opacity: 0.3),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
                child: AppIcon(SvgIcons.star, size: 28, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          Text('Poin Kamu',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          const SizedBox(height: 2),
          AnimatedCounter(
            value: app.points.toDouble(),
            groupThousands: true,
            style: const TextStyle(
                color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800),
          ),
          const Text('AstraPoints',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _earn() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cara Dapat Poin',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _earnRow(SvgIcons.check, 'Bayar cicilan tepat waktu',
              '+100', AppColors.success),
          _earnRow(SvgIcons.qris, 'Tiap QRIS menyicil Modal Jalan',
              '+8', AppColors.primary),
          _earnRow(SvgIcons.trendUp, 'AstraScore naik signifikan',
              '+50', AppColors.accentDark),
          _earnRow(SvgIcons.star, 'Naik level (mis. ke Mandiri)',
              '+1000', AppColors.points),
        ],
      ),
    );
  }

  Widget _earnRow(String icon, String title, String pts, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: AppIcon(icon, size: 17, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text('$pts poin',
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _rewardCard(BuildContext context, AppState app, _Reward r) {
    final can = app.points >= r.cost;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.points.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: AppIcon(SvgIcons.gift, size: 22, color: AppColors.points)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700)),
                Text(r.desc,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: can
                ? () {
                    final ok = context
                        .read<AppState>()
                        .redeemReward(r.cost, r.title);
                    if (ok) {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                            SnackBar(content: Text('Berhasil menukar ${r.title}')));
                    }
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: can ? AppColors.primary : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${Formatters.number(r.cost)} pts',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: can ? Colors.white : AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Reward {
  final String title;
  final String desc;
  final int cost;
  const _Reward(this.title, this.desc, this.cost);
}
