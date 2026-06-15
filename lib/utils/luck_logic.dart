import 'dart:math';

import '../data/game_data.dart';
import '../models/mutation.dart';

/// Luck level upgrades and mutation chance adjustments.
class LuckLogic {
  LuckLogic._();

  static const int minLevel = 1;
  static const int maxLevel = 10;
  static const int weightTotal = 10000;

  static int clampLevel(int level) =>
      level.clamp(minLevel, maxLevel).toInt();

  /// Applies a temporary luck multiplier for one-off bonus rolls (e.g. secret rewards).
  static int boostedLuckLevel(int luckLevel, {required double multiplier}) {
    return clampLevel((luckLevel * multiplier).round());
  }

  /// Cost to upgrade from [currentLevel] to the next level.
  static int upgradeCost(int currentLevel) {
    final level = clampLevel(currentLevel);
    if (level >= maxLevel) return 0;
    return 500 * level * level;
  }

  /// Display percentages (sum to 100) for each mutation at [luckLevel].
  static Map<String, double> mutationPercentages(int luckLevel) {
    final level = clampLevel(luckLevel);
    final bonus = level - 1;
    return {
      'none': 70.0 - 3.0 * bonus,
      'golden': 20.0 + 2.0 * bonus,
      'rainbow': 8.0 + 0.75 * bonus,
      'shadow': 2.0 + 0.25 * bonus,
    };
  }

  /// Integer weights out of 10,000 for weighted random rolls.
  static Map<String, int> mutationWeights(int luckLevel) {
    final percentages = mutationPercentages(luckLevel);
    final ids = ['none', 'golden', 'rainbow', 'shadow'];
    final weights = <String, int>{};

    for (final id in ids) {
      weights[id] = (percentages[id]! * 100).round();
    }

    var sum = weights.values.fold<int>(0, (total, w) => total + w);
    if (sum != weightTotal) {
      weights['none'] = weights['none']! + (weightTotal - sum);
    }

    return weights;
  }

  static int totalWeight(int luckLevel) {
    final weights = mutationWeights(luckLevel);
    return weights.values.fold<int>(0, (sum, w) => sum + w);
  }

  /// Roll a mutation using luck-adjusted chances.
  static Mutation rollMutation(Random random, int luckLevel) {
    final weights = mutationWeights(luckLevel);
    final total = weightTotal;
    final roll = random.nextInt(total);
    var cumulative = 0;

    for (final mutation in GameData.mutations) {
      cumulative += weights[mutation.id] ?? 0;
      if (roll < cumulative) return mutation;
    }

    return GameData.mutations.first;
  }
}
