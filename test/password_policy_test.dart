import 'package:flutter_test/flutter_test.dart';
import 'package:tatum_bank/domain/services/password_policy.dart';

void main() {
  const policy = TatumPasswordPolicy();

  group('TatumPasswordPolicy', () {
    test('an empty password satisfies no rules', () {
      final result = policy.assess('');
      expect(result.strength, PasswordStrength.none);
      expect(result.isAcceptable, isFalse);
      expect(result.rules.where((r) => r.satisfied), isEmpty);
    });

    test('a long lowercase password only satisfies the length rule', () {
      final result = policy.assess('abcdefghij');
      expect(result.strength, PasswordStrength.weak);
      expect(result.isAcceptable, isFalse);
    });

    test('a password meeting every rule is strong and acceptable', () {
      final result = policy.assess('Tatum2024!');
      expect(result.strength, PasswordStrength.strong);
      expect(result.isAcceptable, isTrue);
      expect(result.rules.every((r) => r.satisfied), isTrue);
    });

    test('always reports exactly four rules', () {
      expect(policy.assess('anything').rules.length, 4);
    });
  });
}
