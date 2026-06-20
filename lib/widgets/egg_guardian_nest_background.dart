import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ancient egg nest cavern backdrop for the Egg Guardian defeat cinematic.
class EggGuardianNestBackground extends StatelessWidget {
  const EggGuardianNestBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _EggGuardianNestPainter());
  }
}

class _EggGuardianNestPainter extends CustomPainter {
  const _EggGuardianNestPainter();

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
            Color(0xFF0D1B2A),
            Color(0xFF1A237E),
            Color(0xFF283593),
            Color(0xFF1A1A2E),
          ],
          stops: [0.0, 0.3, 0.65, 1.0],
        ).createShader(rect),
    );

    // Cavern arch
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.35)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.06,
          size.width,
          size.height * 0.32,
        )
        ..lineTo(size.width, 0)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = const Color(0xFF0D47A1).withValues(alpha: 0.45),
    );

    // Glowing egg nests (background)
    _drawNest(canvas, Offset(size.width * 0.14, size.height * 0.68), 0.7);
    _drawNest(canvas, Offset(size.width * 0.86, size.height * 0.65), 0.6);
    _drawNest(canvas, Offset(size.width * 0.72, size.height * 0.78), 0.45);

    // Stone platform under boss
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.74),
        width: size.width * 0.5,
        height: size.height * 0.09,
      ),
      Paint()..color = const Color(0xFF37474F).withValues(alpha: 0.65),
    );

    // Rune ring on platform
    final rune = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.72),
        width: size.width * 0.38,
        height: size.height * 0.06,
      ),
      rune,
    );

    // Ancient markings
    final mark = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.22)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 2;
      final c = Offset(size.width * 0.5, size.height * 0.72);
      canvas.drawLine(
        c,
        c + Offset(math.cos(angle) * size.width * 0.16, math.sin(angle) * 18),
        mark,
      );
    }

    // Side cavern walls
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.3, size.width * 0.08, size.height * 0.55),
      Paint()..color = const Color(0xFF263238).withValues(alpha: 0.55),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.92, size.height * 0.28, size.width * 0.08, size.height * 0.58),
      Paint()..color = const Color(0xFF263238).withValues(alpha: 0.55),
    );

    // Central holy glow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.52),
        width: size.width * 0.32,
        height: size.height * 0.25,
      ),
      Paint()..color = const Color(0xFF42A5F5).withValues(alpha: 0.08),
    );
  }

  void _drawNest(Canvas canvas, Offset center, double scale) {
    final w = 52.0 * scale;
    final h = 28.0 * scale;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w, height: h),
      Paint()..color = const Color(0xFF5D4037).withValues(alpha: 0.55),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, -h * 0.35),
        width: w * 0.55,
        height: h * 0.9,
      ),
      Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
