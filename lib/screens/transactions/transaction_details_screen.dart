import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/bank_transaction.dart';
import '../../domain/entities/telco.dart';
import '../../domain/entities/transaction_status.dart';
import '../../widgets/callout.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tatum_scaffold.dart';

/// Transaction Details Redesign — brand-yellow app bar, a circular badge
/// (network logo for airtime, arrow for transfers), the stacked category
/// label, and the full transaction info card.
class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transaction =
        ModalRoute.of(context)?.settings.arguments as BankTransaction?;

    if (transaction == null) {
      return const TatumScaffold(
        title: 'Transaction Details',
        body: Center(child: Text('This transaction is no longer available.')),
      );
    }

    final deps = context.read<Dependencies>();
    final theme = Theme.of(context);

    return TatumScaffold(
      title: 'Transaction Details',
      style: TatumAppBarStyle.brand,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => context.showMessage('Sharing this receipt…'),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _Summary(transaction: transaction, deps: deps),
          const SizedBox(height: AppSpacing.xl),
          Text('TRANSACTION INFO',
              style: theme.textTheme.bodySmall
                  ?.copyWith(letterSpacing: 1, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          InfoCard(
            rows: [
              InfoRow(label: 'Transaction Type', value: transaction.transactionType),
              InfoRow(label: 'Amount', value: deps.money.format(transaction.amount)),
              InfoRow(
                label: transaction.isCredit ? 'Account Credited' : 'Account Debited',
                value: transaction.counterpartyAccount ?? 'Savings • 012****345',
              ),
              if (transaction.narration.isNotEmpty)
                InfoRow(label: 'Narration', value: transaction.narration),
              if (transaction.reference.isNotEmpty)
                InfoRow(
                    label: 'Reference Number',
                    value: transaction.reference,
                    copyable: true),
              InfoRow(label: 'Transaction ID', value: transaction.id, copyable: true),
              InfoRow(label: 'Channel', value: transaction.channel),
              if (transaction.phoneNumber != null)
                InfoRow(label: 'Phone Number', value: transaction.phoneNumber!),
              if (transaction.sessionId != null)
                InfoRow(label: 'Session ID', value: transaction.sessionId!),
              if (transaction.fee > 0)
                InfoRow(label: 'Transaction Fee', value: deps.money.format(transaction.fee)),
              if (transaction.fee > 0)
                InfoRow(
                    label: 'Total Amount',
                    value: deps.money.format(transaction.total),
                    emphasised: true),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Callout(
            title: 'Need Help with this?',
            message: 'If you have issues with this transaction, our team is here to help.',
            icon: Icons.help_outline,
            actionLabel: 'CONTACT SUPPORT',
            onAction: () => Navigator.pushNamed(context, AppRoutes.support),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Download Receipt',
            icon: Icons.receipt_long_outlined,
            showChevron: true,
            onPressed: () => context.showMessage('Your receipt is downloading…'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final BankTransaction transaction;
  final Dependencies deps;

  const _Summary({required this.transaction, required this.deps});

  /// Airtime and data rows show the network badge; everything else shows a
  /// directional arrow.
  bool get _isTelco =>
      transaction.category == TransactionCategory.airtime ||
      transaction.category == TransactionCategory.data;

  TelcoNetwork get _network => TelcoNetwork.values.firstWhere(
        (n) => transaction.title.toLowerCase().contains(n.label.toLowerCase()),
        orElse: () => TelcoNetwork.mtn,
      );

  String get _categoryLabel => switch (transaction.category) {
        TransactionCategory.data => 'DATA PURCHASE',
        TransactionCategory.airtime => 'AIRTIME',
        TransactionCategory.bills => 'BILL PAYMENT',
        TransactionCategory.salary => 'MONEY IN',
        TransactionCategory.refund => 'REFUND',
        TransactionCategory.transfer =>
          transaction.isCredit ? 'MONEY IN' : 'MONEY OUT',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _isTelco
                  ? Color(_network.brandColor)
                  : (transaction.isCredit
                      ? AppColors.successTint
                      : AppColors.primaryTint),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: _isTelco
                ? Text(_network.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(_network.onBrandColor)))
                : Icon(
                    transaction.isCredit
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 28,
                    color: transaction.isCredit
                        ? AppColors.success
                        : AppColors.navy,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(_categoryLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(letterSpacing: 1.4, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text(transaction.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            deps.money.formatSigned(transaction.amount,
                isCredit: transaction.isCredit),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              color: transaction.status == TransactionStatus.failed
                  ? AppColors.danger
                  : AppColors.navy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          StatusBadge(status: transaction.status),
          const SizedBox(height: AppSpacing.sm),
          Text(deps.dates.fullDateTime(transaction.date),
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
