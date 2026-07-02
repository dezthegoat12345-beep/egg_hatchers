import 'package:flutter/material.dart';

import '../data/retro_pixel_boss_sprites.dart';
import '../models/animal_sprite_theme.dart';
import 'animal_sprite_theme_scope.dart';
import 'game_sprite.dart';
import 'retro_pixel_boss_sprite.dart';

/// Boss portrait with PNG sprite and emoji fallback.
///
/// When [bossId] is set and Animal Style is Retro Pixel, uses pixel boss art.
class BossSprite extends StatelessWidget {
  const BossSprite({
    super.key,
    required this.spritePath,
    required this.fallbackEmoji,
    required this.size,
    this.bossId,
    this.semanticLabel,
  });

  final String? spritePath;
  final String fallbackEmoji;
  final double size;
  final String? bossId;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (bossId != null) {
      final animalTheme = AnimalSpriteThemeScope.of(context);
      if (animalTheme.id == AnimalSpriteThemes.retroPixel.id &&
          RetroPixelBossSprites.hasSprite(bossId!)) {
        return RetroPixelBossSprite(
          bossId: bossId!,
          size: size,
          semanticLabel: semanticLabel,
        );
      }
    }

    return GameSprite(
      spritePath: spritePath,
      fallbackEmoji: fallbackEmoji,
      size: size,
      semanticLabel: semanticLabel,
      emojiFontSize: size * 0.55,
    );
  }
}
