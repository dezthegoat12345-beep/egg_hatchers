import 'package:flutter/material.dart';

import '../data/retro_pixel_animal_sprites.dart';
import 'retro_pixel_sprite.dart';

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
    final definition = RetroPixelAnimalSprites.spriteFor(animalId);
    if (definition == null || !definition.hasVisiblePixels) {
      return SizedBox(width: size, height: size);
    }

    return Semantics(
      label: semanticLabel,
      child: RetroPixelSprite(
        definition: definition,
        size: size,
      ),
    );
  }
}
