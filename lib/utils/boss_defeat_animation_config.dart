/// Visual style for manual-battle boss defeat celebrations.
enum BossDefeatAnimationType {
  slimeBurst,
  golemCollapse,
  shadowFeathers,
  royalSlimeBurst,
  guardianShatter,
  shadowPhoenixFlame,
  generic,
}

/// Maps boss ids to defeat animation styles and display titles.
class BossDefeatAnimationConfig {
  BossDefeatAnimationConfig._();

  static BossDefeatAnimationType typeForBossId(String bossId) {
    return switch (bossId) {
      'slime_boss' => BossDefeatAnimationType.slimeBurst,
      'egg_golem' => BossDefeatAnimationType.golemCollapse,
      'shadow_rooster' ||
      'night_rooster' ||
      'night_crow' =>
        BossDefeatAnimationType.shadowFeathers,
      'slime_king' => BossDefeatAnimationType.royalSlimeBurst,
      'egg_guardian' => BossDefeatAnimationType.guardianShatter,
      'shadow_phoenix' => BossDefeatAnimationType.shadowPhoenixFlame,
      _ => BossDefeatAnimationType.generic,
    };
  }

  static Duration durationFor(BossDefeatAnimationType type) {
    return switch (type) {
      BossDefeatAnimationType.royalSlimeBurst ||
      BossDefeatAnimationType.guardianShatter ||
      BossDefeatAnimationType.shadowPhoenixFlame =>
        const Duration(milliseconds: 2600),
      _ => const Duration(milliseconds: 2300),
    };
  }

  static String defeatTitle({
    required BossDefeatAnimationType type,
    required bool isEliteBoss,
  }) {
    return switch (type) {
      BossDefeatAnimationType.slimeBurst => 'SLIME SPLAT!',
      BossDefeatAnimationType.golemCollapse => 'GOLEM CRUMBLED!',
      BossDefeatAnimationType.shadowFeathers => 'SHADOW SCATTERED!',
      BossDefeatAnimationType.royalSlimeBurst => 'ROYAL SPLAT!',
      BossDefeatAnimationType.guardianShatter => 'GUARDIAN SHATTERED!',
      BossDefeatAnimationType.shadowPhoenixFlame => 'PHOENIX EXTINGUISHED!',
      BossDefeatAnimationType.generic =>
        isEliteBoss ? 'ELITE BOSS DEFEATED!' : 'BOSS DEFEATED!',
    };
  }
}
