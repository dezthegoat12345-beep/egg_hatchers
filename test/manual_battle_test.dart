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

  test('boss definitions define manual projectile tuning', () {
    for (final boss in BossData.bosses) {
      expect(boss.projectileIntervalMs, greaterThan(0));
      expect(boss.projectileSpeed, greaterThan(0));
    }

    expect(BossData.bossById('slime_boss')!.projectileIntervalMs, 1200);
    expect(BossData.bossById('egg_golem')!.projectileIntervalMs, 950);
    expect(BossData.bossById('shadow_rooster')!.projectileIntervalMs, 750);
  });
}
