import '../models/player_state.dart';
import 'battle_upgrade_logic.dart';

/// Egg Shard currency, endgame boss gates, and limit-break upgrades.
class EggShardLogic {
  EggShardLogic._();

  static const rottenShellBossId = 'rotten_shell';
  static const rottenShellEggShardReward = 3;

  /// Every boss that must be defeated at least once before The Rotten Shell.
  static const prerequisiteBossIds = [
    'slime_boss',
    'egg_golem',
    'shadow_rooster',
    'slime_king',
    'egg_guardian',
    'shadow_phoenix',
  ];

  static const battleLimitBreakMaxLevel = 2;
  static const battleLimitBreakCosts = [5, 10];
  static const extraLifeLimitBreakMaxLevel = 1;
  static const extraLifeLimitBreakCost = 12;
  static const eggRebirthReductionMaxLevel = 3;
  static const eggRebirthReductionCosts = [8, 15, 25];
  static const customSpriteCanvasMaxLevel = 1;
  static const customSpriteCanvasCost = 10;

  static int homingMaxLevel(int battleLimitBreakLevel) =>
      BattleUpgradeLogic.maxLevel + clampBattleLimitBreak(battleLimitBreakLevel) * 2;

  static int shotSpeedMaxLevel(int battleLimitBreakLevel) =>
      BattleUpgradeLogic.maxLevel + clampBattleLimitBreak(battleLimitBreakLevel) * 2;

  static int extraLifeMaxLevel(int extraLifeLimitBreakLevel) =>
      BattleUpgradeLogic.extraLifeMaxLevel +
      clampExtraLifeLimitBreak(extraLifeLimitBreakLevel);

  static int clampBattleLimitBreak(int level) =>
      level.clamp(0, battleLimitBreakMaxLevel).toInt();

  static int clampExtraLifeLimitBreak(int level) =>
      level.clamp(0, extraLifeLimitBreakMaxLevel).toInt();

  static int clampEggRebirthReduction(int level) =>
      level.clamp(0, eggRebirthReductionMaxLevel).toInt();

  static int clampCustomSpriteCanvas(int level) =>
      level.clamp(0, customSpriteCanvasMaxLevel).toInt();

  static int clampHomingLevel(int level, int battleLimitBreakLevel) =>
      level.clamp(0, homingMaxLevel(battleLimitBreakLevel)).toInt();

  static int clampShotSpeedLevel(int level, int battleLimitBreakLevel) =>
      level.clamp(0, shotSpeedMaxLevel(battleLimitBreakLevel)).toInt();

  static int clampExtraLifeLevel(int level, int extraLifeLimitBreakLevel) =>
      level.clamp(0, extraLifeMaxLevel(extraLifeLimitBreakLevel)).toInt();

  static int battleLimitBreakCost(int currentLevel) {
    if (currentLevel >= battleLimitBreakMaxLevel) return 0;
    return battleLimitBreakCosts[currentLevel];
  }

  static int eggRebirthReductionCost(int currentLevel) {
    if (currentLevel >= eggRebirthReductionMaxLevel) return 0;
    return eggRebirthReductionCosts[currentLevel];
  }

  static int effectiveRebirthRequirement(int baseRequirement, int reductionLevel) {
    if (baseRequirement <= 0) return 0;
    return (baseRequirement - clampEggRebirthReduction(reductionLevel))
        .clamp(0, baseRequirement);
  }

  static int maxCustomSpriteGridSize(int canvasTier) =>
      canvasTier >= 1 ? CustomSpriteGridSizes.expanded : CustomSpriteGridSizes.standard;

  static int defeatedPrerequisiteCount(PlayerState state) {
    var count = 0;
    for (final id in prerequisiteBossIds) {
      if ((state.bossWins[id] ?? 0) > 0) count++;
    }
    return count;
  }

  static bool hasDefeatedAllPrerequisiteBosses(PlayerState state) =>
      defeatedPrerequisiteCount(state) >= prerequisiteBossIds.length;

  static bool isRottenShellUnlocked(PlayerState state) =>
      hasDefeatedAllPrerequisiteBosses(state) && state.shadowPhoenixFlawlessWin;
}

/// Supported custom sprite editor grid sizes.
class CustomSpriteGridSizes {
  CustomSpriteGridSizes._();

  static const standard = 16;
  static const expanded = 24;
}
