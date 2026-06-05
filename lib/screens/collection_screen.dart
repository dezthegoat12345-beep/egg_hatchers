import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../services/game_service.dart';
import '../widgets/animal_card.dart';
import '../widgets/coin_header.dart';

/// Shows every animal the player owns with quantities, levels, and income.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.game});

  final GameService game;

  void _handleUpgrade(BuildContext context, String animalId, String name) {
    final newLevel = game.upgradeAnimal(animalId);
    if (newLevel != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name upgraded to Level $newLevel!'),
          backgroundColor: Colors.teal.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins to upgrade $name.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final owned = game.ownedAnimals;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text(
          '📚 Collection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 600 ? 600.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CoinHeader(
                        coins: game.coins,
                        coinsPerSecond: game.coinsPerSecond,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: owned.isEmpty
                            ? _EmptyCollection()
                            : ListView.separated(
                                itemCount: owned.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final entry = owned[index];
                                  final animal =
                                      GameData.animalById(entry.animalId);
                                  if (animal == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return AnimalCard(
                                    animal: animal,
                                    quantity: entry.quantity,
                                    level: entry.level,
                                    typeIncome:
                                        GameService.incomeFor(animal, entry),
                                    upgradeCost: GameService.upgradeCostFor(
                                      animal,
                                      entry,
                                    ),
                                    showUpgradeButton: true,
                                    canAffordUpgrade:
                                        game.canAffordUpgrade(animal.id),
                                    onUpgrade: () => _handleUpgrade(
                                      context,
                                      animal.id,
                                      animal.name,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            'Your collection is empty.\nHatch some eggs first!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
