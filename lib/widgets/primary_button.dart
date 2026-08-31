import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';

/// Filled brand button with a built-in loading state.
///
/// SRP: renders a button. It does not decide when it is loading — the caller
/// passes that in.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool showChevron;
  final Color? background;
  final Color? foreground;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.showChevron = false,
    this.background,
    this.foreground,
  });

  /// Dark navy variant used for "Get Started" and secondary CTAs.
  const PrimaryButton.navy({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.showChevron = false,
  })  : background = AppColors.navy,
        foreground = AppColors.white;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? AppColors.navy;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background ?? AppColors.primary,
        foregroundColor: fg,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            )
          : Row(
              mainAxisAlignment:
                  showChevron ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                if (showChevron) const SizedBox(width: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(label),
                  ],
                ),
                if (showChevron) const Icon(Icons.chevron_right, size: 20),
              ],
            ),
    );
  }
}

/// Outlined counterpart used for "Try Again" / "Back to Home".
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label),
        ],
      ),
    );
  }
}
