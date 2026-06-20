import '../data/game_data.dart';
import '../models/egg_mastery_progress.dart';
import 'custom_egg_logic.dart';

/// Egg Mastery thresholds, bonuses, and helpers.
class EggMasteryLogic {
  EggMasteryLogic._();

  static const maxLevel = 5;
  static const thresholds = [10, 25, 50, 100, 200];
  static const incomeBonusPerLevel = 0.02;

  static bool isMasteryEligibleEgg(String? eggId) {
    if (eggId == null || eggId.isEmpty) return false;
    if (CustomEggLogic.isCustomEggId(eggId)) return false;
    return GameData.eggById(eggId) != null;
  }

  static int masteryLevelForHatchCount(int hatchCount) {
    final count = hatchCount < 0 ? 0 : hatchCount;
    var level = 0;
    for (final threshold in thresholds) {
      if (count >= threshold) {
        level++;
      }
    }
    return level.clamp(0, maxLevel);
  }

  static int? nextThresholdForLevel(int level) {
    if (level >= maxLevel) return null;
    return thresholds[level.clamp(0, maxLevel - 1)];
  }

  static int incomeBonusPercent(int masteryLevel) {
    return masteryLevel.clamp(0, maxLevel) * 2;
  }

  static double incomeMultiplier(int masteryLevel) {
    return 1 + masteryLevel.clamp(0, maxLevel) * incomeBonusPerLevel;
  }

  static int applyIncomeBonus(int baseIncome, int masteryLevel) {
    if (baseIncome <= 0 || masteryLevel <= 0) return baseIncome;
    return (baseIncome * incomeMultiplier(masteryLevel)).round();
  }

  static String progressLabel(EggMasteryProgress progress) {
    if (progress.masteryLevel >= maxLevel) {
      return 'Max Mastery';
    }
    final next = nextThresholdForLevel(progress.masteryLevel);
    return 'Hatches: ${progress.hatchCount} / $next';
  }

  static String levelUpMessage(String eggName, int level) {
    return '$eggName Mastery Level $level!';
  }

  static Map<String, EggMasteryProgress> normalizeMap(
    Map<String, EggMasteryProgress> raw,
  ) {
    return {
      for (final entry in raw.entries)
        entry.key: entry.value.normalized(),
    };
  }
}
