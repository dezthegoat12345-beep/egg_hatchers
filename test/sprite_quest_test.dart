import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egg_hatchers/data/quest_data.dart';
import 'package:egg_hatchers/models/quest.dart';
import 'package:egg_hatchers/models/quest_progress.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/services/sprite_reference_overlay_service.dart';
import 'package:egg_hatchers/utils/quest_logic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Quest questById(String id) =>
      QuestData.all.firstWhere((quest) => quest.id == id);

  test('custom sprite quests are defined in quest data', () {
    final spriteQuests =
        QuestData.forCategory(QuestCategory.customSprite);
    expect(spriteQuests, hasLength(8));
    expect(QuestData.categoryOrder, contains(QuestCategory.customSprite));
  });

  test('rating a sprite updates quest stats and completes first rating quest',
      () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.recordSpriteRated(
      animalId: 'chicken',
      score: 7,
      spriteHash: 'abc123',
    );

    expect(game.questProgress.totalSpritesRated, 1);
    expect(game.questProgress.bestSpriteRatingScore, 7);
    expect(
      QuestLogic.isComplete(questById('sprite_rate_1'), game.state),
      isTrue,
    );
    expect(
      QuestLogic.isComplete(questById('sprite_best_7'), game.state),
      isTrue,
    );
  });

  test('perfect rating counts once per sprite version', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.recordSpriteRated(
      animalId: 'chicken',
      score: 10,
      spriteHash: 'perfect1',
    );
    game.recordSpriteRated(
      animalId: 'chicken',
      score: 10,
      spriteHash: 'perfect1',
    );

    expect(game.questProgress.totalSpritesRated, 1);
    expect(game.questProgress.totalPerfectSpriteRatings, 1);
    expect(game.questProgress.questCountedRatedSpriteKeys, ['chicken:perfect1']);
    expect(
      QuestLogic.isComplete(questById('sprite_perfect_1'), game.state),
      isTrue,
    );
  });

  test('repeat rating same sprite does not increment quest progress', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.recordSpriteRated(
      animalId: 'chicken',
      score: 7,
      spriteHash: 'same_hash',
    );
    game.recordSpriteRated(
      animalId: 'chicken',
      score: 7,
      spriteHash: 'same_hash',
    );
    game.recordSpriteRated(
      animalId: 'chicken',
      score: 7,
      spriteHash: 'same_hash',
    );

    expect(game.questProgress.totalSpritesRated, 1);
    expect(game.isSpriteRatingCountedForQuest('chicken', 'same_hash'), isTrue);
  });

  test('different sprite hash counts as new rating', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.recordSpriteRated(
      animalId: 'chicken',
      score: 6,
      spriteHash: 'hash_a',
    );
    game.recordSpriteRated(
      animalId: 'chicken',
      score: 8,
      spriteHash: 'hash_b',
    );

    expect(game.questProgress.totalSpritesRated, 2);
    expect(game.questProgress.bestSpriteRatingScore, 8);
  });

  test('claiming sprite rating reward updates claim quest progress', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.recordSpriteRatingRewardClaimed();
    game.recordSpriteRatingRewardClaimed();
    game.recordSpriteRatingRewardClaimed();

    expect(game.questProgress.totalSpriteRatingRewardsClaimed, 3);
    expect(
      QuestLogic.isComplete(questById('sprite_claim_3'), game.state),
      isTrue,
    );
  });

  test('unlocking reference overlay updates overlay quest progress', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    final overlay = SpriteReferenceOverlayService();
    await Future.wait([game.initialize(), overlay.initialize()]);

    game.setCoins(100000);
    expect(
      await game.unlockReferenceOverlay('chicken', overlay),
      isTrue,
    );

    expect(game.questProgress.totalReferenceOverlaysUnlocked, 1);
    expect(
      QuestLogic.isComplete(questById('sprite_overlay_1'), game.state),
      isTrue,
    );
  });

  test('custom sprite quest notification uses custom sprite label', () {
    final message = QuestLogic.completionNotificationMessage(
      [questById('sprite_rate_1')],
    );
    expect(message, contains('Custom Sprite'));
    expect(message, contains('🎨'));
  });

  test('claiming custom sprite quest reward does not increase lifetime coins',
      () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.recordSpriteRated(
      animalId: 'chicken',
      score: 1,
      spriteHash: 'hash1',
    );
    game.setLifetimeCoinsEarned(5000);
    final lifetimeBefore = game.lifetimeCoinsEarned;
    final coinsBefore = game.coins;

    final reward = game.claimQuest('sprite_rate_1');

    expect(reward?.coins, 250);
    expect(game.coins, coinsBefore + 250);
    expect(game.lifetimeCoinsEarned, lifetimeBefore);
  });

  test('rebirth resets sprite quest stats with other quest progress', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.recordSpriteRated(
      animalId: 'chicken',
      score: 10,
      spriteHash: 'hash1',
    );
    game.recordSpriteRatingRewardClaimed();
    game.setLifetimeCoinsEarned(1000000);
    game.performRebirth();

    expect(game.questProgress.totalSpritesRated, 0);
    expect(game.questProgress.bestSpriteRatingScore, 0);
    expect(game.questProgress.totalPerfectSpriteRatings, 0);
    expect(game.questProgress.totalSpriteRatingRewardsClaimed, 0);
    expect(game.questProgress.totalReferenceOverlaysUnlocked, 0);
    expect(game.questProgress.perfectRatedSpriteKeys, isEmpty);
    expect(game.questProgress.questCountedRatedSpriteKeys, isEmpty);
  });

  test('sprite quest stats serialize and deserialize', () {
    final progress = QuestProgress(
      totalSpritesRated: 4,
      totalSpriteRatingRewardsClaimed: 2,
      bestSpriteRatingScore: 9,
      totalPerfectSpriteRatings: 1,
      totalReferenceOverlaysUnlocked: 3,
      perfectRatedSpriteKeys: const ['chicken:abc123'],
      questCountedRatedSpriteKeys: const ['chicken:abc123', 'fox:def456'],
    );

    final restored = QuestProgress.fromJson(progress.toJson());
    expect(restored.totalSpritesRated, 4);
    expect(restored.totalSpriteRatingRewardsClaimed, 2);
    expect(restored.bestSpriteRatingScore, 9);
    expect(restored.totalPerfectSpriteRatings, 1);
    expect(restored.totalReferenceOverlaysUnlocked, 3);
    expect(restored.perfectRatedSpriteKeys, ['chicken:abc123']);
    expect(restored.questCountedRatedSpriteKeys,
        ['chicken:abc123', 'fox:def456']);
  });
}
