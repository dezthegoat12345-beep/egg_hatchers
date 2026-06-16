import 'dart:math';

import '../data/boss_data.dart';
import '../models/boss_battle.dart';
import '../models/owned_animal.dart';
import '../models/player_state.dart';
import 'battle_power_logic.dart';
import 'collection_quest_logic.dart';

/// Boss unlock checks and auto-battle simulation.
class BossBattleLogic {
  BossBattleLogic._();

  static const int maxRounds = 12;
  static const int maxVisibleAnimationSteps = 8;
  static const int maxAutoBattleDefeats = 25;

  static int maxAnimalHpFor(int battlePower) => max(100, battlePower * 6);

  /// Boss projectile hit damage in manual dodge battle.
  static int manualBossProjectileDamage(BossBattleDefinition boss) =>
      max(10, boss.recommendedPower ~/ 2);

  /// Egg shot damage in manual dodge battle (unused for lives-based manual fights).
  static int manualEggDamage(int battlePower) =>
      max(10, (battlePower / 8).round());

  static const int manualShieldBaseMisses = 5;
  static const int manualShieldMaxMisses = 12;
  static const double manualBossMoveSpeedCap = 2.5;
  static const double manualProjectileSpeedAbsoluteCap = 3.0;
  static const int manualMinProjectileIntervalMs = 450;
  static const Duration manualEggCooldown = Duration(milliseconds: 850);
  static const int manualMaxBossProjectiles = 6;
  static const int manualBattleLives = 3;

  static const int hardPhaseUnlockWins = 5;
  static const int hardPhaseShieldBaseMisses = 8;
  static const int hardPhaseShieldMaxMisses = 16;
  static const int hardPhaseRewardMultiplier = 2;
  static const double hardPhaseProjectileSpeedStart = 1.40;
  static const double hardPhaseIntervalScale = 0.65;
  static const double hardPhaseAimErrorScale = 0.50;
  static const double hardPhasePredictionScale = 1.35;
  static const double hardPhaseTrackingSpeedScale = 1.35;
  static const double hardPhaseHitStrengthScale = 1.25;

  static const int nightmareUnlockHardWins = 7;
  static const int nightmareShieldBaseMisses = 10;
  static const int nightmareShieldMaxMisses = 20;
  static const int nightmareRewardMultiplier = 3;
  static const double nightmareProjectileSpeedStart = 1.75;
  static const double nightmareIntervalScale = 0.50;
  static const double nightmareAimErrorScale = 0.25;
  static const double nightmarePredictionScale = 1.60;
  static const double nightmareTrackingSpeedScale = 1.60;
  static const double nightmareHitStrengthScale = 1.40;
  static const int nightmareMinProjectileIntervalMs = 325;

  static bool isHardPhaseUnlocked(int bossWinCount) =>
      bossWinCount >= hardPhaseUnlockWins;

  static bool isNightmareUnlocked(int hardPhaseWinCount) =>
      hardPhaseWinCount >= nightmareUnlockHardWins;

  /// Manual battle boss lives by id (Auto Battle still uses [BossBattleDefinition.maxHp]).
  static int manualBossLives(BossBattleDefinition boss) {
    switch (boss.id) {
      case 'slime_boss':
        return 1;
      case 'egg_golem':
        return 2;
      case 'shadow_rooster':
        return 3;
      default:
        return 3;
    }
  }

  static int manualRewardMultiplier(ManualBattleMode mode) {
    switch (mode) {
      case ManualBattleMode.hard:
        return hardPhaseRewardMultiplier;
      case ManualBattleMode.nightmare:
        return nightmareRewardMultiplier;
      case ManualBattleMode.normal:
        return 1;
    }
  }

  static double _hitStrengthScale(ManualBattleMode mode) {
    switch (mode) {
      case ManualBattleMode.hard:
        return hardPhaseHitStrengthScale;
      case ManualBattleMode.nightmare:
        return nightmareHitStrengthScale;
      case ManualBattleMode.normal:
        return 1.0;
    }
  }

  /// First shield break needs 5 misses (8 hard, 10 nightmare); scaling per egg hit.
  static int manualRequiredMisses(
    int successfulEggHits, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    final (base, increment, cap) = switch (mode) {
      ManualBattleMode.hard => (
          hardPhaseShieldBaseMisses,
          2,
          hardPhaseShieldMaxMisses,
        ),
      ManualBattleMode.nightmare => (
          nightmareShieldBaseMisses,
          2,
          nightmareShieldMaxMisses,
        ),
      ManualBattleMode.normal => (
          manualShieldBaseMisses,
          1,
          manualShieldMaxMisses,
        ),
    };
    return min(cap, base + successfulEggHits * increment);
  }

