import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('secret tools coin reward is one-time and skips lifetime earnings', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService();
    await game.initialize();
    final initialLifetime = game.lifetimeCoinsEarned;
    final initialCoins = game.coins;

    expect(game.secretToolsCoinsClaimed, isFalse);

    final granted = game.claimSecretToolsCoins();
    expect(granted, GameService.secretToolsCoinReward);
    expect(game.coins, initialCoins + GameService.secretToolsCoinReward);
    expect(game.lifetimeCoinsEarned, initialLifetime);
    expect(game.secretToolsCoinsClaimed, isTrue);

    expect(game.claimSecretToolsCoins(), isNull);
    expect(game.coins, initialCoins + GameService.secretToolsCoinReward);

    game.dispose();
  });

  test('secretToolsCoinsClaimed defaults false for older saves', () {
    final restored = PlayerState.fromJson({
      'coins': 100,
      'ownedAnimals': <dynamic>[],
      'lastSavedTime': '2025-01-01T00:00:00.000',
      'lifetimeCoinsEarned': 100,
    });

    expect(restored.secretToolsCoinsClaimed, isFalse);
  });

  test('secretToolsCoinsClaimed round-trips through json', () {
    final state = PlayerState.initial().copyWith(secretToolsCoinsClaimed: true);
    final restored = PlayerState.fromJson(state.toJson());
    expect(restored.secretToolsCoinsClaimed, isTrue);
  });
}
