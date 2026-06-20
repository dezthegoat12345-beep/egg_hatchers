import 'package:egg_hatchers/utils/boss_defeat_animation_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boss ids map to expected defeat animation types', () {
    expect(
      BossDefeatAnimationConfig.typeForBossId('slime_boss'),
      BossDefeatAnimationType.slimeBurst,
    );
    expect(
      BossDefeatAnimationConfig.typeForBossId('egg_golem'),
      BossDefeatAnimationType.golemCollapse,
    );
    expect(
      BossDefeatAnimationConfig.typeForBossId('shadow_rooster'),
      BossDefeatAnimationType.shadowFeathers,
    );
    expect(
      BossDefeatAnimationConfig.typeForBossId('slime_king'),
      BossDefeatAnimationType.royalSlimeBurst,
    );
    expect(
      BossDefeatAnimationConfig.typeForBossId('egg_guardian'),
      BossDefeatAnimationType.guardianShatter,
    );
    expect(
      BossDefeatAnimationConfig.typeForBossId('shadow_phoenix'),
      BossDefeatAnimationType.shadowPhoenixFlame,
    );
    expect(
      BossDefeatAnimationConfig.typeForBossId('unknown_boss'),
      BossDefeatAnimationType.generic,
    );
  });

  test('defeat titles are boss-specific', () {
    expect(
      BossDefeatAnimationConfig.defeatTitle(
        type: BossDefeatAnimationType.slimeBurst,
        isEliteBoss: false,
      ),
      'SLIME SPLAT!',
    );
    expect(
      BossDefeatAnimationConfig.defeatTitle(
        type: BossDefeatAnimationType.shadowPhoenixFlame,
        isEliteBoss: true,
      ),
      'PHOENIX EXTINGUISHED!',
    );
  });
}
