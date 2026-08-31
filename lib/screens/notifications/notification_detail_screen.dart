import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../domain/entities/app_notification.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../domain/entities/transaction_status_x.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tatum_scaffold.dart';

/// Notification Detail — the haloed icon, the amount, and whatever structured
/// rows the notification carried with it.
///
/// OCP: the rows come from `notification.details`, so a new notification type
/// with different fields renders correctly without editing this screen.
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notification =
        ModalRoute.of(context)?.settings.arguments as AppNotification?;

    if (notification == null) {
      return const TatumScaffold(
        title: 'Notification Detail',
        body: Center(child: Text('This notification is no longer available.')),
      );
    }

    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();

    return TatumScaffold(
      title: 'Notification Detail',
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                  color: AppColors.primaryTint, shape: BoxShape.circle),
              child: Icon(_iconFor(notification.kind),
                  size: 38, color: AppColors.gold),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(notification.title,
              textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          if (notification.amount != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              deps.money.formatSigned(notification.amount!, isCredit: false),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 30),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          InfoCard(
            rows: [
              for (final entry in notification.details.entries)
                if (entry.key.toLowerCase() == 'status')
                  InfoRow(
                    label: entry.key,
                    valueWidget: StatusBadge(
                      status: TransactionStatusX.parseLabel(entry.value),
                      compact: true,
                    ),
                  )
                else
                  InfoRow(label: entry.key, value: entry.value),
              if (notification.details.isEmpty)
                InfoRow(label: 'Received', value: deps.dates.fullDateTime(notification.date)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  IconData _iconFor(NotificationKind kind) => switch (kind) {
        NotificationKind.transaction => Icons.wifi,
        NotificationKind.balance => Icons.account_balance_wallet_outlined,
        NotificationKind.security => Icons.shield_outlined,
        NotificationKind.promo => Icons.card_giftcard,
      };
}
