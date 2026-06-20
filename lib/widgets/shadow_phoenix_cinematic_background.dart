import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dark canyon backdrop for the Shadow Phoenix defeat cinematic.
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
      painter: _ShadowPhoenixCanyonPainter(topViewPhase: topViewPhase),
    );
  }
}

class _ShadowPhoenixCanyonPainter extends CustomPainter {
  _ShadowPhoenixCanyonPainter({required this.topViewPhase});

  final double topViewPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;
    final tv = topViewPhase.clamp(0.0, 1.0);

    // Twilight sky
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF0A0A18), const Color(0xFF1A1A2E), tv)!,
            Color.lerp(const Color(0xFF1A237E), const Color(0xFF311B92), tv * 0.6)!,
            Color.lerp(const Color(0xFF311B92), const Color(0xFF4A148C), tv * 0.4)!,
            Color.lerp(const Color(0xFF1A1A2E), const Color(0xFF0D0D1A), tv)!,
          ],
        ).createShader(rect),
    );

    // Storm/moon glow
    canvas.drawCircle(
      Offset(w * (0.78 - tv * 0.1), h * (0.1 + tv * 0.05)),
      26 - tv * 6,
      Paint()..color = const Color(0xFF7E57C2).withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      Offset(w * (0.78 - tv * 0.1), h * (0.1 + tv * 0.05)),
      16 - tv * 4,
      Paint()..color = const Color(0xFFB39DDB).withValues(alpha: 0.35),
    );

    // Left cliff
    final leftCliff = Path()
      ..moveTo(0, h * 0.08)
      ..lineTo(w * (0.22 - tv * 0.06), h * 0.32)
      ..lineTo(w * (0.18 - tv * 0.04), h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      leftCliff,
      Paint()..color = const Color(0xFF0D0D1A).withValues(alpha: 0.88),
    );

    // Right cliff
    final rightCliff = Path()
      ..moveTo(w, h * 0.06)
      ..lineTo(w * (0.78 + tv * 0.06), h * 0.3)
      ..lineTo(w * (0.82 + tv * 0.04), h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      rightCliff,
      Paint()..color = const Color(0xFF0D0D1A).withValues(alpha: 0.88),
    );

    // Cliff edge highlights
    final edge = Paint()
      ..color = const Color(0xFF4527A0).withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.2, h * 0.3), Offset(w * 0.18, h * 0.95), edge);
    canvas.drawLine(Offset(w * 0.8, h * 0.28), Offset(w * 0.82, h * 0.95), edge);

    // Canyon depth / fog below
    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, h * (0.38 + tv * 0.12), w * 0.64, h * (0.62 - tv * 0.1)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF311B92).withValues(alpha: 0.15),
            const Color(0xFF1A1A2E).withValues(alpha: 0.55 + tv * 0.2),
            const Color(0xFF0D0D1A).withValues(alpha: 0.75),
          ],
        ).createShader(Rect.fromLTWH(w * 0.18, h * 0.38, w * 0.64, h * 0.62)),
    );

    // Canyon floor (more visible in top view)
    if (tv > 0.2) {
      final floorAlpha = (tv * 0.65).clamp(0.0, 0.65);
      canvas.drawRect(
        Rect.fromLTWH(w * 0.22, h * (0.62 + tv * 0.08), w * 0.56, h * 0.28),
        Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: floorAlpha),
      );
      final crack = Paint()
        ..color = const Color(0xFF4527A0).withValues(alpha: floorAlpha * 0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(w * 0.35, h * 0.78),
        Offset(w * 0.5, h * 0.82),
        crack,
      );
      canvas.drawLine(
        Offset(w * 0.55, h * 0.8),
        Offset(w * 0.68, h * 0.84),
        crack,
      );
    }

    // Impact zone marker (subtle, visible in top view)
    if (tv > 0.5) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * (0.72 + tv * 0.06)),
          width: w * (0.12 + tv * 0.08),
          height: h * (0.04 + tv * 0.02),
        ),
        Paint()..color = const Color(0xFF4A148C).withValues(alpha: tv * 0.25),
      );
    }

    // Distant stars
    final random = math.Random(88);
    for (var i = 0; i < 16; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * w, random.nextDouble() * h * 0.35),
        0.8 + random.nextDouble(),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12 + random.nextDouble() * 0.2),
      );
    }

    // Edge vignette
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0, -0.1 + tv * 0.3),
          radius: 0.95,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.22),
          ],
          stops: const [0.5, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _ShadowPhoenixCanyonPainter oldDelegate) =>
      oldDelegate.topViewPhase != topViewPhase;
}
