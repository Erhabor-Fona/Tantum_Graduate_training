import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';

/// Labelled text field matching the Figma auth inputs, including the red
/// error treatment on the border and helper line.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final String? errorText;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.formatters,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: hasError ? AppColors.danger : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: AppColors.textMuted),
            suffixIcon: suffix,
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            enabledBorder: hasError ? _errorBorder() : null,
            focusedBorder: hasError ? _errorBorder(width: 1.6) : null,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
        ],
      ],
    );
  }

  OutlineInputBorder _errorBorder({double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
        borderSide: const BorderSide(color: AppColors.danger).copyWith(width: width),
      );
}

/// Password field that owns only its own visibility toggle.
class PasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool showBiometricIcon;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.errorText,
    this.showBiometricIcon = false,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint ?? '\u2022' * 11,
      controller: widget.controller,
      prefixIcon: widget.showBiometricIcon ? Icons.person_outline : Icons.lock_outline,
      obscureText: _obscured,
      validator: widget.validator,
      onChanged: widget.onChanged,
      errorText: widget.errorText,
      suffix: widget.showBiometricIcon
          ? const Icon(Icons.fingerprint, size: 22, color: AppColors.textMuted)
          : IconButton(
              icon: Icon(
                _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
    );
  }
}
