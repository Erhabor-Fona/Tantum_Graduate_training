import 'package:flutter/material.dart';

import '../app/app_colors.dart';

/// Visual weight of a [Callout].
enum CalloutTone { info, success, warning, danger }

/// The tinted advisory boxes used throughout the designs
/// ("Security Tip", "Important Notice", "Need Help with this?").
class Callout extends StatelessWidget {
  final String? title;
  final String message;
  final IconData icon;
  final CalloutTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  const Callout({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.info_outline,
    this.tone = CalloutTone.info,
    this.actionLabel,
    this.onAction,
  });

  Color get _tint => switch (tone) {
        CalloutTone.info => AppColors.infoTint,
        CalloutTone.success => AppColors.successTint,
        CalloutTone.warning => AppColors.primaryTint,
        CalloutTone.danger => AppColors.dangerTint,
      };

  Color get _accent => switch (tone) {
        CalloutTone.info => AppColors.accent,
        CalloutTone.success => AppColors.success,
        CalloutTone.warning => AppColors.gold,
        CalloutTone.danger => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _tint, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
            child: Icon(icon, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!,
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5)),
                  const SizedBox(height: 3),
                ],
                Text(message,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45, fontSize: 12.5)),
                if (actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onAction,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(actionLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: tone == CalloutTone.danger ? AppColors.danger : AppColors.gold,
                            )),
                        Icon(Icons.chevron_right,
                            size: 15,
                            color: tone == CalloutTone.danger ? AppColors.danger : AppColors.gold),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
