import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../app/app_config.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_wave.dart';

/// Splash Screen M01 — brand mark over the yellow wave, then routes the user
/// to the dashboard or the welcome screen depending on the stored session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      auth.bootstrap(),
      Future<void>.delayed(AppConfig.splashDuration),
    ]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      auth.isLoggedIn ? AppRoutes.home : AppRoutes.welcome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: BrandWave(height: MediaQuery.sizeOf(context).height * 0.34),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppConfig.logo,
                  height: 62,
                  placeholderBuilder: (_) => const SizedBox(height: 62),
                ),
                const SizedBox(height: 40),
                Text(
                  'Banking that\nkeeps you smiling',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 10),
                Text(
                  'All-in-One Banking, All for You',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
