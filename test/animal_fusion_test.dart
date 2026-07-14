import 'dart:math';

import 'package:egg_hatchers/models/owned_animal.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/utils/animal_fusion_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnimalFusionLogic', () {
    test('resolveResultMutation advances one step by default', () {
      expect(
        AnimalFusionLogic.resolveResultMutation('none', _fixedRandom(0.5)),
        'golden',
      );
      expect(
        AnimalFusionLogic.resolveResultMutation('golden', _fixedRandom(0.5)),
        'rainbow',
      );
      expect(
        AnimalFusionLogic.resolveResultMutation('rainbow', _fixedRandom(0.5)),
        'shadow',
      );
    });

    test('resolveResultMutation can lucky jump two steps', () {
      expect(
        AnimalFusionLogic.resolveResultMutation('none', _fixedRandom(0.05)),
        'rainbow',
      );
      expect(
        AnimalFusionLogic.wasLuckyFusion('none', 'rainbow'),
        isTrue,
      );
    });

    test('rainbow lucky jump still caps at shadow', () {
      expect(
        AnimalFusionLogic.resolveResultMutation('rainbow', _fixedRandom(0.05)),
        'shadow',
      );
      expect(
        AnimalFusionLogic.wasLuckyFusion('rainbow', 'shadow'),
        isFalse,
      );
    });

    test('chanceDescription matches ladder', () {
      expect(
        AnimalFusionLogic.chanceDescription('none'),
        '90% Golden, 10% Rainbow',
      );
      expect(
        AnimalFusionLogic.chanceDescription('golden'),
        '90% Rainbow, 10% Shadow',
      );
      expect(
        AnimalFusionLogic.chanceDescription('rainbow'),
        '100% Shadow',
      );
    });

    test('protected and boss stacks cannot fuse', () {
      const protectedStack = OwnedAnimal(
        animalId: 'chicken',
        quantity: 5,
        mutationId: 'none',
        isProtected: true,
        isSecretReward: true,
      );
      expect(
        AnimalFusionLogic.canFuseStack(protectedStack, inBattle: false),
        isFalse,
      );

      const bossStack = OwnedAnimal(
        animalId: 'chicken',
        quantity: 5,
        mutationId: 'boss',
      );
      expect(
        AnimalFusionLogic.canFuseStack(bossStack, inBattle: false),
        isFalse,
      );

      const shadowStack = OwnedAnimal(
        animalId: 'chicken',
        quantity: 5,
        mutationId: 'shadow',
      );
      expect(
        AnimalFusionLogic.canFuseStack(shadowStack, inBattle: false),
        isFalse,
      );
    });
  });

  group('GameService fuseAnimals', () {
    late GameService game;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      game = GameService();
      await game.initialize();
      game.devSetOwnedAnimalsForTesting(const [
        OwnedAnimal(animalId: 'chicken', quantity: 3, mutationId: 'none'),
      ]);
    });

    tearDown(() {
      game.dispose();
    });

    test('consumes 3 normal chickens and creates golden chicken', () {
      final source = game.ownedAnimals.first;
      final outcome = game.fuseAnimals(source, random: _fixedRandom(0.5));

      expect(outcome, isNotNull);
      expect(outcome!.resultMutationId, 'golden');
      expect(outcome.wasLucky, isFalse);
      expect(game.ownedAnimals, hasLength(1));
      expect(game.ownedAnimals.first.mutationId, 'golden');
      expect(game.ownedAnimals.first.quantity, 1);
    });

    test('lucky fusion creates rainbow from 3 normal', () {
      game.devSetOwnedAnimalsForTesting(const [
        OwnedAnimal(animalId: 'chicken', quantity: 3, mutationId: 'none'),
      ]);
      final outcome = game.fuseAnimals(
        game.ownedAnimals.first,
        random: _fixedRandom(0.05),
      );

      expect(outcome?.resultMutationId, 'rainbow');
      expect(outcome?.wasLucky, isTrue);
    });

    test('merges into existing output stack', () {
      game.devSetOwnedAnimalsForTesting(const [
        OwnedAnimal(animalId: 'chicken', quantity: 3, mutationId: 'none'),
        OwnedAnimal(animalId: 'chicken', quantity: 2, mutationId: 'golden'),
      ]);

      game.fuseAnimals(game.ownedAnimals.first, random: _fixedRandom(0.5));

      final golden = game.ownedAnimal('chicken', mutationId: 'golden');
      expect(golden?.quantity, 3);
    });
  });
}

/// Returns a Random whose first double is [value] in [0, 1).
Random _fixedRandom(double value) {
  return _SeededRandom(value);
}

class _SeededRandom implements Random {
  _SeededRandom(this._next);

  final double _next;
  var _used = false;

  @override
  int nextInt(int max) => (nextDouble() * max).floor();

  @override
  double nextDouble() {
    if (!_used) {
      _used = true;
      return _next;
    }
    return 0.5;
  }

  @override
  bool nextBool() => nextDouble() < 0.5;
}