  /// Time-based scaling plus bumps per successful egg hit on the boss.
  static double manualProjectileSpeedMultiplier({
    required double elapsedSeconds,
    required int bossHitCount,
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    final base = switch (mode) {
      ManualBattleMode.hard => hardPhaseProjectileSpeedStart,
      ManualBattleMode.nightmare => nightmareProjectileSpeedStart,
      ManualBattleMode.normal => 1.0,
    };
    final hitStrength = _hitStrengthScale(mode);
    final hitPerBump = 0.15 * hitStrength;
    final hitTimeBump = 0.10 * hitStrength;
    final multiplier = base +
        (elapsedSeconds / 30.0) +
        bossHitCount * hitPerBump +
        bossHitCount * hitTimeBump;
    return min(manualProjectileSpeedAbsoluteCap, multiplier);
  }

  static double manualBossMoveSpeedMultiplier(
    int bossHitCount, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    final perHit = 0.15 * _hitStrengthScale(mode);
    return min(manualBossMoveSpeedCap, 1.0 + bossHitCount * perHit);
  }

  static int manualProjectileIntervalMs(
    BossBattleDefinition boss,
    int bossHitCount, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    final baseInterval = switch (mode) {
      ManualBattleMode.hard =>
        (boss.projectileIntervalMs * hardPhaseIntervalScale).round(),
      ManualBattleMode.nightmare =>
        (boss.projectileIntervalMs * nightmareIntervalScale).round(),
      ManualBattleMode.normal => boss.projectileIntervalMs,
    };
    final hitScale = 0.12 * _hitStrengthScale(mode);
    final scaled = baseInterval / (1 + bossHitCount * hitScale);
    final minInterval = mode == ManualBattleMode.nightmare
        ? nightmareMinProjectileIntervalMs
        : manualMinProjectileIntervalMs;
    return max(minInterval, scaled.round());
  }

  static double manualBossMoveSpeed(
    BossBattleDefinition boss,
    int bossHitCount, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    final trackingScale = switch (mode) {
      ManualBattleMode.hard => hardPhaseTrackingSpeedScale,
      ManualBattleMode.nightmare => nightmareTrackingSpeedScale,
      ManualBattleMode.normal => 1.0,
    };
    return boss.manualBossMoveSpeed *
        manualBossMoveSpeedMultiplier(bossHitCount, mode: mode) *
        trackingScale;
  }

  static double manualAimErrorMax(
    BossBattleDefinition boss, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    return switch (mode) {
      ManualBattleMode.hard =>
        boss.manualAimErrorMax * hardPhaseAimErrorScale,
      ManualBattleMode.nightmare =>
        boss.manualAimErrorMax * nightmareAimErrorScale,
      ManualBattleMode.normal => boss.manualAimErrorMax,
    };
  }

  static double manualPredictionStrength(
    BossBattleDefinition boss, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    return switch (mode) {
      ManualBattleMode.hard =>
        boss.manualPredictionStrength * hardPhasePredictionScale,
      ManualBattleMode.nightmare =>
        boss.manualPredictionStrength * nightmarePredictionScale,
      ManualBattleMode.normal => boss.manualPredictionStrength,
    };
  }

  static double manualAimAccuracy(
    BossBattleDefinition boss, {
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    final scale = switch (mode) {
      ManualBattleMode.hard => hardPhasePredictionScale,
      ManualBattleMode.nightmare => nightmarePredictionScale,
      ManualBattleMode.normal => 1.0,
    };
    if (scale == 1.0) return boss.manualAimAccuracy;
    return min(1.0, boss.manualAimAccuracy * scale);
  }

  /// Computes a clamped horizontal aim target for manual battle boss tracking.
  static double manualBossAimTarget({
    required BossBattleDefinition boss,
    required double playerX,
    required double playerVelocityX,
    required double minX,
    required double maxX,
    required double aimError,
    ManualBattleMode mode = ManualBattleMode.normal,
  }) {
    final prediction = manualPredictionStrength(boss, mode: mode);
    final accuracy = manualAimAccuracy(boss, mode: mode);
    final predictedX = playerX + playerVelocityX * prediction;
    final rawTarget = predictedX + aimError;
    final blended = playerX + (rawTarget - playerX) * accuracy;
    return blended.clamp(minX, maxX);
  }

  /// Legacy alias for the first shield break threshold.
  static const int manualShieldMissThreshold = manualShieldBaseMisses;

  static int uniqueBaseAnimalCount(PlayerState state) {
    return CollectionQuestLogic.collectedBaseAnimalCount(state);
  }

  static bool isBossUnlocked(BossBattleDefinition boss, PlayerState state) {
    switch (boss.id) {
      case 'slime_boss':
        return true;
      case 'egg_golem':
        return uniqueBaseAnimalCount(state) >= 10;
      case 'shadow_rooster':
        return state.rebirthLevel >= 1 || uniqueBaseAnimalCount(state) >= 25;
      default:
        return false;
    }
  }

  static BossBattleResult simulate({
    required BossBattleDefinition boss,
    required OwnedAnimal fighter,
    required String fighterDisplayName,
    required Random random,
    int? startingPlayerHp,
  }) {
    final battlePower = BattlePowerLogic.battlePowerForOwnedAnimal(fighter);
    final initialPlayerHp =
        startingPlayerHp ?? maxAnimalHpFor(battlePower);
    var playerHp = initialPlayerHp;
    var bossHp = boss.maxHp;
    final log = <BattleLogEntry>[];
    final snapshots = <BattleRoundSnapshot>[];
    var rounds = 0;

    while (rounds < maxRounds && playerHp > 0 && bossHp > 0) {
      rounds++;
      final playerDamage =
          (battlePower * (0.85 + random.nextDouble() * 0.30)).round();
      bossHp = max(0, bossHp - playerDamage);
      final playerHitText =
          '$fighterDisplayName hit ${boss.name} for $playerDamage.';
      log.add(BattleLogEntry(text: playerHitText));
      snapshots.add(
        BattleRoundSnapshot(
          isPlayerAttack: true,
          damage: playerDamage,
          playerHpAfter: playerHp,
          bossHpAfter: bossHp,
          logText: playerHitText,
        ),
      );
      if (bossHp <= 0) break;

      final bossDamage =
          (boss.recommendedPower * (0.35 + random.nextDouble() * 0.40))
              .round();
      playerHp = max(0, playerHp - bossDamage);
      final bossHitText = '${boss.name} splashed back for $bossDamage.';
      log.add(BattleLogEntry(text: bossHitText));
      snapshots.add(
        BattleRoundSnapshot(
          isPlayerAttack: false,
          damage: bossDamage,
          playerHpAfter: playerHp,
          bossHpAfter: bossHp,
          logText: bossHitText,
        ),
      );
    }

    final won = bossHp <= 0;
    return BossBattleResult(
      won: won,
      rounds: rounds,
      initialPlayerHp: initialPlayerHp,
      initialBossHp: boss.maxHp,
      finalPlayerHp: playerHp,
      finalBossHp: bossHp,
      damageLog: log,
      roundSnapshots: snapshots,
      battlePower: battlePower,
      coinReward: won ? boss.coinReward : 0,
      battleTokenReward: won ? boss.battleTokenReward : 0,
    );
  }

  /// Picks up to [maxVisibleAnimationSteps] snapshots for the battle animation.
  static List<BattleRoundSnapshot> visibleSnapshots(BossBattleResult result) {
    final all = result.roundSnapshots;
    if (all.length <= maxVisibleAnimationSteps) return all;
    if (all.isEmpty) return all;

    final picked = <BattleRoundSnapshot>[];
    final lastIndex = all.length - 1;
    for (var i = 0; i < maxVisibleAnimationSteps; i++) {
      final index = ((i / (maxVisibleAnimationSteps - 1)) * lastIndex).round();
      picked.add(all[index]);
    }
    return picked;
  }

  static BossBattleDefinition? bossById(String id) => BossData.bossById(id);

  /// Simulates repeated boss fights until the animal loses, HP reaches 0, or
  /// [maxDefeats] bosses are defeated.
  static AutoBattleResult simulateAutoBattle({
    required BossBattleDefinition boss,
    required OwnedAnimal fighter,
    required String fighterDisplayName,
    required Random random,
    int maxDefeats = maxAutoBattleDefeats,
  }) {
    final battlePower = BattlePowerLogic.battlePowerForOwnedAnimal(fighter);
    final maxAnimalHp = maxAnimalHpFor(battlePower);
    var animalHp = maxAnimalHp;
    var bossesDefeated = 0;
    var totalCoins = 0;
    var totalTokens = 0;
    final roundSummaries = <AutoBattleRoundSummary>[];
    BossBattleResult? lastFightResult;
    var hitCap = false;

    while (animalHp > 0 && bossesDefeated < maxDefeats) {
      final roundNumber = roundSummaries.length + 1;
      final result = simulate(
        boss: boss,
        fighter: fighter,
        fighterDisplayName: fighterDisplayName,
        random: random,
        startingPlayerHp: animalHp,
      );

      roundSummaries.add(
        AutoBattleRoundSummary(
          roundNumber: roundNumber,
          startingAnimalHp: animalHp,
          result: result,
        ),
      );
      lastFightResult = result;
      animalHp = result.finalPlayerHp;

      if (!result.won) break;

      bossesDefeated++;
      totalCoins += boss.coinReward;
      totalTokens += boss.battleTokenReward;

      if (animalHp <= 0) break;
    }

    if (bossesDefeated >= maxDefeats && animalHp > 0) {
      hitCap = true;
    }

    return AutoBattleResult(
      fighter: fighter,
      fighterDisplayName: fighterDisplayName,
      boss: boss,
      startingAnimalHp: maxAnimalHp,
      maxAnimalHp: maxAnimalHp,
      battlePower: battlePower,
      bossesDefeated: bossesDefeated,
      totalCoinsEarned: totalCoins,
      totalBattleTokensEarned: totalTokens,
      finalAnimalHp: animalHp,
      roundSummaries: roundSummaries,
      lastFightResult: lastFightResult,
      wonAtLeastOne: bossesDefeated > 0,
      hitAutoBattleCap: hitCap,
    );
  }
}
