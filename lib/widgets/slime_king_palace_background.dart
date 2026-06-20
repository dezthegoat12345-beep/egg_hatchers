import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Royal slime palace backdrop for the Slime King defeat cinematic.
class SlimeKingPalaceBackground extends StatelessWidget {
  const SlimeKingPalaceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _SlimeKingPalacePainter());
  }
}

class _SlimeKingPalacePainter extends CustomPainter {
  const _SlimeKingPalacePainter();

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
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF33691E),
            Color(0xFF1B4332),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ).createShader(rect),
    );

    // Throne silhouette
    final throne = Paint()..color = const Color(0xFF14532D).withValues(alpha: 0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.58),
          width: size.width * 0.38,
          height: size.height * 0.22,
        ),
        const Radius.circular(12),
      ),
      throne,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.48),
          width: size.width * 0.22,
          height: size.height * 0.14,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.18),
    );

    // Palace pillars
    final pillar = Paint()..color = const Color(0xFF388E3C).withValues(alpha: 0.55);
    for (final x in [0.08, 0.92]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * x - 14,
            size.height * 0.18,
            28,
            size.height * 0.62,
          ),
          const Radius.circular(6),
        ),
        pillar,
      );
    }

    // Royal carpet / slime stage
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.72),
        width: size.width * 0.55,
        height: size.height * 0.1,
      ),
      Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.35),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.72),
        width: size.width * 0.48,
        height: size.height * 0.07,
      ),
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.15),
    );

    // Slime banners
    final banner = Paint()..color = const Color(0xFF43A047).withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.22, size.width * 0.1, size.height * 0.18),
      banner,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.78, size.height * 0.22, size.width * 0.1, size.height * 0.18),
      banner,
    );
    canvas.drawCircle(
      Offset(size.width * 0.17, size.height * 0.22),
      8,
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      Offset(size.width * 0.83, size.height * 0.22),
      8,
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.6),
    );

    // Gold trim arches
    final gold = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.08, size.width * 0.6, size.height * 0.2),
      math.pi,
      math.pi,
      false,
      gold,
    );

    // Floor slime puddle
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.82),
        width: size.width * 0.7,
        height: size.height * 0.08,
      ),
      Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
