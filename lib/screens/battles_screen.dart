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
import '../widgets/boss_sprite.dart';
import '../widgets/game_sprite.dart';
import '../widgets/phone_width_layout.dart';
import 'manual_boss_battle_screen.dart';

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

  Future<void> _unlockBossMutation(BuildContext context) async {
    if (game.bossMutationUnlocked) return;

    if (!game.canUnlockBossMutation()) {
      showGameSnackBar(
        context,
        message: 'Not enough Battle Tokens.',
        backgroundColor: Colors.red.shade400,
      );
      return;
    }

    if (game.unlockBossMutation() && context.mounted) {
      showGameSnackBar(
        context,
        message: 'Boss Mutation unlocked!',
        backgroundColor: Colors.green.shade700,
      );
    }
  }

  Future<void> _applyBossMutation(BuildContext context, BackgroundTheme theme) async {
    if (!game.canApplyBossMutation()) {
      showGameSnackBar(
        context,
        message: 'Not enough Battle Tokens.',
        backgroundColor: Colors.red.shade400,
      );
      return;
    }

    final target = await _pickBossMutationTarget(context, theme);
    if (target == null || !context.mounted) return;

    if (target.mutationId == 'boss') {
      showGameSnackBar(
        context,
        message: 'That animal already has Boss Mutation.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    if (!game.applyBossMutation(target)) {
      showGameSnackBar(
        context,
        message: 'Could not apply Boss Mutation.',
        backgroundColor: Colors.red.shade400,
      );
      return;
    }

    if (context.mounted) {
      showGameSnackBar(
        context,
        message: 'Boss Mutation applied!',
        backgroundColor: Colors.green.shade700,
      );
    }
  }

  Future<OwnedAnimal?> _pickBossMutationTarget(
    BuildContext context,
    BackgroundTheme theme,
  ) {
    final candidates = game.ownedAnimals
        .where((owned) =>
            owned.mutationId != 'boss' &&
            owned.quantity > 0 &&
            !game.isOwnedStackAutoBattling(owned))
        .toList();
    candidates.sort(
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
                      color: theme.disabledColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apply Boss Mutation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.cardTextPrimaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cost: ${GameData.applyBossMutationCost} Battle Tokens · converts 1 animal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.cardTextSecondaryColor,
                  ),
                ),
                const SizedBox(height: 14),
                if (candidates.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No eligible animals.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.cardTextSecondaryColor),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: candidates.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final owned = candidates[index];
                        final animal = GameData.animalById(owned.animalId);
                        if (animal == null) return const SizedBox.shrink();
                        final mutation = GameData.mutationById(owned.mutationId) ??
                            GameData.mutations.first;
                        final power =
                            BattlePowerLogic.battlePowerForOwnedAnimal(owned);
                        return ListTile(
                          tileColor: theme.panelColor.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: theme.cardBorderColor),
                          ),
                          leading: GameAnimalPortrait(
                            customSprite:
                                customSprites.getDisplaySprite(animal.id),
                            spritePath: animal.spritePath,
                            fallbackEmoji: mutation.displayEmoji(animal),
                            size: 48,
                            mutation: mutation,
                          ),
                          title: Text(
                            mutation.fullName(animal),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.cardTextPrimaryColor,
                            ),
                          ),
                          subtitle: Text(
                            'Lv ${owned.level} · x${owned.quantity} · '
                            'Power ${formatCoins(power)}'
                            '${owned.isProtected ? ' · Protected' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.cardTextSecondaryColor,
                            ),
                          ),
                          trailing: FilledButton(
                            onPressed: () =>
                                Navigator.pop(sheetContext, owned),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Mutate'),
                          ),
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

  Future<void> _startAutoBattle(
    BuildContext context,
    BossBattleDefinition boss,
    BackgroundTheme theme,
  ) async {
    if (game.hasActiveAutoBattle) {
      showGameSnackBar(
        context,
        message: 'An animal is already battling.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    if (game.ownedAnimals.isEmpty) {
      showGameSnackBar(
        context,
        message: 'Hatch an animal before auto battling.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    final fighter = await _pickFighter(
      context,
      theme,
      title: 'Choose Auto Battler',
      subtitle: 'One stack fights ${boss.name} until defeated.',
    );
    if (fighter == null || !context.mounted) return;

    final animal = GameData.animalById(fighter.animalId);
    if (animal == null || !context.mounted) return;

    final mutation = GameData.mutationById(fighter.mutationId) ??
        GameData.mutations.first;
    final fighterName = mutation.fullName(animal);

    final started = game.startActiveAutoBattle(
      bossId: boss.id,
      animalId: fighter.animalId,
      mutationId: fighter.mutationId,
      isProtected: fighter.isProtected,
    );
    if (!started || !context.mounted) {
      showGameSnackBar(
        context,
        message: 'Could not start auto battle.',
        backgroundColor: Colors.red.shade400,
      );
      return;
    }

    showGameSnackBar(
      context,
      message: '$fighterName is battling ${boss.name}!',
      backgroundColor: theme.primaryColor,
    );

    if (!context.mounted) return;
    await returnToHatcheryWithTransition(context, theme: theme);
  }

  Future<void> _startManualBattle(
    BuildContext context,
    BossBattleDefinition boss,
    BackgroundTheme theme, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) async {
    if (game.ownedAnimals.isEmpty) {
      showGameSnackBar(
        context,
        message: 'Hatch an animal before battling.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    if (mode == ManualBattleMode.hard && !game.isHardPhaseUnlocked(boss.id)) {
      showGameSnackBar(
        context,
        message:
            'Beat ${boss.name} ${BossBattleLogic.hardPhaseUnlockWins} times to unlock Hard Phase.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    if (mode == ManualBattleMode.nightmare &&
        !game.isNightmareUnlocked(boss.id)) {
      showGameSnackBar(
        context,
        message:
            'Beat ${boss.name} in Hard Phase ${BossBattleLogic.nightmareUnlockHardWins} times to unlock Nightmare.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    final (title, subtitle) = switch (mode) {
      ManualBattleMode.hard => (
          'Choose Hard Phase Fighter',
          'Hard Phase: dodge faster shots and earn 2× rewards from ${boss.name}.',
        ),
      ManualBattleMode.nightmare => (
          'Choose Nightmare Fighter',
          'Nightmare: extreme difficulty with 3× rewards from ${boss.name}.',
        ),
      ManualBattleMode.normal => (
          'Choose Fighter',
          'Dodge projectiles and shoot eggs at ${boss.name}.',
        ),
    };

    final fighter = await _pickFighter(
      context,
      theme,
      title: title,
      subtitle: subtitle,
    );
    if (fighter == null || !context.mounted) return;

    game.recordBossBattleStarted();

    if (!context.mounted) return;
    await pushThemedAppRoute<void>(
      context,
      theme: theme,
      settings: const RouteSettings(name: '/manual-boss-battle'),
      builder: (_) => ManualBossBattleScreen(
        game: game,
        preferences: preferences,
        customSprites: customSprites,
        boss: boss,
        fighter: fighter,
        mode: mode,
      ),
    );
  }

  Future<OwnedAnimal?> _pickFighter(
    BuildContext context,
    BackgroundTheme theme, {
    String title = 'Choose Fighter',
    String? subtitle,
  }) {
    final fighters = game.ownedAnimals
        .where((owned) => !game.isOwnedStackAutoBattling(owned))
        .toList();
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
                  title,
                  textAlign: TextAlign.center,
                  style: GameTheme.sectionTitle(theme),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.cardTextSecondaryColor,
                      height: 1.35,
                    ),
                  ),
                ],
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
                    const SizedBox(height: 14),
                    _BattleUpgradesCard(
                      theme: theme,
                      game: game,
                      onUnlockBossMutation: () => _unlockBossMutation(context),
                      onApplyBossMutation: () =>
                          _applyBossMutation(context, theme),
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
                              game: game,
                              isUnlocked: BossBattleLogic.isBossUnlocked(
                                BossData.bosses[i],
                                game.state,
                              ),
                              winCount: game.bossWinCount(BossData.bosses[i].id),
                              hardPhaseWinCount:
                                  game.hardPhaseWinCount(BossData.bosses[i].id),
                              eliteUnlockProgress: game.eliteBossUnlockProgress(
                                BossData.bosses[i].id,
                              ),
                              hardPhaseUnlocked: game.isHardPhaseUnlocked(
                                BossData.bosses[i].id,
                              ),
                              nightmareUnlocked: game.isNightmareUnlocked(
                                BossData.bosses[i].id,
                              ),
                              onAutoBattle: () => _startAutoBattle(
                                context,
                                BossData.bosses[i],
                                theme,
                              ),
                              onManualBattle: () => _startManualBattle(
                                context,
                                BossData.bosses[i],
                                theme,
                              ),
                              onHardPhaseBattle: () => _startManualBattle(
                                context,
                                BossData.bosses[i],
                                theme,
                                mode: ManualBattleMode.hard,
                              ),
                              onNightmareBattle: () => _startManualBattle(
                                context,
                                BossData.bosses[i],
                                theme,
                                mode: ManualBattleMode.nightmare,
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

class _BattleUpgradesCard extends StatelessWidget {
  const _BattleUpgradesCard({
    required this.theme,
    required this.game,
    required this.onUnlockBossMutation,
    required this.onApplyBossMutation,
  });

  final BackgroundTheme theme;
  final GameService game;
  final VoidCallback onUnlockBossMutation;
  final VoidCallback onApplyBossMutation;

  @override
  Widget build(BuildContext context) {
    final unlocked = game.bossMutationUnlocked;

    return Container(
      decoration: GameTheme.cardDecoration(theme),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Battle Upgrades',
            style: GameTheme.sectionTitle(theme, size: 18),
          ),
          const SizedBox(height: 12),
          if (unlocked)
            Text(
              'Boss Mutation unlocked',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.secondaryColor,
              ),
            )
          else ...[
            Text(
              'Unlock Boss Mutation',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.cardTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adds a tiny chance for Boss Mutation when hatching eggs.',
              style: TextStyle(
                fontSize: 13,
                color: theme.cardTextSecondaryColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: onUnlockBossMutation,
              style: GameTheme.filledButton(
                theme,
                color: game.canUnlockBossMutation()
                    ? theme.primaryColor
                    : theme.disabledColor,
              ),
              child: Text(
                'Unlock · ⚔️ ${GameData.unlockBossMutationCost}',
              ),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onApplyBossMutation,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: game.canApplyBossMutation()
                  ? theme.secondaryColor
                  : theme.disabledColor,
              side: BorderSide(
                color: game.canApplyBossMutation()
                    ? theme.secondaryColor
                    : theme.disabledColor,
              ),
            ),
            child: Text(
              'Apply Boss Mutation · ⚔️ ${GameData.applyBossMutationCost}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _BossCard extends StatelessWidget {
  const _BossCard({
    required this.boss,
    required this.theme,
    required this.game,
    required this.isUnlocked,
    required this.winCount,
    required this.hardPhaseWinCount,
    required this.eliteUnlockProgress,
    required this.hardPhaseUnlocked,
    required this.nightmareUnlocked,
    required this.onAutoBattle,
    required this.onManualBattle,
    required this.onHardPhaseBattle,
    required this.onNightmareBattle,
  });

  final BossBattleDefinition boss;
  final BackgroundTheme theme;
  final GameService game;
  final bool isUnlocked;
  final int winCount;
  final int hardPhaseWinCount;
  final int eliteUnlockProgress;
  final bool hardPhaseUnlocked;
  final bool nightmareUnlocked;
  final VoidCallback onAutoBattle;
  final VoidCallback onManualBattle;
  final VoidCallback onHardPhaseBattle;
  final VoidCallback onNightmareBattle;

  @override
  Widget build(BuildContext context) {
    final rewardAnimal = boss.rewardAnimalId != null
        ? GameData.animalById(boss.rewardAnimalId!)
        : null;

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
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? theme.secondaryColor.withValues(alpha: 0.18)
                      : theme.disabledColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isUnlocked
                    ? BossSprite(
                        spritePath: boss.spritePath,
                        fallbackEmoji: boss.emoji,
                        size: 52,
                        semanticLabel: boss.name,
                      )
                    : Text(
                        '🔒',
                        style: TextStyle(
                          fontSize: 28,
                          color: theme.disabledColor,
                        ),
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
          if (boss.manualBattleOnly) ...[
            if (isUnlocked) ...[
              if (rewardAnimal != null) ...[
                Text(
                  'Reward: ${rewardAnimal.name} animal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton(
                onPressed: onManualBattle,
                style: GameTheme.filledButton(
                  theme,
                  color: const Color(0xFF1565C0),
                ),
                child: const Text(
                  'Battle',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              FilledButton(
                onPressed: null,
                style: GameTheme.filledButton(
                  theme,
                  color: theme.disabledColor,
                ),
                child: Text(boss.name),
              ),
              const SizedBox(height: 6),
              Text(
                'Unlock: ${BossData.unlockProgressLabel(boss)} '
                '$eliteUnlockProgress / ${boss.unlockNightmareWinsRequired}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.cardTextSecondaryColor,
                ),
              ),
            ],
          ] else if (isUnlocked) ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onAutoBattle,
                    style: GameTheme.filledButton(
                      theme,
                      color: theme.primaryColor,
                    ),
                    child: const Text('Auto Battle'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onManualBattle,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      foregroundColor: theme.secondaryColor,
                      side: BorderSide(color: theme.secondaryColor),
                    ),
                    child: const Text(
                      'Battle',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (hardPhaseUnlocked)
              FilledButton(
                onPressed: onHardPhaseBattle,
                style: GameTheme.filledButton(
                  theme,
                  color: Colors.deepOrange.shade700,
                ),
                child: const Text(
                  'Hard Phase',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else ...[
              FilledButton(
                onPressed: null,
                style: GameTheme.filledButton(
                  theme,
                  color: theme.disabledColor,
                ),
                child: const Text('Hard Phase'),
              ),
              const SizedBox(height: 4),
              Text(
                'Hard Phase unlock: $winCount / '
                '${BossBattleLogic.hardPhaseUnlockWins} wins',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.cardTextSecondaryColor,
                ),
              ),
            ],
            if (hardPhaseUnlocked)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Hard Phase unlocked',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange.shade300,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (nightmareUnlocked)
              FilledButton(
                onPressed: onNightmareBattle,
                style: GameTheme.filledButton(
                  theme,
                  color: Colors.purple.shade800,
                ),
                child: const Text(
                  'Nightmare Mode',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else ...[
              FilledButton(
                onPressed: null,
                style: GameTheme.filledButton(
                  theme,
                  color: theme.disabledColor,
                ),
                child: const Text('Nightmare'),
              ),
              const SizedBox(height: 4),
              Text(
                'Nightmare unlock: $hardPhaseWinCount / '
                '${BossBattleLogic.nightmareUnlockHardWins} Hard wins',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.cardTextSecondaryColor,
                ),
              ),
            ],
            if (nightmareUnlocked)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Nightmare unlocked',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade200,
                  ),
                ),
              ),
          ] else
            FilledButton(
              onPressed: null,
              style: GameTheme.filledButton(
                theme,
                color: theme.disabledColor,
              ),
              child: const Text('Locked 🔒'),
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
