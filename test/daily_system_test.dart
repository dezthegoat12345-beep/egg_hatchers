import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/utils/daily_system_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailySystemLogic', () {
    test('reward track rotates every 7 streak days', () {
      expect(DailySystemLogic.rewardForStreak(1).coins, 500);
      expect(DailySystemLogic.rewardForStreak(3).battleTokens, 10);
      expect(DailySystemLogic.rewardForStreak(7).coins, 10000);
      expect(DailySystemLogic.rewardForStreak(7).battleTokens, 50);
      expect(DailySystemLogic.rewardForStreak(8).coins, 500);
    });

    test('generates three fixed daily quests', () {
      final quests = DailySystemLogic.generateDailyQuests();
      expect(quests.length, 3);
      expect(quests.map((q) => q.type).toSet(), {
        DailySystemLogic.hatchEggsType,
        DailySystemLogic.upgradeAnimalsType,
        DailySystemLogic.defeatBossType,
      });
    });
  });

  group('PlayerState daily persistence', () {
    test('old saves default daily fields safely', () {
      final restored = PlayerState.fromJson({
        'coins': 100,
        'ownedAnimals': [],
        'lastSavedTime': DateTime.now().toIso8601String(),
        'lifetimeCoinsEarned': 100,
      });

      expect(restored.lastDailyRewardClaimDate, isNull);
      expect(restored.dailyRewardStreak, 0);
      expect(restored.bestDailyRewardStreak, 0);
      expect(restored.dailyQuestDate, isNull);
      expect(restored.dailyQuests, isEmpty);
    });

    test('daily fields round-trip', () {
      final quests = DailySystemLogic.generateDailyQuests();
      final state = PlayerState.initial().copyWith(
        lastDailyRewardClaimDate: '2026-06-05',
        dailyRewardStreak: 4,
        bestDailyRewardStreak: 6,
        dailyQuestDate: '2026-06-05',
        dailyQuests: quests,
      );
      final restored = PlayerState.fromJson(state.toJson());

      expect(restored.lastDailyRewardClaimDate, '2026-06-05');
      expect(restored.dailyRewardStreak, 4);
      expect(restored.bestDailyRewardStreak, 6);
      expect(restored.dailyQuestDate, '2026-06-05');
      expect(restored.dailyQuests.length, 3);
    });
  });

  group('GameService daily systems', () {
    test('claimDailyReward grants coins without lifetime earnings', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameService();
      await game.initialize();

      final lifetimeBefore = game.lifetimeCoinsEarned;
      expect(game.claimDailyReward(), isTrue);

      expect(game.hasClaimedDailyRewardToday, isTrue);
      expect(game.dailyRewardStreak, 1);
      expect(game.coins, greaterThan(250));
      expect(game.lifetimeCoinsEarned, lifetimeBefore);
      expect(game.claimDailyReward(), isFalse);
    });

    test('daily quest progress increments on hatch count', () async {
      SharedPreferences.setMockInitialValues({});
      final game = GameService();
      await game.initialize();

      final hatchQuest = game.dailyQuests.firstWhere(
        (q) => q.type == DailySystemLogic.hatchEggsType,
      );
      expect(hatchQuest.progress, 0);

      game.hatchEgg(GameData.eggs.first);
      final updated = game.dailyQuests.firstWhere(
        (q) => q.type == DailySystemLogic.hatchEggsType,
      );
      expect(updated.progress, 1);
    });
  });
}
