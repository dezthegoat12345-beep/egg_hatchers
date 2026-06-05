import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/egg.dart';
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

    return Card(
      elevation: 4,
      color: isUnlocked ? null : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isUnlocked ? egg.emoji : '🔒',
                  style: TextStyle(
                    fontSize: 48,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        egg.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? null : Colors.grey.shade700,
                        ),
                      ),
                      if (egg.description.isNotEmpty)
                        Text(
                          egg.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '🪙 ${egg.cost}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 12),
              Text(
                egg.unlockMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Progress: ${formatCoins(lifetimeCoinsEarned)} / ${formatCoins(egg.unlockLifetimeCoins)} total coins earned',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Possible animals:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final animal in possibleAnimals)
                  Chip(
                    avatar: Text(animal.emoji),
                    label: Text(animal.name),
                    backgroundColor: animal.rarity.color.withValues(alpha: 0.12),
                    side: BorderSide(color: animal.rarity.color),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isUnlocked ? onBuy : null,
                style: FilledButton.styleFrom(
                  backgroundColor: !isUnlocked
                      ? Colors.grey.shade500
                      : canAfford
                          ? Colors.teal
                          : Colors.grey,
                  disabledBackgroundColor: Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  !isUnlocked
                      ? 'Locked 🔒'
                      : canAfford
                          ? 'Buy & Hatch 🐣'
                          : 'Not enough coins',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
