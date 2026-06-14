import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../services/custom_egg_service.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
import '../widgets/luck_panel.dart';
import '../widgets/owned_animal_list.dart';
import '../widgets/quest_notification_listener.dart';
import '../widgets/rebirth_panel.dart';
import 'backgrounds_screen.dart';
import 'collection_screen.dart';
import 'developer_screen.dart';
import 'quests_screen.dart';
import 'shop_screen.dart';

/// Main home screen: coins, income, owned animals, and navigation.
class HatcheryScreen extends StatefulWidget {
  const HatcheryScreen({
    super.key,
    required this.game,
    required this.preferences,
    required this.customSprites,
    required this.customEggs,
  });

  final GameService game;
  final PreferencesService preferences;
  final CustomSpriteService customSprites;
  final CustomEggService customEggs;

  @override
  State<HatcheryScreen> createState() => _HatcheryScreenState();
}

class _HatcheryScreenState extends State<HatcheryScreen> {
  int _coinTapCount = 0;

  GameService get game => widget.game;
  PreferencesService get preferences => widget.preferences;
  CustomSpriteService get customSprites => widget.customSprites;
  CustomEggService get customEggs => widget.customEggs;

  void _onCoinTap() {
    _coinTapCount++;
    if (_coinTapCount >= 3) {
      _coinTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeveloperScreen(
            game: game,
            customSprites: customSprites,
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
      listenable: Listenable.merge([game, preferences, customSprites]),
      builder: (context, _) {
        final bg = preferences.selectedTheme;

        return QuestNotificationListener(
          game: game,
          preferences: preferences,
          child: Scaffold(
          backgroundColor: bg.scaffoldColor,
          extendBody: true,
          appBar: AppBar(
            title: const Text(
              '🐣 Egg Hatchers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
            backgroundColor: bg.appBarColor,
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
                      customSprites: customSprites,
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
                              theme: bg,
                            ),
                            const SizedBox(height: 14),
                            LuckPanel(game: game, theme: bg),
                            const SizedBox(height: 14),
                            RebirthPanel(game: game, theme: bg),
                            const SizedBox(height: 18),
                            _NavButton(
                              label: '🛒 Shop',
                              theme: bg,
                              color: bg.secondaryColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShopScreen(
                                    game: game,
                                    preferences: preferences,
                                    customSprites: customSprites,
                                    customEggs: customEggs,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _NavButton(
                              label: '🎯 Quests',
                              theme: bg,
                              color: bg.panelAccentColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuestsScreen(
                                    game: game,
                                    preferences: preferences,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _NavButton(
                              label: '📚 Collection',
                              theme: bg,
                              color: bg.primaryColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CollectionScreen(
                                    game: game,
                                    preferences: preferences,
                                    customSprites: customSprites,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Your Animals',
                              style: GameTheme.sectionTitle(bg),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: game.ownedAnimals.isEmpty
                                  ? _EmptyHatchery(theme: bg)
                                  : OwnedAnimalList(
                                      game: game,
                                      theme: bg,
                                      compact: true,
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
                  );
                },
              ),
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
    required this.theme,
    required this.color,
    required this.onTap,
  });

  final String label;
  final BackgroundTheme theme;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: GameTheme.filledButton(theme, color: color, height: 56),
      child: Text(label, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _EmptyHatchery extends StatelessWidget {
  const _EmptyHatchery({required this.theme});

  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: GameTheme.cardDecoration(theme),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥚', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 14),
            Text(
              'No animals yet.\nHatch your first egg!',
              textAlign: TextAlign.center,
              style: GameTheme.emptyStateTitle(theme),
            ),
            const SizedBox(height: 8),
            Text(
              'Visit the Shop to get started 🐣',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.cardTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
