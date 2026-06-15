import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
import '../widgets/owned_animal_list.dart';
import '../widgets/phone_width_layout.dart';
import '../widgets/quest_notification_listener.dart';

/// Shows every animal the player owns with quantities, levels, and income.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.game,
    required this.preferences,
    required this.customSprites,
  });

  final GameService game;
  final PreferencesService preferences;
  final CustomSpriteService customSprites;

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
      listenable: Listenable.merge([game, preferences, customSprites]),
      builder: (context, _) {
        final bg = preferences.selectedTheme;

        return QuestNotificationListener(
          game: game,
          preferences: preferences,
          child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PhoneWidthAppBar(
            title: '📚 Collection',
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            backgroundColor: bg.appBarColor,
            foregroundColor: Colors.white,
          ),
          body: GameBackground(
            theme: bg,
            child: PhoneWidthLayout(
              child: Column(
                children: [
                  CoinHeader(
                    coins: game.coins,
                    coinsPerSecond: game.coinsPerSecond,
                    theme: bg,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: game.ownedAnimals.isEmpty
                        ? _EmptyCollection(theme: bg)
                        : OwnedAnimalList(
                            game: game,
                            theme: bg,
                            separatorHeight: 12,
                            customSprites: customSprites,
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
        ),
        );
      },
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.theme});

  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: GameTheme.cardDecoration(
          theme,
          borderColor: theme.primaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📭', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 14),
            Text(
              'Your collection is empty.\nHatch some eggs first!',
              textAlign: TextAlign.center,
              style: GameTheme.emptyStateTitle(theme),
            ),
          ],
        ),
      ),
    );
  }
}
