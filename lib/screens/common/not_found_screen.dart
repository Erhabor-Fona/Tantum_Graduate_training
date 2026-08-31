import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';

/// Fallback for an unknown route.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const EmptyView(
                title: 'We could not find that page',
                message: 'The screen you were looking for does not exist.',
                icon: Icons.explore_off_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Back to Home',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.home, (_) => false),
              ),
            ],
          ),
        ),
      );
}
