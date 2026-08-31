import 'package:flutter/material.dart';

/// The Tatum Bank palette, taken from the Figma design tokens.
///
/// SRP: colour values only. [AppTheme] decides how they are applied.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFFFCC33);
  static const Color gold = Color(0xFFFFD700);
  static const Color navy = Color(0xFF001F3F);

  // Status
  static const Color success = Color(0xFF27AE60);
  static const Color danger = Color(0xFFFF0000);

  // Tints (alpha values straight from the design tokens)
  static const Color successTint = Color(0x3327AE60);
  static const Color dangerTint = Color(0x33FF0000);
  static const Color greenTint = Color(0x3300FF00);
  static const Color primaryTint = Color(0x33FFCC00);
  static const Color surfaceTint = Color(0x66F3F4F6);
  static const Color infoTint = Color(0xFFF0F7FF);

  // Neutrals
  static const Color textPrimary = Color(0xFF001F3F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);

  // Dark theme
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF11223D);
  static const Color darkBorder = Color(0xFF1E3555);

  /// Accent used for the "info" / lavender callouts in the designs.
  static const Color accent = Color(0xFF5C6BC0);
}
