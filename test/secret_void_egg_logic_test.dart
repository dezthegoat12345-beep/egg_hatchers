import 'dart:math';

import 'package:egg_hatchers/utils/luck_logic.dart';
import 'package:egg_hatchers/utils/secret_void_egg_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('secret void egg animal roll only returns void egg animals', () {
    final random = Random(42);
    for (var i = 0; i < 50; i++) {
      final animalId = SecretVoidEggLogic.rollAnimal(random);
      expect(SecretVoidEggLogic.rewardAnimalWeights.keys, contains(animalId));
    }
  });

  test('boosted luck multiplies player luck for secret void reward rolls', () {
    expect(
      LuckLogic.boostedLuckLevel(
        2,
        multiplier: SecretVoidEggLogic.rewardLuckMultiplier,
      ),
      6,
    );
    expect(
      LuckLogic.boostedLuckLevel(
        4,
        multiplier: SecretVoidEggLogic.rewardLuckMultiplier,
      ),
      LuckLogic.maxLevel,
    );
  });
}
