import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Desert canyon backdrop for the Shadow Phoenix defeat cinematic.
class ShadowPhoenixCinematicBackground extends StatelessWidget {
  const ShadowPhoenixCinematicBackground({
    super.key,
    required this.topViewPhase,
  });

  /// 0 = flying above canyon; 1 = top-down view toward floor.
  final double topViewPhase;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DesertCanyonPainter(topViewPhase: topViewPhase),
    );
  }
}

class _DesertCanyonPainter extends CustomPainter {
  _DesertCanyonPainter({required this.topViewPhase});

  final double topViewPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;
    final tv = topViewPhase.clamp(0.0, 1.0);

    // Purple dusk sky
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF1A1033), const Color(0xFF2D1B4E), tv)!,
            Color.lerp(const Color(0xFF4A2C6A), const Color(0xFF6D4C41), tv * 0.35)!,
            Color.lerp(const Color(0xFF8D6E63), const Color(0xFFBF8A5A), tv * 0.5)!,
            Color.lerp(const Color(0xFF5D4037), const Color(0xFF4E342E), tv)!,
          ],
        ).createShader(rect),
    );

    // Distant mesas
    final mesa = Paint()..color = const Color(0xFF6D4C41).withValues(alpha: 0.55);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.42)
        ..lineTo(w * 0.18, h * 0.34)
        ..lineTo(w * 0.32, h * 0.38)
        ..lineTo(w * 0.48, h * 0.3)
        ..lineTo(w * 0.65, h * 0.36)
        ..lineTo(w * 0.82, h * 0.32)
        ..lineTo(w, h * 0.4)
        ..lineTo(w, h * 0.48)
        ..lineTo(0, h * 0.5)
        ..close(),
      mesa,
    );

    // Moon + stars
    canvas.drawCircle(
      Offset(w * 0.82, h * 0.1),
      18,
      Paint()..color = const Color(0xFFE1BEE7).withValues(alpha: 0.35),
    );
    final random = math.Random(88);
    for (var i = 0; i < 14; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * w, random.nextDouble() * h * 0.28),
        0.7 + random.nextDouble(),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15 + random.nextDouble() * 0.25),
      );
    }

    // Left sandstone cliff
    final leftCliff = Path()
      ..moveTo(0, h * 0.1)
      ..lineTo(w * (0.24 - tv * 0.05), h * 0.34)
      ..lineTo(w * (0.2 - tv * 0.03), h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      leftCliff,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF5D4037),
            const Color(0xFFBF360C).withValues(alpha: 0.85),
            const Color(0xFF8D6E63),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w * 0.3, h)),
    );

    // Right sandstone cliff
    final rightCliff = Path()
      ..moveTo(w, h * 0.08)
      ..lineTo(w * (0.76 + tv * 0.05), h * 0.32)
      ..lineTo(w * (0.8 + tv * 0.03), h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      rightCliff,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            const Color(0xFF4E342E),
            const Color(0xFFE65100).withValues(alpha: 0.75),
            const Color(0xFF795548),
          ],
        ).createShader(Rect.fromLTWH(w * 0.7, 0, w * 0.3, h)),
    );

    // Rock strata on cliffs
    final strata = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 5; i++) {
      final y = h * (0.38 + i * 0.1);
      canvas.drawLine(Offset(0, y), Offset(w * 0.22, y + 4), strata);
      canvas.drawLine(Offset(w * 0.78, y + 2), Offset(w, y - 2), strata);
    }

    // Canyon depth / shadow pit
    canvas.drawRect(
      Rect.fromLTWH(w * 0.2, h * (0.4 + tv * 0.1), w * 0.6, h * (0.6 - tv * 0.08)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF3E2723).withValues(alpha: 0.25),
            const Color(0xFF2C1810).withValues(alpha: 0.55 + tv * 0.15),
            const Color(0xFF1A120B).withValues(alpha: 0.8),
          ],
        ).createShader(Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.6)),
    );

    // Sandy canyon floor (stronger in top view)
    final floorY = h * (0.62 + tv * 0.1);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.22, floorY, w * 0.56, h * 0.28),
      Paint()..color = const Color(0xFFD7CCC8).withValues(alpha: 0.35 + tv * 0.35),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * (0.74 + tv * 0.04)),
        width: w * (0.38 + tv * 0.12),
        height: h * (0.07 + tv * 0.025),
      ),
      Paint()..color = const Color(0xFFBCAAA4).withValues(alpha: 0.45 + tv * 0.25),
    );

    // Impact target on sand
    if (tv > 0.35) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * (0.73 + tv * 0.05)),
          width: w * (0.1 + tv * 0.06),
          height: h * (0.035 + tv * 0.015),
        ),
        Paint()..color = const Color(0xFF5D4037).withValues(alpha: tv * 0.35),
      );
    }

    // Dusty haze near floor
    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.68, w * 0.7, h * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF8D6E63).withValues(alpha: 0.12 + tv * 0.08),
            const Color(0xFF5D4037).withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromLTWH(w * 0.15, h * 0.68, w * 0.7, h * 0.22)),
    );

    // Vignette
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0, -0.05 + tv * 0.25),
          radius: 0.92,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.2),
          ],
          stops: const [0.52, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _DesertCanyonPainter oldDelegate) =>
      oldDelegate.topViewPhase != topViewPhase;
}
