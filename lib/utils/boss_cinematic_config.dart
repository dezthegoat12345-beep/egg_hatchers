/// Which manual-battle bosses use dedicated long cinematic defeat overlays.
class BossCinematicConfig {
  BossCinematicConfig._();

  static bool isCinematicBoss(String bossId) {
    return switch (bossId) {
      'slime_boss' ||
      'egg_golem' ||
      'shadow_rooster' ||
      'night_rooster' ||
      'night_crow' =>
        true,
      _ => false,
    };
  }

  static bool isBirdBoss(String bossId) {
    return switch (bossId) {
      'shadow_rooster' || 'night_rooster' || 'night_crow' => true,
      _ => false,
    };
  }
}
