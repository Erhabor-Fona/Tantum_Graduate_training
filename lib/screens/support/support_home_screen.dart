import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/support_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/support_provider.dart';
import '../../widgets/status_badge.dart';

/// Support Home M18 — greeting, help search, the assistance card, four help
/// tiles and the recent requests list.
class SupportHomeScreen extends StatefulWidget {
  final bool embedded;
  const SupportHomeScreen({super.key, this.embedded = false});

  @override
  State<SupportHomeScreen> createState() => _SupportHomeScreenState();
}

class _SupportHomeScreenState extends State<SupportHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().authToken;
      context.read<SupportProvider>().load(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();
    final support = context.watch<SupportProvider>();
    final user = context.watch<AuthProvider>().user;
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Support'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_none),
            ),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Hi, ${user?.firstName ?? 'there'} 👋',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('How can we help you today?', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            onSubmitted: (q) =>
                context.showMessage('Searching help articles for "$q"…'),
            decoration: const InputDecoration(
              hintText: 'Search help articles...',
              prefixIcon: Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _AssistanceCard(
            onCreate: () =>
                Navigator.pushNamed(context, AppRoutes.createRequest),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.55,
            children: [
              _HelpTile(
                icon: Icons.help_outline,
                color: AppColors.success,
                title: 'FAQs',
                subtitle: 'Find answers to common questions',
                onTap: () => context.showMessage('Opening FAQs…'),
              ),
              _HelpTile(
                icon: Icons.menu_book_outlined,
                color: AppColors.accent,
                title: 'Guides & Tutorials',
                subtitle: 'Step-by-step guides to help you',
                onTap: () => context.showMessage('Opening guides…'),
              ),
              _HelpTile(
                icon: Icons.shield_outlined,
                color: AppColors.gold,
                title: 'Security Center',
                subtitle: 'Tips and info to keep your account safe',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.securitySettings),
              ),
              _HelpTile(
                icon: Icons.chat_bubble_outline,
                color: AppColors.accent,
                title: 'Contact Us',
                subtitle: 'Reach out to our support team',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.createRequest),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Requests', style: theme.textTheme.titleMedium),
              if (support.requests.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.requestStatus),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (support.requests.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 32, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No requests yet', style: theme.textTheme.titleSmall),
                  Text('Anything you raise will show up here.',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            )
          else
            for (final request in support.requests.take(3))
              _RequestCard(
                request: request,
                updatedLabel: deps.dates.shortDate(request.createdAt),
                onTap: () {
                  support.select(request);
                  Navigator.pushNamed(
                      context,
                      request.isResolved
                          ? AppRoutes.requestStatus
                          : AppRoutes.requestDetails);
                },
              ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _AssistanceCard extends StatelessWidget {
  final VoidCallback onCreate;
  const _AssistanceCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoTint,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need Assistance?', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text('Our support team is ready to help you with any issue.',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: onCreate,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Create a Request',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent)),
                      Icon(Icons.chevron_right,
                          size: 16, color: AppColors.accent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.headset_mic_outlined,
              size: 46, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const Spacer(),
            Text(title,
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 13)),
            Text(subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SupportRequest request;
  final String updatedLabel;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.updatedLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequestStatusPill(status: request.status),
                  const SizedBox(height: AppSpacing.sm),
                  Text(request.issueType, style: theme.textTheme.titleSmall),
                  Text('Request ID: ${request.id}',
                      style: theme.textTheme.bodySmall),
                  Text('Updated on $updatedLabel',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
