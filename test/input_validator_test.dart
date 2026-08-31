import 'package:flutter_test/flutter_test.dart';
import 'package:tatum_bank/domain/services/input_validator.dart';

void main() {
  const validator = AppInputValidator();

  group('AppInputValidator', () {
    test('rejects a malformed email', () {
      expect(validator.email('john.doe'), isNotNull);
      expect(validator.email('john.doe@gmail.com'), isNull);
    });

    test('requires a first and last name', () {
      expect(validator.fullName('Sarima'), isNotNull);
      expect(validator.fullName('Sarima Hassan'), isNull);
    });

    test('requires exactly ten digits for an account number', () {
      expect(validator.accountNumber('12345'), isNotNull);
      expect(validator.accountNumber('12345678a0'), isNotNull);
      expect(validator.accountNumber('1234567890'), isNull);
    });

    test('rejects a password shorter than eight characters', () {
      expect(validator.loginPassword('abc'), isNotNull);
      expect(validator.loginPassword('abcdefgh'), isNull);
    });

    test('flags an amount above the supplied limit', () {
      expect(validator.amount('6000000', max: 5000000), isNotNull);
      expect(validator.amount('4000', max: 5000000), isNull);
    });

    test('accepts either an email or a phone number as an identifier', () {
      expect(validator.identifier('sarima.hassan@email.com'), isNull);
      expect(validator.identifier('08061234567'), isNull);
      expect(validator.identifier('nope'), isNotNull);
    });
  });
}
