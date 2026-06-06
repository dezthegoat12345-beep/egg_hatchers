import 'dart:math';

import '../data/game_data.dart';
import '../models/custom_egg.dart';
import '../models/egg.dart';

/// Pricing, weighting, and hatch helpers for player-created custom eggs.
class CustomEggLogic {
  CustomEggLogic._();

  static const double flexibilityMultiplier = 1.25;
  static const int minWeight = 1;
  static const int maxWeight = 100;

  /// Cheapest built-in egg that can hatch [animalId].
  static Egg? findSourceEggForAnimal(String animalId) {
    Egg? cheapest;
    for (final egg in GameData.eggs) {
      if (!egg.possibleAnimalIds.contains(animalId)) continue;
      if (cheapest == null || egg.cost < cheapest.cost) {
        cheapest = egg;
      }
    }
    return cheapest;
  }

  /// Normalized weights for valid selected animals (1–100, default 1).
  static Map<String, int> effectiveWeights(CustomEgg egg) {
    final weights = <String, int>{};
    for (final id in egg.validAnimalIds) {
      final raw = egg.animalWeights[id] ?? 1;
      weights[id] = raw.clamp(minWeight, maxWeight);
    }
    return weights;
  }

  static int totalWeight(CustomEgg egg) {
    return effectiveWeights(egg).values.fold(0, (sum, w) => sum + w);
  }

  /// Hatch chance as 0–100 percent.
  static double chancePercentForAnimal(CustomEgg egg, String animalId) {
    final weights = effectiveWeights(egg);
    if (!weights.containsKey(animalId)) return 0;
    final total = totalWeight(egg);
    if (total <= 0) return 0;
    return weights[animalId]! / total * 100;
  }

  static int minimumCostForCustomEgg(CustomEgg egg) {
    if (egg.validAnimalIds.isEmpty) return 1;

    var sum = 0.0;
    final weights = effectiveWeights(egg);
    final total = totalWeight(egg);
    if (total <= 0) return 1;

    for (final animalId in egg.validAnimalIds) {
      final sourceEgg = findSourceEggForAnimal(animalId);
      if (sourceEgg == null) continue;

      final baseContribution =
          sourceEgg.cost / sourceEgg.possibleAnimalIds.length;
      final chance = weights[animalId]! / total;
      sum += baseContribution * chance;
    }

    return roundCleanCost(sum * flexibilityMultiplier);
  }

  /// Rounds up to a clean coin value by tier.
  static int roundCleanCost(double value) {
    final v = value.ceil();
    if (v < 1000) return ((v + 9) ~/ 10) * 10;
    if (v < 100000) return ((v + 99) ~/ 100) * 100;
    return ((v + 999) ~/ 1000) * 1000;
  }

  /// Picks an animal id using weighted random selection.
  static String weightedRandomAnimal(CustomEgg egg, Random random) {
    final weights = effectiveWeights(egg);
    final ids = egg.validAnimalIds;
    if (ids.isEmpty) {
      throw StateError('Custom egg has no valid animals');
    }
    if (ids.length == 1) return ids.first;

    final total = totalWeight(egg);
    var roll = random.nextInt(total);
    for (final id in ids) {
      roll -= weights[id]!;
      if (roll < 0) return id;
    }
    return ids.last;
  }

  /// Short summary for shop cards, e.g. "Chicken 60% · Rabbit 30%".
  static String formatChanceSummary(CustomEgg egg, {int maxEntries = 3}) {
    final ids = List<String>.from(egg.validAnimalIds)
      ..sort(
        (a, b) => chancePercentForAnimal(egg, b)
            .compareTo(chancePercentForAnimal(egg, a)),
      );

    final parts = <String>[];
    for (final id in ids.take(maxEntries)) {
      final animal = GameData.animalById(id);
      if (animal == null) continue;
      final pct = chancePercentForAnimal(egg, id).round();
      parts.add('${animal.name} $pct%');
    }

    if (ids.length > maxEntries) {
      parts.add('…');
    }
    return parts.join(' · ');
  }

  static bool isCustomEggId(String id) => id.startsWith(CustomEgg.idPrefix);
}
