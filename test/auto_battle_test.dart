import 'dart:math';

import 'package:egg_hatchers/data/boss_data.dart';
import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/owned_animal.dart';
import 'package:egg_hatchers/services/game_service.dart';
import 'package:egg_hatchers/utils/boss_battle_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('auto battle carries animal HP between boss fights', () {
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
    expect(result.startingAnimalHp, result.maxAnimalHp);

    if (result.roundSummaries.length > 1) {
      final first = result.roundSummaries.first;
      final second = result.roundSummaries[1];
      expect(second.startingAnimalHp, first.result.finalPlayerHp);
      expect(second.result.initialBossHp, boss.maxHp);
    }
  });

  test('auto battle stops at safety cap', () {
    final boss = BossData.bossById('slime_boss')!;
    const fighter = OwnedAnimal(
      animalId: 'nebula_hydra',
      quantity: 1,
      level: 20,
      mutationId: 'shadow',
    );

    final result = BossBattleLogic.simulateAutoBattle(
      boss: boss,
      fighter: fighter,
      fighterDisplayName: 'Shadow Nebula Hydra',
      random: Random(7),
      maxDefeats: 25,
    );

    expect(result.bossesDefeated, lessThanOrEqualTo(25));
    if (result.bossesDefeated >= 25 && result.finalAnimalHp > 0) {
      expect(result.hitAutoBattleCap, isTrue);
    }
  });

  test('applyAutoBattleResult grants rewards exactly once', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devCollectAllAnimals();

    final beforeLifetime = game.lifetimeCoinsEarned;
    final beforeCoins = game.coins;
    final beforeTokens = game.battleTokens;

    final preview = game.simulateAutoBattle(
      bossId: 'slime_boss',
      animalId: 'nebula_hydra',
      mutationId: 'none',
      isProtected: false,
    );
    expect(preview, isNotNull);
    expect(game.coins, beforeCoins);
    expect(game.battleTokens, beforeTokens);

    game.applyAutoBattleResult('slime_boss', preview!);

    expect(game.coins, beforeCoins + preview.totalCoinsEarned);
    expect(game.battleTokens, beforeTokens + preview.totalBattleTokensEarned);
    expect(game.lifetimeCoinsEarned, beforeLifetime);
    expect(
      game.questProgress.totalBossBattlesStarted,
      preview.fightsAttempted,
    );
    expect(
      game.questProgress.totalBossBattlesWon,
      preview.bossesDefeated,
    );
    expect(
      game.bossWinCount('slime_boss'),
      preview.bossesDefeated,
    );

    game.dispose();
  });

  test('idle income pauses during auto battle session', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(1));
    await game.initialize();
    game.devCollectAllAnimals();
    game.buyEgg(GameData.eggs.first);
    game.hatchEgg(GameData.eggs.first);

    expect(game.isIdleIncomePaused, isFalse);
    game.pauseIdleIncomeForAutoBattle();
    expect(game.isIdleIncomePaused, isTrue);
    game.resumeIdleIncomeAfterAutoBattle();
    expect(game.isIdleIncomePaused, isFalse);

    game.dispose();
  });

  test('protected animals can auto battle without being removed', () async {
    SharedPreferences.setMockInitialValues({});
    final game = GameService(random: Random(2));
    await game.initialize();

    const protected = OwnedAnimal(
      animalId: 'galaxy_dragon',
      quantity: 1,
      level: 10,
      mutationId: 'shadow',
      isProtected: true,
    );
    game.devSetOwnedAnimalsForTesting([protected]);

    final preview = game.simulateAutoBattle(
      bossId: 'slime_boss',
      animalId: protected.animalId,
      mutationId: protected.mutationId,
      isProtected: true,
    );
    expect(preview, isNotNull);

    game.applyAutoBattleResult('slime_boss', preview!);
    expect(game.ownedAnimals.length, 1);
    expect(game.ownedAnimals.first.isProtected, isTrue);

    game.dispose();
  });
}
