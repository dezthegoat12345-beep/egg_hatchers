import 'dart:math';

import '../models/egg.dart';

/// Weighted animal rolls for built-in eggs only.
class BuiltInEggLogic {
  BuiltInEggLogic._();

  /// Effective weights for [egg], using [animalWeights] or equal fallback.
  static Map<String, int> effectiveWeights(Egg egg) {
    final weights = <String, int>{};
    for (final animalId in egg.possibleAnimalIds) {
      final raw = egg.animalWeights[animalId];
      weights[animalId] = raw != null && raw > 0 ? raw : 1;
    }
    return weights;
  }

  static int totalWeight(Egg egg) {
    return effectiveWeights(egg).values.fold(0, (sum, weight) => sum + weight);
  }

  /// Hatch chance as 0–100 percent from configured weights.
  static double chancePercentForAnimal(Egg egg, String animalId) {
    final weights = effectiveWeights(egg);
    if (!weights.containsKey(animalId)) return 0;
    final total = totalWeight(egg);
    if (total <= 0) return 0;
    return weights[animalId]! / total * 100;
  }

  /// Rounded display percent for shop UI.
  static int roundedChancePercent(Egg egg, String animalId) {
    return chancePercentForAnimal(egg, animalId).round();
  }

  /// Rolls one animal from a built-in egg using configured weights.
  static String rollAnimal(Egg egg, Random random) {
    final weights = effectiveWeights(egg);
    final entries = weights.entries.toList();
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    var roll = random.nextInt(total);

    for (final entry in entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }

    return entries.last.key;
  }
}
