import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds the light and dark [ThemeData] from [AppColors].
///
/// OCP: screens read colours and text styles from the theme, so a rebrand is
/// a change here and nowhere else.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.navy,
      secondary: AppColors.navy,
      onSecondary: AppColors.white,
      error: AppColors.danger,
      onError: AppColors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.white,
      onSurface: isDark ? AppColors.white : AppColors.textPrimary,
    );

    final baseText = isDark ? AppColors.white : AppColors.textPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      dividerColor: isDark ? AppColors.darkBorder : AppColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        foregroundColor: baseText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: baseText,
        ),
      ),
      textTheme: TextTheme(
        displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: baseText, height: 1.2),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: baseText, height: 1.2),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: baseText),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: baseText),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: baseText),
        bodyLarge: TextStyle(fontSize: 15, color: baseText),
        bodyMedium: TextStyle(fontSize: 14, color: isDark ? AppColors.textMuted : AppColors.textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : AppColors.textSecondary),
        labelSmall: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.navy,
          disabledBackgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: baseText,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: baseText,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.white,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _outline(AppColors.border, isDark),
        enabledBorder: _outline(isDark ? AppColors.darkBorder : AppColors.border, isDark),
        focusedBorder: _outline(AppColors.primary, isDark, width: 1.6),
        errorBorder: _outline(AppColors.danger, isDark),
        focusedErrorBorder: _outline(AppColors.danger, isDark, width: 1.6),
        errorStyle: const TextStyle(fontSize: 12, color: AppColors.danger),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.white : AppColors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.navy : Colors.transparent),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(color: AppColors.textSecondary, width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        contentTextStyle: TextStyle(color: AppColors.white),
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, bool isDark, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );
}
