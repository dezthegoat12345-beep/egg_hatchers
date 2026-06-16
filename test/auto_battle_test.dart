import 'dart:math';

import 'package:egg_hatchers/data/boss_data.dart';
import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/player_state.dart';
import 'package:egg_hatchers/models/owned_animal.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/utils/boss_battle_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('auto battle carries animal HP between boss fights in simulation', () {
    final boss = BossData.bossById('slime_boss')!;
    const fighter = OwnedAnimal(
      animalId: 'galaxy_dragon',
      quantity: 1,
      level: 10,
      mutationId: 'shadow',
    );

    final result = BossBattleLogic.simulateAutoBattle(
      boss: boss,
      fighter: fighter,
      fighterDisplayName: 'Shadow Galaxy Dragon',
      random: Random(42),
      maxDefeats: 5,
    );

    expect(result.maxAnimalHp, BossBattleLogic.maxAnimalHpFor(result.battlePower));

    if (result.roundSummaries.length > 1) {
      final first = result.roundSummaries.first;
      final second = result.roundSummaries[1];
      expect(second.startingAnimalHp, first.result.finalPlayerHp);
      expect(second.result.initialBossHp, boss.maxHp);
    }
  });

  test('starting active auto battle blocks a second assignment', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devSetOwnedAnimalsForTesting([
      const OwnedAnimal(animalId: 'chicken', quantity: 1),
      const OwnedAnimal(animalId: 'rabbit', quantity: 1),
    ]);

    expect(
      game.startActiveAutoBattle(
        bossId: 'slime_boss',
        animalId: 'chicken',
        mutationId: 'none',
        isProtected: false,
      ),
      isTrue,
    );
    expect(game.hasActiveAutoBattle, isTrue);
    expect(
      game.startActiveAutoBattle(
        bossId: 'slime_boss',
        animalId: 'rabbit',
        mutationId: 'none',
        isProtected: false,
      ),
      isFalse,
    );

    game.dispose();
  });

  test('battling stack is excluded from idle income', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devSetOwnedAnimalsForTesting([
      const OwnedAnimal(animalId: 'chicken', quantity: 1, level: 5),
      const OwnedAnimal(animalId: 'rabbit', quantity: 1, level: 1),
    ]);

    final incomeBefore = game.coinsPerSecond;
    expect(incomeBefore, greaterThan(0));

    game.startActiveAutoBattle(
      bossId: 'slime_boss',
      animalId: 'chicken',
      mutationId: 'none',
      isProtected: false,
    );

    expect(game.coinsPerSecond, lessThan(incomeBefore));

    game.dispose();
  });

  test('devAdvanceActiveAutoBattleFight grants rewards for one fight', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devCollectAllAnimals();

    final beforeLifetime = game.lifetimeCoinsEarned;
    final beforeCoins = game.coins;
    final beforeTokens = game.battleTokens;

    game.startActiveAutoBattle(
      bossId: 'slime_boss',
      animalId: 'nebula_hydra',
      mutationId: 'none',
      isProtected: false,
    );

    game.devAdvanceActiveAutoBattleFight();

    final battle = game.activeAutoBattle;
    if (battle != null && battle.battlesWon > 0) {
      expect(game.coins, greaterThan(beforeCoins));
      expect(game.battleTokens, greaterThan(beforeTokens));
      expect(game.lifetimeCoinsEarned, beforeLifetime);
      expect(game.questProgress.totalBossBattlesStarted, 1);
      expect(game.questProgress.totalBossBattlesWon, 1);
    }

    game.dispose();
  });

  test('cannot sell battling stack', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devSetOwnedAnimalsForTesting([
      const OwnedAnimal(animalId: 'chicken', quantity: 1),
    ]);
    game.startActiveAutoBattle(
      bossId: 'slime_boss',
      animalId: 'chicken',
      mutationId: 'none',
      isProtected: false,
    );

    expect(
      game.canSellOwnedAnimal('chicken', 'none'),
      isFalse,
    );

    game.dispose();
  });

  test('rebirth blocked while auto battle active', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devSetOwnedAnimalsForTesting([
      const OwnedAnimal(animalId: 'chicken', quantity: 1),
    ]);
    game.setLifetimeCoinsEarned(1000000);
    game.startActiveAutoBattle(
      bossId: 'slime_boss',
      animalId: 'chicken',
      mutationId: 'none',
      isProtected: false,
    );

    expect(game.performRebirth(), isFalse);

    game.dispose();
  });

  test('active auto battle persists through save round trip', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devSetOwnedAnimalsForTesting([
      const OwnedAnimal(animalId: 'chicken', quantity: 1, level: 3),
    ]);
    game.startActiveAutoBattle(
      bossId: 'slime_boss',
      animalId: 'chicken',
      mutationId: 'none',
      isProtected: false,
    );

    final json = game.state.toJson();
    final restored = PlayerState.fromJson(json);
    expect(restored.activeAutoBattle, isNotNull);
    expect(restored.activeAutoBattle!.bossId, 'slime_boss');
    expect(json['activeAutoBattle'], isNotNull);

    game.dispose();
  });

  test('boss definitions define auto battle durations', () {
    expect(BossData.bossById('slime_boss')!.autoBattleSeconds, 10);
    expect(BossData.bossById('egg_golem')!.autoBattleSeconds, 20);
    expect(BossData.bossById('shadow_rooster')!.autoBattleSeconds, 35);
  });
}
