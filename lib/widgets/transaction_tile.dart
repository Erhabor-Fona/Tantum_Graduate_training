import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../domain/entities/bank_transaction.dart';
import '../domain/entities/transaction_status.dart';
import '../domain/services/date_formatter.dart';
import '../domain/services/money_formatter.dart';

/// A single row in Recent Transactions and Transaction History.
///
/// DIP: formatting comes in through [money] and [dates] rather than being
/// hard-coded, so the tile works in any locale the app is configured for.
class TransactionTile extends StatelessWidget {
  final BankTransaction transaction;
  final MoneyFormatter money;
  final DateFormatterService dates;
  final VoidCallback? onTap;
  final bool showTime;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.money,
    required this.dates,
    this.onTap,
    this.showTime = true,
  });

  ({IconData icon, Color color, Color tint}) get _visual {
    if (transaction.isCredit) {
      return (icon: Icons.arrow_downward, color: AppColors.success, tint: AppColors.successTint);
    }
    return switch (transaction.category) {
      TransactionCategory.bills =>
        (icon: Icons.receipt_long_outlined, color: AppColors.gold, tint: AppColors.primaryTint),
      TransactionCategory.airtime =>
        (icon: Icons.phone_android_outlined, color: AppColors.accent, tint: AppColors.infoTint),
      TransactionCategory.data =>
        (icon: Icons.wifi, color: AppColors.gold, tint: AppColors.primaryTint),
      _ => (icon: Icons.arrow_upward, color: AppColors.accent, tint: AppColors.infoTint),
    };
  }

  Color get _amountColor => switch (transaction.status) {
        TransactionStatus.failed => AppColors.textMuted,
        _ => transaction.isCredit ? AppColors.success : AppColors.textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    final visual = _visual;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: visual.tint, shape: BoxShape.circle),
              child: Icon(visual.icon, size: 19, color: visual.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.status.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: transaction.status == TransactionStatus.failed
                          ? AppColors.danger
                          : transaction.status == TransactionStatus.pending
                              ? AppColors.gold
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isCredit ? '+ ' : '- '}${money.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _amountColor,
                    decoration: transaction.status == TransactionStatus.failed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (showTime) ...[
                  const SizedBox(height: 2),
                  Text(dates.time(transaction.date),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
