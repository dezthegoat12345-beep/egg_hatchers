import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rocky egg cave backdrop for the Egg Golem defeat cinematic.
class EggGolemCaveBackground extends StatelessWidget {
  const EggGolemCaveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _EggGolemCavePainter());
  }
}

class _EggGolemCavePainter extends CustomPainter {
  const _EggGolemCavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF37474F),
            Color(0xFF4E342E),
            Color(0xFF3E2723),
            Color(0xFF2C1810),
          ],
        ).createShader(rect),
    );

    final wall = Paint()..color = const Color(0xFF5D4037).withValues(alpha: 0.55);
    final cave = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.05,
        size.width,
        size.height * 0.3,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(cave, wall);

    final pillar = Paint()..color = const Color(0xFF6D4C41).withValues(alpha: 0.45);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.22, 22, size.height * 0.55),
      pillar,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.9, size.height * 0.2, 20, size.height * 0.58),
      pillar,
    );

    final floor = Paint()..color = const Color(0xFF4E342E).withValues(alpha: 0.65);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
      floor,
    );

    final crackFloor = Paint()
      ..color = const Color(0xFFBCAAA4).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.78),
      Offset(size.width * 0.45, size.height * 0.82),
      crackFloor,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.8),
      Offset(size.width * 0.82, size.height * 0.76),
      crackFloor,
    );

    final eggGlow = Paint()..color = const Color(0xFFFFF8E1).withValues(alpha: 0.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.58),
        width: 48,
        height: 58,
      ),
      eggGlow,
    );

    final random = math.Random(9);
    final stone = Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.4);
    for (var i = 0; i < 8; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * (0.1 + random.nextDouble() * 0.8),
            size.height * (0.74 + random.nextDouble() * 0.12),
            14 + random.nextDouble() * 18,
            10 + random.nextDouble() * 8,
          ),
          const Radius.circular(4),
        ),
        stone,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
