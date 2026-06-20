import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ancient rocky egg cave / ruins backdrop for the Egg Golem defeat cinematic.
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
            Color(0xFF263238),
            Color(0xFF37474F),
            Color(0xFF4E342E),
            Color(0xFF3E2723),
            Color(0xFF1C1210),
          ],
          stops: [0.0, 0.25, 0.55, 0.78, 1.0],
        ).createShader(rect),
    );

    // Cave ceiling arch
    final ceiling = Paint()..color = const Color(0xFF455A64).withValues(alpha: 0.5);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.32)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.04,
          size.width,
          size.height * 0.3,
        )
        ..lineTo(size.width, 0)
        ..lineTo(0, 0)
        ..close(),
      ceiling,
    );

    // Side pillars
    final pillar = Paint()..color = const Color(0xFF6D4C41).withValues(alpha: 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, size.height * 0.2, 28, size.height * 0.58),
        const Radius.circular(6),
      ),
      pillar,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.88, size.height * 0.18, 26, size.height * 0.6),
        const Radius.circular(6),
      ),
      pillar,
    );

    // Ancient egg statues (background)
    _drawEggStatue(canvas, size, Offset(size.width * 0.14, size.height * 0.62), 0.55);
    _drawEggStatue(canvas, size, Offset(size.width * 0.86, size.height * 0.58), 0.48, cracked: true);

    // Glowing rune cracks on walls
    final runeGlow = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final runeGold = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.35),
      Offset(size.width * 0.12, size.height * 0.55),
      runeGlow,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.55),
      Offset(size.width * 0.06, size.height * 0.68),
      runeGold,
    );
    canvas.drawLine(
      Offset(size.width * 0.92, size.height * 0.38),
      Offset(size.width * 0.88, size.height * 0.58),
      runeGlow,
    );

    // Stone floor
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      Paint()..color = const Color(0xFF4E342E).withValues(alpha: 0.72),
    );

    // Cracked floor lines
    final floorCrack = Paint()
      ..color = const Color(0xFFBCAAA4).withValues(alpha: 0.4)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.76),
      Offset(size.width * 0.42, size.height * 0.8),
      floorCrack,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.8),
      Offset(size.width * 0.38, size.height * 0.88),
      floorCrack,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.78),
      Offset(size.width * 0.85, size.height * 0.82),
      floorCrack,
    );

    // Scattered rubble on floor
    final random = math.Random(9);
    final stone = Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.45);
    for (var i = 0; i < 12; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * (0.08 + random.nextDouble() * 0.84),
            size.height * (0.73 + random.nextDouble() * 0.14),
            12 + random.nextDouble() * 20,
            8 + random.nextDouble() * 10,
          ),
          const Radius.circular(4),
        ),
        stone,
      );
    }

    // Boss shadow / ground highlight under center
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.72),
        width: size.width * 0.42,
        height: size.height * 0.06,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Faint central glow from ancient energy
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.52),
        width: size.width * 0.35,
        height: size.height * 0.28,
      ),
      Paint()..color = const Color(0xFF64B5F6).withValues(alpha: 0.06),
    );
  }

  void _drawEggStatue(
    Canvas canvas,
    Size size,
    Offset center,
    double scale, {
    bool cracked = false,
  }) {
    final w = 36.0 * scale;
    final h = 48.0 * scale;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w, height: h),
      Paint()..color = const Color(0xFF795548).withValues(alpha: 0.55),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.85, height: h * 0.85),
      Paint()
        ..color = const Color(0xFFBCAAA4).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (cracked) {
      final crack = Paint()
        ..color = const Color(0xFF64B5F6).withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        center + Offset(-w * 0.2, -h * 0.25),
        center + Offset(w * 0.05, h * 0.15),
        crack,
      );
      canvas.drawLine(
        center + Offset(w * 0.1, -h * 0.1),
        center + Offset(-w * 0.15, h * 0.2),
        crack,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
