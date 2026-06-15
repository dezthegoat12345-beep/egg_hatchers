import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/owned_animal.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/utils/animal_sell_logic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sell value uses base, mutation, and level multipliers', () {
    final chicken = GameData.animalById('chicken')!;
    final normal = const OwnedAnimal(animalId: 'chicken', quantity: 3, level: 2);
    final golden = const OwnedAnimal(
      animalId: 'chicken',
      quantity: 1,
      level: 1,
      mutationId: 'golden',
    );
    final shadowDragon = const OwnedAnimal(
      animalId: 'dragon',
      quantity: 1,
      level: 3,
      mutationId: 'shadow',
    );

    expect(AnimalSellLogic.sellValueFor(chicken, normal), 40);
    expect(AnimalSellLogic.sellValueFor(chicken, golden), 40);
    expect(
      AnimalSellLogic.sellValueFor(GameData.animalById('dragon')!, shadowDragon),
      60000,
    );
  });

  test('minimum sell value is 10 coins', () {
    final chicken = GameData.animalById('chicken')!;
    const owned = OwnedAnimal(animalId: 'chicken', quantity: 1, level: 1);
    expect(AnimalSellLogic.sellValueFor(chicken, owned), greaterThanOrEqualTo(10));
  });

  test('selling one animal adds coins without lifetime earnings', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();

    game.setCoins(100);

    game.devCollectAllAnimals();
    final coinsBefore = game.coins;
    final lifetime = game.lifetimeCoinsEarned;

    final reward = game.sellOwnedAnimal('chicken', 'none', quantity: 1);
    expect(reward, isNotNull);
    expect(game.coins, coinsBefore + reward!);
    expect(game.lifetimeCoinsEarned, lifetime);
    expect(game.ownedAnimal('chicken', mutationId: 'none'), isNull);
  });

  test('selling last animal removes stack', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();
    game.devCollectAllAnimals();

    final reward = game.sellOwnedAnimal('mouse', 'none', quantity: 1);
    expect(reward, isNotNull);
    expect(game.ownedAnimal('mouse', mutationId: 'none'), isNull);
  });

  test('cannot sell more than owned quantity', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();
    game.devCollectAllAnimals();

    expect(game.sellOwnedAnimal('rabbit', 'none', quantity: 2), isNull);
    expect(game.ownedAnimal('rabbit')?.quantity, 1);
  });
}
