import '../models/retro_pixel_sprite_definition.dart';
import 'retro_pixel_native_64_canvas.dart';
import 'retro_pixel_native_64_extended.dart';
import 'retro_pixel_palette.dart';

/// True native 64×64 Retro Pixel art — not upscaled legacy grids.
class RetroPixelNative64Sprites {
  RetroPixelNative64Sprites._();

  static const _k = RetroPixelPalette.black;
  static const _w = RetroPixelPalette.offWhite;
  static const _g = RetroPixelPalette.lightGray;
  static const _p = RetroPixelPalette.earPink;
  static const _pk = RetroPixelPalette.pink;
  static const _r = RetroPixelPalette.red;
  static const _o = RetroPixelPalette.orange;
  static const _y = RetroPixelPalette.yellow;
  static const _e = RetroPixelPalette.green;
  static const _d = RetroPixelPalette.darkGreen;
  static const _l = RetroPixelPalette.blue;
  static const _b = RetroPixelPalette.brown;
  static const _db = RetroPixelPalette.darkBrown;
  static const _t = RetroPixelPalette.tan;
  static const _s = RetroPixelPalette.slimeGreen;
  static const _sd = RetroPixelPalette.slimeDark;

  static const priorityIds = [
    'chicken',
    'mouse',
    'rabbit',
    'penguin',
    'alien_slime',
    'turtle',
    'moon_cat',
    'fox',
    'pig',
    'cow',
    'sheep',
    'fish',
    'horse',
    'monkey',
    'parrot',
    'deer',
    'slime_pet',
    'cloud_bunny',
  ];

  static final Map<String, RetroPixelSpriteDefinition> all = {
    for (final id in priorityIds) id: _builders[id]!(),
    ...RetroPixelNative64Extended.all,
  };

  /// Every animal id with native high-detail Retro Pixel art.
  static Set<String> get native64Ids => {
        ...priorityIds,
        ...RetroPixelNative64Extended.extendedIds,
      };

  static final Map<String, RetroPixelSpriteDefinition Function()> _builders = {
    'chicken': _chicken,
    'mouse': _mouse,
    'rabbit': _rabbit,
    'penguin': _penguin,
    'alien_slime': _frog,
    'turtle': _turtle,
    'moon_cat': _cat,
    'fox': _fox,
    'pig': _pig,
    'cow': _cow,
    'sheep': _sheep,
    'fish': _fish,
    'horse': _horse,
    'monkey': _monkey,
    'parrot': _parrot,
    'deer': _deer,
    'slime_pet': _slimePet,
    'cloud_bunny': _cloudBunny,
  };

