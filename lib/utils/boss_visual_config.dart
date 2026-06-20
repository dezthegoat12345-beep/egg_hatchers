/// Visual style for manual-battle boss projectiles (hitbox unchanged).
enum BossProjectileVisualType {
  slimeGlob,
  rockEgg,
  shadowFeather,
  royalSlime,
  guardianShard,
  phoenixFlame,
  rottenEgg,
}

/// Scene style for manual-battle arena backgrounds.
enum BossBattleBackgroundType {
  slimeSwamp,
  eggCave,
  shadowRoost,
  royalPalace,
  guardianNest,
  phoenixLair,
  genericArena,
}

/// Maps boss ids to manual-battle visual styles.
class BossVisualConfig {
  BossVisualConfig._();

  static BossProjectileVisualType projectileTypeForBossId(String bossId) {
    return switch (bossId) {
      'slime_boss' => BossProjectileVisualType.slimeGlob,
      'egg_golem' => BossProjectileVisualType.rockEgg,
      'shadow_rooster' ||
      'night_rooster' ||
      'night_crow' =>
        BossProjectileVisualType.shadowFeather,
      'slime_king' => BossProjectileVisualType.royalSlime,
      'egg_guardian' => BossProjectileVisualType.guardianShard,
      'shadow_phoenix' => BossProjectileVisualType.phoenixFlame,
      _ => BossProjectileVisualType.rottenEgg,
    };
  }

  static BossBattleBackgroundType backgroundTypeForBossId(String bossId) {
    return switch (bossId) {
      'slime_boss' => BossBattleBackgroundType.slimeSwamp,
      'egg_golem' => BossBattleBackgroundType.eggCave,
      'shadow_rooster' ||
      'night_rooster' ||
      'night_crow' =>
        BossBattleBackgroundType.shadowRoost,
      'slime_king' => BossBattleBackgroundType.royalPalace,
      'egg_guardian' => BossBattleBackgroundType.guardianNest,
      'shadow_phoenix' => BossBattleBackgroundType.phoenixLair,
      _ => BossBattleBackgroundType.genericArena,
    };
  }
}
