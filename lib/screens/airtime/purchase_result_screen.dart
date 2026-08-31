import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/purchase_request.dart';
import '../../domain/entities/telco.dart';
import '../../widgets/callout.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/tatum_scaffold.dart';

/// Data Purchase Success and Data Purchase Failed.
///
/// OCP: the two outcomes are configuration of one layout, so a third outcome
/// (for example "Pending") would be a new set of values rather than a new
/// screen.
class PurchaseResultScreen extends StatelessWidget {
  const PurchaseResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final deps = context.read<Dependencies>();

    if (args is PurchaseReceipt) {
      return _PurchaseResultView(
        succeeded: true,
        amountLabel: deps.money.format(args.amount),
        caption: 'AMOUNT PAID',
        rows: [
          InfoRow(label: 'Network', value: args.network.label),
          if (args.planName != null)
            InfoRow(label: 'Plan', value: args.planName!),
          InfoRow(label: 'Recipient', value: args.recipient, copyable: true),
          InfoRow(
              label: 'Transaction ID',
              value: args.transactionId,
              copyable: true),
          InfoRow(label: 'Date', value: deps.dates.fullDateTime(args.date)),
        ],
      );
    }

    final map = args is Map<String, dynamic> ? args : const <String, dynamic>{};
    final amount = (map['amount'] as num?)?.toDouble() ?? 0;
    final network = map['network'] as TelcoNetwork? ?? TelcoNetwork.mtn;

    return _PurchaseResultView(
      succeeded: false,
      amountLabel: deps.money.format(amount),
      caption: 'ATTEMPTED AMOUNT',
      message: map['failure'] as String? ??
          "We couldn't process your request at this time.",
      rows: [
        InfoRow(label: 'Network', value: network.label),
        if (map['planName'] != null)
          InfoRow(label: 'Plan', value: map['planName'] as String),
        InfoRow(
            label: 'Recipient',
            value: map['recipient'] as String? ?? '—',
            copyable: true),
      ],
    );
  }
}

class _PurchaseResultView extends StatelessWidget {
  final bool succeeded;
  final String amountLabel;
  final String caption;
  final String? message;
  final List<Widget> rows;

  const _PurchaseResultView({
    required this.succeeded,
    required this.amountLabel,
    required this.caption,
    required this.rows,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TatumScaffold(
      title: succeeded ? 'Transaction Successful' : 'Transaction Failed',
      style: TatumAppBarStyle.brand,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: succeeded ? AppColors.successTint : AppColors.dangerTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                succeeded ? Icons.check : Icons.close,
                size: 38,
                color: succeeded ? AppColors.success : AppColors.danger,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (message != null) ...[
            Text(message!,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(caption,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(letterSpacing: 1, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text(amountLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 32)),
          const SizedBox(height: AppSpacing.xxl),
          InfoCard(rows: rows),
          const SizedBox(height: AppSpacing.xl),
          Callout(
            title: 'Need Help?',
            message:
                'If you encounter any issues, our support team is available 24/7.',
            icon: Icons.help_outline,
            actionLabel: succeeded ? 'CONTACT SUPPORT' : 'LEARN MORE',
            onAction: () => Navigator.pushNamed(context, AppRoutes.support),
            tone: succeeded ? CalloutTone.info : CalloutTone.warning,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (succeeded) ...[
            PrimaryButton(
              label: 'Done',
              icon: Icons.receipt_long_outlined,
              showChevron: true,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (_) => false),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Share Receipt',
              icon: Icons.share_outlined,
              onPressed: () => context.showMessage('Sharing this receipt…'),
            ),
          ] else ...[
            PrimaryButton(
              label: 'Try Again',
              icon: Icons.refresh,
              showChevron: true,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Back to Home',
              icon: Icons.home_outlined,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (_) => false),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
