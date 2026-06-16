import 'package:flutter/material.dart';

import '../data/boss_data.dart';
import '../data/game_data.dart';
import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import '../models/owned_animal.dart';
import '../navigation/app_page_route.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/battle_power_logic.dart';
import '../utils/boss_battle_logic.dart';
import '../utils/format_utils.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
import '../widgets/game_sprite.dart';
import '../widgets/phone_width_layout.dart';

/// Boss battle selection and auto-battle results.
class BattlesScreen extends StatelessWidget {
  const BattlesScreen({
    super.key,
    required this.game,
    required this.preferences,
    required this.customSprites,
  });

  final GameService game;
  final PreferencesService preferences;
  final CustomSpriteService customSprites;

  Future<void> _startBoss(
    BuildContext context,
    BossBattleDefinition boss,
    BackgroundTheme theme,
  ) async {
    if (game.ownedAnimals.isEmpty) {
      showGameSnackBar(
        context,
        message: 'Hatch an animal before battling.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    final fighter = await _pickFighter(context, theme);
    if (fighter == null || !context.mounted) return;

    final result = game.fightBoss(
      bossId: boss.id,
      animalId: fighter.animalId,
      mutationId: fighter.mutationId,
      isProtected: fighter.isProtected,
    );
    if (result == null || !context.mounted) return;

    await _showBattleResultDialog(
      context,
      theme: theme,
      boss: boss,
      fighter: fighter,
      result: result,
    );
  }

  Future<OwnedAnimal?> _pickFighter(
    BuildContext context,
    BackgroundTheme theme,
  ) {
    final fighters = List<OwnedAnimal>.from(game.ownedAnimals);
    fighters.sort(
      (a, b) => GameData.compareOwnedAnimals(a.animalId, b.animalId),
    );

    return showModalBottomSheet<OwnedAnimal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.disabledColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Choose Fighter',
                  textAlign: TextAlign.center,
                  style: GameTheme.sectionTitle(theme),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: fighters.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final owned = fighters[index];
                      return _FighterTile(
                        owned: owned,
                        theme: theme,
                        customSprites: customSprites,
                        onTap: () => Navigator.pop(sheetContext, owned),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBattleResultDialog(
    BuildContext context, {
    required BackgroundTheme theme,
    required BossBattleDefinition boss,
    required OwnedAnimal fighter,
    required BossBattleResult result,
  }) async {
    final animal = GameData.animalById(fighter.animalId);
    if (animal == null) return;

    final mutation =
        GameData.mutationById(fighter.mutationId) ?? GameData.mutations.first;
    final fighterName = mutation.fullName(animal);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        ),
        title: Text(
          result.won ? 'Victory!' : 'Defeat',
          style: TextStyle(
            color: result.won ? theme.secondaryColor : theme.disabledColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${boss.emoji} ${boss.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.cardTextPrimaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$fighterName · Power ${formatCoins(result.battlePower)}',
                style: TextStyle(
                  color: theme.cardTextSecondaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rounds: ${result.rounds} · Boss HP left: ${formatCoins(result.finalBossHp)}',
                style: TextStyle(
                  color: theme.cardTextSecondaryColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Battle log',
                style: GameTheme.sectionTitle(theme, size: 14),
              ),
              const SizedBox(height: 6),
              for (final entry in result.damageLog.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    entry.text,
                    style: TextStyle(
                      color: theme.cardTextSecondaryColor,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              if (result.damageLog.length > 8)
                Text(
                  '…',
                  style: TextStyle(color: theme.cardTextSecondaryColor),
                ),
              if (result.won) ...[
                const SizedBox(height: 12),
                Text(
                  'Rewards: 🪙 ${formatCoins(result.coinReward)}, '
                  'Battle Tokens +${result.battleTokenReward}',
                  style: TextStyle(
                    color: theme.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([game, preferences, customSprites]),
      builder: (context, _) {
        final theme = preferences.selectedTheme;

        return ReturnToHatcheryPopScope(
          theme: theme,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PhoneWidthAppBar(
              title: '⚔️ Boss Battles',
              titleStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              backgroundColor: theme.appBarColor,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: ReturnToHatcheryBackButton(
                theme: theme,
                color: Colors.white,
              ),
            ),
            body: GameBackground(
              theme: theme,
              child: PhoneWidthLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CoinHeader(
                      coins: game.coins,
                      coinsPerSecond: game.coinsPerSecond,
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: GameTheme.cardDecoration(theme),
                      child: Row(
                        children: [
                          Text(
                            '⚔️',
                            style: TextStyle(fontSize: 28, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Battle Tokens: ${game.battleTokens}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.cardTextPrimaryColor,
                              ),
                            ),
                          ),
                          if (game.totalBossWins > 0)
                            Text(
                              '${game.totalBossWins} wins',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.cardTextSecondaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView(
                        children: [
                          for (var i = 0; i < BossData.bosses.length; i++) ...[
                            if (i > 0) const SizedBox(height: 14),
                            _BossCard(
                              boss: BossData.bosses[i],
                              theme: theme,
                              isUnlocked: BossBattleLogic.isBossUnlocked(
                                BossData.bosses[i],
                                game.state,
                              ),
                              winCount: game.bossWinCount(BossData.bosses[i].id),
                              onStart: () => _startBoss(
                                context,
                                BossData.bosses[i],
                                theme,
                              ),
                            ),
                          ],
                        ],
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

class _BossCard extends StatelessWidget {
  const _BossCard({
    required this.boss,
    required this.theme,
    required this.isUnlocked,
    required this.winCount,
    required this.onStart,
  });

  final BossBattleDefinition boss;
  final BackgroundTheme theme;
  final bool isUnlocked;
  final int winCount;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GameTheme.cardDecoration(theme, locked: !isUnlocked),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? theme.secondaryColor.withValues(alpha: 0.18)
                      : theme.disabledColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isUnlocked ? boss.emoji : '🔒',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boss.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked
                            ? theme.cardTextPrimaryColor
                            : theme.disabledColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      boss.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.cardTextSecondaryColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatChip(
                theme: theme,
                label: 'HP ${formatCoins(boss.maxHp)}',
              ),
              _StatChip(
                theme: theme,
                label: 'Power ${formatCoins(boss.recommendedPower)}',
              ),
              _StatChip(
                theme: theme,
                label: '🪙 ${formatCoins(boss.coinReward)}',
              ),
              _StatChip(
                theme: theme,
                label: '⚔️ +${boss.battleTokenReward}',
              ),
            ],
          ),
          if (winCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Defeated $winCount time${winCount == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.secondaryColor,
              ),
            ),
          ],
          if (!isUnlocked) ...[
            const SizedBox(height: 10),
            Text(
              boss.unlockRequirementText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.secondaryColor,
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton(
            onPressed: isUnlocked ? onStart : null,
            style: GameTheme.filledButton(
              theme,
              color: isUnlocked ? theme.primaryColor : theme.disabledColor,
            ),
            child: Text(isUnlocked ? 'Start Battle' : 'Locked 🔒'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.theme,
    required this.label,
  });

  final BackgroundTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.panelAccentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.panelAccentColor.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.cardTextPrimaryColor,
        ),
      ),
    );
  }
}

class _FighterTile extends StatelessWidget {
  const _FighterTile({
    required this.owned,
    required this.theme,
    required this.customSprites,
    required this.onTap,
  });

  final OwnedAnimal owned;
  final BackgroundTheme theme;
  final CustomSpriteService customSprites;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final animal = GameData.animalById(owned.animalId);
    if (animal == null) return const SizedBox.shrink();

    final mutation =
        GameData.mutationById(owned.mutationId) ?? GameData.mutations.first;
    final displayName = mutation.fullName(animal);
    final power = BattlePowerLogic.battlePowerForOwnedAnimal(owned);

    return Material(
      color: theme.panelColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              GameSprite(
                customSprite: customSprites.getDisplaySprite(animal.id),
                spritePath: animal.spritePath,
                fallbackEmoji: mutation.displayEmoji(animal),
                size: 40,
                emojiFontSize: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.cardTextPrimaryColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lv ${owned.level} · ×${owned.quantity} · '
                      'Power ${formatCoins(power)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.cardTextSecondaryColor,
                      ),
                    ),
                    if (owned.isProtected)
                      Text(
                        'Secret Reward',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.secondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.cardTextSecondaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
