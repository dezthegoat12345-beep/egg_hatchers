import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/egg.dart';
import '../services/game_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/egg_card.dart';
import '../widgets/game_background.dart';
import '../widgets/hatch_dialog.dart';

/// Screen where the player buys eggs to hatch.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.game});

  final GameService game;

  Future<void> _buyAndHatch(BuildContext context, Egg egg) async {
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.cream,
      appBar: AppBar(
        title: const Text(
          '🛒 Egg Shop',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: GameTheme.appBarColorFor(GameBackgroundStyle.shop),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GameBackground(
        style: GameBackgroundStyle.shop,
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
                                isUnlocked: game.isEggUnlocked(egg),
                                canAfford: game.canAfford(egg),
                                lifetimeCoinsEarned: game.lifetimeCoinsEarned,
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
  }
}
