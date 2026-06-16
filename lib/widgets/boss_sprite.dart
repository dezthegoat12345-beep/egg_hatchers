import 'package:flutter/material.dart';

import 'game_sprite.dart';

/// Boss portrait with PNG sprite and emoji fallback.
class BossSprite extends StatelessWidget {
  const BossSprite({
    super.key,
    required this.spritePath,
    required this.fallbackEmoji,
    required this.size,
    this.semanticLabel,
  });

  final String? spritePath;
  final String fallbackEmoji;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return GameSprite(
      spritePath: spritePath,
      fallbackEmoji: fallbackEmoji,
      size: size,
      semanticLabel: semanticLabel,
      emojiFontSize: size * 0.55,
    );
  }
}
