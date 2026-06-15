import 'dart:math';

/// Special Space Egg rolls for the one-time Secret Hatchery reward only.
class SecretSpaceEggLogic {
  SecretSpaceEggLogic._();

  /// Boosted weights favor rarer Space Egg animals (not used by normal hatching).
  static const Map<String, int> rewardAnimalWeights = {
    'moon_cat': 3,
    'star_fox': 6,
    'alien_slime': 12,
    'galaxy_dragon': 24,
  };

  static const double rewardLuckMultiplier = 3;

  /// Rolls one Space Egg animal using [rewardAnimalWeights].
  static String rollAnimal(Random random) {
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
