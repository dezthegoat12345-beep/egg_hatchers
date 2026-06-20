import '../models/daily_quest_progress.dart';

/// Daily reward track and daily quest definitions.
class DailySystemLogic {
  DailySystemLogic._();

  static const hatchEggsType = 'hatchEggs';
  static const upgradeAnimalsType = 'upgradeAnimals';
  static const defeatBossType = 'defeatBoss';

  /// Local calendar date key: yyyy-MM-dd.
  static String todayKey([DateTime? now]) {
    final date = now ?? DateTime.now();
    return _formatDateKey(date);
  }

  static String yesterdayKey([DateTime? now]) {
    final date = (now ?? DateTime.now()).subtract(const Duration(days: 1));
    return _formatDateKey(date);
  }

  static bool isYesterday(String? dateKey, [DateTime? now]) {
    if (dateKey == null || dateKey.isEmpty) return false;
    return dateKey == yesterdayKey(now);
  }

  static String _formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Reward slot (1–7) for the given streak after claiming today.
  static int rewardDaySlot(int streak) {
    if (streak <= 0) return 1;
    return ((streak - 1) % 7) + 1;
  }

  static DailyRewardOffer rewardForStreak(int streak) {
    return rewardForDaySlot(rewardDaySlot(streak));
  }

  static DailyRewardOffer rewardForDaySlot(int daySlot) {
    switch (daySlot) {
      case 1:
        return const DailyRewardOffer(
          daySlot: 1,
          coins: 500,
          battleTokens: 0,
          label: '500 coins',
        );
      case 2:
        return const DailyRewardOffer(
          daySlot: 2,
          coins: 1000,
          battleTokens: 0,
          label: '1,000 coins',
        );
      case 3:
        return const DailyRewardOffer(
          daySlot: 3,
          coins: 0,
          battleTokens: 10,
          label: '10 Battle Tokens',
        );
      case 4:
        return const DailyRewardOffer(
          daySlot: 4,
          coins: 2500,
          battleTokens: 0,
          label: '2,500 coins',
        );
      case 5:
        return const DailyRewardOffer(
          daySlot: 5,
          coins: 0,
          battleTokens: 20,
          label: '20 Battle Tokens',
        );
      case 6:
        return const DailyRewardOffer(
          daySlot: 6,
          coins: 5000,
          battleTokens: 0,
          label: '5,000 coins',
        );
      case 7:
        return const DailyRewardOffer(
          daySlot: 7,
          coins: 10000,
          battleTokens: 50,
          label: '50 Battle Tokens + 10,000 coins',
        );
      default:
        return rewardForDaySlot(1);
    }
  }

  static List<DailyQuestProgress> generateDailyQuests() {
    return const [
      DailyQuestProgress(
        id: 'daily_hatch_3',
        type: hatchEggsType,
        title: 'Hatch 3 eggs',
        target: 3,
        rewardCoins: 1000,
      ),
      DailyQuestProgress(
        id: 'daily_upgrade_3',
        type: upgradeAnimalsType,
        title: 'Upgrade animals 3 times',
        target: 3,
        rewardCoins: 1500,
      ),
      DailyQuestProgress(
        id: 'daily_defeat_boss',
        type: defeatBossType,
        title: 'Defeat 1 boss',
        target: 1,
        rewardBattleTokens: 15,
      ),
    ];
  }

  static String rewardLabel({
    required int rewardCoins,
    required int rewardBattleTokens,
  }) {
    if (rewardCoins > 0 && rewardBattleTokens > 0) {
      return '$rewardCoins coins + $rewardBattleTokens Battle Tokens';
    }
    if (rewardBattleTokens > 0) {
      return '$rewardBattleTokens Battle Tokens';
    }
    return '$rewardCoins coins';
  }
}

class DailyRewardOffer {
  const DailyRewardOffer({
    required this.daySlot,
    required this.coins,
    required this.battleTokens,
    required this.label,
  });

  final int daySlot;
  final int coins;
  final int battleTokens;
  final String label;
}
