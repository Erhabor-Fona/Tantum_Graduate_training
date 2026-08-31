import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Register Screen — Create Account. The CTA stays disabled until the terms
/// checkbox is ticked, matching the "Auth" vs "Filled" design states.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _acceptedTerms = false;
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validator = context.read<Dependencies>().validator;
    setState(() {
      _nameError = validator.fullName(_name.text);
      _emailError = validator.email(_email.text);
      _phoneError = validator.phone(_phone.text);
      _passwordError = validator.loginPassword(_password.text);
    });
    if ([_nameError, _emailError, _phoneError, _passwordError].any((e) => e != null)) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushNamed(context, AppRoutes.otp);
    } else {
      context.showMessage(auth.errorMessage ?? 'Registration failed.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: SvgPicture.asset(AppConfig.logo,
                    height: 42, placeholderBuilder: (_) => const SizedBox(height: 42)),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text('Create Account', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Join Tatum Bank today', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _name,
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                errorText: _nameError,
                onChanged: (_) => setState(() => _nameError = null),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Email Address',
                hint: 'john.doe@email.com',
                controller: _email,
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) => setState(() => _emailError = null),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Phone Number',
                hint: '+1 234 567 890',
                controller: _phone,
                prefixIcon: Icons.phone_iphone,
                keyboardType: TextInputType.phone,
                errorText: _phoneError,
                onChanged: (_) => setState(() => _phoneError = null),
              ),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                label: 'Password',
                controller: _password,
                errorText: _passwordError,
                onChanged: (_) => setState(() => _passwordError = null),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.titleMedium?.color,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Continue',
                isLoading: auth.isLoading,
                onPressed: _acceptedTerms ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: theme.textTheme.bodyMedium),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: const Text('Log In',
                        style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
