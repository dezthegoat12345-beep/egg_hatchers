import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/boss_data.dart';
import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/utils/boss_battle_logic.dart';
import 'package:egg_hatchers/utils/egg_shard_logic.dart';

void main() {
  test('Rotten Shell locked until all bosses defeated and flawless phoenix', () {
    final boss = BossData.bossById('rotten_shell')!;
    var state = PlayerState.initial();

    expect(BossBattleLogic.isBossUnlocked(boss, state), isFalse);

    final wins = {
      for (final id in EggShardLogic.prerequisiteBossIds) id: 1,
    };
    state = state.copyWith(bossWins: wins);
    expect(BossBattleLogic.isBossUnlocked(boss, state), isFalse);

    state = state.copyWith(shadowPhoenixFlawlessWin: true);
    expect(BossBattleLogic.isBossUnlocked(boss, state), isTrue);
  });

  test('Egg Shard battle limit break raises max homing level', () {
    expect(EggShardLogic.homingMaxLevel(0), 10);
    expect(EggShardLogic.homingMaxLevel(1), 12);
    expect(EggShardLogic.homingMaxLevel(2), 14);
  });

  test('Egg rebirth reduction lowers effective requirement', () {
    expect(
      EggShardLogic.effectiveRebirthRequirement(3, 1),
      2,
    );
    expect(
      EggShardLogic.effectiveRebirthRequirement(1, 3),
      0,
    );
  });

  test('PlayerState defaults egg shard fields for old saves', () {
    final json = PlayerState.initial().toJson()..remove('eggShards');
    final loaded = PlayerState.fromJson(json);
    expect(loaded.eggShards, 0);
    expect(loaded.shadowPhoenixFlawlessWin, isFalse);
    expect(loaded.battleLimitBreakLevel, 0);
  });
}
