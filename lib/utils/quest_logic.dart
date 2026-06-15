import '../data/quest_data.dart';
import '../models/player_state.dart';
import '../models/quest.dart';
import 'collection_quest_logic.dart';
import 'format_utils.dart';

/// Evaluates quest progress and status from player state.
class QuestLogic {
  QuestLogic._();

  static int metricValue(QuestMetric metric, PlayerState state) {
    final progress = state.questProgress;
    switch (metric) {
      case QuestMetric.totalEggsHatched:
        return progress.totalEggsHatched;
      case QuestMetric.totalSingleHatches:
        return progress.totalSingleHatches;
      case QuestMetric.totalTripleHatches:
        return progress.totalTripleHatches;
      case QuestMetric.totalMutationsHatched:
        return progress.totalMutationsHatched;
      case QuestMetric.totalGoldenHatched:
        return progress.totalGoldenHatched;
      case QuestMetric.totalRainbowHatched:
        return progress.totalRainbowHatched;
      case QuestMetric.totalShadowHatched:
        return progress.totalShadowHatched;
      case QuestMetric.totalAnimalUpgrades:
        return progress.totalAnimalUpgrades;
      case QuestMetric.totalLuckUpgrades:
        return progress.totalLuckUpgrades;
      case QuestMetric.totalCustomEggsCreated:
        return progress.totalCustomEggsCreated;
      case QuestMetric.totalCustomEggHatches:
        return progress.totalCustomEggHatches;
      case QuestMetric.totalCustomTripleHatches:
        return progress.totalCustomTripleHatches;
      case QuestMetric.totalSpritesRated:
        return progress.totalSpritesRated;
      case QuestMetric.totalSpriteRatingRewardsClaimed:
        return progress.totalSpriteRatingRewardsClaimed;
      case QuestMetric.bestSpriteRatingScore:
        return progress.bestSpriteRatingScore;
      case QuestMetric.totalPerfectSpriteRatings:
        return progress.totalPerfectSpriteRatings;
      case QuestMetric.totalReferenceOverlaysUnlocked:
        return progress.totalReferenceOverlaysUnlocked;
      case QuestMetric.luckLevel:
        return state.luckLevel;
      case QuestMetric.lifetimeCoinsEarned:
        return state.lifetimeCoinsEarned;
      case QuestMetric.rebirthLevel:
        return state.rebirthLevel;
      case QuestMetric.collectedBaseAnimals:
        return CollectionQuestLogic.collectedBaseAnimalCount(state);
    }
  }

  static int currentValue(Quest quest, PlayerState state) {
    if (quest.requiresCustomEggCreated &&
        state.questProgress.totalCustomEggsCreated < 1) {
      return 0;
    }
    return metricValue(quest.metric, state);
  }

  static bool isComplete(Quest quest, PlayerState state) {
    if (quest.requiresCustomEggCreated &&
        state.questProgress.totalCustomEggsCreated < 1) {
      return false;
    }
    return currentValue(quest, state) >= quest.target;
  }

  static QuestStatus status(Quest quest, PlayerState state) {
    if (state.questProgress.isQuestClaimed(quest.id)) {
      return QuestStatus.claimed;
    }
    if (isComplete(quest, state)) return QuestStatus.readyToClaim;
    return QuestStatus.inProgress;
  }

  static String progressText(Quest quest, PlayerState state) {
    if (quest.metric == QuestMetric.collectedBaseAnimals) {
      return CollectionQuestLogic.progressText(quest, state);
    }
    final current = currentValue(quest, state).clamp(0, quest.target);
    if (quest.metric == QuestMetric.lifetimeCoinsEarned) {
      return '${formatCoins(current)} / ${formatCoins(quest.target)}';
    }
    if (quest.metric == QuestMetric.bestSpriteRatingScore) {
      final best = state.questProgress.bestSpriteRatingScore;
      return '$best / ${quest.target}';
    }
    return '$current / ${quest.target}';
  }

  static int readyToClaimCount(PlayerState state) {
    return readyToClaimQuests(state).length;
  }

  /// Completed but unclaimed quests in stable definition order.
  static List<Quest> readyToClaimQuests(PlayerState state) {
    return QuestData.all
        .where((quest) => status(quest, state) == QuestStatus.readyToClaim)
        .toList();
  }

  /// Quests that just became complete and have not triggered a notification.
  static List<Quest> newlyCompletedUnnotified(PlayerState state) {
    return QuestData.all
        .where(
          (quest) =>
              !state.questProgress.wasCompletionNotified(quest.id) &&
              status(quest, state) == QuestStatus.readyToClaim,
        )
        .toList();
  }

  /// SnackBar message for one or more newly completed quests.
  static String completionNotificationMessage(List<Quest> quests) {
    if (quests.isEmpty) return '';
    if (quests.length > 1) {
      return '${quests.length} Quests Complete! Claim your rewards.';
    }
    final quest = quests.first;
    return '${quest.notificationEmoji} ${quest.notificationCategoryLabel} '
        'Quest Complete! Claim your reward.';
  }
}
