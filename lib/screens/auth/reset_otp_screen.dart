import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/callout.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/primary_button.dart';

/// Enter OTP | Auth — including the error state from the designs, where the
/// six boxes turn red, an inline message appears and "Resend Now" is offered
/// immediately.
class ResetOtpScreen extends StatefulWidget {
  const ResetOtpScreen({super.key});

  @override
  State<ResetOtpScreen> createState() => _ResetOtpScreenState();
}

class _ResetOtpScreenState extends State<ResetOtpScreen> {
  String _code = '';
  bool _hasError = false;
  int _secondsLeft = AppConfig.otpResendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = AppConfig.otpResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  bool get _canResend => _secondsLeft == 0 || _hasError;
  bool get _isComplete => _code.length == AppConfig.otpLength;

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    if (!_isComplete) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(_code);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      setState(() => _hasError = true);
    }
  }

  Future<void> _resend() async {
    final ok = await context.read<AuthProvider>().resendOtp();
    if (!mounted) return;
    setState(() => _hasError = false);
    if (ok) _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final destination = auth.otpDestination ?? '+234 **** 1234';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            const SizedBox(height: AppSpacing.xxxl * 2),
            Text('Verify Your Identity', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter the ${AppConfig.otpLength}-digit code sent to your phone number $destination',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            OtpInput(
              length: AppConfig.otpLength,
              hasError: _hasError,
              onChanged: (v) => setState(() {
                _code = v;
                _hasError = false;
              }),
              onCompleted: (_) => Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: {'otp': _code}),
            ),
            if (_hasError) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.danger),
                  const SizedBox(width: 6),
                  Text(
                    auth.errorMessage ?? 'Invalid code. Please try again.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.danger),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'Resend code in '),
                        TextSpan(
                          text: _timerLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _canResend ? _resend : null,
                    child: Text(
                      _hasError ? 'Resend Now' : 'Resend',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _hasError
                            ? AppColors.danger
                            : (_canResend
                            ? AppColors.navy
                            : AppColors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
             // label: _hasError ? 'Verify & Reset' : 'Log In',
              label: 'Verify & Reset',
              isLoading: auth.isLoading,
              onPressed: _isComplete ? (){ Navigator.pushNamed(context, AppRoutes.resetPassword, arguments: {'otp': _code}); }: (){},
            ),
            const SizedBox(height: AppSpacing.xl),
            const Callout(
              message: "Didn't receive the code? Check your spam folder or try again.",
            ),
          ],
        ),
      ),
    );
  }
}
