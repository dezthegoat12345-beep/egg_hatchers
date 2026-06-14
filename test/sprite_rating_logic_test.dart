import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egg_hatchers/data/sprite_reference_data.dart';
import 'package:egg_hatchers/models/custom_sprite_data.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/services/sprite_rating_service.dart';
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
}
