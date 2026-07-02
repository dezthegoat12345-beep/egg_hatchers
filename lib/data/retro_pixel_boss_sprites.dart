import '../models/retro_pixel_sprite_definition.dart';
import 'retro_pixel_native_64_canvas.dart';
import 'retro_pixel_palette.dart';

/// Native 64×64 Retro Pixel boss art — follows Animal Style, not Classic PNGs.
class RetroPixelBossSprites {
  RetroPixelBossSprites._();

  static const bossIds = [
    'slime_boss',
    'egg_golem',
    'shadow_rooster',
    'slime_king',
    'egg_guardian',
    'shadow_phoenix',
    'rotten_shell',
  ];

  /// Maps bird boss variants to the shared shadow rooster sprite.
  static String canonicalBossId(String bossId) {
    return switch (bossId) {
      'night_rooster' || 'night_crow' => 'shadow_rooster',
      _ => bossId,
    };
  }

  static RetroPixelSpriteDefinition? forBossId(String bossId) {
    return all[canonicalBossId(bossId)];
  }

  static bool hasSprite(String bossId) => forBossId(bossId) != null;

  static final Map<String, RetroPixelSpriteDefinition> all = {
    for (final id in bossIds) id: _builders[id]!(),
  };

  static const _k = RetroPixelPalette.black;
  static const _w = RetroPixelPalette.offWhite;
  static const _g = RetroPixelPalette.lightGray;
  static const _r = RetroPixelPalette.red;
  static const _o = RetroPixelPalette.orange;
  static const _y = RetroPixelPalette.yellow;
  static const _e = RetroPixelPalette.green;
  static const _l = RetroPixelPalette.blue;
  static const _dl = RetroPixelPalette.darkBlue;
  static const _b = RetroPixelPalette.brown;
  static const _db = RetroPixelPalette.darkBrown;
  static const _t = RetroPixelPalette.tan;
  static const _c = RetroPixelPalette.cream;
  static const _s = RetroPixelPalette.slimeGreen;
  static const _sd = RetroPixelPalette.slimeDark;
  static const _p = RetroPixelPalette.purple;

  static final Map<String, RetroPixelSpriteDefinition Function()> _builders = {
    'slime_boss': _slimeBoss,
    'egg_golem': _eggGolem,
    'shadow_rooster': _shadowRooster,
    'slime_king': _slimeKing,
    'egg_guardian': _eggGuardian,
    'shadow_phoenix': _shadowPhoenix,
    'rotten_shell': _rottenShell,
  };

  static RetroPixelSpriteDefinition _slimeBoss() {
    final c = RetroPixelNative64Canvas();
    // Drippy base blocks
    c.fillRect(18, 52, 6, 6, _sd);
    c.fillRect(26, 54, 8, 4, _sd);
    c.fillRect(36, 52, 6, 6, _sd);
    c.fillRect(42, 50, 5, 5, _sd);
    for (var x = 17; x <= 47; x++) {
      c.set(x, 51, _k);
      c.set(x, 58, _k);
    }
    // Main blob
    c.outlineEllipse(32, 36, 20, 18, _s, _k);
    c.fillEllipse(24, 32, 6, 8, _e);
    c.fillRect(38, 28, 4, 6, _w);
    c.fillRect(39, 29, 2, 4, _w);
    // Angry eyes
    c.fillRect(22, 28, 6, 5, _k);
    c.fillRect(36, 28, 6, 5, _k);
    c.fillRect(23, 29, 3, 3, _w);
    c.fillRect(37, 29, 3, 3, _w);
    c.set(25, 30, _k);
    c.set(39, 30, _k);
    c.fillRect(24, 27, 2, 1, _k);
    c.fillRect(38, 27, 2, 1, _k);
    // Mouth
    c.fillRect(28, 40, 8, 2, _k);
    c.fillRect(29, 42, 6, 2, _sd);
    return c.build();
  }

  static RetroPixelSpriteDefinition _eggGolem() {
    final c = RetroPixelNative64Canvas();
    // Left rocky arm
    c.rectOutline(8, 30, 10, 18, _g, _k);
    c.fillRect(10, 32, 4, 4, _db);
    c.fillRect(11, 38, 3, 3, _b);
    // Right rocky arm
    c.rectOutline(46, 30, 10, 18, _g, _k);
    c.fillRect(50, 32, 4, 4, _db);
    c.fillRect(50, 38, 3, 3, _b);
    // Egg body
    c.outlineEllipse(32, 38, 16, 20, _c, _k);
    c.fillEllipse(28, 34, 5, 7, _t);
    // Cracks / glow
    c.fillRect(30, 26, 2, 10, _l);
    c.fillRect(34, 24, 2, 12, _l);
    c.fillRect(38, 28, 2, 8, _l);
    c.set(31, 25, _k);
    c.set(35, 23, _k);
    c.set(39, 27, _k);
    // Face
    c.eye(26, 34);
    c.eye(38, 34);
    c.fillRect(28, 42, 8, 2, _k);
    c.fillRect(29, 44, 6, 1, _db);
    // Rubble feet
    c.fillRect(22, 56, 8, 4, _g);
    c.fillRect(34, 56, 8, 4, _g);
    c.set(21, 55, _k);
    c.set(42, 55, _k);
    return c.build();
  }

