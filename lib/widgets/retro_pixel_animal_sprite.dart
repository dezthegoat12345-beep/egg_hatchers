import 'package:flutter/material.dart';

import '../data/retro_pixel_animal_sprites.dart';
import 'pixel_sprite.dart';

/// Crisp retro pixel-art animal sprite (nearest-neighbor block scaling).
class RetroPixelAnimalSprite extends StatelessWidget {
  const RetroPixelAnimalSprite({
    super.key,
    required this.animalId,
    required this.size,
    this.semanticLabel,
  });

  final String animalId;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final data = RetroPixelAnimalSprites.spriteFor(animalId);
    if (data == null || !data.hasVisiblePixels) {
      return SizedBox(width: size, height: size);
    }

    return Semantics(
      label: semanticLabel,
      child: PixelSprite(data: data, size: size),
    );
  }
}
