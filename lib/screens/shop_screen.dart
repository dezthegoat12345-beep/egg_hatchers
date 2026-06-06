import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/egg.dart';
import '../utils/custom_egg_logic.dart';
import '../services/custom_egg_service.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/egg_card.dart';
import '../widgets/game_background.dart';
import '../widgets/hatch_dialog.dart';
import '../models/background_theme.dart';
import 'custom_egg_editor_screen.dart';
import 'custom_eggs_screen.dart';

/// Screen where the player buys eggs to hatch.
class ShopScreen extends StatelessWidget {
  const ShopScreen({
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

  void _openCustomEggsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomEggsScreen(
          preferences: preferences,
          customEggs: customEggs,
        ),
      ),
    );
  }

  void _openCreateCustomEgg(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomEggEditorScreen(
          preferences: preferences,
          customEggs: customEggs,
        ),
      ),
    );
  }

  Future<void> _buyAndHatch(BuildContext context, Egg egg) async {
    final bg = preferences.selectedTheme;

    if (!game.isEggUnlocked(egg)) {
      showGameSnackBar(
        context,
        message: egg.unlockMessage,
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    if (!game.canAfford(egg)) {
      showGameSnackBar(
        context,
        message:
            'You need ${egg.cost - game.coins} more coins for ${egg.name}!',
        backgroundColor: Colors.red.shade400,
      );
      return;
    }

    final customDefinition = CustomEggLogic.isCustomEggId(egg.id)
        ? customEggs.getById(egg.id)
        : null;

    game.buyEgg(egg);
    final result = game.hatchEgg(egg, customEgg: customDefinition);

    if (context.mounted) {
      await HatchDialog.show(
        context,
        egg: egg,
        result: result,
        theme: bg,
        customSprites: customSprites,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([game, preferences, customEggs]),
      builder: (context, _) {
        final bg = preferences.selectedTheme;
        final customShopEggs = customEggs.shopEggs;
        final hasSavedCustomEggs = customEggs.allEggs.isNotEmpty;
        final hasHiddenCustomEggs =
            hasSavedCustomEggs && customShopEggs.isEmpty;

        return Scaffold(
          backgroundColor: bg.scaffoldColor,
          appBar: AppBar(
            title: const Text(
              '🛒 Egg Shop',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
            backgroundColor: bg.appBarColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () => _openCustomEggsScreen(context),
                child: const Text(
                  'Custom Eggs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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
                          children: [
                            CoinHeader(
                              coins: game.coins,
                              coinsPerSecond: game.coinsPerSecond,
                              theme: bg,
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: ListView(
                                children: [
                                  for (var i = 0;
                                      i < GameData.eggs.length;
                                      i++) ...[
                                    if (i > 0) const SizedBox(height: 14),
                                    EggCard(
                                      egg: GameData.eggs[i],
                                      theme: bg,
                                      isUnlocked:
                                          game.isEggUnlocked(GameData.eggs[i]),
                                      canAfford:
                                          game.canAfford(GameData.eggs[i]),
                                      lifetimeCoinsEarned:
                                          game.lifetimeCoinsEarned,
                                      onBuy: () => _buyAndHatch(
                                        context,
                                        GameData.eggs[i],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  Text(
                                    'Custom Eggs',
                                    style: GameTheme.sectionTitle(bg),
                                  ),
                                  const SizedBox(height: 12),
                                  if (customShopEggs.isNotEmpty)
                                    for (var i = 0;
                                        i < customShopEggs.length;
                                        i++) ...[
                                      if (i > 0) const SizedBox(height: 14),
                                      EggCard(
                                        egg: customShopEggs[i].toEgg(),
                                        theme: bg,
                                        isUnlocked: true,
                                        canAfford: game.canAfford(
                                          customShopEggs[i].toEgg(),
                                        ),
                                        lifetimeCoinsEarned:
                                            game.lifetimeCoinsEarned,
                                        isCustomEgg: true,
                                        onBuy: () => _buyAndHatch(
                                          context,
                                          customShopEggs[i].toEgg(),
                                        ),
                                      ),
                                    ]
                                  else if (hasHiddenCustomEggs)
                                    _CustomEggsShopNotice(
                                      theme: bg,
                                      message:
                                          'You have custom eggs, but none are '
                                          'enabled for the shop.',
                                      buttonLabel: 'Manage Custom Eggs',
                                      onPressed: () =>
                                          _openCustomEggsScreen(context),
                                    )
                                  else
                                    _CustomEggsShopNotice(
                                      theme: bg,
                                      message:
                                          'No custom eggs yet.\n'
                                          'Create your own egg to hatch your '
                                          'favorite animals.',
                                      buttonLabel: 'Create Custom Egg',
                                      onPressed: () =>
                                          _openCreateCustomEgg(context),
                                    ),
                                ],
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

class _CustomEggsShopNotice extends StatelessWidget {
  const _CustomEggsShopNotice({
    required this.theme,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final BackgroundTheme theme;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: GameTheme.cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: theme.cardTextSecondaryColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            style: GameTheme.filledButton(
              theme,
              color: theme.secondaryColor,
              height: 48,
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
