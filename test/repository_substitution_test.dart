import 'package:flutter_test/flutter_test.dart';
import 'package:tatum_bank/core/error/app_exception.dart';
import 'package:tatum_bank/data/repositories/mock_auth_repository.dart';
import 'package:tatum_bank/domain/entities/user.dart';
import 'package:tatum_bank/domain/repositories/auth_repository.dart';

/// A hand-written stand-in, proving a screen or provider only ever needs the
/// [AuthRepository] interface.
class FakeAuthRepository implements AuthRepository {
  bool loginCalled = false;

  @override
  Future<AuthSession> login({required String identifier, required String password}) async {
    loginCalled = true;
    if (password.length < 8) throw const AuthException('Invalid credentials.');
    return const AuthSession(
      token: 'fake.token',
      user: User(id: 'u1', fullName: 'Test User', email: 't@example.com', phone: '0800'),
    );
  }

  @override
  Future<OtpChallenge> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async =>
      const OtpChallenge(maskedDestination: '+234 **** 0000');

  @override
  Future<AuthSession> verifyOtp(String code) async {
    if (code.length != 6) throw const AuthException('Invalid code.');
    return const AuthSession(
      token: 'fake.token',
      user: User(id: 'u1', fullName: 'Test User', email: 't@example.com', phone: '0800'),
    );
  }

  @override
  Future<OtpChallenge> resendOtp() async =>
      const OtpChallenge(maskedDestination: '+234 **** 0000');

  @override
  Future<void> requestPasswordReset(String identifier) async {}

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {}
}

void main() {
  group('Liskov substitution across AuthRepository implementations', () {
    // Every implementation must behave the same way for the same input.
    final implementations = <String, AuthRepository Function()>{
      'MockAuthRepository': MockAuthRepository.new,
      'FakeAuthRepository': FakeAuthRepository.new,
    };

    implementations.forEach((name, build) {
      test('$name rejects a short password with an AuthException', () async {
        final repo = build();
        expect(
          () => repo.login(identifier: 'sarima@email.com', password: 'short'),
          throwsA(isA<AuthException>()),
        );
      });

      test('$name returns a session for valid credentials', () async {
        final repo = build();
        final session = await repo.login(
          identifier: 'sarima@email.com',
          password: 'Tatum2024!',
        );
        expect(session.token, isNotEmpty);
        expect(session.user.fullName, isNotEmpty);
      });

      test('$name rejects a malformed OTP', () async {
        final repo = build();
        expect(() => repo.verifyOtp('123'), throwsA(isA<AuthException>()));
      });
    });
  });
}
