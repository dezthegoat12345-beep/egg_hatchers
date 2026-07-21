import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/animal_sprite_theme.dart';
import '../utils/egg_shard_logic.dart';
import 'animal_sprite_theme_scope.dart';
import 'realistic_boss_battle_background.dart';
import 'retro_pixel_boss_battle_background.dart';

/// Corrupted nest backdrop for The Rotten Shell defeat cinematic.
class RottenShellCinematicBackground extends StatelessWidget {
  const RottenShellCinematicBackground({
    super.key,
    this.vignetteStrength = 0.35,
  });

  final double vignetteStrength;

  @override
  Widget build(BuildContext context) {
    final animalTheme = AnimalSpriteThemeScope.of(context);
    if (animalTheme.id == AnimalSpriteThemes.retroPixel.id) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const RetroPixelBossBattleBackground(
            bossId: EggShardLogic.rottenShellBossId,
            showOverlay: false,
          ),
          CustomPaint(
            painter: _RetroVignettePainter(strength: vignetteStrength),
          ),
        ],
      );
    }
    if (animalTheme.id == AnimalSpriteThemes.realistic.id) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const RealisticBossBattleBackground(
            bossId: EggShardLogic.rottenShellBossId,
            showOverlay: false,
          ),
          CustomPaint(
            painter: _RetroVignettePainter(strength: vignetteStrength),
          ),
        ],
      );
    }

    return CustomPaint(
      painter: _RottenShellCinematicPainter(vignetteStrength: vignetteStrength),
    );
  }
}

class _RetroVignettePainter extends CustomPainter {
  _RetroVignettePainter({required this.strength});

  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: strength * 0.55),
          ],
          stops: const [0.45, 1.0],
        ).createShader(rect),
    );
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.12 + i * 0.14);
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.78, 14, 4),
        Paint()..color = const Color(0xFF558B2F).withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RetroVignettePainter oldDelegate) =>
      oldDelegate.strength != strength;
}

class _RottenShellCinematicPainter extends CustomPainter {
  _RottenShellCinematicPainter({required this.vignetteStrength});

  final double vignetteStrength;

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
            Color(0xFF120A1C),
            Color(0xFF4A148C),
            Color(0xFF2E4A1E),
            Color(0xFF1A1028),
          ],
        ).createShader(rect),
    );

    // Cracked nest floor
    final floorPaint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final floorY = size.height * 0.78;
    canvas.drawLine(
      Offset(size.width * 0.08, floorY),
      Offset(size.width * 0.92, floorY),
      floorPaint,
    );
    for (var i = 0; i < 7; i++) {
      final x = size.width * (0.15 + i * 0.1);
      canvas.drawLine(
        Offset(x, floorY),
        Offset(x + (i.isEven ? 18 : -14), floorY + 22),
        floorPaint..strokeWidth = 1.5,
      );
    }

    // Broken egg silhouettes in background
    for (var i = 0; i < 5; i++) {
      final ex = size.width * (0.1 + i * 0.18);
      final ey = size.height * (0.62 + (i % 2) * 0.06);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, ey), width: 28, height: 34),
        Paint()..color = const Color(0xFF5D4037).withValues(alpha: 0.35),
      );
      canvas.drawLine(
        Offset(ex - 4, ey - 8),
        Offset(ex + 6, ey + 4),
        Paint()
          ..color = const Color(0xFF9CCC65).withValues(alpha: 0.3)
          ..strokeWidth = 1.5,
      );
    }

    // Toxic fog layers
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.72),
        width: size.width * 0.9,
        height: 70,
      ),
      Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.28),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.32, size.height * 0.58),
        width: size.width * 0.55,
        height: 48,
      ),
      Paint()..color = const Color(0xFF8E24AA).withValues(alpha: 0.32),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.68, size.height * 0.5),
        width: size.width * 0.4,
        height: 36,
      ),
      Paint()..color = const Color(0xFF558B2F).withValues(alpha: 0.22),
    );

    // Dark vignette — strengthens during meltdown via [vignetteStrength]
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: vignetteStrength),
          ],
          stops: const [0.38, 1.0],
        ).createShader(rect),
    );

    // Subtle corruption speckles
    final speckle = Paint()
      ..color = const Color(0xFFAB47BC).withValues(alpha: 0.15);
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi * 2 / 12;
      canvas.drawCircle(
        Offset(
          size.width * 0.5 + math.cos(angle) * size.width * 0.38,
          size.height * 0.55 + math.sin(angle) * 80,
        ),
        3 + (i % 3),
        speckle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RottenShellCinematicPainter oldDelegate) =>
      oldDelegate.vignetteStrength != vignetteStrength;
}
