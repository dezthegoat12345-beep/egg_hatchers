import 'package:flutter/material.dart';

import '../models/custom_sprite_data.dart';
import 'game_sprite.dart';

/// Preview that follows custom → themed built-in → classic PNG → emoji order.
class CustomSpritePreview extends StatelessWidget {
  const CustomSpritePreview({
    super.key,
    this.customSprite,
    this.animalId,
    this.spritePath,
    required this.fallbackEmoji,
    required this.size,
    this.semanticLabel,
    this.emojiFontSize,
  });

  final CustomSpriteData? customSprite;
  final String? animalId;
  final String? spritePath;
  final String fallbackEmoji;
  final double size;
  final String? semanticLabel;
  final double? emojiFontSize;

  @override
  Widget build(BuildContext context) {
    return GameSprite(
      customSprite: customSprite,
      animalId: animalId,
      spritePath: spritePath,
      fallbackEmoji: fallbackEmoji,
      size: size,
      semanticLabel: semanticLabel,
      emojiFontSize: emojiFontSize,
    );
  }
}
