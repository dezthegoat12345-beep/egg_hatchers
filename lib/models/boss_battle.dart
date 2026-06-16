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
    this.spritePath,
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
  final String? spritePath;
}

/// One line in the auto-battle log.
class BattleLogEntry {
  const BattleLogEntry({required this.text});

  final String text;
}

/// HP snapshot after one attack in the simulated fight.
class BattleRoundSnapshot {
  const BattleRoundSnapshot({
    required this.isPlayerAttack,
    required this.damage,
    required this.playerHpAfter,
    required this.bossHpAfter,
    required this.logText,
  });

  final bool isPlayerAttack;
  final int damage;
  final int playerHpAfter;
  final int bossHpAfter;
  final String logText;
}

/// Outcome of a simulated boss battle.
class BossBattleResult {
  const BossBattleResult({
    required this.won,
    required this.rounds,
    required this.initialPlayerHp,
    required this.initialBossHp,
    required this.finalPlayerHp,
    required this.finalBossHp,
    required this.damageLog,
    required this.roundSnapshots,
    required this.battlePower,
    this.coinReward = 0,
    this.battleTokenReward = 0,
  });

  final bool won;
  final int rounds;
  final int initialPlayerHp;
  final int initialBossHp;
  final int finalPlayerHp;
  final int finalBossHp;
  final List<BattleLogEntry> damageLog;
  final List<BattleRoundSnapshot> roundSnapshots;
  final int battlePower;
  final int coinReward;
  final int battleTokenReward;
}
