import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/transfer.dart';
import '../../widgets/callout.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tatum_scaffold.dart';
import '../../domain/entities/transaction_status.dart';

/// Transfer Success and Transfer Failed in one screen.
///
/// LSP in practice: both outcomes render the same summary + details card and
/// differ only in tone, copy and the actions offered — so there is one layout
/// to maintain rather than two that drift apart.
class TransferResultScreen extends StatelessWidget {
  const TransferResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final deps = context.read<Dependencies>();

    if (args is TransferReceipt) {
      return _ResultView(
        succeeded: true,
        title: 'Transfer Successful!',
        subtitle: 'Your money has been sent successfully.',
        amount: args.request.amount,
        recipient: args.request.accountName,
        rows: [
          const InfoRow(label: 'Transaction Type', value: 'Bank Transfer'),
          InfoRow(
              label: 'From Account',
              value: 'Savings Account\n${args.fromAccount}'),
          InfoRow(
              label: 'To',
              value:
                  '${args.request.accountName}\n${args.request.bank.name} - ${args.request.accountNumber}'),
          InfoRow(label: 'Amount', value: deps.money.format(args.request.amount)),
          InfoRow(label: 'Transaction Fee', value: deps.money.format(args.fee)),
          InfoRow(
              label: 'Total Amount',
              value: deps.money.format(args.total),
              emphasised: true),
          InfoRow(label: 'Reference Number', value: args.reference, copyable: true),
        ],
        dateLabel: deps.dates.fullDateTime(args.date),
      );
    }

    final map = args is Map<String, dynamic> ? args : const <String, dynamic>{};
    final amount = (map['amount'] as num?)?.toDouble() ?? 0;
    final bank = map['bank'] as Bank?;
    final resolved = map['resolved'] as ResolvedAccount?;

    return _ResultView(
      succeeded: false,
      title: 'Transfer Failed',
      subtitle: "We couldn't complete your transfer.",
      amount: amount,
      recipient: resolved?.accountName ?? 'the recipient',
      reason: map['failure'] as String? ?? 'Insufficient Funds',
      rows: [
        const InfoRow(label: 'Transaction Type', value: 'Bank Transfer'),
        const InfoRow(
            label: 'From Account', value: 'Savings Account\n7099887766'),
        if (resolved != null && bank != null)
          InfoRow(
              label: 'To',
              value:
                  '${resolved.accountName}\n${bank.name} - ${resolved.accountNumber}'),
        InfoRow(label: 'Amount', value: deps.money.format(amount)),
        InfoRow(
            label: 'Reason',
            value: map['failure'] as String? ?? 'Insufficient Funds',
            valueColor: AppColors.danger),
      ],
      dateLabel: deps.dates.fullDateTime(DateTime.now()),
    );
  }
}

class _ResultView extends StatelessWidget {
  final bool succeeded;
  final String title;
  final String subtitle;
  final double amount;
  final String recipient;
  final String? reason;
  final List<Widget> rows;
  final String dateLabel;

  const _ResultView({
    required this.succeeded,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.recipient,
    required this.rows,
    required this.dateLabel,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();

    return TatumScaffold(
      title: succeeded ? 'Transfer Success' : 'Transfer Failed',
      leading: IconButton(
        icon: const Icon(Icons.home_outlined),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (_) => false),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => context.showMessage('Sharing this receipt…'),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: succeeded ? AppColors.successTint : AppColors.dangerTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              succeeded ? Icons.check_circle : Icons.cancel,
              size: 40,
              color: succeeded ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title,
              textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle,
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Text(deps.money.format(amount),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 30)),
          Text('to $recipient',
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: StatusBadge(
                status: succeeded
                    ? TransactionStatus.successful
                    : TransactionStatus.failed),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(dateLabel,
              textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          Text('TRANSACTION DETAILS',
              style: theme.textTheme.bodySmall
                  ?.copyWith(letterSpacing: 1, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          InfoCard(rows: rows),
          const SizedBox(height: AppSpacing.xl),
          if (succeeded)
            const Callout(
              title: 'Important Notice',
              message:
                  'The recipient will be notified of this transfer. Some banks may take up to 24 hours to reflect the transaction.',
            )
          else
            Callout(
              tone: CalloutTone.danger,
              icon: Icons.error_outline,
              message: reason == 'Insufficient Funds'
                  ? "You don't have enough balance to complete this transfer."
                  : reason ?? 'Please try again in a moment.',
              actionLabel: 'Fund Your Account',
              onAction: () => context.showMessage('Account funding is coming soon.'),
            ),
          const SizedBox(height: AppSpacing.xxl),
          if (succeeded) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconAction(
                  icon: Icons.download_outlined,
                  label: 'Download Receipt',
                  onTap: () => context.showMessage('Your receipt is downloading…'),
                ),
                const SizedBox(width: AppSpacing.xxxl),
                _IconAction(
                  icon: Icons.share_outlined,
                  label: 'Share Receipt',
                  onTap: () => context.showMessage('Sharing this receipt…'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'View Receipt',
              icon: Icons.receipt_long_outlined,
              showChevron: true,
              onPressed: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.transactionHistory),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.support),
                child: const Text('Need help? CONTACT SUPPORT'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: 'New Transfer',
              background: AppColors.navy,
              foreground: AppColors.white,
              onPressed: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.newTransfer),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Try Again',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: 'Fund Account',
                    background: AppColors.navy,
                    foreground: AppColors.white,
                    onPressed: () =>
                        context.showMessage('Account funding is coming soon.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.support),
                child: const Text('Having issues? CONTACT SUPPORT'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.navy),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}
