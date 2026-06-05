import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/owned_animal_list.dart';
import 'collection_screen.dart';
import 'developer_screen.dart';
import 'shop_screen.dart';

/// Main home screen: coins, income, owned animals, and navigation.
class HatcheryScreen extends StatefulWidget {
  const HatcheryScreen({super.key, required this.game});

  final GameService game;

  @override
  State<HatcheryScreen> createState() => _HatcheryScreenState();
}

class _HatcheryScreenState extends State<HatcheryScreen> {
  int _coinTapCount = 0;

  GameService get game => widget.game;

  void _onCoinTap() {
    _coinTapCount++;
    if (_coinTapCount >= 3) {
      _coinTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeveloperScreen(game: game),
        ),
      );
    }
  }

  void _handleUpgrade(
    BuildContext context,
    String animalId,
    String mutationId,
    String displayName,
  ) {
    final newLevel = game.upgradeAnimal(animalId, mutationId);
    if (newLevel != null) {
      showGameSnackBar(
        context,
        message: '$displayName upgraded to Level $newLevel!',
        backgroundColor: Colors.teal.shade400,
      );
    } else {
      showGameSnackBar(
        context,
        message: 'Not enough coins to upgrade $displayName.',
        backgroundColor: Colors.red.shade400,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text(
          '🐣 Egg Hatchers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CoinHeader(
                        coins: game.coins,
                        coinsPerSecond: game.coinsPerSecond,
                        lifetimeCoinsEarned: game.lifetimeCoinsEarned,
                        onCoinTap: _onCoinTap,
                      ),
                      const SizedBox(height: 16),
                      _NavButton(
                        label: '🛒 Shop',
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopScreen(game: game),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _NavButton(
                        label: '📚 Collection',
                        color: Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CollectionScreen(game: game),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your Animals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: game.ownedAnimals.isEmpty
                            ? _EmptyHatchery()
                            : OwnedAnimalList(
                                game: game,
                                compact: true,
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EmptyHatchery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥚', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            'No animals yet!\nVisit the Shop to buy an egg.',
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
