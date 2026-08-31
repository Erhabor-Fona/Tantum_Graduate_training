import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_colors.dart';

/// Six-box OTP entry with auto-advance, backspace handling and the red
/// error treatment from the `otp-error-state` design.
class OtpInput extends StatefulWidget {
  final int length;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpInput({
    super.key,
    this.length = 6,
    this.hasError = false,
    required this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _handleChange(int index, String value) {
    if (value.length > 1) {
      // Pasted code: distribute across the boxes.
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      FocusScope.of(context).unfocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }

    widget.onChanged(_code);
    if (_code.length == widget.length) widget.onCompleted?.call(_code);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        final focused = _nodes[i].hasFocus;

        return Flexible(
          child: Padding(
            padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 8),
            child: AspectRatio(
              aspectRatio: 0.86,
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                onChanged: (v) => _handleChange(i, v),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: widget.hasError
                      ? AppColors.danger
                      : Theme.of(context).textTheme.titleLarge?.color,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: _border(
                    widget.hasError
                        ? AppColors.danger
                        : (filled ? AppColors.navy : AppColors.border),
                  ),
                  focusedBorder: _border(
                    widget.hasError ? AppColors.danger : AppColors.navy,
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.4}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}
