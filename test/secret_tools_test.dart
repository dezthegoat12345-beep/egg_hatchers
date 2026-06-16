import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('secret void egg reward is one-time and free', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();
    final initialLifetime = game.lifetimeCoinsEarned;
    final initialCoins = game.coins;
    final initialOwned = game.ownedAnimals.length;

    expect(game.secretSpaceEggClaimed, isFalse);

    final result = game.claimSecretVoidEggReward();
    expect(result, isNotNull);
    expect(
      GameData.eggById('void')!.possibleAnimalIds,
      contains(result!.animal.id),
    );
    expect(game.ownedAnimals.length, greaterThanOrEqualTo(initialOwned));
    expect(game.coins, initialCoins);
    expect(game.lifetimeCoinsEarned, initialLifetime);
    expect(game.secretSpaceEggClaimed, isTrue);
    expect(game.claimSecretVoidEggReward(), isNull);

    game.dispose();
  });

  test('old coin-claim saves can still claim secret void egg', () {
    final restored = PlayerState.fromJson({
      'coins': 100,
      'ownedAnimals': <dynamic>[],
      'lastSavedTime': '2025-01-01T00:00:00.000',
      'lifetimeCoinsEarned': 100,
      'secretToolsCoinsClaimed': true,
    });

    expect(restored.secretSpaceEggClaimed, isFalse);
  });

  test('secretSpaceEggClaimed defaults false for older saves', () {
    final restored = PlayerState.fromJson({
      'coins': 100,
      'ownedAnimals': <dynamic>[],
      'lastSavedTime': '2025-01-01T00:00:00.000',
      'lifetimeCoinsEarned': 100,
    });

    expect(restored.secretSpaceEggClaimed, isFalse);
    expect(restored.fullDeveloperToolsUnlocked, isFalse);
  });

  test('secretSpaceEggClaimed round-trips through json', () {
    final state = PlayerState.initial().copyWith(secretSpaceEggClaimed: true);
    final restored = PlayerState.fromJson(state.toJson());
    expect(restored.secretSpaceEggClaimed, isTrue);
  });

  test('fullDeveloperToolsUnlocked is ignored but loads safely from old saves', () {
    final restored = PlayerState.fromJson({
      'coins': 100,
      'ownedAnimals': <dynamic>[],
      'lastSavedTime': '2025-01-01T00:00:00.000',
      'lifetimeCoinsEarned': 100,
      'fullDeveloperToolsUnlocked': true,
    });

    expect(restored.fullDeveloperToolsUnlocked, isTrue);
    final roundTrip = PlayerState.fromJson(restored.toJson());
    expect(roundTrip.fullDeveloperToolsUnlocked, isTrue);
  });
}
