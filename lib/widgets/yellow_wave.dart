import 'package:flutter/material.dart';

import '../app/app_colors.dart';


/// The curved yellow wave at the bottom of the splash and welcome screens.
/// A small CustomPainter — a nice classroom example of custom drawing.
class YellowWave extends StatelessWidget {
  final double height;
  const YellowWave({super.key, this.height = 260});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.yellow;
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.15,
        size.width * 0.55,
        size.height * 0.05,
        size.width,
        size.height * 0.35,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
