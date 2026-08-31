import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../domain/entities/support_request.dart';
import '../../providers/support_provider.dart';
import '../../widgets/info_row.dart';
import '../../widgets/tatum_scaffold.dart';

/// Request Status — the four-step horizontal tracker plus the resolution
/// summary shown once a ticket closes.
class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<SupportProvider>().active;

    if (request == null) {
      return const TatumScaffold(
        title: 'Request Status',
        body: Center(child: Text('Select a request to track its progress.')),
      );
    }

    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();

    return TatumScaffold(
      title: 'Request Status',
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'share', child: Text('Share request')),
          ],
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          if (request.isResolved) ...[
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.successTint, shape: BoxShape.circle),
                child: const Icon(Icons.check,
                    size: 32, color: AppColors.success),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(request.issueType,
              textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Request ID: ${request.id}',
              textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          Text(
            'CREATED ON ${deps.dates.fullDateTime(request.createdAt).toUpperCase()}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _StatusTracker(request: request, dates: deps.dates),
          const SizedBox(height: AppSpacing.xxl),
          if (request.resolutionNote != null) ...[
            Text('Resolution', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.successTint,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      size: 20, color: AppColors.success),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your request has been resolved.',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: AppColors.success)),
                        const SizedBox(height: 2),
                        Text(request.resolutionNote!,
                            style: theme.textTheme.bodyMedium),
                        if (request.resolvedAt != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Resolution Date: ${deps.dates.fullDateTime(request.resolvedAt!)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          Text('Request Information', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          InfoCard(
            rows: [
              InfoRow(label: 'Category', value: request.category),
              InfoRow(label: 'Issue Type', value: request.issueType),
              if (request.transactionReference != null)
                InfoRow(
                    label: 'Transaction Reference',
                    value: request.transactionReference!),
              if (request.amount != null)
                InfoRow(
                    label: 'Amount', value: deps.money.format(request.amount!)),
              if (_expanded) ...[
                InfoRow(label: 'Description', value: request.description),
                InfoRow(
                    label: 'Created On',
                    value: deps.dates.fullDateTime(request.createdAt)),
              ],
            ],
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              label: Text(_expanded ? 'View Less' : 'View More'),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Need More Help?', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.createRequest),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.infoTint,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic_outlined,
                      color: AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("If you have any other issues, we're here to help.",
                            style: theme.textTheme.bodyMedium),
                        const Text('Create New Request',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.accent),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

/// Horizontal Received → Under Review → In Progress → Resolved tracker.
class _StatusTracker extends StatelessWidget {
  final SupportRequest request;
  final dynamic dates;

  const _StatusTracker({required this.request, required this.dates});

  /// The step index the ticket has reached.
  int get _reached => RequestStatus.values.indexOf(request.status);

  DateTime? _dateFor(RequestStatus status) {
    for (final event in request.timeline) {
      if (event.status == status) return event.at;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final statuses = RequestStatus.values;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < statuses.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= _reached
                        ? AppColors.success
                        : AppColors.border,
                  ),
                  child: Icon(
                    i < _reached || request.isResolved
                        ? Icons.check
                        : Icons.circle,
                    size: i <= _reached ? 15 : 8,
                    color: i <= _reached
                        ? AppColors.white
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statuses[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        i <= _reached ? FontWeight.w700 : FontWeight.w400,
                    color: i <= _reached
                        ? AppColors.navy
                        : AppColors.textSecondary,
                  ),
                ),
                if (_dateFor(statuses[i]) != null)
                  Text(
                    dates.shortDate(_dateFor(statuses[i])!),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 8, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          if (i < statuses.length - 1)
            Container(
              width: 16,
              height: 2,
              margin: const EdgeInsets.only(top: 14),
              color: i < _reached ? AppColors.success : AppColors.border,
            ),
        ],
      ],
    );
  }
}
