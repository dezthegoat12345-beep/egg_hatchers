import 'package:egg_hatchers/models/egg_mastery_progress.dart';
import 'package:egg_hatchers/models/owned_animal.dart';
import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/utils/egg_mastery_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EggMasteryLogic', () {
    test('mastery levels at expected thresholds', () {
      expect(EggMasteryLogic.masteryLevelForHatchCount(0), 0);
      expect(EggMasteryLogic.masteryLevelForHatchCount(9), 0);
      expect(EggMasteryLogic.masteryLevelForHatchCount(10), 1);
      expect(EggMasteryLogic.masteryLevelForHatchCount(24), 1);
      expect(EggMasteryLogic.masteryLevelForHatchCount(25), 2);
      expect(EggMasteryLogic.masteryLevelForHatchCount(50), 3);
      expect(EggMasteryLogic.masteryLevelForHatchCount(100), 4);
      expect(EggMasteryLogic.masteryLevelForHatchCount(200), 5);
      expect(EggMasteryLogic.masteryLevelForHatchCount(999), 5);
    });

    test('income bonus scales by level', () {
      expect(EggMasteryLogic.incomeBonusPercent(0), 0);
      expect(EggMasteryLogic.incomeBonusPercent(3), 6);
      expect(EggMasteryLogic.incomeBonusPercent(5), 10);
      expect(EggMasteryLogic.applyIncomeBonus(100, 5), 110);
    });

    test('built-in eggs are eligible, custom eggs are not', () {
      expect(EggMasteryLogic.isMasteryEligibleEgg('basic'), isTrue);
      expect(EggMasteryLogic.isMasteryEligibleEgg('boss_egg'), isTrue);
      expect(EggMasteryLogic.isMasteryEligibleEgg('custom_egg_1'), isFalse);
    });
  });

  group('save compatibility', () {
    test('missing eggMastery defaults safely', () {
      final state = PlayerState.fromJson({
        'coins': 250,
        'ownedAnimals': [],
        'lastSavedTime': DateTime.now().toIso8601String(),
      });
      expect(state.eggMastery, isEmpty);
    });

    test('egg mastery normalizes level on load', () {
      final progress = EggMasteryProgress.fromJson({
        'eggId': 'basic',
        'hatchCount': 31,
        'masteryLevel': 0,
      });
      expect(progress.masteryLevel, 2);
    });

    test('owned animal sourceEggId defaults null', () {
      final owned = OwnedAnimal.fromJson({
        'animalId': 'chicken',
        'quantity': 1,
      });
      expect(owned.sourceEggId, isNull);
    });
  });
}
