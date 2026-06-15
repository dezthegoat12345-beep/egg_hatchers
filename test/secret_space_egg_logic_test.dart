import 'dart:math';

import 'package:egg_hatchers/utils/luck_logic.dart';
import 'package:egg_hatchers/utils/secret_space_egg_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('secret space egg animal roll only returns space egg animals', () {
    final random = Random(42);
    for (var i = 0; i < 50; i++) {
      final animalId = SecretSpaceEggLogic.rollAnimal(random);
      expect(SecretSpaceEggLogic.rewardAnimalWeights.keys, contains(animalId));
    }
  });

  test('boosted luck multiplies player luck for secret reward rolls', () {
    expect(
      LuckLogic.boostedLuckLevel(2, multiplier: SecretSpaceEggLogic.rewardLuckMultiplier),
      6,
    );
    expect(
      LuckLogic.boostedLuckLevel(4, multiplier: SecretSpaceEggLogic.rewardLuckMultiplier),
      LuckLogic.maxLevel,
    );
  });
}
