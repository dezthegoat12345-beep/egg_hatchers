import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../widgets/coin_header.dart';
import '../widgets/owned_animal_list.dart';

/// Shows every animal the player owns with quantities, levels, and income.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.game});

  final GameService game;

  void _handleUpgrade(
    BuildContext context,
    String animalId,
    String mutationId,
    String displayName,
  ) {
    final newLevel = game.upgradeAnimal(animalId, mutationId);
    if (newLevel != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$displayName upgraded to Level $newLevel!'),
          backgroundColor: Colors.teal.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins to upgrade $displayName.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        child: game.ownedAnimals.isEmpty
                            ? _EmptyCollection()
                            : OwnedAnimalList(
                                game: game,
                                separatorHeight: 10,
                                onUpgrade: (animalId, mutationId, name) =>
                                    _handleUpgrade(
                                  context,
                                  animalId,
                                  mutationId,
                                  name,
                                ),
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
