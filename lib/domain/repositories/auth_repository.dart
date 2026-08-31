import '../entities/user.dart';

/// Result of a successful credential exchange.
class AuthSession {
  final String token;
  final User user;
  const AuthSession({required this.token, required this.user});
}

/// Result of starting registration — the app must collect an OTP next.
class OtpChallenge {
  final String maskedDestination;
  final int resendSeconds;
  const OtpChallenge({required this.maskedDestination, this.resendSeconds = 59});
}

/// Everything the app can do with credentials.
///
/// SRP: authentication only — it never stores tokens (that is [SessionStore])
/// and never fetches balances (that is `AccountRepository`).
abstract interface class AuthRepository {
  Future<AuthSession> login({required String identifier, required String password});

  Future<OtpChallenge> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthSession> verifyOtp(String code);

  Future<OtpChallenge> resendOtp();

  Future<void> requestPasswordReset(String identifier);

  Future<void> resetPassword({required String token, required String newPassword});
}
