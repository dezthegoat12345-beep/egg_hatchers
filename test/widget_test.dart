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

    final animal = game.hatchEgg(basicEgg);
    expect(basicEgg.possibleAnimalIds, contains(animal.id));
    expect(game.ownedAnimals.length, 1);
    expect(game.ownedAnimals.first.quantity, 1);
    expect(game.ownedAnimals.first.level, 1);

    game.dispose();
  });

  test('player state serializes and deserializes', () {
    final state = PlayerState(
      coins: 500,
      ownedAnimals: const [
        OwnedAnimal(animalId: 'chicken', quantity: 2, level: 3),
      ],
      lastSavedTime: DateTime(2025, 1, 1),
    );

    final restored = PlayerState.fromJson(state.toJson());
    expect(restored.coins, 500);
    expect(restored.ownedAnimals.first.quantity, 2);
    expect(restored.ownedAnimals.first.level, 3);
  });

  test('old saves without level default to level 1', () {
    final json = {
      'animalId': 'chicken',
      'quantity': 2,
    };
    final owned = OwnedAnimal.fromJson(json);
    expect(owned.level, 1);
  });

  test('income uses base x quantity x level', () {
    const animal = Animal(
      id: 'chicken',
      name: 'Chicken',
      rarity: Rarity.common,
      coinsPerSecond: 1,
      emoji: '🐔',
    );
    const owned = OwnedAnimal(animalId: 'chicken', quantity: 3, level: 4);
    expect(GameService.incomeFor(animal, owned), 12);
  });

  test('upgrade cost uses base x level x 50', () {
    const animal = Animal(
      id: 'chicken',
      name: 'Chicken',
      rarity: Rarity.common,
      coinsPerSecond: 1,
      emoji: '🐔',
    );
    const owned = OwnedAnimal(animalId: 'chicken', quantity: 1, level: 2);
    expect(GameService.upgradeCostFor(animal, owned), 100);
  });

  test('upgrading increases level and subtracts coins', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    final basicEgg = GameData.eggs.first;
    game.buyEgg(basicEgg);
    game.hatchEgg(basicEgg);

    final animalId = game.ownedAnimals.first.animalId;
    final animal = GameData.animalById(animalId)!;
    final cost = GameService.upgradeCostFor(animal, game.ownedAnimal(animalId)!);

    expect(game.coins, 150);
    final newLevel = game.upgradeAnimal(animalId);

    expect(newLevel, 2);
    expect(game.coins, 150 - cost);
    expect(game.ownedAnimal(animalId)!.level, 2);

    game.dispose();
  });

  test('duplicate hatch increases quantity without resetting level', () async {
    SharedPreferences.setMockInitialValues({});
    // Fixed seed so both hatches pick the same animal.
    final game = GameService(random: Random(1));
    await game.initialize();

    final basicEgg = GameData.eggs.first;
    game.buyEgg(basicEgg);
    final first = game.hatchEgg(basicEgg);
    expect(game.upgradeAnimal(first.id), 2);

    game.buyEgg(basicEgg);
    game.hatchEgg(basicEgg);

    final owned = game.ownedAnimal(first.id)!;
    expect(owned.quantity, 2);
    expect(owned.level, 2);

    game.dispose();
  });
}
