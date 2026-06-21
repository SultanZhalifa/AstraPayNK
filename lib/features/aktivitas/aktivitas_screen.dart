import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/widgets/svg_icon.dart';
import '../../shared/widgets/sub_app_bar.dart';
import '../../shared/widgets/transaction_tile.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

enum _Filter { semua, masuk, cicilan, modal }

class _AktivitasScreenState extends State<AktivitasScreen> {
  _Filter _filter = _Filter.semua;

  bool _match(TransactionModel t) {
    switch (_filter) {
      case _Filter.semua:
        return true;
      case _Filter.masuk:
        return t.isCredit;
      case _Filter.cicilan:
        return t.type == TransactionType.splitRepayment ||
            t.type == TransactionType.angsuranFif;
      case _Filter.modal:
        return t.type == TransactionType.modalCair;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final txs = app.transactions.where(_match).toList();
    final masuk = app.transactions
        .where((t) => t.isCredit)
        .fold<double>(0, (s, t) => s + t.amount);
    final keluar = app.transactions
        .where((t) => !t.isCredit)
        .fold<double>(0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              const SubAppBar(title: 'Aktivitas'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                  children: [
                    _cashflow(app),
                    const SizedBox(height: 16),
                    _summary(masuk, keluar),
                    const SizedBox(height: 16),
                    _filters(),
                    const SizedBox(height: 14),
                    if (txs.isEmpty)
                      _empty()
                    else
                      ...txs.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: TransactionTile(tx: t),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cashflow(AppState app) {
    final data = app.seed.weeklyCashflow;
    final total = data.fold<double>(0, (s, v) => s + v);
    final avg = data.isEmpty ? 0.0 : total / data.length;
    final maxV = data.reduce(math.max);
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(SvgIcons.chart, size: 17, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Arus Kas QRIS · 7 Hari',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(Formatters.compactCurrency(total),
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxV * 1.25,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxV / 2).clamp(1, double.infinity),
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
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i > 6) return const SizedBox.shrink();
                        final d = now.subtract(Duration(days: 6 - i));
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(Formatters.dayShort(d),
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textTertiary)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i],
                          width: 15,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5)),
                          gradient: AppColors.primaryGradient,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Rata-rata ${Formatters.compactCurrency(avg)}/hari · sinyal utama AstraScore',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _summary(double masuk, double keluar) {
    return Row(
      children: [
        Expanded(
          child:
              _sumCard('Total Masuk', masuk, AppColors.success, SvgIcons.trendUp),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _sumCard('Total Keluar', keluar, AppColors.textSecondary,
              SvgIcons.trendDown),
        ),
      ],
    );
  }

  Widget _sumCard(String label, double value, Color color, String icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(Formatters.currency(value),
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    final labels = {
      _Filter.semua: 'Semua',
      _Filter.masuk: 'Masuk',
      _Filter.cicilan: 'Cicilan',
      _Filter.modal: 'Modal',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.entries.map((e) {
          final sel = _filter == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textSecondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
                child: AppIcon(SvgIcons.receipt,
                    size: 28, color: AppColors.textTertiary)),
          ),
          const SizedBox(height: 14),
          const Text('Belum ada transaksi',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
