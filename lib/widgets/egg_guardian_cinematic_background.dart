import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dedicated ancient nest cavern backdrop for the Egg Guardian defeat cinematic.
class EggGuardianCinematicBackground extends StatelessWidget {
  const EggGuardianCinematicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _EggGuardianCinematicPainter());
  }
}

class _EggGuardianCinematicPainter extends CustomPainter {
  const _EggGuardianCinematicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;

    // Deep cavern gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF050A14),
            Color(0xFF0D1B2A),
            Color(0xFF1A237E),
            Color(0xFF283593),
            Color(0xFF12122A),
          ],
          stops: [0.0, 0.2, 0.45, 0.72, 1.0],
        ).createShader(rect),
    );

    // Cavern ceiling arch
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.34)
        ..quadraticBezierTo(w * 0.5, h * 0.04, w, h * 0.3)
        ..lineTo(w, 0)
        ..lineTo(0, 0)
        ..close(),
      Paint()..color = const Color(0xFF0D47A1).withValues(alpha: 0.42),
    );

    // Stalactites
    final stalactite = Paint()..color = const Color(0xFF263238).withValues(alpha: 0.65);
    final random = math.Random(33);
    for (var i = 0; i < 9; i++) {
      final x = w * (0.06 + i * 0.105);
      final len = 14 + random.nextDouble() * 28;
      canvas.drawPath(
        Path()
          ..moveTo(x - 5, h * 0.08)
          ..lineTo(x, h * 0.08 + len)
          ..lineTo(x + 5, h * 0.08),
        stalactite,
      );
    }

    // Side cavern walls (depth)
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.22, w * 0.1, h * 0.62),
      Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: 0.6),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.9, h * 0.2, w * 0.1, h * 0.64),
      Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: 0.6),
    );

    // Ancient stone arches / ruins
    final ruin = Paint()
      ..color = const Color(0xFF37474F).withValues(alpha: 0.55)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.18, h * 0.32, w * 0.22, h * 0.18),
      math.pi,
      math.pi * 0.85,
      false,
      ruin,
    );
    canvas.drawArc(
      Rect.fromLTWH(w * 0.6, h * 0.3, w * 0.22, h * 0.18),
      math.pi * 0.15,
      math.pi * 0.85,
      false,
      ruin,
    );

    // Blue/gold runes on walls
    final runeBlue = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.28)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final runeGold = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.08, h * 0.38), Offset(w * 0.1, h * 0.52), runeBlue);
    canvas.drawLine(Offset(w * 0.1, h * 0.52), Offset(w * 0.06, h * 0.62), runeGold);
    canvas.drawLine(Offset(w * 0.92, h * 0.4), Offset(w * 0.88, h * 0.55), runeBlue);
    canvas.drawCircle(Offset(w * 0.09, h * 0.45), 4, runeGold);

    // Glowing egg nests (midground)
    _drawGlowingNest(canvas, Offset(w * 0.13, h * 0.66), 0.75);
    _drawGlowingNest(canvas, Offset(w * 0.87, h * 0.63), 0.68);
    _drawGlowingNest(canvas, Offset(w * 0.74, h * 0.76), 0.52);
    _drawGlowingNest(canvas, Offset(w * 0.24, h * 0.78), 0.45);

    // Soft holy glow behind boss area
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.5),
        width: w * 0.38,
        height: h * 0.28,
      ),
      Paint()..color = const Color(0xFF42A5F5).withValues(alpha: 0.09),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.52),
        width: w * 0.22,
        height: h * 0.14,
      ),
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.05),
    );

    // Cracked stone floor
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.8, w, h * 0.2),
      Paint()..color = const Color(0xFF263238).withValues(alpha: 0.55),
    );
    final floorCrack = Paint()
      ..color = const Color(0xFF78909C).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.18, h * 0.84), Offset(w * 0.42, h * 0.87), floorCrack);
    canvas.drawLine(Offset(w * 0.58, h * 0.85), Offset(w * 0.82, h * 0.88), floorCrack);

    // Circular nest/stone platform under boss
    final platform = Offset(w * 0.5, h * 0.73);
    canvas.drawOval(
      Rect.fromCenter(
        center: platform,
        width: w * 0.56,
        height: h * 0.11,
      ),
      Paint()..color = const Color(0xFF37474F).withValues(alpha: 0.7),
    );
    // Nest straw rings
    final straw = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var r = 0.0; r < 3; r++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: platform,
          width: w * (0.34 + r * 0.06),
          height: h * (0.055 + r * 0.012),
        ),
        straw,
      );
    }
    // Rune ring on platform
    canvas.drawOval(
      Rect.fromCenter(
        center: platform,
        width: w * 0.4,
        height: h * 0.065,
      ),
      Paint()
        ..color = const Color(0xFF64B5F6).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 2;
      canvas.drawLine(
        platform,
        platform + Offset(math.cos(angle) * w * 0.17, math.sin(angle) * 16),
        runeGold,
      );
    }

    // Boss / fragment shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.71),
        width: w * 0.3,
        height: h * 0.04,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    // Loose nest debris on floor
    for (var i = 0; i < 8; i++) {
      canvas.drawArc(
        Rect.fromLTWH(
          w * (0.12 + random.nextDouble() * 0.76),
          h * (0.82 + random.nextDouble() * 0.1),
          10 + random.nextDouble() * 14,
          6,
        ),
        0,
        math.pi,
        false,
        Paint()..color = const Color(0xFF5D4037).withValues(alpha: 0.35),
      );
    }

    // Edge vignette for readability
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.88,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.2),
          ],
          stops: const [0.5, 1.0],
        ).createShader(rect),
    );
  }

  void _drawGlowingNest(Canvas canvas, Offset center, double scale) {
    final w = 56.0 * scale;
    final h = 30.0 * scale;

    // Nest glow
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 1.3, height: h * 1.4),
      Paint()..color = const Color(0xFF42A5F5).withValues(alpha: 0.12),
    );

    // Twigs / nest bowl
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w, height: h),
      Paint()..color = const Color(0xFF4E342E).withValues(alpha: 0.6),
    );

    // Glowing egg
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, -h * 0.32),
        width: w * 0.5,
        height: h * 0.95,
      ),
      Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.35),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, -h * 0.32),
        width: w * 0.38,
        height: h * 0.72,
      ),
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