  static RetroPixelSpriteDefinition _shadowRooster() {
    final c = RetroPixelNative64Canvas();
    // Tail feathers
    c.fillRect(10, 28, 8, 4, _p);
    c.fillRect(8, 32, 10, 3, _dl);
    c.fillRect(12, 24, 6, 4, _p);
    for (var y = 23; y <= 36; y++) {
      c.set(9, y, _k);
      c.set(18, y, _k);
    }
    // Body
    c.outlineEllipse(30, 38, 14, 16, _dl, _k);
    c.fillEllipse(34, 36, 6, 8, _p);
    // Wing
    c.fillRect(36, 34, 12, 8, _p);
    c.fillRect(38, 36, 8, 4, _dl);
    c.set(35, 33, _k);
    c.set(48, 33, _k);
    c.set(48, 42, _k);
    // Head
    c.outlineEllipse(42, 24, 8, 8, _dl, _k);
    // Glowing eye
    c.fillRect(44, 22, 4, 4, _k);
    c.fillRect(45, 23, 2, 2, _y);
    c.set(46, 24, _o);
    // Beak
    c.fillRect(50, 24, 5, 3, _o);
    c.set(54, 25, _k);
    // Comb spikes
    c.fillRect(40, 14, 3, 4, _r);
    c.fillRect(44, 12, 3, 5, _r);
    c.fillRect(48, 14, 3, 4, _r);
    c.set(39, 17, _k);
    c.set(51, 17, _k);
    // Legs & claws
    c.fillRect(26, 52, 3, 8, _o);
    c.fillRect(34, 52, 3, 8, _o);
    c.fillRect(24, 58, 6, 2, _k);
    c.fillRect(32, 58, 6, 2, _k);
    c.set(24, 57, _k);
    c.set(32, 57, _k);
    return c.build();
  }

  static RetroPixelSpriteDefinition _slimeKing() {
    final c = RetroPixelNative64Canvas();
    // Royal cape trim
    c.fillRect(14, 40, 6, 14, _p);
    c.fillRect(44, 40, 6, 14, _p);
    c.set(13, 39, _k);
    c.set(50, 39, _k);
    // Larger royal blob
    c.outlineEllipse(32, 38, 22, 20, _s, _k);
    c.fillEllipse(22, 34, 7, 9, _e);
    c.fillRect(36, 30, 5, 7, _w);
    // Crown
    c.fillRect(22, 14, 20, 4, _y);
    c.fillRect(24, 10, 4, 4, _y);
    c.fillRect(30, 8, 4, 6, _y);
    c.fillRect(36, 10, 4, 4, _y);
    c.fillRect(40, 12, 4, 4, _y);
    for (var x = 21; x <= 42; x++) {
      c.set(x, 13, _k);
      c.set(x, 18, _k);
    }
    c.set(23, 9, _k);
    c.set(31, 7, _k);
    c.set(39, 9, _k);
    // Jewels
    c.set(31, 11, _r);
    c.set(35, 11, _l);
    // Eyes
    c.fillRect(22, 30, 6, 5, _k);
    c.fillRect(36, 30, 6, 5, _k);
    c.fillRect(23, 31, 3, 3, _w);
    c.fillRect(37, 31, 3, 3, _w);
    c.set(25, 32, _k);
    c.set(39, 32, _k);
    // Drippy base with gold flecks
    c.fillRect(16, 54, 8, 4, _sd);
    c.fillRect(28, 56, 10, 4, _sd);
    c.fillRect(40, 54, 8, 4, _sd);
    c.set(20, 55, _y);
    c.set(34, 57, _y);
    c.set(44, 55, _y);
    for (var x = 15; x <= 49; x++) {
      c.set(x, 53, _k);
      c.set(x, 60, _k);
    }
    return c.build();
  }

