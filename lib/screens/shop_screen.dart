import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/egg.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/egg_card.dart';
import '../widgets/game_background.dart';
import '../widgets/hatch_dialog.dart';

/// Screen where the player buys eggs to hatch.
class ShopScreen extends StatelessWidget {
  const ShopScreen({
    super.key,
    required this.game,
    required this.preferences,
    required this.customSprites,
  });

  final GameService game;
  final PreferencesService preferences;
  final CustomSpriteService customSprites;

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
      listenable: preferences,
      builder: (context, _) {
        final bg = preferences.selectedTheme;

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
                              child: ListView.separated(
                                itemCount: GameData.eggs.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final egg = GameData.eggs[index];
                                  return EggCard(
                                    egg: egg,
                                    theme: bg,
                                    isUnlocked: game.isEggUnlocked(egg),
                                    canAfford: game.canAfford(egg),
                                    lifetimeCoinsEarned:
                                        game.lifetimeCoinsEarned,
                                    onBuy: () => _buyAndHatch(context, egg),
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
          ),
        );
      },
    );
  }
}
