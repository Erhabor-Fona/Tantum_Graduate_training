import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../domain/services/password_policy.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/password_strength_meter.dart';
import '../../widgets/primary_button.dart';

/// Reset Password M07 — live strength meter and rule checklist.
///
/// SRP: the screen renders an assessment; it does not decide what makes a
/// password strong. That rule lives in [PasswordPolicy], so the policy can be
/// tightened without touching this widget.
class ResetPasswordScreen extends StatefulWidget {
  final String otp;
  const ResetPasswordScreen({super.key, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _confirmError;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit(PasswordAssessment assessment) async {
    final validator = context.read<Dependencies>().validator;
    setState(() =>
        _confirmError = validator.confirmPassword(_confirm.text, _password.text));
    if (!assessment.isAcceptable || _confirmError != null) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(_password.text, widget.otp);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.resetSuccess, (r) => r.settings.name == AppRoutes.login);
    } else {
      setState(() => _confirmError = auth.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final policy = context.read<Dependencies>().passwordPolicy;
    final assessment = policy.assess(_password.text);

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(AppConfig.logo,
            height: 30, placeholderBuilder: (_) => const SizedBox(height: 30)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('Create New Password', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Enter your new password below.',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xxl),
          PasswordField(
            label: 'New Password',
            controller: _password,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          PasswordStrengthMeter(assessment: assessment),
          const SizedBox(height: AppSpacing.lg),
          PasswordField(
            label: 'Confirm New Password',
            controller: _confirm,
            showBiometricIcon: true,
            errorText: _confirmError,
            onChanged: (_) => setState(() => _confirmError = null),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Reset Password',
            isLoading: auth.isLoading,
            onPressed: assessment.isAcceptable ? () => _submit(assessment) : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false),
              child: const Text('Back to Login',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
