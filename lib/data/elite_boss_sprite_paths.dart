/// Shared sprite assets for elite bosses and their matching reward animals.
class EliteBossSpritePaths {
  EliteBossSpritePaths._();

  static const slimeKing = 'assets/images/bosses/slime_king.png';
  static const eggGuardian = 'assets/images/bosses/egg_guardian.png';
  static const shadowPhoenix = 'assets/images/bosses/shadow_phoenix.png';

  /// Elite boss id and reward animal id share the same sprite file.
  static const shared = <String, String>{
    'slime_king': slimeKing,
    'egg_guardian': eggGuardian,
    'shadow_phoenix': shadowPhoenix,
  };

  static String? forId(String id) => shared[id];
}
