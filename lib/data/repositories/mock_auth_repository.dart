import '../../core/error/app_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/mock_data.dart';
import 'mock_delay.dart';

/// Offline [AuthRepository] used for classroom demos.
///
/// LSP: every method honours the same contract as the HTTP implementation —
/// same return types, same exception types — so providers cannot tell them
/// apart.
class MockAuthRepository with MockLatency implements AuthRepository {
  User _pendingUser = MockData.user;

  static const _token = 'mock.jwt.token';

  @override
  Future<AuthSession> login({required String identifier, required String password}) async {
    await settle();
    if (password.length < 8) {
      throw const AuthException('Invalid email/phone or password.');
    }
    return const AuthSession(token: _token, user: MockData.user);
  }

  @override
  Future<OtpChallenge> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await settle();
    _pendingUser = User(
      id: 'usr_new',
      fullName: fullName,
      email: email,
      phone: phone,
    );
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final tail = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    return OtpChallenge(maskedDestination: '+234 **** $tail');
  }

  @override
  Future<AuthSession> verifyOtp(String code) async {
    await settle();
    if (code.length != 6 || code == '000000') {
      throw const AuthException('Invalid code. Please try again.');
    }
    return AuthSession(token: _token, user: _pendingUser);
  }

  @override
  Future<OtpChallenge> resendOtp() async {
    await settle(400);
    final digits = _pendingUser.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final tail = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    return OtpChallenge(maskedDestination: '+234 **** $tail');
  }

  @override
  Future<void> requestPasswordReset(String identifier) async {
    await settle();
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await settle();
  }
}
