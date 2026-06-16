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
    var playerHp = max(100, battlePower * 6);
    var bossHp = boss.maxHp;
    final log = <BattleLogEntry>[];
    var rounds = 0;

    while (rounds < maxRounds && playerHp > 0 && bossHp > 0) {
      rounds++;
      final playerDamage =
          (battlePower * (0.85 + random.nextDouble() * 0.30)).round();
      bossHp = max(0, bossHp - playerDamage);
      log.add(
        BattleLogEntry(
          text: '$fighterDisplayName hit ${boss.name} for $playerDamage.',
        ),
      );
      if (bossHp <= 0) break;

      final bossDamage =
          (boss.recommendedPower * (0.35 + random.nextDouble() * 0.40))
              .round();
      playerHp = max(0, playerHp - bossDamage);
      log.add(
        BattleLogEntry(
          text: '${boss.name} splashed back for $bossDamage.',
        ),
      );
    }

    final won = bossHp <= 0;
    return BossBattleResult(
      won: won,
      rounds: rounds,
      finalPlayerHp: playerHp,
      finalBossHp: bossHp,
      damageLog: log,
      battlePower: battlePower,
      coinReward: won ? boss.coinReward : 0,
      battleTokenReward: won ? boss.battleTokenReward : 0,
    );
  }

  static BossBattleDefinition? bossById(String id) => BossData.bossById(id);
}
