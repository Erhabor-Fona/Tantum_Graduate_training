import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Login Screen M03, including the two error states from the designs:
/// an invalid email and a too-short password each highlight only their own
/// field label, border and helper line.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  bool _rememberMe = false;
  String? _identifierError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    final remembered = context.read<AuthProvider>().rememberedIdentifier;
    if (remembered != null) {
      _identifier.text = remembered;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validator = context.read<Dependencies>().validator;
    setState(() {
      _identifierError = validator.identifier(_identifier.text);
      _passwordError = validator.loginPassword(_password.text);
    });
    if (_identifierError != null || _passwordError != null) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      identifier: _identifier.text.trim(),
      password: _password.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      setState(() => _passwordError = auth.errorMessage);
    }
  }

  void _biometricLogin() => context.showMessage(
      'Biometric login will be available once your device is enrolled.');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: SvgPicture.asset(AppConfig.logo,
                  height: 46, placeholderBuilder: (_) => const SizedBox(height: 46)),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Text('Welcome Back', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Log in to your Tatum account', style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              label: 'Email or Phone Number',
              hint: 'john.doe@email.com',
              controller: _identifier,
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              errorText: _identifierError,
              onChanged: (_) => setState(() => _identifierError = null),
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordField(
              label: 'Password',
              controller: _password,
              errorText: _passwordError,
              onChanged: (_) => setState(() => _passwordError = null),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Remember me',
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13.5)),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  child: const Text('Forgot Password?',
                      style: TextStyle(decoration: TextDecoration.underline, fontSize: 13.5)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Log In', isLoading: auth.isLoading, onPressed: _submit),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text('OR',
                      style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.2)),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SecondaryButton(
              label: 'Log in with Biometrics',
              icon: Icons.fingerprint,
              onPressed: _biometricLogin,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?", style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
                  child: const Text('Register',
                      style: TextStyle(decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