  static RetroPixelSpriteDefinition _eggGuardian() {
    final c = RetroPixelNative64Canvas();
    // Shield plates
    c.rectOutline(10, 28, 8, 20, _l, _k);
    c.rectOutline(46, 28, 8, 20, _l, _k);
    c.fillRect(12, 32, 4, 4, _y);
    c.fillRect(48, 32, 4, 4, _y);
    // Armored egg body
    c.outlineEllipse(32, 38, 17, 21, _dl, _k);
    c.fillEllipse(28, 34, 6, 8, _l);
    // Gold trim bands
    c.fillRect(18, 36, 28, 3, _y);
    c.fillRect(20, 46, 24, 3, _y);
    c.set(17, 35, _k);
    c.set(45, 35, _k);
    c.set(19, 45, _k);
    c.set(43, 45, _k);
    // Rune glow
    c.fillRect(30, 40, 4, 6, _l);
    c.fillRect(31, 38, 2, 2, _w);
    c.set(29, 39, _k);
    c.set(34, 39, _k);
    // Eyes
    c.eye(26, 32);
    c.eye(38, 32);
    // Legs
    c.fillRect(24, 56, 5, 6, _g);
    c.fillRect(35, 56, 5, 6, _g);
    c.fillRect(22, 60, 8, 2, _k);
    c.fillRect(34, 60, 8, 2, _k);
    return c.build();
  }

  static RetroPixelSpriteDefinition _shadowPhoenix() {
    final c = RetroPixelNative64Canvas();
    // Left wing
    c.fillRect(6, 22, 16, 6, _p);
    c.fillRect(4, 28, 18, 6, _dl);
    c.fillRect(8, 34, 14, 5, _p);
    c.fillRect(10, 38, 10, 4, _l);
    for (var x = 3; x <= 22; x++) {
      c.set(x, 21, _k);
      c.set(x, 42, _k);
    }
    // Right wing
    c.fillRect(42, 22, 16, 6, _p);
    c.fillRect(42, 28, 18, 6, _dl);
    c.fillRect(42, 34, 14, 5, _p);
    c.fillRect(44, 38, 10, 4, _l);
    for (var x = 41; x <= 60; x++) {
      c.set(x, 21, _k);
      c.set(x, 42, _k);
    }
    // Body
    c.outlineEllipse(32, 36, 12, 14, _dl, _k);
    c.fillEllipse(32, 34, 6, 8, _p);
    // Head
    c.outlineEllipse(32, 22, 8, 7, _dl, _k);
    // Glowing eyes
    c.fillRect(28, 20, 4, 4, _k);
    c.fillRect(34, 20, 4, 4, _k);
    c.set(29, 21, _l);
    c.set(35, 21, _l);
    // Beak
    c.fillRect(31, 26, 4, 3, _o);
    c.set(34, 27, _k);
    // Flame tail
    c.fillRect(28, 48, 4, 6, _l);
    c.fillRect(32, 50, 4, 8, _p);
    c.fillRect(36, 48, 4, 6, _l);
    c.set(27, 47, _k);
    c.set(40, 47, _k);
    c.set(33, 58, _k);
    // Talons
    c.fillRect(26, 48, 3, 6, _o);
    c.fillRect(35, 48, 3, 6, _o);
    c.set(25, 53, _k);
    c.set(38, 53, _k);
    return c.build();
  }

  static RetroPixelSpriteDefinition _rottenShell() {
    final c = RetroPixelNative64Canvas();
    // Jagged shell spikes
    c.fillRect(18, 14, 4, 6, _g);
    c.fillRect(26, 10, 4, 8, _g);
    c.fillRect(34, 12, 4, 7, _g);
    c.fillRect(42, 16, 4, 5, _g);
    for (var x = 17; x <= 46; x++) {
      c.set(x, 13, _k);
    }
    // Main corrupted shell body
    c.outlineEllipse(32, 38, 20, 22, _g, _k);
    c.fillEllipse(26, 34, 7, 9, _s);
    // Purple rot patches
    c.fillRect(24, 40, 8, 6, _p);
    c.fillRect(34, 42, 10, 5, _p);
    c.fillRect(28, 48, 6, 4, _sd);
    // Dark yolk core
    c.fillEllipse(32, 44, 8, 7, _o);
    c.fillRect(30, 42, 4, 4, _y);
    // Angry eyes
    c.fillRect(22, 30, 5, 4, _k);
    c.fillRect(37, 30, 5, 4, _k);
    c.set(23, 31, _r);
    c.set(38, 31, _r);
    c.set(24, 32, _k);
    c.set(39, 32, _k);
    // Toxic drips
    c.fillRect(20, 56, 4, 5, _sd);
    c.fillRect(30, 58, 5, 4, _p);
    c.fillRect(40, 56, 4, 5, _sd);
    c.set(19, 55, _k);
    c.set(44, 55, _k);
    return c.build();
  }
}
