/// Definition of a single-player boss fight.
class BossBattleDefinition {
  const BossBattleDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.maxHp,
    required this.recommendedPower,
    required this.coinReward,
    required this.battleTokenReward,
    required this.unlockRequirementText,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final int maxHp;
  final int recommendedPower;
  final int coinReward;
  final int battleTokenReward;
  final String unlockRequirementText;
}

/// One line in the auto-battle log.
class BattleLogEntry {
  const BattleLogEntry({required this.text});

  final String text;
}

/// Outcome of a simulated boss battle.
class BossBattleResult {
  const BossBattleResult({
    required this.won,
    required this.rounds,
    required this.finalPlayerHp,
    required this.finalBossHp,
    required this.damageLog,
    required this.battlePower,
    this.coinReward = 0,
    this.battleTokenReward = 0,
  });

  final bool won;
  final int rounds;
  final int finalPlayerHp;
  final int finalBossHp;
  final List<BattleLogEntry> damageLog;
  final int battlePower;
  final int coinReward;
  final int battleTokenReward;
}
