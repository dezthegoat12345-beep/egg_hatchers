import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/animal_sprite_theme.dart';
import 'animal_sprite_theme_scope.dart';
import 'retro_pixel_boss_battle_background.dart';

/// Dedicated royal slime palace backdrop for the Slime King defeat cinematic.
class SlimeKingCinematicBackground extends StatelessWidget {
  const SlimeKingCinematicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final animalTheme = AnimalSpriteThemeScope.of(context);
    if (animalTheme.id == AnimalSpriteThemes.retroPixel.id) {
      return const RetroPixelBossBattleBackground(
        bossId: 'slime_king',
        showOverlay: false,
      );
    }

    return const CustomPaint(painter: _SlimeKingCinematicPainter());
  }
}

class _SlimeKingCinematicPainter extends CustomPainter {
  const _SlimeKingCinematicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;

    // Back wall gradient — deep emerald room
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D2818),
            Color(0xFF1B4332),
            Color(0xFF2D6A4F),
            Color(0xFF1B4332),
            Color(0xFF081C15),
          ],
          stops: [0.0, 0.22, 0.48, 0.75, 1.0],
        ).createShader(rect),
    );

    // Side wall depth panels
    final wallDepth = Paint()..color = const Color(0xFF14532D).withValues(alpha: 0.35);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.12, w * 0.14, h * 0.72), wallDepth);
    canvas.drawRect(Rect.fromLTWH(w * 0.86, h * 0.12, w * 0.14, h * 0.72), wallDepth);

    // Palace arches (background)
    final arch = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.14)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      final cx = w * (0.22 + i * 0.28);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, h * 0.18), width: w * 0.18, height: h * 0.14),
        math.pi,
        math.pi,
        false,
        arch,
      );
    }

    // Slime banners / curtains
    _drawBanner(canvas, Offset(w * 0.1, h * 0.14), h * 0.28, true);
    _drawBanner(canvas, Offset(w * 0.9, h * 0.14), h * 0.26, false);

    // Gold/green pillars with slime columns
    _drawPillar(canvas, Offset(w * 0.1, h * 0.2), h * 0.58);
    _drawPillar(canvas, Offset(w * 0.9, h * 0.2), h * 0.58);
    _drawPillar(canvas, Offset(w * 0.28, h * 0.28), h * 0.42, slim: true);
    _drawPillar(canvas, Offset(w * 0.72, h * 0.28), h * 0.42, slim: true);

    // Throne silhouette (midground, behind boss)
    final throneBack = Paint()..color = const Color(0xFF0F3324).withValues(alpha: 0.82);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.56),
          width: w * 0.42,
          height: h * 0.24,
        ),
        const Radius.circular(14),
      ),
      throneBack,
    );
    // Throne backrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.44),
          width: w * 0.24,
          height: h * 0.16,
        ),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF14532D).withValues(alpha: 0.9),
    );
    // Gold throne trim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.44),
          width: w * 0.24,
          height: h * 0.16,
        ),
        const Radius.circular(10),
      ),
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Floor plane
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.22),
      Paint()..color = const Color(0xFF1B4332).withValues(alpha: 0.55),
    );

    // Royal circular slime carpet / platform
    final stageCenter = Offset(w * 0.5, h * 0.72);
    canvas.drawOval(
      Rect.fromCenter(
        center: stageCenter,
        width: w * 0.62,
        height: h * 0.12,
      ),
      Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: stageCenter,
        width: w * 0.52,
        height: h * 0.095,
      ),
      Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.4),
    );
    // Gold trim ring
    canvas.drawOval(
      Rect.fromCenter(
        center: stageCenter,
        width: w * 0.54,
        height: h * 0.098,
      ),
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: stageCenter,
        width: w * 0.38,
        height: h * 0.065,
      ),
      Paint()..color = const Color(0xFF43A047).withValues(alpha: 0.35),
    );

    // Boss shadow on platform
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.7),
        width: w * 0.28,
        height: h * 0.045,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.38),
    );

    // Floor slime puddle spread
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.86),
        width: w * 0.75,
        height: h * 0.09,
      ),
      Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.4),
    );

    // Gold sparkle accents (static, matches crown particles)
    final random = math.Random(12);
    for (var i = 0; i < 14; i++) {
      final x = w * (0.15 + random.nextDouble() * 0.7);
      final y = h * (0.08 + random.nextDouble() * 0.55);
      canvas.drawCircle(
        Offset(x, y),
        1.2 + random.nextDouble() * 2,
        Paint()
          ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.15 + random.nextDouble() * 0.25),
      );
    }

    // Vignette for boss readability (edges only, center stays clear)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.18),
          ],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );
  }

  void _drawPillar(Canvas canvas, Offset topLeft, double height, {bool slim = false}) {
    final width = slim ? 18.0 : 32.0;
    final pillar = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(topLeft.dx - width / 2, topLeft.dy, width, height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(topLeft.dx - width / 2, topLeft.dy, width, height),
        const Radius.circular(5),
      ),
      pillar,
    );
    // Gold cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(topLeft.dx - width / 2 - 2, topLeft.dy - 6, width + 4, 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.55),
    );
    // Slime drip at base
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(topLeft.dx, topLeft.dy + height),
        width: width * 1.4,
        height: 10,
      ),
      Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.45),
    );
  }

  void _drawBanner(Canvas canvas, Offset anchor, double length, bool leftSide) {
    final dir = leftSide ? 1.0 : -1.0;
    final cloth = Paint()..color = const Color(0xFF388E3C).withValues(alpha: 0.55);
    final path = Path()
      ..moveTo(anchor.dx, anchor.dy)
      ..quadraticBezierTo(
        anchor.dx + dir * 18,
        anchor.dy + length * 0.5,
        anchor.dx + dir * 8,
        anchor.dy + length,
      )
      ..lineTo(anchor.dx - dir * 6, anchor.dy + length)
      ..quadraticBezierTo(
        anchor.dx - dir * 4,
        anchor.dy + length * 0.5,
        anchor.dx,
        anchor.dy,
      )
      ..close();
    canvas.drawPath(path, cloth);
    canvas.drawCircle(
      anchor,
      7,
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.65),
    );
    // Gold fringe
    final fringe = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(anchor.dx + dir * 8, anchor.dy + length),
      Offset(anchor.dx + dir * 14, anchor.dy + length + 6),
      fringe,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
