/// One rule the password must satisfy, plus whether it currently does.
class PasswordRule {
  final String label;
  final bool satisfied;
  const PasswordRule(this.label, this.satisfied);
}

enum PasswordStrength {
  none(0, 'Too short'),
  weak(1, 'Weak'),
  fair(2, 'Fair'),
  good(3, 'Good'),
  strong(4, 'Strong');

  final int score;
  final String label;
  const PasswordStrength(this.score, this.label);
}

/// The full assessment shown under the New Password field.
class PasswordAssessment {
  final PasswordStrength strength;
  final List<PasswordRule> rules;
  const PasswordAssessment({required this.strength, required this.rules});

  bool get isAcceptable => rules.every((r) => r.satisfied);
}

/// Contract for grading a password.
///
/// OCP: the bank can tighten its policy by supplying a different
/// implementation to the composition root — no screen or provider changes.
abstract interface class PasswordPolicy {
  PasswordAssessment assess(String password);
}

/// Tatum Bank's current policy: 8+ characters, one uppercase, one number,
/// one special character.
class TatumPasswordPolicy implements PasswordPolicy {
  const TatumPasswordPolicy();

  @override
  PasswordAssessment assess(String password) {
    final rules = <PasswordRule>[
      PasswordRule('At least 8 characters', password.length >= 8),
      PasswordRule('One uppercase letter', password.contains(RegExp(r'[A-Z]'))),
      PasswordRule('One number', password.contains(RegExp(r'[0-9]'))),
      PasswordRule('One special character', password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\/~`+=;]'))),
    ];

    final satisfied = rules.where((r) => r.satisfied).length;
    final strength = switch (satisfied) {
      0 => PasswordStrength.none,
      1 => PasswordStrength.weak,
      2 => PasswordStrength.fair,
      3 => PasswordStrength.good,
      _ => PasswordStrength.strong,
    };

    return PasswordAssessment(strength: strength, rules: rules);
  }
}
