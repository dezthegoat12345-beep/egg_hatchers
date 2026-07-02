import 'package:flutter/material.dart';

import '../data/retro_pixel_boss_sprites.dart';
import 'retro_pixel_sprite.dart';

/// Retro Pixel boss portrait — used when Animal Style is Retro Pixel.
class RetroPixelBossSprite extends StatelessWidget {
  const RetroPixelBossSprite({
    super.key,
    required this.bossId,
    required this.size,
    this.semanticLabel,
  });

  final String bossId;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final definition = RetroPixelBossSprites.forBossId(bossId);
    if (definition == null) {
      return SizedBox(width: size, height: size);
    }

    final sprite = RetroPixelSprite(
      definition: definition,
      size: size,
    );

    if (semanticLabel == null) return sprite;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: sprite,
    );
  }
}
