import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app_colors.dart';
import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../widgets/primary_button.dart';

/// Password Reset Success — the confirmation screen with the haloed green
/// check mark from the designs.
class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(AppConfig.logo,
            height: 30, placeholderBuilder: (_) => const SizedBox(height: 30)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxl * 2),
            const _SuccessHalo(),
            const SizedBox(height: AppSpacing.xxxl),
            Text('Password Reset\nSuccessful',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your password has been updated successfully. '
              'You can now log in with your new credentials.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            PrimaryButton(
              label: 'Back to Login',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false),
            ),
          ],
        ),
      ),
    );
  }
}

/// The concentric green circles behind the tick.
class _SuccessHalo extends StatelessWidget {
  const _SuccessHalo();

  @override
  Widget build(BuildContext context) => Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
            color: AppColors.greenTint, shape: BoxShape.circle),
        child: Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
                color: AppColors.success, shape: BoxShape.circle),
            child: const Icon(Icons.check,
                color: AppColors.white, size: 46),
          ),
        ),
      );
}
