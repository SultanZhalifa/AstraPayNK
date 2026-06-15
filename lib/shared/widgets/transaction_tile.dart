import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../models/transaction_model.dart';
import 'svg_icon.dart';

/// Visual mapping (icon + colour) for each transaction type.
class TxVisuals {
  static String icon(TransactionType t) {
    switch (t) {
      case TransactionType.qrisIncoming:
        return SvgIcons.qris;
      case TransactionType.qrisOutgoing:
        return SvgIcons.store;
      case TransactionType.splitRepayment:
        return SvgIcons.split;
      case TransactionType.angsuranFif:
        return SvgIcons.motorcycle;
      case TransactionType.topUp:
        return SvgIcons.plus;
      case TransactionType.modalCair:
        return SvgIcons.handCoins;
      case TransactionType.transfer:
        return SvgIcons.arrowRight;
      case TransactionType.ppob:
        return SvgIcons.lightning;
    }
  }

  static Color color(TransactionType t) {
    switch (t) {
      case TransactionType.qrisIncoming:
        return AppColors.success;
      case TransactionType.splitRepayment:
        return AppColors.accentDark;
      case TransactionType.angsuranFif:
        return AppColors.primary;
      case TransactionType.modalCair:
        return AppColors.success;
      case TransactionType.topUp:
        return AppColors.info;
      case TransactionType.qrisOutgoing:
      case TransactionType.transfer:
      case TransactionType.ppob:
        return AppColors.textSecondary;
    }
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final bool showSplitInfo;

  const TransactionTile({
    super.key,
    required this.tx,
    this.showSplitInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = TxVisuals.color(tx.type);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: AppIcon(TxVisuals.icon(tx.type), size: 20, color: c)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.typeLabel} · ${Formatters.relativeTime(tx.date)}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                ),
                if (showSplitInfo && tx.splitInfo != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tx.splitInfo!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${tx.isCredit ? '+' : '−'}${Formatters.currency(tx.amount)}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: tx.isCredit ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
