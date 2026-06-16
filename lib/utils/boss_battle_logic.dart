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
  }) {
    final battlePower = BattlePowerLogic.battlePowerForOwnedAnimal(fighter);
    final initialPlayerHp = max(100, battlePower * 6);
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
}
