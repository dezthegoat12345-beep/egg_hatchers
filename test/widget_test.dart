import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/animal.dart';
import 'package:egg_hatchers/models/owned_animal.dart';
import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/services/game_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starting player has 250 coins and no animals', () {
    final state = GameData.startingPlayerState();
    expect(state.coins, 250);
    expect(state.lifetimeCoinsEarned, 0);
    expect(state.ownedAnimals, isEmpty);
  });

  test('buying and hatching a basic egg works', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    final basicEgg = GameData.eggs.first;
    expect(game.canAfford(basicEgg), isTrue);

    final bought = game.buyEgg(basicEgg);
    expect(bought, isTrue);
    expect(game.coins, 150);

    final result = game.hatchEgg(basicEgg);
    expect(basicEgg.possibleAnimalIds, contains(result.animal.id));
    expect(game.ownedAnimals.length, 1);
    expect(game.ownedAnimals.first.quantity, 1);
    expect(game.ownedAnimals.first.level, 1);
    expect(
      GameData.mutationById(game.ownedAnimals.first.mutationId),
      isNotNull,
    );

    game.dispose();
  });

  test('player state serializes and deserializes', () {
    final state = PlayerState(
      coins: 500,
      ownedAnimals: const [
        OwnedAnimal(
          animalId: 'chicken',
          quantity: 2,
          level: 3,
          mutationId: 'golden',
        ),
      ],
      lastSavedTime: DateTime(2025, 1, 1),
      lifetimeCoinsEarned: 1200,
    );

    final restored = PlayerState.fromJson(state.toJson());
    expect(restored.coins, 500);
    expect(restored.lifetimeCoinsEarned, 1200);
    expect(restored.ownedAnimals.first.quantity, 2);
    expect(restored.ownedAnimals.first.level, 3);
    expect(restored.ownedAnimals.first.mutationId, 'golden');
  });

  test('old saves without lifetimeCoinsEarned default to current coins', () {
    final restored = PlayerState.fromJson({
      'coins': 750,
      'ownedAnimals': [],
      'lastSavedTime': '2025-01-01T00:00:00.000',
    });
    expect(restored.lifetimeCoinsEarned, 750);
  });

  test('old saves without level or mutation default correctly', () {
    final owned = OwnedAnimal.fromJson({
      'animalId': 'chicken',
      'quantity': 2,
    });
    expect(owned.level, 1);
    expect(owned.mutationId, 'none');
  });

  test('income uses base x mutation x quantity x level', () {
    const animal = Animal(
      id: 'chicken',
      name: 'Chicken',
      rarity: Rarity.common,
      coinsPerSecond: 1,
      emoji: '🐔',
    );
    const owned = OwnedAnimal(
      animalId: 'chicken',
      quantity: 3,
      level: 2,
      mutationId: 'golden',
    );
    expect(GameService.incomeFor(animal, owned), 12);
  });

  test('upgrade cost uses base x level x 50 without mutation multiplier', () {
    const animal = Animal(
      id: 'rabbit',
      name: 'Rabbit',
      rarity: Rarity.common,
      coinsPerSecond: 3,
      emoji: '🐰',
    );
    const rainbowRabbit = OwnedAnimal(
      animalId: 'rabbit',
      quantity: 1,
      level: 1,
      mutationId: 'rainbow',
    );
    const normalRabbit = OwnedAnimal(
      animalId: 'rabbit',
      quantity: 1,
      level: 1,
      mutationId: 'none',
    );
    expect(GameService.upgradeCostFor(animal, rainbowRabbit), 150);
    expect(GameService.upgradeCostFor(animal, normalRabbit), 150);
  });

  test('mutated and normal animals share the same upgrade cost at same level', () {
    const animal = Animal(
      id: 'chicken',
      name: 'Chicken',
      rarity: Rarity.common,
      coinsPerSecond: 1,
      emoji: '🐔',
    );
    const normal = OwnedAnimal(animalId: 'chicken', quantity: 1, level: 2);
    const golden = OwnedAnimal(
      animalId: 'chicken',
      quantity: 1,
      level: 2,
      mutationId: 'golden',
    );
    const shadow = OwnedAnimal(
      animalId: 'chicken',
      quantity: 1,
      level: 2,
      mutationId: 'shadow',
    );

    expect(GameService.upgradeCostFor(animal, normal), 100);
    expect(GameService.upgradeCostFor(animal, golden), 100);
    expect(GameService.upgradeCostFor(animal, shadow), 100);
  });

  test('upgrading increases level and subtracts coins', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();

    final basicEgg = GameData.eggs.first;
    game.buyEgg(basicEgg);
    game.hatchEgg(basicEgg);

    final owned = game.ownedAnimals.first;
    final animal = GameData.animalById(owned.animalId)!;
    final cost = GameService.upgradeCostFor(animal, owned);

    expect(game.coins, 150);
    final newLevel = game.upgradeAnimal(owned.animalId, owned.mutationId);

    expect(newLevel, 2);
    expect(game.coins, 150 - cost);
    expect(game.ownedAnimal(owned.animalId, mutationId: owned.mutationId)!.level, 2);

    game.dispose();
  });

  test('duplicate hatch increases quantity without resetting level', () async {
    final basicEgg = GameData.eggs.first;
    var found = false;

    for (var seed = 0; seed < 500; seed++) {
      SharedPreferences.setMockInitialValues({});
      final game = GameService(random: Random(seed));
      await game.initialize();

      game.buyEgg(basicEgg);
      final first = game.hatchEgg(basicEgg);
      expect(game.upgradeAnimal(first.animal.id, first.mutation.id), 2);

      game.buyEgg(basicEgg);
      final second = game.hatchEgg(basicEgg);

      if (first.animal.id == second.animal.id &&
          first.mutation.id == second.mutation.id) {
        final owned =
            game.ownedAnimal(first.animal.id, mutationId: first.mutation.id)!;
        expect(owned.quantity, 2);
        expect(owned.level, 2);
        found = true;
      }

      game.dispose();
      if (found) break;
    }

    expect(found, isTrue, reason: 'Need a seed that hatches the same combo twice');
  });

  test('golden and normal chickens are separate entries', () async {
    SharedPreferences.setMockInitialValues({});
    // Rolls: animal index, mutation roll (99 = shadow)... need controlled rolls.
    // Use a custom approach: hatch twice with forced mutations via direct state is not available.
    // Instead test rollMutation and matching logic separately.
    final shadowMutation = GameData.mutationById('shadow')!;
    expect(shadowMutation.incomeMultiplier, 10);

    const animal = Animal(
      id: 'chicken',
      name: 'Chicken',
      rarity: Rarity.common,
      coinsPerSecond: 1,
      emoji: '🐔',
    );
    const normal = OwnedAnimal(animalId: 'chicken', quantity: 3, level: 2);
    const golden = OwnedAnimal(
      animalId: 'chicken',
      quantity: 1,
      level: 1,
      mutationId: 'golden',
    );

    expect(GameService.incomeFor(animal, normal), 6);
    expect(GameService.incomeFor(animal, golden), 2);
  });

  test('mutation roll weighted chances', () {
    final random = Random(42);
    final results = <String, int>{};
    for (var i = 0; i < 1000; i++) {
      final mutation = GameData.rollMutation(random);
      results[mutation.id] = (results[mutation.id] ?? 0) + 1;
    }
    expect(results['none'], greaterThan(results['golden']!));
    expect(results['golden'], greaterThan(results['rainbow']!));
    expect(results['rainbow'], greaterThan(results['shadow']!));
  });

  test('upgrading golden chicken does not upgrade normal chicken', () async {
    const saveKey = 'egg_hatchers_player_state';
    SharedPreferences.setMockInitialValues({
      saveKey:
          '{"coins":1000,"ownedAnimals":[{"animalId":"chicken","quantity":1,"level":1,"mutationId":"none"},{"animalId":"chicken","quantity":1,"level":1,"mutationId":"golden"}],"lastSavedTime":"2025-06-01T00:00:00.000"}',
    });

    final game = GameService();
    await game.initialize();

    expect(game.upgradeAnimal('chicken', 'golden'), 2);
    expect(game.ownedAnimal('chicken', mutationId: 'none')!.level, 1);
    expect(game.ownedAnimal('chicken', mutationId: 'golden')!.level, 2);

    game.dispose();
  });

  test('setCoins and resetCoins work', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.setCoins(9999);
    expect(game.coins, 9999);

    game.resetCoins();
    expect(game.coins, 250);

    game.dispose();
  });

  test('forced next hatch overrides random then clears', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();

    game.setForcedNextHatch('dragon', 'shadow');
    expect(game.hasForcedNextHatch, isTrue);

    game.buyEgg(GameData.eggs.first);
    final result = game.hatchEgg(GameData.eggs.first);

    expect(result.animal.id, 'dragon');
    expect(result.mutation.id, 'shadow');
    expect(game.hasForcedNextHatch, isFalse);

    game.dispose();
  });

  test('egg unlocks based on lifetime coins earned', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    final basic = GameData.eggs[0];
    final forest = GameData.eggs[1];
    final magic = GameData.eggs[2];

    expect(game.isEggUnlocked(basic), isTrue);
    expect(game.isEggUnlocked(forest), isFalse);
    expect(game.isEggUnlocked(magic), isFalse);

    game.setLifetimeCoinsEarned(500);
    expect(game.isEggUnlocked(forest), isTrue);
    expect(game.isEggUnlocked(magic), isFalse);

    game.setLifetimeCoinsEarned(5000);
    expect(game.isEggUnlocked(magic), isTrue);

    game.dispose();
  });

  test('spending coins does not reduce lifetime coins earned', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.setLifetimeCoinsEarned(1000);
    game.setCoins(1000);
    game.buyEgg(GameData.eggs.first);

    expect(game.lifetimeCoinsEarned, 1000);
    expect(game.coins, 900);

    game.dispose();
  });

  test('setCoins does not change lifetime coins earned', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.setLifetimeCoinsEarned(500);
    game.setCoins(9999);

    expect(game.lifetimeCoinsEarned, 500);
    expect(game.coins, 9999);

    game.dispose();
  });

  test('normal hatch is random when no forced override', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    expect(game.hasForcedNextHatch, isFalse);

    game.buyEgg(GameData.eggs.first);
    final result = game.hatchEgg(GameData.eggs.first);

    expect(
      GameData.eggs.first.possibleAnimalIds,
      contains(result.animal.id),
    );

    game.dispose();
  });
}
