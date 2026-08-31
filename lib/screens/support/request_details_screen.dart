import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/support_request.dart';
import '../../providers/support_provider.dart';
import '../../widgets/callout.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tatum_scaffold.dart';

/// Request Details — the open-ticket view with the activity timeline.
class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<SupportProvider>().active;

    if (request == null) {
      return const TatumScaffold(
        title: 'Request Details',
        body: Center(child: Text('Select a request to see its details.')),
      );
    }

    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();

    return TatumScaffold(
      title: 'Request Details',
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'close', child: Text('Close request')),
          ],
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Center(child: RequestStatusPill(status: request.status)),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.infoTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.swap_horiz,
                  size: 26, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(request.issueType,
              textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Request ID: ${request.id}',
              textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          Text(
            'CREATED ON ${deps.dates.fullDateTime(request.createdAt).toUpperCase()}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!request.isResolved)
            const Callout(
              message:
                  "We're reviewing your request. Our team will respond as soon as possible.",
            ),
          const SizedBox(height: AppSpacing.xl),
          Text('Request Information', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          InfoCard(
            rows: [
              InfoRow(label: 'Category', value: request.category),
              InfoRow(label: 'Issue Type', value: request.issueType),
              if (request.transactionReference != null)
                InfoRow(
                    label: 'Transaction Reference',
                    value: request.transactionReference!,
                    copyable: true),
              if (request.amount != null)
                InfoRow(
                    label: 'Amount', value: deps.money.format(request.amount!)),
              InfoRow(label: 'Description', value: request.description),
              if (request.attachmentName != null)
                InfoRow(label: 'Attachment', value: request.attachmentName!),
              InfoRow(
                  label: 'Created On',
                  value: deps.dates.fullDateTime(request.createdAt)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Activity Timeline', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ActivityTimeline(request: request, dates: deps.dates),
          const SizedBox(height: AppSpacing.xxl),
          SecondaryButton(
            label: 'Chat with Support',
            icon: Icons.chat_bubble_outline,
            onPressed: () => context.showMessage('Live chat is coming soon.'),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

/// Vertical timeline of a ticket's events.
///
/// Shared by Request Details and Request Status so the two views can never
/// drift apart (DRY / SRP).
class ActivityTimeline extends StatelessWidget {
  final SupportRequest request;
  final dynamic dates;

  const ActivityTimeline({
    super.key,
    required this.request,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events = request.timeline.isEmpty
        ? [
            RequestEvent(
                status: RequestStatus.received,
                at: request.createdAt,
                note: 'Your request has been received.'),
            const RequestEvent(status: RequestStatus.underReview),
            const RequestEvent(status: RequestStatus.resolved),
          ]
        : request.timeline;

    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: events[i].at != null
                            ? AppColors.accent
                            : AppColors.border,
                      ),
                    ),
                    if (i < events.length - 1)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: AppColors.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          events[i].status == RequestStatus.received
                              ? 'Request Created'
                              : events[i].status.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: events[i].at != null
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          events[i].at == null
                              ? 'Pending'
                              : dates.fullDateTime(events[i].at!),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (events[i].note != null) ...[
                          const SizedBox(height: 2),
                          Text(events[i].note!,
                              style: theme.textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
