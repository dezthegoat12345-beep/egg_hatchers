import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/egg.dart';
import '../theme/game_theme.dart';
import '../utils/format_utils.dart';

/// A shop card for buying an egg.
class EggCard extends StatelessWidget {
  const EggCard({
    super.key,
    required this.egg,
    required this.isUnlocked,
    required this.canAfford,
    required this.lifetimeCoinsEarned,
    required this.onBuy,
  });

  final Egg egg;
  final bool isUnlocked;
  final bool canAfford;
  final int lifetimeCoinsEarned;
  final VoidCallback onBuy;

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
      decoration: GameTheme.cardDecoration(locked: !isUnlocked),
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
                        ? GameTheme.softYellow.withValues(alpha: 0.6)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUnlocked
                          ? const Color(0xFFFFB74D).withValues(alpha: 0.4)
                          : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    isUnlocked ? egg.emoji : '🔒',
                    style: TextStyle(
                      fontSize: 40,
                      color: isUnlocked ? null : Colors.grey,
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
                              ? GameTheme.textDark
                              : Colors.grey.shade700,
                        ),
                      ),
                      if (egg.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          egg.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '🪙 ${formatCoins(egg.cost)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: GameTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 14),
              Text(
                egg.unlockMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: unlockProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Progress: ${formatCoins(lifetimeCoinsEarned)} / ${formatCoins(egg.unlockLifetimeCoins)} lifetime',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Possible animals:',
              style: GameTheme.sectionTitle(size: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final animal in possibleAnimals)
                  Chip(
                    avatar: Text(animal.emoji, style: const TextStyle(fontSize: 16)),
                    label: Text(animal.name),
                    backgroundColor:
                        GameTheme.rarityAccent(animal.rarity).withValues(alpha: 0.12),
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
                !isUnlocked
                    ? Colors.grey.shade500
                    : canAfford
                        ? const Color(0xFF4DB6AC)
                        : Colors.grey.shade500,
              ),
              child: Text(
                !isUnlocked
                    ? 'Locked 🔒'
                    : canAfford
                        ? 'Buy & Hatch 🐣'
                        : 'Not enough coins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
