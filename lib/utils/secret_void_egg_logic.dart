import 'dart:math';

import '../data/game_data.dart';
import 'secret_space_egg_logic.dart';

/// Special Void Egg rolls for the one-time Secret Hatchery reward only.
class SecretVoidEggLogic {
  SecretVoidEggLogic._();

  /// Boosted weights favor rarer Void Egg animals (not used by normal hatching).
  static const Map<String, int> rewardAnimalWeights = {
    'void_mouse': 20,
    'eclipse_wolf': 30,
    'nebula_hydra': 50,
  };

  static const double rewardLuckMultiplier = 3;

  static bool get _hasVoidEgg => GameData.eggById('void') != null;

  /// Rolls one Void Egg animal using [rewardAnimalWeights], or Space Egg fallback.
  static String rollAnimal(Random random) {
    if (!_hasVoidEgg) {
      return SecretSpaceEggLogic.rollAnimal(random);
    }

    final entries = rewardAnimalWeights.entries.toList();
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    var roll = random.nextInt(total);

    for (final entry in entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }

    return entries.last.key;
  }
}
