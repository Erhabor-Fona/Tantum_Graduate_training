/// Contract for form field validation.
///
/// Screens depend on this rather than on free functions so the rules can be
/// localised or tightened in one place.
abstract interface class InputValidator {
  String? required(String? value, {String field = 'This field'});
  String? fullName(String? value);
  String? email(String? value);
  String? phone(String? value);
  String? identifier(String? value);
  String? loginPassword(String? value);
  String? confirmPassword(String? value, String original);
  String? accountNumber(String? value);
  String? amount(String? value, {double? max});
}

class AppInputValidator implements InputValidator {
  const AppInputValidator();

  static final RegExp _email = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w.\-]+$');
  static final RegExp _digits = RegExp(r'^[0-9]+$');

  @override
  String? required(String? value, {String field = 'This field'}) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  @override
  String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().split(RegExp(r'\s+')).length < 2) return 'Please enter your first and last name';
    return null;
  }

  @override
  String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email address is required';
    if (!_email.hasMatch(value.trim())) return 'Please enter a valid email address';
    return null;
  }

  @override
  String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Please enter a valid phone number';
    return null;
  }

  @override
  String? identifier(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email or phone number is required';
    final v = value.trim();
    if (v.contains('@')) return _email.hasMatch(v) ? null : 'Please enter a valid email address';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Please enter a valid email address';
    return null;
  }

  @override
  String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  @override
  String? accountNumber(String? value) {
    if (value == null || value.isEmpty) return 'Account number is required';
    if (!_digits.hasMatch(value)) return 'Account number must contain digits only';
    if (value.length != 10) return 'Enter a 10-digit account number';
    return null;
  }

  @override
  String? amount(String? value, {double? max}) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
    if (max != null && parsed > max) return 'Amount exceeds your limit';
    return null;
  }
}
