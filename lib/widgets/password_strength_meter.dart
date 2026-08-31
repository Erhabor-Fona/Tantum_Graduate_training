import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../domain/services/password_policy.dart';

/// Four-segment strength bar plus the rule checklist.
///
/// DIP: it renders a [PasswordAssessment] and never grades the password
/// itself — that is the [PasswordPolicy]'s job.
class PasswordStrengthMeter extends StatelessWidget {
  final PasswordAssessment assessment;

  const PasswordStrengthMeter({super.key, required this.assessment});

  Color get _color => switch (assessment.strength) {
        PasswordStrength.none => AppColors.border,
        PasswordStrength.weak => AppColors.danger,
        PasswordStrength.fair => AppColors.gold,
        PasswordStrength.good => AppColors.primary,
        PasswordStrength.strong => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password Strength', style: Theme.of(context).textTheme.bodySmall),
            Text(
              assessment.strength.label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            final active = i < assessment.strength.score;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: active ? _color : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        ...assessment.rules.map(
          (rule) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: rule.satisfied ? AppColors.success : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: rule.satisfied ? Colors.white : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  rule.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: rule.satisfied
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
