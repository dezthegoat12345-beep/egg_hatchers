import 'package:flutter/material.dart';

import '../models/animal_sprite_theme.dart';
import '../utils/egg_shard_logic.dart';
import 'animal_sprite_theme_scope.dart';
import 'retro_pixel_boss_battle_background.dart';

/// Corrupted nest backdrop for The Rotten Shell defeat cinematic.
class RottenShellCinematicBackground extends StatelessWidget {
  const RottenShellCinematicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final animalTheme = AnimalSpriteThemeScope.of(context);
    if (animalTheme.id == AnimalSpriteThemes.retroPixel.id) {
      return const RetroPixelBossBattleBackground(
        bossId: EggShardLogic.rottenShellBossId,
        showOverlay: false,
      );
    }

    return CustomPaint(
      painter: _RottenShellCinematicPainter(),
    );
  }
}

class _RottenShellCinematicPainter extends CustomPainter {
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
            Color(0xFF1A1028),
            Color(0xFF4A148C),
            Color(0xFF33691E),
          ],
        ).createShader(rect),
    );

    final fog = Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.7),
        width: size.width * 0.85,
        height: 60,
      ),
      fog,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.55),
        width: size.width * 0.5,
        height: 40,
      ),
      Paint()..color = const Color(0xFF8E24AA).withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
