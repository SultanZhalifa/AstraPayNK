import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/engine/astra_score_engine.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/animated_counter.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/score_gauge.dart';
import '../../shared/widgets/svg_icon.dart';
import '../../shared/widgets/transaction_tile.dart';
import 'persona_switcher.dart';

Color levelColor(String level) {
  switch (level) {
    case 'Bintang':
      return AppColors.scoreBintang;
    case 'Mandiri':
      return AppColors.scoreMandiri;
    case 'Berkembang':
      return AppColors.scoreBerkembang;
    default:
      return AppColors.scorePemula;
  }
}

class DashboardView extends StatelessWidget {
  final VoidCallback onOpenModal;
  final VoidCallback onOpenScore;
  final VoidCallback onTerimaQris;
  final VoidCallback onOpenAktivitas;
  final VoidCallback onOpenPoints;

  const DashboardView({
    super.key,
    required this.onOpenModal,
    required this.onOpenScore,
    required this.onTerimaQris,
    required this.onOpenAktivitas,
    required this.onOpenPoints,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pad = Responsive.pagePadding(context);

    return SafeArea(
      bottom: false,
      child: ResponsiveCenter(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 110),
          children: [
            _greeting(context, app),
            const SizedBox(height: 18),
            _scoreHero(context, app),
            const SizedBox(height: 14),
            _modalCard(context, app),
            const SizedBox(height: 22),
            _quickActions(context),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Aktivitas Terbaru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: onOpenAktivitas,
                  child: const Text('Lihat semua',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...app.transactions.take(5).map(
                  (tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: TransactionTile(tx: tx),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // ===== Greeting =====
  Widget _greeting(BuildContext context, AppState app) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => showPersonaSwitcher(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                app.seed.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${app.seed.name.split(' ').first}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800),
              ),
              Text(
                app.seed.businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _circleBtn(SvgIcons.users, onTap: () => showPersonaSwitcher(context)),
        const SizedBox(width: 8),
        _circleBtn(SvgIcons.notification, onTap: () {}, dot: true),
      ],
    );
  }

  Widget _circleBtn(String icon, {required VoidCallback onTap, bool dot = false}) {
    return Stack(
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                  child:
                      AppIcon(icon, size: 19, color: AppColors.textSecondary)),
            ),
          ),
        ),
        if (dot)
          Positioned(
            right: 9,
            top: 9,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  // ===== Score hero =====
  Widget _scoreHero(BuildContext context, AppState app) {
    final s = app.score;
    final lc = levelColor(s.level);
    final next = AstraScoreEngine.nextLevelScore(s.score);
    final gaugeSize = (Responsive.width(context) * 0.46).clamp(150.0, 180.0);

    return GlassCard(
      onTap: onOpenScore,
      gradient: AppColors.heroGradient,
      border: Border.all(color: Colors.transparent),
      shadow: AppColors.softShadow(AppColors.primary, opacity: 0.30),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('AstraScore',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                    const SizedBox(width: 8),
                    Flexible(child: _sandboxPill('Sandbox')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _deltaChip(app),
            ],
          ),
          const SizedBox(height: 4),
          ScoreGauge(
            score: s.score,
            size: gaugeSize,
            stroke: 13,
            trackColor: Colors.white.withValues(alpha: 0.18),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedCounter(
                  value: s.score.toDouble(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1),
                ),
                Text('dari ${AppConstants.scoreMax}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level ${s.level}',
              style: TextStyle(
                  color: lc, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),
          _nextLevelBar(s.score, next),
          const SizedBox(height: 14),
          _heroStats(app),
        ],
      ),
    );
  }

  Widget _sandboxPill(String env) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(SvgIcons.server, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(env,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _deltaChip(AppState app) {
    final up = app.scoreUp;
    final delta = app.scoreDelta;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(up ? SvgIcons.trendUp : SvgIcons.trendDown,
              size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text('${up && delta > 0 ? '+' : ''}$delta bln ini',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _nextLevelBar(int score, int? next) {
    final progress = AstraScoreEngine.progressToNextLevel(score);
    final caption = next == null
        ? 'Skor tertinggi tercapai — pertahankan!'
        : '${next - score} poin lagi menuju ${Formatters.scoreLevel(next)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.20),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        const SizedBox(height: 7),
        Text(caption,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.5,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _heroStats(AppState app) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _stat('Saldo', Formatters.compactCurrency(app.balance)),
          _divider(),
          _stat(
            'Plafon',
            app.score.eligible
                ? Formatters.compactCurrency(app.score.plafon)
                : 'Terkunci',
          ),
          _divider(),
          _stat('Poin', Formatters.number(app.points)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
          const SizedBox(height: 3),
          FittedBox(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.18),
      );

  // ===== Modal card (context-aware) =====
  Widget _modalCard(BuildContext context, AppState app) {
    if (app.hasActiveObligation) return _activeModalCard(app);
    if (app.score.eligible) return _eligibleModalCard(app);
    return _lockedModalCard(app);
  }

  Widget _activeModalCard(AppState app) {
    final m = app.activeModal!;
    return GlassCard(
      onTap: onOpenModal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconTile(SvgIcons.handCoins, AppColors.accentDark),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modal Jalan Aktif',
                        style: TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w700)),
                    Text('Cicilan otomatis dari tiap QRIS masuk',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const AppIcon(SvgIcons.chevronRight,
                  size: 18, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sisa ${Formatters.currency(m.remaining)}',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700)),
              Text('${(m.progress * 100).toStringAsFixed(0)}% lunas',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentDark)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: m.progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text('Jatuh tempo ${Formatters.date(m.dueDate)} · ${m.daysRemaining} hari lagi',
              style: const TextStyle(
                  fontSize: 11.5, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _eligibleModalCard(AppState app) {
    return GlassCard(
      onTap: onOpenModal,
      gradient: AppColors.successGradient,
      border: Border.all(color: Colors.transparent),
      shadow: AppColors.softShadow(AppColors.success, opacity: 0.28),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
                child:
                    AppIcon(SvgIcons.handCoins, size: 24, color: Colors.white)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plafon ${Formatters.compactCurrency(app.score.plafon)} terbuka',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                const Text('Cairkan Modal Jalan sekarang, sekali tap',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          const AppIcon(SvgIcons.arrowRight, size: 20, color: Colors.white),
        ],
      ),
    );
  }

  Widget _lockedModalCard(AppState app) {
    final need = AppConstants.eligibleScore - app.score.score;
    final progress =
        (app.score.score - AppConstants.scoreMin) /
            (AppConstants.eligibleScore - AppConstants.scoreMin);
    return GlassCard(
      onTap: onOpenScore,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconTile(SvgIcons.lock, AppColors.textSecondary),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modal Jalan belum terbuka',
                        style: TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w700)),
                    Text('Tingkatkan AstraScore untuk membuka akses modal',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
          Text(
            'Skor ${app.score.score} · $need poin lagi menuju ${AppConstants.eligibleScore}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _iconTile(String icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(child: AppIcon(icon, size: 20, color: color)),
    );
  }

  // ===== Quick actions =====
  Widget _quickActions(BuildContext context) {
    final items = [
      _QA('Terima\nQRIS', SvgIcons.qris, AppColors.primary, onTerimaQris),
      _QA('Cairkan\nModal', SvgIcons.handCoins, AppColors.success, onOpenModal),
      _QA('Aktivitas', SvgIcons.receipt, AppColors.info, onOpenAktivitas),
      _QA('Astra\nPoints', SvgIcons.star, AppColors.points, onOpenPoints),
    ];
    return Row(
      children: items
          .map((q) => Expanded(
                child: GestureDetector(
                  onTap: q.onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: q.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: q.color.withValues(alpha: 0.18)),
                        ),
                        child: Center(
                            child: AppIcon(q.icon, size: 23, color: q.color)),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        q.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _QA {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;
  _QA(this.label, this.icon, this.color, this.onTap);
}
