import 'package:egg_hatchers/utils/boss_cinematic_config.dart';
import 'package:egg_hatchers/utils/boss_defeat_animation_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cinematic boss ids include base and elite cinematics', () {
    expect(BossCinematicConfig.isCinematicBoss('slime_boss'), isTrue);
    expect(BossCinematicConfig.isCinematicBoss('egg_golem'), isTrue);
    expect(BossCinematicConfig.isCinematicBoss('shadow_rooster'), isTrue);
    expect(BossCinematicConfig.isCinematicBoss('night_rooster'), isTrue);
    expect(BossCinematicConfig.isCinematicBoss('night_crow'), isTrue);
    expect(BossCinematicConfig.isCinematicBoss('slime_king'), isTrue);
    expect(BossCinematicConfig.isCinematicBoss('egg_guardian'), isTrue);
    expect(BossCinematicConfig.isCinematicBoss('shadow_phoenix'), isTrue);
  });

  test('elite cinematic boss ids include all elites', () {
    expect(BossCinematicConfig.isEliteCinematicBoss('slime_king'), isTrue);
    expect(BossCinematicConfig.isEliteCinematicBoss('egg_guardian'), isTrue);
    expect(BossCinematicConfig.isEliteCinematicBoss('shadow_phoenix'), isTrue);
    expect(BossCinematicConfig.isEliteCinematicBoss('slime_boss'), isFalse);
  });

  test('bird boss ids are detected', () {
    expect(BossCinematicConfig.isBirdBoss('shadow_rooster'), isTrue);
    expect(BossCinematicConfig.isBirdBoss('night_rooster'), isTrue);
    expect(BossCinematicConfig.isBirdBoss('night_crow'), isTrue);
    expect(BossCinematicConfig.isBirdBoss('egg_golem'), isFalse);
  });

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
