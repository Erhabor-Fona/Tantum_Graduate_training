import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../domain/entities/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/state_views.dart';

/// Notification Page — TODAY / YESTERDAY sections, unread dots and the
/// optional inline action link ("Top Up Now").
class NotificationsScreen extends StatefulWidget {
  final bool embedded;
  const NotificationsScreen({super.key, this.embedded = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    final token = context.read<AuthProvider>().authToken;
    return context.read<NotificationProvider>().load(token);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'preferences') {
                Navigator.pushNamed(
                    context, AppRoutes.notificationPreferences);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'preferences', child: Text('Notification settings')),
            ],
          ),
        ],
      ),
      body: StateSwitcher(
        state: provider.state,
        errorMessage: provider.errorMessage,
        onRetry: _load,
        emptyView: const EmptyView(
          title: 'No notifications',
          message: "We'll let you know when something happens.",
          icon: Icons.notifications_none,
        ),
        onSuccess: () => RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              for (final entry in provider.grouped.entries) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(entry.key,
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                ),
                for (final item in entry.value)
                  _NotificationCard(
                    notification: item,
                    relativeTime:
                        context.read<Dependencies>().dates.relative(item.date),
                    onTap: () {
                      final token = context.read<AuthProvider>().authToken;
                      provider.markAsRead(token, item.id);
                      Navigator.pushNamed(
                          context, AppRoutes.notificationDetail,
                          arguments: item);
                    },
                  ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final String relativeTime;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.relativeTime,
    required this.onTap,
  });

  (IconData, Color, Color) get _visual => switch (notification.kind) {
        NotificationKind.transaction => (
            Icons.wifi,
            AppColors.gold,
            AppColors.primaryTint
          ),
        NotificationKind.balance => (
            Icons.account_balance_wallet_outlined,
            AppColors.danger,
            AppColors.dangerTint
          ),
        NotificationKind.security => (
            Icons.notifications_active_outlined,
            AppColors.accent,
            AppColors.infoTint
          ),
        NotificationKind.promo => (
            Icons.card_giftcard,
            AppColors.accent,
            AppColors.infoTint
          ),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, iconColor, background) = _visual;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(color: background, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notification.title,
                            style: theme.textTheme.titleSmall),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.accent, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(notification.body, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(relativeTime, style: theme.textTheme.bodySmall),
                      const Spacer(),
                      if (notification.actionLabel != null)
                        Text(
                          notification.actionLabel!,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
