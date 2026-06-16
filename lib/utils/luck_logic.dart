import 'dart:math';

import '../data/game_data.dart';
import '../models/mutation.dart';

/// Luck level upgrades and mutation chance adjustments.
class LuckLogic {
  LuckLogic._();

  static const int minLevel = 1;
  static const int maxLevel = 10;
  static const int weightTotal = 10000;

  static const double _bossBaseChance = 0.5;
  static const double _bossLuckStep = 0.08;
  static const double _bossMaxChance = 1.5;

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

  static double bossChancePercent(int luckLevel) {
    final bonus = clampLevel(luckLevel) - 1;
    final chance = _bossBaseChance + bonus * _bossLuckStep;
    return chance > _bossMaxChance ? _bossMaxChance : chance;
  }

  /// Display percentages (sum to 100) for each mutation at [luckLevel].
  static Map<String, double> mutationPercentages(
    int luckLevel, {
    bool bossMutationUnlocked = false,
  }) {
    final level = clampLevel(luckLevel);
    final bonus = level - 1;
    var none = 70.0 - 3.0 * bonus;
    final golden = 20.0 + 2.0 * bonus;
    final rainbow = 8.0 + 0.75 * bonus;
    final shadow = 2.0 + 0.25 * bonus;
    final result = <String, double>{
      'none': none,
      'golden': golden,
      'rainbow': rainbow,
      'shadow': shadow,
    };
    if (bossMutationUnlocked) {
      final boss = bossChancePercent(level);
      result['boss'] = boss;
      result['none'] = none - boss;
    }
    return result;
  }

  /// Integer weights out of 10,000 for weighted random rolls.
  static Map<String, int> mutationWeights(
    int luckLevel, {
    bool bossMutationUnlocked = false,
  }) {
    final percentages = mutationPercentages(
      luckLevel,
      bossMutationUnlocked: bossMutationUnlocked,
    );
    final ids = bossMutationUnlocked
        ? ['none', 'golden', 'rainbow', 'shadow', 'boss']
        : ['none', 'golden', 'rainbow', 'shadow'];
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

  static int totalWeight(int luckLevel, {bool bossMutationUnlocked = false}) {
    final weights = mutationWeights(
      luckLevel,
      bossMutationUnlocked: bossMutationUnlocked,
    );
    return weights.values.fold<int>(0, (sum, w) => sum + w);
  }

  /// Roll a mutation using luck-adjusted chances.
  static Mutation rollMutation(
    Random random,
    int luckLevel, {
    bool bossMutationUnlocked = false,
  }) {
    final weights = mutationWeights(
      luckLevel,
      bossMutationUnlocked: bossMutationUnlocked,
    );
    final total = weightTotal;
    final roll = random.nextInt(total);
    var cumulative = 0;

    for (final mutation in GameData.mutations) {
      if (mutation.id == 'boss' && !bossMutationUnlocked) continue;
      cumulative += weights[mutation.id] ?? 0;
      if (roll < cumulative) return mutation;
    }

    return GameData.mutations.first;
  }
}
