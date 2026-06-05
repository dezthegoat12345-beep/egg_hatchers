import 'package:flutter/material.dart';

import '../models/mutation.dart';
import '../theme/game_theme.dart';

/// Shows a sprite image when available, otherwise falls back to an emoji.
class GameSprite extends StatelessWidget {
  const GameSprite({
    super.key,
    this.spritePath,
    required this.fallbackEmoji,
    required this.size,
    this.semanticLabel,
    this.fit = BoxFit.contain,
    this.emojiFontSize,
  });

  final String? spritePath;
  final String fallbackEmoji;
  final double size;
  final String? semanticLabel;
  final BoxFit fit;
  final double? emojiFontSize;

  @override
  Widget build(BuildContext context) {
    final emojiSize = emojiFontSize ?? size * 0.58;

    if (spritePath == null || spritePath!.isEmpty) {
      return _emojiFallback(emojiSize);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        spritePath!,
        width: size,
        height: size,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => _emojiFallback(emojiSize),
      ),
    );
  }

  Widget _emojiFallback(double emojiSize) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          fallbackEmoji,
          style: TextStyle(fontSize: emojiSize, height: 1.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Animal portrait with optional mutation glow; uses base animal sprite only.
class GameAnimalPortrait extends StatelessWidget {
  const GameAnimalPortrait({
    super.key,
    required this.spritePath,
    required this.fallbackEmoji,
    required this.size,
    this.mutation,
    this.semanticLabel,
    this.emojiFontSize,
  });

  final String? spritePath;
  final String fallbackEmoji;
  final double size;
  final Mutation? mutation;
  final String? semanticLabel;
  final double? emojiFontSize;

  @override
  Widget build(BuildContext context) {
    final activeMutation = mutation;
    final isMutated =
        activeMutation != null && !activeMutation.isNormal;
    final accent = isMutated
        ? GameTheme.mutationAccent(activeMutation.id)
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        color: accent?.withValues(alpha: 0.08),
        border: Border.all(
          color: (accent ?? Colors.transparent).withValues(
            alpha: isMutated ? 0.75 : 0.0,
          ),
          width: isMutated ? 2.5 : 0,
        ),
        boxShadow: isMutated
            ? [
                BoxShadow(
                  color: accent!.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          GameSprite(
            spritePath: spritePath,
            fallbackEmoji: fallbackEmoji,
            size: size * 0.82,
            semanticLabel: semanticLabel,
            emojiFontSize: emojiFontSize,
          ),
          if (isMutated && activeMutation.icon.isNotEmpty)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: accent!.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent),
                ),
                child: Text(
                  activeMutation.icon,
                  style: TextStyle(fontSize: size * 0.18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
