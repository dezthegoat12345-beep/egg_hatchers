import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/utils/battle_upgrade_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('BattleUpgradeLogic', () {
    test('homing upgrade costs scale with level squared', () {
      expect(BattleUpgradeLogic.homingUpgradeCost(0), 15);
      expect(BattleUpgradeLogic.homingUpgradeCost(1), 60);
      expect(BattleUpgradeLogic.homingUpgradeCost(2), 135);
      expect(BattleUpgradeLogic.homingUpgradeCost(9), 1500);
      expect(BattleUpgradeLogic.homingUpgradeCost(10), 0);
    });

    test('shot speed upgrade costs scale with level squared', () {
      expect(BattleUpgradeLogic.shotSpeedUpgradeCost(0), 12);
      expect(BattleUpgradeLogic.shotSpeedUpgradeCost(1), 48);
      expect(BattleUpgradeLogic.shotSpeedUpgradeCost(2), 108);
      expect(BattleUpgradeLogic.shotSpeedUpgradeCost(9), 1200);
      expect(BattleUpgradeLogic.shotSpeedUpgradeCost(10), 0);
    });

    test('level 0 manual battle uses base egg tuning', () {
      expect(
        BattleUpgradeLogic.manualEggSpeed(0),
        BattleUpgradeLogic.baseEggSpeed,
      );
      expect(
        BattleUpgradeLogic.manualEggHomingLerp(0),
        BattleUpgradeLogic.baseEggHomingLerp,
      );
      expect(
        BattleUpgradeLogic.manualEggMaxHomingSpeed(0),
        BattleUpgradeLogic.baseEggMaxHomingSpeed,
      );
    });

    test('homing and speed scale with level and cap at max', () {
      expect(
        BattleUpgradeLogic.manualEggHomingLerp(10),
        closeTo(BattleUpgradeLogic.baseEggHomingLerp * 1.8, 0.0001),
      );
      expect(
        BattleUpgradeLogic.manualEggMaxHomingSpeed(10),
        closeTo(BattleUpgradeLogic.baseEggMaxHomingSpeed * 1.8, 0.0001),
      );
      expect(
        BattleUpgradeLogic.manualEggSpeed(10),
        closeTo(BattleUpgradeLogic.baseEggSpeed * 1.6, 0.0001),
      );
    });
  });

  group('PlayerState battle upgrade persistence', () {
    test('old saves default battle upgrade levels to 0', () {
      final restored = PlayerState.fromJson({
        'coins': 100,
        'ownedAnimals': [],
        'lastSavedTime': DateTime.now().toIso8601String(),
        'lifetimeCoinsEarned': 100,
      });

      expect(restored.battleHomingLevel, 0);
      expect(restored.battleShotSpeedLevel, 0);
    });

    test('battle upgrade levels round-trip and clamp', () {
      final state = PlayerState.initial().copyWith(
        battleHomingLevel: 12,
        battleShotSpeedLevel: -3,
      );
      final restored = PlayerState.fromJson(state.toJson());

      expect(restored.battleHomingLevel, 10);
      expect(restored.battleShotSpeedLevel, 0);
    });
  });

  group('GameService battle upgrades', () {
    test('upgradeBattleHoming spends tokens and increments level', () {
      SharedPreferences.setMockInitialValues({});
      final game = GameService();
      game.devAddBattleTokens(5000);

      expect(game.battleHomingLevel, 0);
      expect(game.battleHomingUpgradeCost(), 15);

      expect(game.upgradeBattleHoming(), isTrue);
      expect(game.battleHomingLevel, 1);
      expect(game.battleTokens, 4985);
    });

    test('upgradeBattleShotSpeed refuses without enough tokens', () {
      final game = GameService();

      expect(game.upgradeBattleShotSpeed(), isFalse);
      expect(game.battleShotSpeedLevel, 0);
      expect(game.battleTokens, 0);
    });

    test('upgradeBattleHoming refuses at max level', () {
      SharedPreferences.setMockInitialValues({});
      final game = GameService();
      game.devAddBattleTokens(99999);
      game.devMaxBattleUpgrades();

      expect(game.upgradeBattleHoming(), isFalse);
      expect(game.battleHomingLevel, BattleUpgradeLogic.maxLevel);
    });
  });
}
