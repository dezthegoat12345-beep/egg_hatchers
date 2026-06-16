import 'package:flutter/material.dart';

import '../data/quest_data.dart';
import '../models/background_theme.dart';
import '../models/quest.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../navigation/app_page_route.dart';
import '../utils/quest_logic.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
import '../widgets/phone_width_layout.dart';
import '../widgets/quest_card.dart';
import '../utils/format_utils.dart';

/// Shows quest categories, progress, and claimable coin rewards.
class QuestsScreen extends StatelessWidget {
  const QuestsScreen({
    super.key,
    required this.game,
    required this.preferences,
  });

  final GameService game;
  final PreferencesService preferences;

  void _claimQuest(BuildContext context, Quest quest) {
    final reward = game.claimQuest(quest.id);
    if (reward == null || !context.mounted) return;

    if (quest.showsSecretHintOnClaim) {
      _showSecretHintDialog(context);
      return;
    }

    if (reward.coins > 0) {
      showGameSnackBar(
        context,
        message: 'Quest complete! +${formatCoins(reward.coins)} coins',
        backgroundColor: preferences.selectedTheme.secondaryColor,
      );
    } else if (reward.battleTokens > 0) {
      showGameSnackBar(
        context,
        message:
            'Quest complete! +${reward.battleTokens} Battle Tokens',
        backgroundColor: preferences.selectedTheme.secondaryColor,
      );
    }
  }

  Future<void> _showSecretHintDialog(BuildContext context) async {
    final theme = preferences.selectedTheme;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        ),
        title: Text(
          'Secret Hint',
          style: TextStyle(
            color: theme.cardTextPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Click the coin in Hatchery 3 times',
          style: TextStyle(
            color: theme.cardTextSecondaryColor,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(
              backgroundColor: theme.secondaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([game, preferences]),
      builder: (context, _) {
        final bg = preferences.selectedTheme;
        final readyToClaim = QuestLogic.readyToClaimQuests(game.state);
        final readyIds = readyToClaim.map((q) => q.id).toSet();
        final readyCount = readyToClaim.length;

        return ReturnToHatcheryPopScope(
          theme: bg,
          child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PhoneWidthAppBar(
            title: '🎯 Quests',
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            backgroundColor: bg.appBarColor,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: ReturnToHatcheryBackButton(
              theme: bg,
              color: Colors.white,
            ),
          ),
          body: GameBackground(
            theme: bg,
            child: PhoneWidthLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CoinHeader(
                    coins: game.coins,
                    coinsPerSecond: game.coinsPerSecond,
                    lifetimeCoinsEarned: game.lifetimeCoinsEarned,
                    theme: bg,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: GameTheme.cardDecoration(bg),
                    child: Row(
                      children: [
                        const Text('🗺️', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Goals & Rewards',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: bg.cardTextPrimaryColor,
                                ),
                              ),
                              Text(
                                readyCount > 0
                                    ? '$readyCount quest${readyCount == 1 ? '' : 's'} ready to claim!'
                                    : 'Complete quests to earn bonus coins.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: bg.cardTextSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                                  if (readyToClaim.isNotEmpty) ...[
                                    _CompletedQuestsHeader(theme: bg),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: GameTheme.cardDecoration(
                                        bg,
                                        borderColor: bg.secondaryColor,
                                        backgroundColor: bg.secondaryColor
                                            .withValues(alpha: 0.1),
                                      ),
                                      child: Column(
                                        children: [
                                          for (var i = 0;
                                              i < readyToClaim.length;
                                              i++) ...[
                                            if (i > 0) const SizedBox(height: 10),
                                            QuestCard(
                                              quest: readyToClaim[i],
                                              game: game,
                                              theme: bg,
                                              onClaim: () => _claimQuest(
                                                context,
                                                readyToClaim[i],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  for (final category
                                      in QuestData.categoryOrder) ...[
                                    _CategoryHeader(
                                      category: category,
                                      theme: bg,
                                    ),
                                    const SizedBox(height: 10),
                                    for (final quest in QuestData.forCategory(
                                      category,
                                    ))
                                      if (!readyIds.contains(quest.id)) ...[
                                        QuestCard(
                                          quest: quest,
                                          game: game,
                                          theme: bg,
                                          onClaim: () =>
                                              _claimQuest(context, quest),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    const SizedBox(height: 8),
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

class _CompletedQuestsHeader extends StatelessWidget {
  const _CompletedQuestsHeader({required this.theme});

  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '🎉 Completed Quests',
          style: GameTheme.sectionTitle(theme, size: 17).copyWith(
            color: theme.secondaryColor,
          ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.theme,
  });

  final QuestCategory category;
  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    final sample = QuestData.forCategory(category).first;
    return Text(
      '${sample.categoryEmoji} ${sample.categoryLabel}',
      style: GameTheme.sectionTitle(theme, size: 16),
    );
  }
}
