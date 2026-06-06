import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/custom_egg.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/utils/custom_egg_logic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('old custom eggs without weights default to weight 1', () {
    final json = jsonEncode([
      {
        'id': 'custom_123',
        'name': 'Legacy Egg',
        'emoji': '🥚',
        'cost': 1000,
        'selectedAnimalIds': ['chicken', 'rabbit'],
        'isEnabled': true,
      },
    ]);

    final eggs = CustomEgg.listFromJsonString(json);
    expect(eggs, hasLength(1));

    final egg = eggs.first;
    expect(CustomEggLogic.effectiveWeights(egg), {'chicken': 1, 'rabbit': 1});
    expect(CustomEggLogic.chancePercentForAnimal(egg, 'chicken'), 50);
    expect(CustomEggLogic.chancePercentForAnimal(egg, 'rabbit'), 50);
  });

  test('weighted chances calculate percentages correctly', () {
    const egg = CustomEgg(
      id: 'custom_test',
      name: 'Weighted',
      emoji: '🥚',
      cost: 1000,
      selectedAnimalIds: ['chicken', 'rabbit', 'dragon'],
      animalWeights: {
        'chicken': 6,
        'rabbit': 3,
        'dragon': 1,
      },
    );

    expect(CustomEggLogic.chancePercentForAnimal(egg, 'chicken'), 60);
    expect(CustomEggLogic.chancePercentForAnimal(egg, 'rabbit'), 30);
    expect(CustomEggLogic.chancePercentForAnimal(egg, 'dragon'), 10);
  });

  test('minimum cost is higher for late-game animals', () {
    const chickenOnly = CustomEgg(
      id: 'custom_a',
      name: 'A',
      emoji: '🥚',
      cost: 100,
      selectedAnimalIds: ['chicken'],
      animalWeights: {'chicken': 1},
    );

    const galaxyOnly = CustomEgg(
      id: 'custom_b',
      name: 'B',
      emoji: '🥚',
      cost: 100,
      selectedAnimalIds: ['galaxy_dragon'],
      animalWeights: {'galaxy_dragon': 1},
    );

    final chickenMin = CustomEggLogic.minimumCostForCustomEgg(chickenOnly);
    final galaxyMin = CustomEggLogic.minimumCostForCustomEgg(galaxyOnly);

    expect(chickenMin, greaterThan(0));
    expect(galaxyMin, greaterThan(chickenMin));
    expect(galaxyMin, greaterThan(100000));
  });

  test('weighted mix prices mostly common animal with rare tail', () {
    const mixed = CustomEgg(
      id: 'custom_mix',
      name: 'Mix',
      emoji: '🥚',
      cost: 100,
      selectedAnimalIds: ['chicken', 'galaxy_dragon'],
      animalWeights: {
        'chicken': 9,
        'galaxy_dragon': 1,
      },
    );

    final mixedMin = CustomEggLogic.minimumCostForCustomEgg(mixed);
    const chickenOnly = CustomEgg(
      id: 'custom_c',
      name: 'C',
      emoji: '🥚',
      cost: 100,
      selectedAnimalIds: ['chicken'],
      animalWeights: {'chicken': 1},
    );
    final chickenMin = CustomEggLogic.minimumCostForCustomEgg(chickenOnly);

    expect(mixedMin, greaterThan(chickenMin));
    expect(mixedMin, lessThan(CustomEggLogic.minimumCostForCustomEgg(
      const CustomEgg(
        id: 'custom_d',
        name: 'D',
        emoji: '🥚',
        cost: 100,
        selectedAnimalIds: ['galaxy_dragon'],
        animalWeights: {'galaxy_dragon': 1},
      ),
    )));
  });

  test('weighted random favors higher weights', () {
    const egg = CustomEgg(
      id: 'custom_weighted',
      name: 'W',
      emoji: '🥚',
      cost: 1000,
      selectedAnimalIds: ['chicken', 'dragon'],
      animalWeights: {
        'chicken': 99,
        'dragon': 1,
      },
    );

    final random = Random(7);
    var chickenHits = 0;
    for (var i = 0; i < 200; i++) {
      if (CustomEggLogic.weightedRandomAnimal(egg, random) == 'chicken') {
        chickenHits++;
      }
    }
    expect(chickenHits, greaterThan(150));
  });

  test('forced hatch overrides custom egg weighted result', () async {
    SharedPreferences.setMockInitialValues({});
    const customEgg = CustomEgg(
      id: 'custom_force',
      name: 'Force Test',
      emoji: '🥚',
      cost: 1000,
      selectedAnimalIds: ['chicken'],
      animalWeights: {'chicken': 1},
    );
    final egg = customEgg.toEgg();
    final game = GameService(random: Random(1));
    await game.initialize();

    game.setForcedNextHatch('dragon', 'none');
    game.buyEgg(egg);
    final result = game.hatchEgg(egg, customEgg: customEgg);

    expect(result.animal.id, 'dragon');
    expect(game.hasForcedNextHatch, isFalse);
    game.dispose();
  });

  test('built-in egg hatching is unchanged', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(2));
    await game.initialize();

    final basicEgg = GameData.eggs.first;
    game.buyEgg(basicEgg);
    final result = game.hatchEgg(basicEgg);

    expect(basicEgg.possibleAnimalIds, contains(result.animal.id));
    game.dispose();
  });

  test('findSourceEggForAnimal uses cheapest built-in egg', () {
    final chickenSource = CustomEggLogic.findSourceEggForAnimal('chicken');
    expect(chickenSource?.id, 'basic');

    final galaxySource = CustomEggLogic.findSourceEggForAnimal('galaxy_dragon');
    expect(galaxySource?.id, 'space');
  });
}
