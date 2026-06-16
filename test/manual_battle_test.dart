import 'package:egg_hatchers/data/boss_data.dart';
import 'package:egg_hatchers/utils/boss_battle_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manual boss projectile damage uses half recommended power minimum 10', () {
    final slime = BossData.bossById('slime_boss')!;
    expect(BossBattleLogic.manualBossProjectileDamage(slime), 50);

    final golem = BossData.bossById('egg_golem')!;
    expect(BossBattleLogic.manualBossProjectileDamage(golem), 750);
  });

  test('manual egg damage uses battle power divided by 8 minimum 10', () {
    expect(BossBattleLogic.manualEggDamage(80), 10);
    expect(BossBattleLogic.manualEggDamage(800), 100);
    expect(BossBattleLogic.manualEggDamage(15000), 1875);
  });

  test('manual shield misses scale with successful egg hits capped at 12', () {
    expect(BossBattleLogic.manualRequiredMisses(0), 5);
    expect(BossBattleLogic.manualRequiredMisses(1), 6);
    expect(BossBattleLogic.manualRequiredMisses(3), 8);
    expect(BossBattleLogic.manualRequiredMisses(7), 12);
    expect(BossBattleLogic.manualRequiredMisses(20), 12);
  });

  test('manual projectile speed multiplier scales with time and hits', () {
    expect(
      BossBattleLogic.manualProjectileSpeedMultiplier(
        elapsedSeconds: 0,
        bossHitCount: 0,
      ),
      1.0,
    );
    expect(
      BossBattleLogic.manualProjectileSpeedMultiplier(
        elapsedSeconds: 15,
        bossHitCount: 0,
      ),
      1.5,
    );
    expect(
      BossBattleLogic.manualProjectileSpeedMultiplier(
        elapsedSeconds: 30,
        bossHitCount: 0,
      ),
      2.0,
    );
    expect(
      BossBattleLogic.manualProjectileSpeedMultiplier(
        elapsedSeconds: 60,
        bossHitCount: 0,
      ),
      3.0,
    );
    expect(
      BossBattleLogic.manualProjectileSpeedMultiplier(
        elapsedSeconds: 0,
        bossHitCount: 2,
      ),
      closeTo(1.5, 0.001),
    );
  });

  test('manual boss move speed scales with hits capped at 2.5x', () {
    final slime = BossData.bossById('slime_boss')!;
    expect(BossBattleLogic.manualBossMoveSpeed(slime, 0), 45);
    expect(BossBattleLogic.manualBossMoveSpeed(slime, 2), closeTo(58.5, 0.001));
    expect(
      BossBattleLogic.manualBossMoveSpeed(slime, 20),
      closeTo(45 * 2.5, 0.001),
    );
  });

  test('manual projectile interval speeds up with hits down to minimum', () {
    final slime = BossData.bossById('slime_boss')!;
    expect(BossBattleLogic.manualProjectileIntervalMs(slime, 0), 1200);
    expect(
      BossBattleLogic.manualProjectileIntervalMs(slime, 3),
      lessThan(1200),
    );
    expect(
      BossBattleLogic.manualProjectileIntervalMs(slime, 100),
      BossBattleLogic.manualMinProjectileIntervalMs,
    );
  });

  test('manual battle uses three lives', () {
    expect(BossBattleLogic.manualBattleLives, 3);
  });

  test('boss definitions define manual projectile and movement tuning', () {
    for (final boss in BossData.bosses) {
      expect(boss.projectileIntervalMs, greaterThan(0));
      expect(boss.projectileSpeed, greaterThan(0));
      expect(boss.manualBossMoveSpeed, greaterThan(0));
    }

    expect(BossData.bossById('slime_boss')!.manualBossMoveSpeed, 45);
    expect(BossData.bossById('egg_golem')!.manualBossMoveSpeed, 70);
    expect(BossData.bossById('shadow_rooster')!.manualBossMoveSpeed, 95);
  });
}
