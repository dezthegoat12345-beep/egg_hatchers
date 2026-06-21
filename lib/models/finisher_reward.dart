/// Accumulated bonus rewards from the post-victory finisher slash window.
class FinisherRewardTotals {
  const FinisherRewardTotals({
    this.bonusCoins = 0,
    this.bonusTokens = 0,
  });

  final int bonusCoins;
  final int bonusTokens;

  bool get hasBonus => bonusCoins > 0 || bonusTokens > 0;

  FinisherRewardTotals addRoll(FinisherSlashRoll roll) => FinisherRewardTotals(
        bonusCoins: bonusCoins + roll.coins,
        bonusTokens: bonusTokens + roll.tokens,
      );
}

/// Result of one finisher slash reward roll.
class FinisherSlashRoll {
  const FinisherSlashRoll({
    this.coins = 0,
    this.tokens = 0,
    required this.message,
  });

  final int coins;
  final int tokens;
  final String message;

  bool get grantsReward => coins > 0 || tokens > 0;
}