  /// User-reference chicken style: white body, red comb/wattle, orange beak/feet.
  static RetroPixelSpriteDefinition _chicken() {
    final c = RetroPixelNative64Canvas();
    // Comb
    c.fillRect(26, 8, 12, 4, _r);
    c.fillRect(28, 6, 8, 2, _r);
    c.fillRect(30, 4, 4, 2, _r);
    for (var x = 26; x <= 37; x++) {
      c.set(x, 7, _k);
      c.set(x, 12, _k);
    }
    // Head
    c.outlineEllipse(32, 22, 10, 9, _w, _k);
    c.sideEye(38, 20);
    // Beak
    c.fillRect(42, 22, 6, 4, _o);
    c.fillRect(47, 23, 3, 2, _o);
    c.set(48, 22, _k);
    c.set(48, 25, _k);
    // Wattle
    c.fillRect(40, 28, 4, 5, _r);
    c.set(39, 28, _k);
    c.set(44, 28, _k);
    // Body
    c.outlineEllipse(30, 40, 14, 12, _w, _k);
    c.fillEllipse(24, 38, 4, 6, _g);
    c.fillRect(18, 36, 3, 8, _w);
    c.set(17, 36, _k);
    c.set(17, 43, _k);
    // Tail bump
    c.fillRect(14, 34, 5, 8, _w);
    c.fillRect(12, 36, 3, 4, _g);
    for (var y = 33; y <= 43; y++) {
      c.set(13, y, _k);
    }
    // Legs & feet
    c.fillRect(24, 50, 4, 6, _o);
    c.fillRect(34, 50, 4, 6, _o);
    c.fillRect(22, 56, 8, 3, _o);
    c.fillRect(32, 56, 8, 3, _o);
    c.set(22, 55, _k);
    c.set(26, 55, _k);
    c.set(29, 55, _k);
    c.set(32, 55, _k);
    c.set(36, 55, _k);
    c.set(39, 55, _k);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _mouse() {
    final c = RetroPixelNative64Canvas();
    // Ears
    c.outlineEllipse(22, 14, 5, 7, _p, _k);
    c.outlineEllipse(42, 14, 5, 7, _p, _k);
    // Head/body
    c.outlineEllipse(32, 32, 14, 12, _g, _k);
    c.eye(28, 28);
    c.eye(36, 28);
    c.set(32, 34, _k);
    // Whiskers
    c.set(16, 30, _k);
    c.set(14, 32, _k);
    c.set(16, 34, _k);
    c.set(48, 30, _k);
    c.set(50, 32, _k);
    c.set(48, 34, _k);
    // Belly
    c.fillEllipse(32, 36, 8, 6, RetroPixelPalette.white);
    // Feet
    c.paw(24, 44, _g);
    c.paw(36, 44, _g);
    // Tail
    c.fillRect(46, 36, 10, 3, _k);
    c.fillRect(52, 34, 4, 3, _k);
    return c.build(displayScale: 1.1);
  }

  static RetroPixelSpriteDefinition _rabbit() {
    final c = RetroPixelNative64Canvas();
    // Long ears
    c.rectOutline(18, 4, 8, 22, _w, _k);
    c.fillRect(20, 6, 4, 18, _p);
    c.rectOutline(38, 4, 8, 22, _w, _k);
    c.fillRect(40, 6, 4, 18, _p);
    // Head
    c.outlineEllipse(32, 30, 12, 10, _w, _k);
    c.eye(28, 28);
    c.eye(36, 28);
    // Pink nose + mouth
    c.fillRect(30, 34, 4, 3, _p);
    c.set(31, 37, _k);
    c.set(33, 37, _k);
    c.set(32, 38, _k);
    // Cheek fluff
    c.fillRect(20, 32, 4, 4, _w);
    c.fillRect(40, 32, 4, 4, _w);
    // Body
    c.outlineEllipse(32, 46, 12, 8, _w, _k);
    // Big hind feet
    c.fillRect(20, 52, 10, 6, _w);
    c.fillRect(34, 52, 10, 6, _w);
    for (var x = 20; x <= 29; x++) {
      c.set(x, 51, _k);
    }
    for (var x = 34; x <= 43; x++) {
      c.set(x, 51, _k);
    }
    c.set(22, 58, _k);
    c.set(26, 58, _k);
    c.set(36, 58, _k);
    c.set(40, 58, _k);
    // Cotton tail
    c.outlineEllipse(46, 44, 4, 4, _w, _k);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _cloudBunny() {
    final c = RetroPixelNative64Canvas();
    // Cloud wisps
    c.outlineEllipse(16, 20, 8, 6, _w, _k);
    c.outlineEllipse(48, 20, 8, 6, _w, _k);
    c.outlineEllipse(10, 36, 6, 5, _w, _k);
    c.outlineEllipse(54, 36, 6, 5, _w, _k);
    // Ears
    c.rectOutline(22, 10, 6, 16, _w, _k);
    c.fillRect(24, 12, 2, 12, _g);
    c.rectOutline(36, 10, 6, 16, _w, _k);
    c.fillRect(38, 12, 2, 12, _g);
    // Face
    c.outlineEllipse(32, 32, 11, 9, _w, _k);
    c.eye(28, 30);
    c.eye(36, 30);
    c.fillRect(30, 36, 4, 3, _p);
    c.set(31, 39, _k);
    c.set(33, 39, _k);
    // Body puff
    c.outlineEllipse(32, 48, 13, 9, _w, _k);
    c.fillRect(22, 54, 8, 5, _w);
    c.fillRect(34, 54, 8, 5, _w);
    for (var x = 22; x <= 41; x++) {
      c.set(x, 53, _k);
    }
    return c.build(displayScale: 1.06);
  }

  static RetroPixelSpriteDefinition _penguin() {
    final c = RetroPixelNative64Canvas();
    // Body black
    c.outlineEllipse(32, 38, 14, 18, _k, _k);
    // White belly
    c.fillEllipse(32, 40, 9, 14, _w);
    // Head
    c.outlineEllipse(32, 18, 10, 9, _k, _k);
    c.fillEllipse(32, 20, 7, 7, _k);
    c.sideEye(36, 17);
    // Beak
    c.fillRect(40, 20, 8, 5, _o);
    c.set(47, 21, _k);
    // Flippers
    c.fillRect(14, 34, 6, 14, _k);
    c.fillRect(44, 34, 6, 14, _k);
    c.set(13, 34, _k);
    c.set(50, 34, _k);
    // Feet
    c.fillRect(24, 54, 10, 4, _o);
    c.fillRect(30, 54, 10, 4, _o);
    c.set(24, 53, _k);
    c.set(39, 53, _k);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _frog() {
    final c = RetroPixelNative64Canvas();
    // Eye bumps
    c.outlineEllipse(24, 18, 7, 6, _e, _k);
    c.outlineEllipse(40, 18, 7, 6, _e, _k);
    c.eye(24, 18, sclera: RetroPixelPalette.white);
    c.eye(40, 18, sclera: RetroPixelPalette.white);
    // Head/body
    c.outlineEllipse(32, 36, 16, 12, _e, _k);
    c.fillRect(26, 38, 12, 4, _d);
    // Wide smile
    c.fillRect(24, 42, 16, 3, _d);
    c.set(25, 41, _k);
    c.set(39, 41, _k);
    // Legs
    c.fillRect(16, 46, 8, 6, _e);
    c.fillRect(40, 46, 8, 6, _e);
    c.fillRect(14, 52, 6, 4, _d);
    c.fillRect(44, 52, 6, 4, _d);
    c.set(14, 51, _k);
    c.set(49, 51, _k);
    return c.build(displayScale: 1.1);
  }

  static RetroPixelSpriteDefinition _turtle() {
    final c = RetroPixelNative64Canvas();
    // Shell
    c.outlineEllipse(32, 34, 18, 14, _d, _k);
    for (var i = 0; i < 5; i++) {
      c.fillRect(20 + i * 5, 28 + (i % 2), 4, 10, _e);
    }
    c.fillRect(28, 30, 8, 8, _d);
    // Head
    c.outlineEllipse(32, 16, 8, 6, _e, _k);
    c.sideEye(36, 15);
    c.set(38, 18, _k);
    // Legs
    c.fillRect(12, 40, 8, 6, _e);
    c.fillRect(44, 40, 8, 6, _e);
    c.fillRect(16, 48, 6, 5, _e);
    c.fillRect(42, 48, 6, 5, _e);
    for (final x in [11, 19, 43, 51]) {
      c.set(x, 39, _k);
    }
    // Tail
    c.fillRect(30, 48, 4, 3, _e);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _cat() {
    final c = RetroPixelNative64Canvas();
    // Ears
    c.fillRect(18, 12, 8, 10, _g);
    c.fillRect(38, 12, 8, 10, _g);
    c.set(17, 12, _k);
    c.set(46, 12, _k);
    c.fillRect(20, 14, 4, 6, _p);
    c.fillRect(40, 14, 4, 6, _p);
    // Head
    c.outlineEllipse(32, 28, 12, 10, _g, _k);
    c.eye(28, 26);
    c.eye(36, 26);
    c.fillRect(30, 32, 4, 3, _p);
    // Whiskers
    for (final y in [30, 32, 34]) {
      c.set(16, y, _k);
      c.set(48, y, _k);
    }
    // Body
    c.outlineEllipse(32, 44, 11, 9, _g, _k);
    // Paws
    c.paw(22, 52, _g);
    c.paw(38, 52, _g);
    // Tail
    c.fillRect(44, 40, 12, 4, _g);
    c.fillRect(52, 36, 4, 6, _g);
    c.set(43, 40, _k);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _fox() {
    final c = RetroPixelNative64Canvas();
    // Ears
    c.fillRect(18, 10, 9, 12, _o);
    c.fillRect(37, 10, 9, 12, _o);
    c.fillRect(20, 12, 5, 8, _k);
    c.fillRect(39, 12, 5, 8, _k);
    // Head
    c.outlineEllipse(32, 26, 12, 10, _o, _k);
    c.eye(28, 24);
    c.eye(36, 24);
    // White muzzle
    c.fillRect(28, 30, 8, 6, _w);
    c.set(31, 35, _k);
    c.set(33, 35, _k);
    // Body
    c.outlineEllipse(30, 44, 13, 10, _o, _k);
    c.fillRect(24, 40, 8, 8, _w);
    // Legs
    c.fillRect(22, 52, 5, 8, _k);
    c.fillRect(34, 52, 5, 8, _k);
    // Bushy tail
    c.fillRect(42, 36, 14, 10, _o);
    c.fillRect(50, 34, 6, 8, _w);
    c.set(41, 36, _k);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _pig() {
    final c = RetroPixelNative64Canvas();
    // Ears
    c.fillRect(18, 14, 8, 8, _pk);
    c.fillRect(38, 14, 8, 8, _pk);
    c.set(17, 14, _k);
    c.set(46, 14, _k);
    // Head
    c.outlineEllipse(32, 28, 13, 11, _pk, _k);
    c.eye(26, 26);
    c.eye(38, 26);
    // Snout
    c.outlineEllipse(32, 34, 7, 5, _p, _k);
    c.set(30, 34, _k);
    c.set(34, 34, _k);
    // Body
    c.outlineEllipse(32, 46, 14, 10, _pk, _k);
    // Legs
    c.fillRect(22, 54, 6, 6, _pk);
    c.fillRect(36, 54, 6, 6, _pk);
    c.fillRect(22, 59, 6, 2, _k);
    c.fillRect(36, 59, 6, 2, _k);
    // Curly tail hint
    c.fillRect(46, 42, 6, 6, _pk);
    c.set(51, 41, _k);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _cow() {
    final c = RetroPixelNative64Canvas();
    // Horns
    c.fillRect(20, 10, 4, 8, _db);
    c.fillRect(40, 10, 4, 8, _db);
    c.set(19, 10, _k);
    c.set(44, 10, _k);
    // Head
    c.outlineEllipse(32, 24, 13, 10, _w, _k);
    c.fillRect(24, 20, 6, 5, _k);
    c.fillRect(34, 22, 5, 4, _k);
    c.eye(26, 22);
    c.eye(38, 22);
    // Pink snout
    c.fillRect(28, 30, 8, 5, _p);
    c.set(30, 31, _k);
    c.set(34, 31, _k);
    // Body with spots
    c.outlineEllipse(32, 44, 16, 12, _w, _k);
    c.fillRect(22, 40, 8, 6, _k);
    c.fillRect(38, 46, 7, 5, _k);
    // Udder hint
    c.fillRect(28, 52, 8, 3, _p);
    // Hooves
    c.hoof(22, 52, _w);
    c.hoof(36, 52, _w);
    return c.build(displayScale: 1.06);
  }

  static RetroPixelSpriteDefinition _sheep() {
    final c = RetroPixelNative64Canvas();
    // Wool puffs
    for (var i = 0; i < 6; i++) {
      c.outlineEllipse(16 + i * 6, 28 + (i % 2) * 2, 5, 5, _w, _k);
    }
    c.outlineEllipse(32, 32, 16, 12, _w, _k);
    // Dark face
    c.fillRect(26, 36, 12, 8, RetroPixelPalette.darkGray);
    c.eye(28, 38, sclera: _w);
    c.eye(36, 38, sclera: _w);
    c.set(32, 42, _k);
    // Legs
    c.fillRect(22, 50, 5, 10, RetroPixelPalette.darkGray);
    c.fillRect(37, 50, 5, 10, RetroPixelPalette.darkGray);
    c.fillRect(21, 59, 7, 2, _k);
    c.fillRect(36, 59, 7, 2, _k);
    return c.build(displayScale: 1.06);
  }

  static RetroPixelSpriteDefinition _fish() {
    final c = RetroPixelNative64Canvas();
    // Body
    c.outlineEllipse(30, 32, 18, 10, _l, _k);
    c.fillRect(18, 28, 6, 8, RetroPixelPalette.darkBlue);
    // Tail
    c.fillRect(46, 26, 10, 12, _l);
    c.fillRect(52, 24, 6, 16, RetroPixelPalette.darkBlue);
    c.set(45, 26, _k);
    // Fins
    c.fillRect(24, 20, 8, 5, RetroPixelPalette.darkBlue);
    c.fillRect(26, 42, 8, 5, RetroPixelPalette.darkBlue);
    c.set(23, 20, _k);
    c.set(25, 47, _k);
    // Eye & mouth
    c.eye(36, 30);
    c.set(22, 32, _k);
    // Scales highlight
    c.fillRect(28, 30, 3, 2, RetroPixelPalette.white);
    c.fillRect(34, 34, 3, 2, RetroPixelPalette.white);
    return c.build(displayScale: 1.1);
  }

  static RetroPixelSpriteDefinition _horse() {
    final c = RetroPixelNative64Canvas();
    // Mane
    c.fillRect(22, 8, 8, 18, _db);
    c.fillRect(20, 10, 4, 14, _b);
    // Head
    c.outlineEllipse(30, 22, 10, 8, _b, _k);
    c.sideEye(34, 20);
    c.fillRect(38, 24, 8, 4, _b);
    c.fillRect(44, 25, 4, 2, _k);
    // Neck/body
    c.fillRect(24, 28, 14, 16, _b);
    c.outlineEllipse(32, 42, 12, 10, _b, _k);
    // Legs
    for (final x in [22, 30, 34, 42]) {
      c.fillRect(x, 50, 4, 10, _b);
      c.fillRect(x - 1, 59, 6, 2, _k);
    }
    // Tail
    c.fillRect(44, 36, 10, 12, _db);
    c.set(43, 36, _k);
    return c.build(displayScale: 1.06);
  }

  static RetroPixelSpriteDefinition _monkey() {
    final c = RetroPixelNative64Canvas();
    // Ears
    c.outlineEllipse(18, 22, 5, 5, _b, _k);
    c.outlineEllipse(46, 22, 5, 5, _b, _k);
    // Head tan face
    c.outlineEllipse(32, 28, 12, 10, _t, _k);
    c.fillRect(26, 26, 12, 8, _t);
    c.eye(28, 26);
    c.eye(36, 26);
    c.set(32, 34, _k);
    // Body
    c.outlineEllipse(32, 44, 12, 10, _b, _k);
    c.fillRect(28, 42, 8, 6, _t);
    // Arms
    c.fillRect(14, 38, 8, 5, _b);
    c.fillRect(42, 38, 8, 5, _b);
    // Hands/feet
    c.fillRect(12, 42, 6, 4, _t);
    c.fillRect(46, 42, 6, 4, _t);
    c.fillRect(24, 52, 6, 5, _b);
    c.fillRect(34, 52, 6, 5, _b);
    // Tail
    c.fillRect(48, 40, 10, 4, _b);
    c.fillRect(54, 36, 4, 6, _b);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _parrot() {
    final c = RetroPixelNative64Canvas();
    // Head red
    c.outlineEllipse(28, 20, 9, 8, _r, _k);
    c.sideEye(32, 18);
    // Beak
    c.fillRect(36, 22, 8, 5, _o);
    c.set(43, 23, _k);
    // Body blocks
    c.fillRect(22, 30, 18, 10, _r);
    c.fillRect(24, 40, 14, 8, _e);
    c.fillRect(26, 48, 10, 6, _l);
    c.fillRect(20, 34, 6, 6, _y);
    for (var y = 29; y <= 54; y++) {
      c.set(21, y, _k);
      c.set(40, y, _k);
    }
    // Wing
    c.fillRect(14, 34, 8, 12, _e);
    c.set(13, 34, _k);
    // Tail feathers
    c.fillRect(38, 44, 4, 10, _r);
    c.fillRect(42, 46, 4, 10, _y);
    c.fillRect(46, 48, 4, 10, _l);
    // Feet
    c.fillRect(26, 54, 6, 3, _o);
    c.fillRect(32, 54, 6, 3, _o);
    return c.build(displayScale: 1.08);
  }

  static RetroPixelSpriteDefinition _deer() {
    final c = RetroPixelNative64Canvas();
    // Antlers
    c.fillRect(22, 6, 3, 12, _db);
    c.fillRect(39, 6, 3, 12, _db);
    c.fillRect(18, 8, 6, 3, _db);
    c.fillRect(40, 8, 6, 3, _db);
    c.set(17, 8, _k);
    c.set(46, 8, _k);
    // Head
    c.outlineEllipse(32, 24, 10, 8, _b, _k);
    c.eye(28, 22);
    c.eye(36, 22);
    c.fillRect(30, 28, 4, 3, _k);
    // Body
    c.outlineEllipse(32, 42, 13, 10, _b, _k);
    c.fillRect(24, 40, 6, 4, _w);
    // Legs
    for (final x in [24, 32, 36, 44]) {
      c.fillRect(x, 50, 4, 10, _b);
      c.fillRect(x - 1, 59, 6, 2, _k);
    }
    // Tail
    c.fillRect(46, 44, 4, 4, _w);
    c.set(45, 44, _k);
    return c.build(displayScale: 1.06);
  }

  static RetroPixelSpriteDefinition _slimePet() {
    final c = RetroPixelNative64Canvas();
    // Blob body
    c.outlineEllipse(32, 38, 16, 14, _s, _k);
    c.fillEllipse(24, 34, 5, 4, _sd);
    c.fillEllipse(40, 34, 5, 4, _sd);
    // Shine
    c.fillRect(22, 26, 6, 4, RetroPixelPalette.white);
    c.fillRect(24, 28, 3, 2, _s);
    // Face
    c.eye(26, 34);
    c.eye(38, 34);
    c.fillRect(28, 40, 8, 3, _sd);
    c.set(29, 39, _k);
    c.set(35, 39, _k);
    // Drips
    c.fillRect(18, 50, 4, 6, _s);
    c.fillRect(42, 50, 4, 6, _s);
    c.fillRect(30, 52, 4, 5, _s);
    c.set(17, 50, _k);
    c.set(41, 50, _k);
    c.set(29, 52, _k);
    return c.build(displayScale: 1.1);
  }
}
