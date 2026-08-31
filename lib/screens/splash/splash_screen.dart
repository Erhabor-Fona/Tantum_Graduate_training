import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/yellow_wave.dart';

/// Splash Screen (M01) — restores any saved session, then routes to the
/// welcome screen or straight to the dashboard.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      auth.bootstrap(),
      Future<void>.delayed(AppConstants.splashDuration),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      auth.isLoggedIn ? AppRoutes.home : AppRoutes.welcome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  SvgPicture.asset(AppConstants.logoSvg, height: 64),
                  const Spacer(flex: 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Banking that\nkeeps you smiling',
                            style: TextStyle(
                              fontSize: 28,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppConstants.tagline,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          const YellowWave(height: 240),
        ],
      ),
    );
  }
}
