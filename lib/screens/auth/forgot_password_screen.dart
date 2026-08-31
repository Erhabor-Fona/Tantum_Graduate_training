import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tatum_bank/screens/auth/reset_otp_screen.dart';

import '../../app/app_colors.dart';
import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/callout.dart';
import '../../widgets/primary_button.dart';

/// Forgot Password M06 — reset request, with the cream "Need help?" footer
/// pinned to the bottom of the screen as in the design.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifier = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validator = context.read<Dependencies>().validator;
    setState(() => _error = validator.identifier(_identifier.text));
    if (_error != null) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.requestPasswordReset(_identifier.text.trim());
    if (!mounted) return;
    if (ok) {
      context.showMessage('Reset link sent. Check your inbox.');
      Navigator.pushNamed(context, AppRoutes.resetOtpScreen);
    } else {
      setState(() => _error = auth.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(AppConfig.logo,
            height: 30, placeholderBuilder: (_) => const SizedBox(height: 30)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text('Forgot Password?', style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "No worries! Enter your email or phone number associated with "
                  "your Tatum account and we'll send you a reset link.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppTextField(
                  label: 'Email or Phone Number',
                  hint: 'Enter your email or phone number',
                  controller: _identifier,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _error,
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Callout(
                  title: 'Secure & Private',
                  message: "We'll send you a secure link to reset your password.",
                  icon: Icons.visibility_off_outlined,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Send Reset Link',
                  isLoading: auth.isLoading,
                  onPressed: _submit,
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
          ),
          _HelpFooter(onTap: () => Navigator.pushNamed(context, AppRoutes.support)),
        ],
      ),
    );
  }
}

class _HelpFooter extends StatelessWidget {
  final VoidCallback onTap;
  const _HelpFooter({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: AppColors.primaryTint,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppColors.white, shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline,
                  size: 18, color: AppColors.navy),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Need help?', style: theme.textTheme.bodyMedium),
            TextButton(
              onPressed: onTap,
              child: const Text('Contact Support',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
