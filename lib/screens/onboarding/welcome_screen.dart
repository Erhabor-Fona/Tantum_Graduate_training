import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app_colors.dart';
import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../widgets/primary_button.dart';

/// Welcome Screen M02 — value proposition, hero illustration and the two
/// entry points into the app.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const SizedBox(height: 70),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All-in-One Banking,\nAll for You',
                    style: theme.textTheme.headlineMedium?.copyWith(height: 1.25)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Open a Tatum Account in minutes and enjoy seamless banking.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.5, height: 1.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned.fill(
                  top: 90,
                  child: Container(color: AppColors.primary),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SvgPicture.asset(
                    AppConfig.heroBoy,
                    fit: BoxFit.contain,
                    placeholderBuilder: (_) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.xxl),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  PrimaryButton.navy(
                    label: 'Get Started',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('I already have an account?',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.navy, fontSize: 13.5)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: AppColors.navy,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
