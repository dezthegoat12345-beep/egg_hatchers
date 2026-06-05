import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
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
      backgroundColor: GameTheme.cream,
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          '🐣 Egg Hatchers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: GameTheme.appBarColorFor(GameBackgroundStyle.hatchery),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GameBackground(
        style: GameBackgroundStyle.hatchery,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth =
                  constraints.maxWidth > 600 ? 600.0 : double.infinity;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CoinHeader(
                          coins: game.coins,
                          coinsPerSecond: game.coinsPerSecond,
                          lifetimeCoinsEarned: game.lifetimeCoinsEarned,
                          onCoinTap: _onCoinTap,
                        ),
                        const SizedBox(height: 18),
                        _NavButton(
                          label: '🛒 Shop',
                          color: const Color(0xFFFFB74D),
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
                          color: const Color(0xFFBA68C8),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CollectionScreen(game: game),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text('Your Animals', style: GameTheme.sectionTitle()),
                        const SizedBox(height: 10),
                        Expanded(
                          child: game.ownedAnimals.isEmpty
                              ? const _EmptyHatchery()
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
    return FilledButton(
      onPressed: onTap,
      style: GameTheme.filledButton(color, height: 56),
      child: Text(label, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _EmptyHatchery extends StatelessWidget {
  const _EmptyHatchery();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: GameTheme.cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥚', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 14),
            Text(
              'No animals yet.\nHatch your first egg!',
              textAlign: TextAlign.center,
              style: GameTheme.emptyStateTitle(),
            ),
            const SizedBox(height: 8),
            Text(
              'Visit the Shop to get started 🐣',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
