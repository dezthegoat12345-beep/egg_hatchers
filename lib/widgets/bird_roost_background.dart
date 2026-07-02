import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/animal_sprite_theme.dart';
import 'animal_sprite_theme_scope.dart';
import 'retro_pixel_boss_battle_background.dart';

/// Moonlit farm roost backdrop for the base bird boss defeat cinematic.
class BirdRoostBackground extends StatelessWidget {
  const BirdRoostBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final animalTheme = AnimalSpriteThemeScope.of(context);
    if (animalTheme.id == AnimalSpriteThemes.retroPixel.id) {
      return const RetroPixelBossBattleBackground(
        bossId: 'shadow_rooster',
        showOverlay: false,
      );
    }

    return const CustomPaint(painter: _BirdRoostPainter());
  }
}

class _BirdRoostPainter extends CustomPainter {
  const _BirdRoostPainter();

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
            Color(0xFF0A1628),
            Color(0xFF0D1B2A),
            Color(0xFF1A237E),
            Color(0xFF311B92),
            Color(0xFF1A1A2E),
          ],
          stops: [0.0, 0.2, 0.45, 0.72, 1.0],
        ).createShader(rect),
    );

    // Stars
    final random = math.Random(42);
    for (var i = 0; i < 28; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.45;
      final r = 0.8 + random.nextDouble() * 1.4;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25 + random.nextDouble() * 0.45),
      );
    }

    // Drifting clouds
    final cloud = Paint()..color = const Color(0xFF283593).withValues(alpha: 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, size.height * 0.18),
        width: size.width * 0.28,
        height: size.height * 0.05,
      ),
      cloud,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.55, size.height * 0.14),
        width: size.width * 0.22,
        height: size.height * 0.04,
      ),
      cloud,
    );

    // Large moon with glow
    final moonCenter = Offset(size.width * 0.78, size.height * 0.12);
    canvas.drawCircle(
      moonCenter,
      38,
      Paint()..color = const Color(0xFF7986CB).withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      moonCenter,
      28,
      Paint()..color = const Color(0xFFE8EAF6).withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      moonCenter + const Offset(-8, -4),
      6,
      Paint()..color = const Color(0xFFC5CAE9).withValues(alpha: 0.35),
    );

    // Distant hills
    final hill = Paint()..color = const Color(0xFF0D0D1A).withValues(alpha: 0.5);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.66)
        ..quadraticBezierTo(
          size.width * 0.35,
          size.height * 0.58,
          size.width * 0.7,
          size.height * 0.64,
        )
        ..lineTo(size.width, size.height * 0.6)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      hill,
    );

    // Barn silhouette
    final barn = Paint()..color = const Color(0xFF12122A).withValues(alpha: 0.82);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.46, size.width * 0.3, size.height * 0.24),
      barn,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.58, size.height * 0.46)
        ..lineTo(size.width * 0.75, size.height * 0.35)
        ..lineTo(size.width * 0.92, size.height * 0.46),
      Paint()
        ..color = const Color(0xFF1A237E).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );

    // Tree silhouettes
    final tree = Paint()..color = const Color(0xFF0D0D1A).withValues(alpha: 0.7);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.4, 14, size.height * 0.3),
      tree,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.1, size.height * 0.38),
        width: 58,
        height: 42,
      ),
      tree,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.48, size.height * 0.44, 10, size.height * 0.22),
      tree,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.51, size.height * 0.42),
        width: 40,
        height: 30,
      ),
      tree,
    );

    // Fence
    final fence = Paint()..color = const Color(0xFF0A0A18).withValues(alpha: 0.75);
    for (var i = 0; i < 10; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (0.02 + i * 0.098),
          size.height * 0.72,
          6,
          size.height * 0.14,
        ),
        fence,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.01, size.height * 0.72, size.width * 0.98, 4),
      fence,
    );

    // Roost perch
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.16, size.height * 0.6, size.width * 0.24, 6),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF4A148C).withValues(alpha: 0.55),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.24, size.height * 0.6, 5, size.height * 0.12),
      Paint()..color = const Color(0xFF311B92).withValues(alpha: 0.5),
    );

    // Tall grass silhouettes
    final grass = Paint()
      ..color = const Color(0xFF0D0D1A).withValues(alpha: 0.65)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 18; i++) {
      final gx = size.width * (0.05 + i * 0.052);
      final gh = 12 + random.nextDouble() * 18;
      canvas.drawLine(
        Offset(gx, size.height * 0.88),
        Offset(gx + (i.isEven ? 3 : -3), size.height * 0.88 - gh),
        grass,
      );
    }

    // Ground plane
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.84, size.width, size.height * 0.16),
      Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
