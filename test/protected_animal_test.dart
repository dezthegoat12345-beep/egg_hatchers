import 'package:egg_hatchers/models/owned_animal.dart';
import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('secret space egg reward marks animal as protected', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    final result = game.claimSecretSpaceEggReward();
    expect(result, isNotNull);

    final protected = game.ownedAnimals.where((owned) => owned.isProtected);
    expect(protected.length, 1);
    expect(protected.first.animalId, result!.animal.id);
    expect(protected.first.mutationId, result.mutation.id);

    game.dispose();
  });

  test('protected animals cannot be sold', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.devSetOwnedAnimalsForTesting(const [
      OwnedAnimal(
        animalId: 'galaxy_dragon',
        quantity: 1,
        level: 2,
        mutationId: 'shadow',
        isProtected: true,
      ),
      OwnedAnimal(
        animalId: 'chicken',
        quantity: 1,
        mutationId: 'none',
      ),
    ]);

    final coinsBefore = game.coins;
    expect(
      game.sellOwnedAnimal('galaxy_dragon', 'shadow', isProtected: true),
      isNull,
    );
    expect(game.ownedAnimals.length, 2);
    expect(game.coins, coinsBefore);

    final sold = game.sellOwnedAnimal('chicken', 'none');
    expect(sold, isNotNull);
    expect(game.ownedAnimals.length, 1);
    expect(game.ownedAnimals.first.isProtected, isTrue);

    game.dispose();
  });

  test('rebirth preserves protected animals only', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.devSetOwnedAnimalsForTesting(const [
      OwnedAnimal(
        animalId: 'alien_slime',
        quantity: 1,
        level: 3,
        mutationId: 'golden',
        isProtected: true,
      ),
      OwnedAnimal(animalId: 'chicken', quantity: 5, mutationId: 'none'),
    ]);
    game.setLifetimeCoinsEarned(1000000);

    expect(game.performRebirth(), isTrue);
    expect(game.ownedAnimals.length, 1);
    expect(game.ownedAnimals.first.animalId, 'alien_slime');
    expect(game.ownedAnimals.first.mutationId, 'golden');
    expect(game.ownedAnimals.first.level, 3);
    expect(game.ownedAnimals.first.isProtected, isTrue);
    expect(game.coins, 250);
    expect(game.lifetimeCoinsEarned, 0);
    expect(game.luckLevel, 1);

    game.dispose();
  });

  test('isProtected defaults false for older owned animal saves', () {
    final restored = OwnedAnimal.fromJson({
      'animalId': 'chicken',
      'quantity': 2,
      'level': 1,
      'mutationId': 'none',
    });
    expect(restored.isProtected, isFalse);
  });

  test('isProtected round-trips through player state json', () {
    final state = PlayerState.initial().copyWith(
      ownedAnimals: const [
        OwnedAnimal(
          animalId: 'moon_cat',
          quantity: 1,
          mutationId: 'rainbow',
          isProtected: true,
        ),
      ],
    );
    final restored = PlayerState.fromJson(state.toJson());
    expect(restored.ownedAnimals.first.isProtected, isTrue);
  });
}
