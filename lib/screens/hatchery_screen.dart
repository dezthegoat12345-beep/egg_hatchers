import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
import '../widgets/owned_animal_list.dart';
import 'backgrounds_screen.dart';
import 'collection_screen.dart';
import 'developer_screen.dart';
import 'shop_screen.dart';

/// Main home screen: coins, income, owned animals, and navigation.
class HatcheryScreen extends StatefulWidget {
  const HatcheryScreen({
    super.key,
    required this.game,
    required this.preferences,
  });

  final GameService game;
  final PreferencesService preferences;

  @override
  State<HatcheryScreen> createState() => _HatcheryScreenState();
}

class _HatcheryScreenState extends State<HatcheryScreen> {
  int _coinTapCount = 0;

  GameService get game => widget.game;
  PreferencesService get preferences => widget.preferences;

  void _onCoinTap() {
    _coinTapCount++;
    if (_coinTapCount >= 3) {
      _coinTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeveloperScreen(
            game: game,
            preferences: preferences,
          ),
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
    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        final bg = preferences.selectedTheme;
        final isDark = bg.isDark;

        return Scaffold(
          backgroundColor: isDark ? bg.colors.first : GameTheme.cream,
          extendBody: true,
          appBar: AppBar(
            title: const Text(
              '🐣 Egg Hatchers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
            backgroundColor:
                GameTheme.appBarColorFor(GameBackgroundStyle.hatchery),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Backgrounds',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BackgroundsScreen(
                      preferences: preferences,
                    ),
                  ),
                ),
                icon: const Text('🎨', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
          body: GameBackground(
            theme: bg,
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
                              isDark: isDark,
                            ),
                            const SizedBox(height: 18),
                            _NavButton(
                              label: '🛒 Shop',
                              color: const Color(0xFFFFB74D),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShopScreen(
                                    game: game,
                                    preferences: preferences,
                                  ),
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
                                  builder: (_) => CollectionScreen(
                                    game: game,
                                    preferences: preferences,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Your Animals',
                              style: GameTheme.sectionTitle(isDark: isDark),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: game.ownedAnimals.isEmpty
                                  ? _EmptyHatchery(isDark: isDark)
                                  : OwnedAnimalList(
                                      game: game,
                                      compact: true,
                                      isDark: isDark,
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
      },
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
  const _EmptyHatchery({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: GameTheme.cardDecoration(isDark: isDark),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥚', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 14),
            Text(
              'No animals yet.\nHatch your first egg!',
              textAlign: TextAlign.center,
              style: GameTheme.emptyStateTitle(isDark: isDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Visit the Shop to get started 🐣',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: GameTheme.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
