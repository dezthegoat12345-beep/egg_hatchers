import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/egg.dart';
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

    game.buyEgg(egg);
    final result = game.hatchEgg(egg);

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
        final customShopEggs = customEggs.shopEggModels;

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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomEggsScreen(
                      preferences: preferences,
                      customEggs: customEggs,
                    ),
                  ),
                ),
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
                                  if (customShopEggs.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    Text(
                                      'Custom Eggs',
                                      style: GameTheme.sectionTitle(bg),
                                    ),
                                    const SizedBox(height: 12),
                                    for (var i = 0;
                                        i < customShopEggs.length;
                                        i++) ...[
                                      if (i > 0) const SizedBox(height: 14),
                                      EggCard(
                                        egg: customShopEggs[i],
                                        theme: bg,
                                        isUnlocked: true,
                                        canAfford:
                                            game.canAfford(customShopEggs[i]),
                                        lifetimeCoinsEarned:
                                            game.lifetimeCoinsEarned,
                                        isCustomEgg: true,
                                        onBuy: () => _buyAndHatch(
                                          context,
                                          customShopEggs[i],
                                        ),
                                      ),
                                    ],
                                  ],
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
