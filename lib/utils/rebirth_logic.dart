/// Rebirth unlock requirement and income multiplier helpers.
class RebirthLogic {
  RebirthLogic._();

  static const int unlockLifetimeCoins = 1000000;
  static const double bonusPerLevel = 0.25;

  static bool canRebirth(int lifetimeCoinsEarned) =>
      lifetimeCoinsEarned >= unlockLifetimeCoins;

  static double incomeMultiplier(int rebirthLevel) =>
      1 + rebirthLevel * bonusPerLevel;

  static double nextIncomeMultiplier(int rebirthLevel) =>
      incomeMultiplier(rebirthLevel + 1);

  static String formatMultiplier(double multiplier) {
    final text = multiplier.toStringAsFixed(2);
    return '${text.replaceAll(RegExp(r'\.?0+$'), '')}x';
  }

  static int applyMultiplier(int baseIncome, int rebirthLevel) {
    if (baseIncome <= 0 || rebirthLevel <= 0) return baseIncome;
    return (baseIncome * incomeMultiplier(rebirthLevel)).round();
  }
}
