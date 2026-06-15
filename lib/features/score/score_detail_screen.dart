import 'package:fl_chart/fl_chart.dart';
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
import '../home/dashboard_view.dart' show levelColor;

class ScoreDetailScreen extends StatelessWidget {
  const ScoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pad = Responsive.pagePadding(context);
    final s = app.score;

    return SafeArea(
      bottom: false,
      child: ResponsiveCenter(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 110),
          children: [
            const Text('AstraScore',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Skor kredit alternatif dari jejak transaksimu',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 18),
            _hero(context, app),
            const SizedBox(height: 16),
            _historyCard(app),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('Faktor Penilaian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('explainable',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Mulai dari basis 300 poin, tiap faktor menambah skormu.',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            const SizedBox(height: 12),
            ...s.signals.map((sig) => _factorCard(sig)),
            const SizedBox(height: 8),
            _boostCard(context, app),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, AppState app) {
    final s = app.score;
    final lc = levelColor(s.level);
    final next = AstraScoreEngine.nextLevelScore(s.score);
    final gaugeSize = (Responsive.width(context) * 0.52).clamp(170.0, 210.0);

    return GlassCard(
      gradient: AppColors.heroGradient,
      border: Border.all(color: Colors.transparent),
      shadow: AppColors.softShadow(AppColors.primary, opacity: 0.3),
      child: Column(
        children: [
          ScoreGauge(
            score: s.score,
            size: gaugeSize,
            trackColor: Colors.white.withValues(alpha: 0.18),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedCounter(
                  value: s.score.toDouble(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      height: 1),
                ),
                Text('dari ${AppConstants.scoreMax}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Level ${s.level}',
                      style: TextStyle(
                          color: lc,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next == null
                ? 'Skor tertinggi tercapai — pertahankan!'
                : '${next - s.score} poin lagi menuju ${Formatters.scoreLevel(next)}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 12.5,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _heroStat(
                    'Status Modal',
                    s.eligible ? 'Terbuka' : 'Terkunci',
                    s.eligible ? null : Colors.white),
                _vline(),
                _heroStat('Plafon',
                    s.eligible ? Formatters.compactCurrency(s.plafon) : '—', null),
                _vline(),
                _heroStat('Biaya',
                    '${(s.serviceFeeRate * 100).toStringAsFixed(1)}%', null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, Color? vc) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
          const SizedBox(height: 3),
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    color: vc ?? Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _vline() =>
      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.18));

  // ===== History chart =====
  Widget _historyCard(AppState app) {
    final pts = app.history;
    final scores = pts.map((e) => e.score).toList();
    // include the live score as the latest point
    final liveScores = [...scores];
    if (liveScores.isNotEmpty) liveScores[liveScores.length - 1] = app.score.score;
    final minY = (liveScores.reduce((a, b) => a < b ? a : b) - 40)
        .clamp(AppConstants.scoreMin, AppConstants.scoreMax)
        .toDouble();
    final maxY = (liveScores.reduce((a, b) => a > b ? a : b) + 40)
        .clamp(AppConstants.scoreMin, AppConstants.scoreMax)
        .toDouble();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(SvgIcons.chart, size: 17, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Riwayat 6 Bulan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('+${liveScores.last - liveScores.first} poin',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: ((maxY - minY) / 3).clamp(1, 1000),
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= pts.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(Formatters.monthShort(pts[i].month),
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textTertiary)),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < liveScores.length; i++)
                        FlSpot(i.toDouble(), liveScores[i].toDouble()),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    gradient: AppColors.primaryGradient,
                    barWidth: 3.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, _) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.22),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Factor card =====
  Widget _factorCard(ScoreSignal sig) {
    final color = _factorColor(sig.value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(sig.label,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text('bobot ${(sig.weight * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: sig.fill.toDouble()),
                      duration: const Duration(milliseconds: 700),
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 7,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('+${sig.points.round()}',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(sig.description,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Color _factorColor(double v) {
    if (v >= 0.7) return AppColors.success;
    if (v >= 0.45) return AppColors.accent;
    return AppColors.error;
  }

  // ===== Demo boost =====
  Widget _boostCard(BuildContext context, AppState app) {
    return GlassCard(
      color: AppColors.primarySofter,
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(SvgIcons.sparkles, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Disiplin = skor naik',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Setiap angsuran FIF tepat waktu & QRIS sehat menaikkan AstraScore dan memberi AstraPoints. Coba simulasikan:',
            style: TextStyle(
                fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              context.read<AppState>().awardScoreBoostDemo();
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(
                    content: Text('AstraScore diperbarui · +50 AstraPoints')));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(SvgIcons.motorcycle, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Simulasi: Bayar Angsuran Tepat Waktu',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
