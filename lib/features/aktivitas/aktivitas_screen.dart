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
