import 'owned_animal.dart';

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
    this.autoBattleSeconds = 10,
    this.projectileIntervalMs = 1000,
    this.projectileSpeed = 180,
    this.manualBossMoveSpeed = 60,
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
  final int autoBattleSeconds;
  /// Milliseconds between boss projectile spawns in manual battle.
  final int projectileIntervalMs;
  /// Downward projectile speed in arena pixels per second.
  final double projectileSpeed;
  /// Horizontal boss movement speed in manual battle (pixels per second).
  final double manualBossMoveSpeed;
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

/// Summary of one boss fight within an auto battle run.
class AutoBattleRoundSummary {
  const AutoBattleRoundSummary({
    required this.roundNumber,
    required this.startingAnimalHp,
    required this.result,
  });

  final int roundNumber;
  final int startingAnimalHp;
  final BossBattleResult result;
}

/// Outcome of a full auto battle run against one boss.
class AutoBattleResult {
  const AutoBattleResult({
    required this.fighter,
    required this.fighterDisplayName,
    required this.boss,
    required this.startingAnimalHp,
    required this.maxAnimalHp,
    required this.battlePower,
    required this.bossesDefeated,
    required this.totalCoinsEarned,
    required this.totalBattleTokensEarned,
    required this.finalAnimalHp,
    required this.roundSummaries,
    required this.wonAtLeastOne,
    required this.hitAutoBattleCap,
    this.lastFightResult,
  });

  final OwnedAnimal fighter;
  final String fighterDisplayName;
  final BossBattleDefinition boss;
  final int startingAnimalHp;
  final int maxAnimalHp;
  final int battlePower;
  final int bossesDefeated;
  final int totalCoinsEarned;
  final int totalBattleTokensEarned;
  final int finalAnimalHp;
  final List<AutoBattleRoundSummary> roundSummaries;
  final BossBattleResult? lastFightResult;
  final bool wonAtLeastOne;
  final bool hitAutoBattleCap;

  int get fightsAttempted => roundSummaries.length;

  bool get endedInDefeat =>
      roundSummaries.isNotEmpty && roundSummaries.last.result.won == false;
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
