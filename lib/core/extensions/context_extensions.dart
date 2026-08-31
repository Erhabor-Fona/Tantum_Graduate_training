import 'package:flutter/material.dart';

/// Small conveniences that keep screen code readable.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  Size get screen => MediaQuery.sizeOf(this);
  bool get isCompact => MediaQuery.sizeOf(this).width < 360;

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFFF0000) : const Color(0xFF001F3F),
        behavior: SnackBarBehavior.floating,
      ));
  }
}
