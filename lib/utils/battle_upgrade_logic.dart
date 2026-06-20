/// Battle Token upgrades for Manual Battle egg homing, shot speed, and lives.
class BattleUpgradeLogic {
  BattleUpgradeLogic._();

  static const int minLevel = 0;
  static const int maxLevel = 10;
  static const int extraLifeMaxLevel = 3;
  static const int baseManualBattleLives = 3;

  static const double baseEggSpeed = 550.0;
  static const double baseEggHomingLerp = 0.04;
  static const double baseEggMaxHomingSpeed = 110.0;

  static const double _homingBonusPerLevel = 0.08;
  static const double _homingMaxMultiplier = 2.0;
  static const double _speedBonusPerLevel = 0.06;
  static const double _speedMaxMultiplier = 1.75;

  static int clampLevel(int level) =>
      level.clamp(minLevel, maxLevel).toInt();

  static int clampExtraLifeLevel(int level) =>
      level.clamp(minLevel, extraLifeMaxLevel).toInt();

  /// Cost to upgrade homing from [currentLevel] to the next level.
  static int homingUpgradeCost(int currentLevel) {
    final level = clampLevel(currentLevel);
    if (level >= maxLevel) return 0;
    final next = level + 1;
    return 15 * next * next;
  }

  /// Cost to upgrade shot speed from [currentLevel] to the next level.
  static int shotSpeedUpgradeCost(int currentLevel) {
    final level = clampLevel(currentLevel);
    if (level >= maxLevel) return 0;
    final next = level + 1;
    return 12 * next * next;
  }

  static double _homingMultiplier(int level) {
    final bonus = clampLevel(level) * _homingBonusPerLevel;
    final multiplier = 1 + bonus;
    return multiplier > _homingMaxMultiplier ? _homingMaxMultiplier : multiplier;
  }

  static double _speedMultiplier(int level) {
    final bonus = clampLevel(level) * _speedBonusPerLevel;
    final multiplier = 1 + bonus;
    return multiplier > _speedMaxMultiplier ? _speedMaxMultiplier : multiplier;
  }

  /// Upward player egg speed in Manual Battle.
  static double manualEggSpeed(int shotSpeedLevel) =>
      baseEggSpeed * _speedMultiplier(shotSpeedLevel);

  /// Horizontal homing lerp for player egg shots in Manual Battle.
  static double manualEggHomingLerp(int homingLevel) =>
      baseEggHomingLerp * _homingMultiplier(homingLevel);

  /// Max horizontal homing step per tick for player egg shots in Manual Battle.
  static double manualEggMaxHomingSpeed(int homingLevel) =>
      baseEggMaxHomingSpeed * _homingMultiplier(homingLevel);

  /// Cost to upgrade extra lives from [currentLevel] to the next level.
  static int extraLifeUpgradeCost(int currentLevel) {
    final level = clampExtraLifeLevel(currentLevel);
    if (level >= extraLifeMaxLevel) return 0;
    final next = level + 1;
    return 100 * next * next;
  }

  /// Starting player lives in Manual Battle (base 3 + upgrade level).
  static int manualBattleStartingLives(int extraLifeLevel) =>
      baseManualBattleLives + clampExtraLifeLevel(extraLifeLevel);
}
