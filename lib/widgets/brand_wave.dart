import 'package:flutter/material.dart';

import '../app/app_colors.dart';

/// The yellow curve at the foot of the splash and welcome screens.
class BrandWave extends StatelessWidget {
  final double height;
  final Color color;

  const BrandWave({super.key, this.height = 220, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _WavePainter(color)),
      );
}

class _WavePainter extends CustomPainter {
  final Color color;
  const _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height * 0.42)
      ..cubicTo(
        size.width * 0.22, size.height * 0.42,
        size.width * 0.28, size.height * 0.02,
        size.width * 0.55, size.height * 0.02,
      )
      ..cubicTo(
        size.width * 0.82, size.height * 0.02,
        size.width * 0.86, size.height * 0.16,
        size.width, size.height * 0.16,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.color != color;
}
