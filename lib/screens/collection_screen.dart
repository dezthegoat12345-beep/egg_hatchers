import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
import '../widgets/owned_animal_list.dart';

/// Shows every animal the player owns with quantities, levels, and income.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.game,
    required this.preferences,
  });

  final GameService game;
  final PreferencesService preferences;

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
          appBar: AppBar(
            title: const Text(
              '📚 Collection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
            backgroundColor:
                GameTheme.appBarColorFor(GameBackgroundStyle.collection),
            foregroundColor: Colors.white,
            elevation: 0,
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
                          children: [
                            CoinHeader(
                              coins: game.coins,
                              coinsPerSecond: game.coinsPerSecond,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: game.ownedAnimals.isEmpty
                                  ? _EmptyCollection(isDark: isDark)
                                  : OwnedAnimalList(
                                      game: game,
                                      separatorHeight: 12,
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

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: GameTheme.cardDecoration(
          borderColor: const Color(0xFFBA68C8),
          isDark: isDark,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📭', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 14),
            Text(
              'Your collection is empty.\nHatch some eggs first!',
              textAlign: TextAlign.center,
              style: GameTheme.emptyStateTitle(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}
