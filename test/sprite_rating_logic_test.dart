import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/data/sprite_reference_data.dart';
import 'package:egg_hatchers/models/custom_sprite_data.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/services/sprite_rating_service.dart';
import 'package:egg_hatchers/services/sprite_reference_overlay_service.dart';
import 'package:egg_hatchers/utils/sprite_rating_logic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sprite hash is stable for identical grids', () {
    final sprite = CustomSpriteData(
      pixels: [
        for (var i = 0; i < CustomSpriteData.cellCount; i++)
          i.isEven ? 0xFFE53935 : null,
      ],
    );

    expect(
      SpriteRatingLogic.computeSpriteHash(sprite),
      SpriteRatingLogic.computeSpriteHash(sprite),
    );
  });

  test('blank sprite scores low against chicken reference', () {
    final reference = SpriteReferenceData.referenceFor('chicken')!;
    final blank = CustomSpriteData.empty();

    expect(SpriteRatingLogic.displayScore(blank, reference), lessThanOrEqualTo(1));
  });

  test('matching reference scores higher than random scribble', () {
    final reference = SpriteReferenceData.referenceFor('chicken')!;
    final match = reference;
    final random = CustomSpriteData(
      pixels: [
        for (var i = 0; i < CustomSpriteData.cellCount; i++)
          i % 3 == 0 ? 0xFF1E88E5 : null,
      ],
    );

    final matchScore = SpriteRatingLogic.displayScore(match, reference);
    final randomScore = SpriteRatingLogic.displayScore(random, reference);

    expect(matchScore, greaterThan(randomScore));
    expect(matchScore, greaterThanOrEqualTo(8));
  });

  test('reward scales with score', () {
    final low = SpriteRatingLogic.calculateReward(
      animalId: 'chicken',
      score: 2,
      currentCoins: 1000,
    );
    final high = SpriteRatingLogic.calculateReward(
      animalId: 'chicken',
      score: 9,
      currentCoins: 1000,
    );

    expect(low, greaterThanOrEqualTo(25));
    expect(high, greaterThan(low));
  });

  test('score 0 gives no reward', () {
    expect(
      SpriteRatingLogic.calculateReward(
        animalId: 'chicken',
        score: 0,
        currentCoins: 1000,
      ),
      0,
    );
  });

  test('sprite rating reward does not increase lifetimeCoinsEarned', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    final lifetimeBefore = game.lifetimeCoinsEarned;
    final coinsBefore = game.coins;

    final granted = game.grantSpriteRatingReward(150);
    expect(granted, 150);
    expect(game.coins, coinsBefore + 150);
    expect(game.lifetimeCoinsEarned, lifetimeBefore);
  });

  test('duplicate claim is blocked', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SpriteRatingService();
    await service.initialize();

    final first = await service.recordClaim(
      animalId: 'chicken',
      spriteHash: 'abc123',
      score: 8,
      rewardCoins: 100,
    );
    final second = await service.recordClaim(
      animalId: 'chicken',
      spriteHash: 'abc123',
      score: 8,
      rewardCoins: 100,
    );

    expect(first, isTrue);
    expect(second, isFalse);
    expect(service.isClaimed('chicken', 'abc123'), isTrue);
  });

  test('different hash can be claimed separately', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SpriteRatingService();
    await service.initialize();

    expect(
      await service.recordClaim(
        animalId: 'chicken',
        spriteHash: 'hash_a',
        score: 6,
        rewardCoins: 80,
      ),
      isTrue,
    );
    expect(
      await service.recordClaim(
        animalId: 'chicken',
        spriteHash: 'hash_b',
        score: 7,
        rewardCoins: 90,
      ),
      isTrue,
    );
    expect(service.isClaimed('chicken', 'hash_a'), isTrue);
    expect(service.isClaimed('chicken', 'hash_b'), isTrue);
  });

  test('claims persist after restart', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SpriteRatingService();
    await service.initialize();
    await service.recordClaim(
      animalId: 'fox',
      spriteHash: 'persist1',
      score: 5,
      rewardCoins: 60,
    );

    final reloaded = SpriteRatingService();
    await reloaded.initialize();

    expect(reloaded.isClaimed('fox', 'persist1'), isTrue);
    expect(reloaded.getClaim('fox', 'persist1')?.score, 5);
  });

  test('every animal has a built-in sprite path', () {
    for (final animal in GameData.animals) {
      expect(
        animal.spritePath,
        isNotNull,
        reason: '${animal.id} is missing spritePath',
      );
      expect(animal.spritePath, startsWith('assets/images/animals/'));
    }
  });

  test('every animal has a sprite rating reference', () {
    for (final animal in GameData.animals) {
      expect(
        SpriteReferenceData.hasReference(animal.id),
        isTrue,
        reason: '${animal.id} is missing rating reference',
      );
    }
  });

  test('reference overlay cost is 25 percent of max reward with 25 coin floor', () {
    for (final animal in GameData.animals) {
      final maxReward = SpriteRatingLogic.maxRatingRewardForAnimal(animal.id);
      final cost = SpriteRatingLogic.referenceOverlayCostForAnimal(animal.id);

      expect(maxReward, greaterThan(0));
      expect(cost, greaterThanOrEqualTo(25));
      expect(cost, (maxReward * 0.25).round());
    }
  });

  test('unlocking reference overlay subtracts coins without lifetime earnings',
      () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    final overlay = SpriteReferenceOverlayService();
    await Future.wait([game.initialize(), overlay.initialize()]);

    final cost = game.referenceOverlayCostForAnimal('chicken');
    game.setCoins(cost + 50);
    game.setLifetimeCoinsEarned(5000);
    final lifetimeBefore = game.lifetimeCoinsEarned;
    final coinsBefore = game.coins;

    final unlocked =
        await game.unlockReferenceOverlay('chicken', overlay);

    expect(unlocked, isTrue);
    expect(overlay.isUnlocked('chicken'), isTrue);
    expect(game.coins, coinsBefore - cost);
    expect(game.lifetimeCoinsEarned, lifetimeBefore);
  });

  test('reference overlay unlock is blocked when coins are too low', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    final overlay = SpriteReferenceOverlayService();
    await Future.wait([game.initialize(), overlay.initialize()]);

    final cost = game.referenceOverlayCostForAnimal('chicken');
    game.setCoins(cost - 1);

    final unlocked =
        await game.unlockReferenceOverlay('chicken', overlay);

    expect(unlocked, isFalse);
    expect(overlay.isUnlocked('chicken'), isFalse);
    expect(game.coins, cost - 1);
  });

  test('reference overlay unlock persists after restart', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    final overlay = SpriteReferenceOverlayService();
    await Future.wait([game.initialize(), overlay.initialize()]);

    game.setCoins(10000);
    expect(
      await game.unlockReferenceOverlay('fox', overlay),
      isTrue,
    );

    final reloaded = SpriteReferenceOverlayService();
    await reloaded.initialize();

    expect(reloaded.isUnlocked('fox'), isTrue);
    expect(reloaded.isUnlocked('chicken'), isFalse);
  });

  test('reference overlay unlock persists after rebirth', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    final overlay = SpriteReferenceOverlayService();
    await Future.wait([game.initialize(), overlay.initialize()]);

    game.setCoins(10000);
    game.setLifetimeCoinsEarned(1000000);
    expect(
      await game.unlockReferenceOverlay('dragon', overlay),
      isTrue,
    );
    expect(game.performRebirth(), isTrue);

    expect(overlay.isUnlocked('dragon'), isTrue);
  });
}
