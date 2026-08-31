import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/constants.dart';
import '../../widgets/custom_button.dart';

/// Welcome Screen (M02) — hero, "Get Started", and log-in shortcut.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 32, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All-in-One Banking,\nAll for You',
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Open a Tatum Account in minutes and\nenjoy seamless banking.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Yellow block behind the hero, like the Figma wave.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 300,
                    child: Container(
                      // color: AppColors.yellow
                    ),
                  ),
                  Positioned.fill(
                    child: SvgPicture.asset(
                      AppConstants.boyHeroSvg,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomButton(
                          label: 'Get Started',
                          dark: true,
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.register),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.login),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.navy,
                              ),
                              children: [
                                TextSpan(
                                    text: 'I already have an account? '),
                                TextSpan(
                                  text: 'Log in',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
