import 'package:egg_hatchers/utils/boss_visual_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boss ids map to expected projectile and background types', () {
    expect(
      BossVisualConfig.projectileTypeForBossId('slime_boss'),
      BossProjectileVisualType.slimeGlob,
    );
    expect(
      BossVisualConfig.backgroundTypeForBossId('slime_king'),
      BossBattleBackgroundType.royalPalace,
    );
    expect(
      BossVisualConfig.backgroundTypeForBossId('egg_guardian'),
      BossBattleBackgroundType.guardianNest,
    );
    expect(
      BossVisualConfig.projectileTypeForBossId('shadow_phoenix'),
      BossProjectileVisualType.phoenixFlame,
    );
    expect(
      BossVisualConfig.projectileTypeForBossId('unknown'),
      BossProjectileVisualType.rottenEgg,
    );
  });
}
