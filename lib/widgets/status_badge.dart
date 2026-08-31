import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../domain/entities/support_request.dart';
import '../domain/entities/transaction_status.dart';

/// Pill showing Successful / Pending / Failed with the matching tint.
///
/// OCP: a new status needs only a new case in [TransactionStatus] plus an
/// entry in the two switches below.
class StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  Color get _color => switch (status) {
        TransactionStatus.successful => AppColors.success,
        TransactionStatus.pending => AppColors.gold,
        TransactionStatus.failed => AppColors.danger,
      };

  Color get _tint => switch (status) {
        TransactionStatus.successful => AppColors.successTint,
        TransactionStatus.pending => AppColors.primaryTint,
        TransactionStatus.failed => AppColors.dangerTint,
      };

  IconData get _icon => switch (status) {
        TransactionStatus.successful => Icons.check_circle,
        TransactionStatus.pending => Icons.schedule,
        TransactionStatus.failed => Icons.cancel,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 2 : 5),
      decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 11 : 13, color: _color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic label pill used for account status, request status and similar.
class LabelPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const LabelPill({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
        ),
      );
}

/// Pill for a support ticket's lifecycle state.
///
/// Kept alongside [StatusBadge] because both express "a status as a pill",
/// but they map different enums — so each owns its own colour mapping (SRP)
/// instead of one widget branching on two unrelated types.
class RequestStatusPill extends StatelessWidget {
  final RequestStatus status;
  const RequestStatusPill({super.key, required this.status});

  Color get _color => switch (status) {
        RequestStatus.received => AppColors.accent,
        RequestStatus.underReview => AppColors.gold,
        RequestStatus.inProgress => AppColors.gold,
        RequestStatus.resolved => AppColors.success,
      };

  Color get _tint => switch (status) {
        RequestStatus.received => AppColors.infoTint,
        RequestStatus.underReview => AppColors.primaryTint,
        RequestStatus.inProgress => AppColors.primaryTint,
        RequestStatus.resolved => AppColors.successTint,
      };

  @override
  Widget build(BuildContext context) =>
      LabelPill(label: status.label.toUpperCase(), color: _color, background: _tint);
}
