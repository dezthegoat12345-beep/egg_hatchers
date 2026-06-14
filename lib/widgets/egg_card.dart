import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/background_theme.dart';
import '../models/egg.dart';
import '../services/custom_sprite_service.dart';
import '../theme/game_theme.dart';
import '../utils/format_utils.dart';
import 'game_sprite.dart';

/// A shop card for buying an egg.
class EggCard extends StatelessWidget {
  const EggCard({
    super.key,
    required this.egg,
    required this.isUnlocked,
    required this.canAfford,
    required this.lifetimeCoinsEarned,
    required this.onBuy,
    required this.theme,
    this.isCustomEgg = false,
    this.customSprites,
    this.tripleHatchCost,
    this.canAffordTripleHatch = false,
    this.onTripleHatch,
  });

  final Egg egg;
  final bool isUnlocked;
  final bool canAfford;
  final int lifetimeCoinsEarned;
  final VoidCallback onBuy;
  final BackgroundTheme theme;
  final bool isCustomEgg;
  final CustomSpriteService? customSprites;
  final int? tripleHatchCost;
  final bool canAffordTripleHatch;
  final VoidCallback? onTripleHatch;

  @override
  Widget build(BuildContext context) {
    final possibleAnimals = egg.possibleAnimalIds
        .map(GameData.animalById)
        .whereType<Animal>()
        .toList();

    final unlockProgress = egg.unlockLifetimeCoins > 0
        ? (lifetimeCoinsEarned / egg.unlockLifetimeCoins).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      decoration: GameTheme.cardDecoration(theme, locked: !isUnlocked),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? theme.secondaryColor.withValues(alpha: 0.18)
                        : theme.disabledColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUnlocked
                          ? theme.secondaryColor.withValues(alpha: 0.45)
                          : theme.disabledColor,
                    ),
                  ),
                  child: isUnlocked
                      ? GameSprite(
                          spritePath: egg.spritePath,
                          fallbackEmoji: egg.emoji,
                          size: 56,
                          semanticLabel: egg.name,
                          emojiFontSize: 40,
                        )
                      : Text(
                          '🔒',
                          style: TextStyle(
                            fontSize: 40,
                            color: theme.disabledColor,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        egg.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? theme.cardTextPrimaryColor
                              : theme.disabledColor,
                        ),
                      ),
                      if (egg.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          egg.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.cardTextSecondaryColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.panelAccentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.panelAccentColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '🪙 ${formatCoins(egg.cost)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.cardTextPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            if (!isUnlocked && !isCustomEgg) ...[
              const SizedBox(height: 14),
              Text(
                egg.unlockMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: unlockProgress,
                  minHeight: 8,
                  backgroundColor:
                      theme.disabledColor.withValues(alpha: 0.2),
                  color: theme.secondaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Progress: ${formatCoins(lifetimeCoinsEarned)} / ${formatCoins(egg.unlockLifetimeCoins)} lifetime',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.cardTextSecondaryColor,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Possible animals:',
              style: GameTheme.sectionTitle(theme, size: 14).copyWith(
                color: theme.cardTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final animal in possibleAnimals)
                  Chip(
                    avatar: SizedBox(
                      width: 24,
                      height: 24,
                      child: GameSprite(
                        customSprite:
                            customSprites?.getDisplaySprite(animal.id),
                        spritePath: animal.spritePath,
                        fallbackEmoji: animal.emoji,
                        size: 24,
                        emojiFontSize: 16,
                      ),
                    ),
                    label: Text(animal.name),
                    backgroundColor: GameTheme.rarityAccent(animal.rarity)
                        .withValues(alpha: 0.12),
                    side: BorderSide(
                      color: GameTheme.rarityAccent(animal.rarity),
                      width: 1.5,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: GameTheme.rarityAccent(animal.rarity),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onBuy,
              style: GameTheme.filledButton(
                theme,
                color: !isUnlocked || !canAfford
                    ? theme.disabledColor
                    : theme.primaryColor,
              ),
              child: Text(
                !isUnlocked
                    ? 'Locked 🔒'
                    : canAfford
                        ? 'Buy & Hatch 🐣'
                        : 'Not enough coins',
              ),
            ),
            if (onTripleHatch != null && tripleHatchCost != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: isUnlocked ? onTripleHatch : onBuy,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: isUnlocked && canAffordTripleHatch
                      ? theme.secondaryColor
                      : theme.disabledColor,
                  side: BorderSide(
                    color: isUnlocked && canAffordTripleHatch
                        ? theme.secondaryColor
                        : theme.disabledColor,
                  ),
                ),
                child: Text(
                  isUnlocked
                      ? 'Triple Hatch · 🪙 ${formatCoins(tripleHatchCost!)}'
                      : 'Triple Hatch',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
