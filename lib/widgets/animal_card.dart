import 'package:flutter/material.dart';

import '../models/animal.dart';

/// A rounded card showing one animal, its stats, and an optional upgrade button.
class AnimalCard extends StatelessWidget {
  const AnimalCard({
    super.key,
    required this.animal,
    this.quantity,
    this.level,
    this.typeIncome,
    this.upgradeCost,
    this.showUpgradeButton = false,
    this.canAffordUpgrade = false,
    this.onUpgrade,
    this.compact = false,
  });

  final Animal animal;
  final int? quantity;
  final int? level;
  final int? typeIncome;
  final int? upgradeCost;
  final bool showUpgradeButton;
  final bool canAffordUpgrade;
  final VoidCallback? onUpgrade;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isOwned = quantity != null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.emoji,
                  style: TextStyle(fontSize: compact ? 36 : 48),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: TextStyle(
                          fontSize: compact ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _RarityBadge(rarity: animal.rarity),
                      const SizedBox(height: 4),
                      if (isOwned) ...[
                        Text(
                          'Owned: $quantity  •  Level $level',
                          style: TextStyle(
                            fontSize: compact ? 13 : 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Income: $typeIncome coin/sec',
                          style: TextStyle(
                            fontSize: compact ? 13 : 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ] else
                        Text(
                          'Base: ${animal.coinsPerSecond} coin/sec',
                          style: TextStyle(
                            fontSize: compact ? 13 : 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (showUpgradeButton && upgradeCost != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Upgrade: 🪙 $upgradeCost',
                      style: TextStyle(
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onUpgrade,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          canAffordUpgrade ? Colors.teal : Colors.grey,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 12 : 16,
                        vertical: compact ? 8 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Upgrade ⬆️',
                      style: TextStyle(
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RarityBadge extends StatelessWidget {
  const _RarityBadge({required this.rarity});

  final Rarity rarity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: rarity.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rarity.color, width: 1.5),
      ),
      child: Text(
        rarity.label,
        style: TextStyle(
          color: rarity.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
