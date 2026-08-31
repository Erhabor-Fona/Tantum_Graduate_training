import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../providers/view_state.dart';
import 'primary_button.dart';

/// Centred spinner with an optional caption.
class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      );
}

/// Friendly "nothing here yet" panel.
class EmptyView extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.surfaceTint, shape: BoxShape.circle),
                child: Icon(icon, size: 28, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: 200, child: PrimaryButton(label: actionLabel!, onPressed: onAction)),
              ],
            ],
          ),
        ),
      );
}

/// Error panel with a retry affordance.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.dangerTint, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline, size: 28, color: AppColors.danger),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: 180, child: PrimaryButton(label: 'Try Again', onPressed: onRetry)),
              ],
            ],
          ),
        ),
      );
}

/// Renders the right panel for a [ViewState] so screens stop repeating
/// if/else ladders (Week 3, Session 9).
class StateSwitcher extends StatelessWidget {
  final ViewState state;
  final String? errorMessage;
  final Widget Function() onSuccess;
  final Widget? emptyView;
  final VoidCallback? onRetry;

  const StateSwitcher({
    super.key,
    required this.state,
    required this.onSuccess,
    this.errorMessage,
    this.emptyView,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => switch (state) {
        ViewState.loading => const LoadingView(),
        ViewState.error => ErrorView(
            message: errorMessage ?? 'Please try again.',
            onRetry: onRetry,
          ),
        ViewState.empty =>
          emptyView ?? const EmptyView(title: 'Nothing here yet'),
        _ => onSuccess(),
      };
}
