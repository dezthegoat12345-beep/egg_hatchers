/// Coins and/or Battle Tokens granted when claiming a quest reward.
class QuestClaimResult {
  const QuestClaimResult({
    this.coins = 0,
    this.battleTokens = 0,
  });

  final int coins;
  final int battleTokens;

  bool get hasReward => coins > 0 || battleTokens > 0;
}
