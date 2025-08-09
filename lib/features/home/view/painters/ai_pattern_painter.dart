import 'package:flutter/material.dart';

/// AI Pattern Painter for background effects
class AIPatternPainter extends CustomPainter {
  final Color color;

  AIPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw subtle grid pattern
    for (int i = 0; i < 15; i++) {
      final y = (size.height / 15) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (int i = 0; i < 12; i++) {
      final x = (size.width / 12) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Add decorative dots
    final nodePaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final x = (size.width / 6) * i + 15;
      final y = (size.height / 4) * (i % 4) + 10;
      canvas.drawCircle(Offset(x, y), 1.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
