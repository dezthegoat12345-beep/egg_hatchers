import '../models/retro_pixel_sprite_definition.dart';
import 'retro_pixel_chicken.dart';
import 'retro_pixel_hand_authored_sprites.dart';
import 'retro_pixel_palette.dart';

/// Massive-grid (64×64) Retro Pixel sprites for the most visible animals.
///
/// Built from native 32×32 hand-authored bases upscaled to 64×64, then patched
/// with finer pixel detail. Separate from the 16×16 custom sprite editor grid.
class RetroPixelMassiveSprites {
  RetroPixelMassiveSprites._();

  static const _k = RetroPixelPalette.black;
  static const _w = RetroPixelPalette.offWhite;
  static const _p = RetroPixelPalette.earPink;
  static const _o = RetroPixelPalette.orange;
  static const _g = RetroPixelPalette.lightGray;
  static const _e = RetroPixelPalette.darkGreen;
  static const _b = RetroPixelPalette.brown;

  /// Minimum built-in Retro Pixel grid dimension (massive-grid target).
  static const int massiveGridSize = 64;

  static RetroPixelSpriteDefinition _to64(
    RetroPixelSpriteDefinition base32, {
    Map<(int x, int y), int?>? patches,
  }) {
    var sprite = base32.width >= massiveGridSize
        ? base32
        : base32.scaleToMinDimension(massiveGridSize);
    if (patches != null && patches.isNotEmpty) {
      sprite = sprite.withPatches(patches);
    }
    return sprite;
  }

  // --- 64×64 priority animals ------------------------------------------------

  static final mouse = _to64(RetroPixelHandAuthoredSprites.mouse, patches: {
    (18, 14): _k, (19, 14): _w, (20, 14): _k,
    (44, 14): _k, (45, 14): _w, (46, 14): _k,
    (28, 22): _p, (29, 22): _p, (34, 22): _p, (35, 22): _p,
    (16, 36): _k, (17, 36): _g, (18, 37): _k,
    (46, 36): _k, (47, 36): _g, (48, 37): _k,
    (20, 52): _k, (21, 52): _g, (22, 53): _k, (23, 53): _k,
    (40, 52): _k, (41, 52): _g, (42, 53): _k, (43, 53): _k,
    (28, 56): _k, (29, 56): _k, (34, 56): _k, (35, 56): _k,
    (30, 58): _g, (33, 58): _g,
  });

  static final rabbit = _to64(RetroPixelHandAuthoredSprites.rabbit, patches: {
    (12, 8): _p, (13, 6): _p, (14, 4): _k, (15, 4): _p,
    (48, 8): _p, (49, 6): _p, (50, 4): _k, (51, 4): _p,
    (20, 24): _k, (21, 24): _w, (22, 24): _k,
    (42, 24): _k, (43, 24): _w, (44, 24): _k,
    (28, 30): _p, (29, 31): _k, (30, 31): _k, (33, 31): _k, (34, 31): _k,
    (56, 28): _w, (57, 28): _w, (58, 29): _w, (57, 30): _w,
    (20, 56): _k, (21, 56): _w, (22, 57): _k,
    (42, 56): _k, (43, 56): _w, (44, 57): _k,
    (28, 52): _k, (29, 52): _k, (34, 52): _k, (35, 52): _k,
  });

  static final cloudBunny = _to64(
    RetroPixelHandAuthoredSprites.rabbit.recolor({
      RetroPixelPalette.offWhite: RetroPixelPalette.white,
      RetroPixelPalette.earPink: RetroPixelPalette.lightGray,
    }),
    patches: {
      (14, 10): RetroPixelPalette.lightGray,
      (50, 10): RetroPixelPalette.lightGray,
      (26, 26): _k, (27, 26): RetroPixelPalette.blue,
      (28, 26): _k,
      (36, 26): _k, (37, 26): RetroPixelPalette.blue,
      (38, 26): _k,
    },
  );

  static final turtle = _to64(RetroPixelHandAuthoredSprites.turtle, patches: {
    (28, 16): _k, (29, 16): _w, (30, 16): _k, (33, 16): _k, (34, 16): _w, (35, 16): _k,
    (24, 20): _e, (25, 20): RetroPixelPalette.green, (26, 20): _e,
    (38, 20): _e, (39, 20): RetroPixelPalette.green, (40, 20): _e,
    (22, 28): RetroPixelPalette.green, (24, 28): _e, (26, 28): RetroPixelPalette.green,
    (38, 28): RetroPixelPalette.green, (40, 28): _e, (42, 28): RetroPixelPalette.green,
    (12, 44): _k, (13, 44): _e, (14, 45): _k, (15, 45): _k,
    (50, 44): _k, (51, 44): _e, (52, 45): _k, (53, 45): _k,
    (28, 48): _e, (29, 48): RetroPixelPalette.green, (30, 48): _e,
    (33, 48): _e, (34, 48): RetroPixelPalette.green, (35, 48): _e,
    (30, 52): _k, (31, 52): _e, (32, 52): _e, (33, 52): _k,
  });

  static final pig = _to64(RetroPixelHandAuthoredSprites.pig, patches: {
    (24, 20): _k, (25, 20): _w, (26, 20): _k,
    (38, 20): _k, (39, 20): _w, (40, 20): _k,
    (28, 28): _k, (29, 28): RetroPixelPalette.pink, (30, 28): _k,
    (31, 28): _k, (32, 28): RetroPixelPalette.pink, (33, 28): _k,
    (34, 28): _k, (35, 28): RetroPixelPalette.pink, (36, 28): _k,
    (52, 32): RetroPixelPalette.pink, (53, 32): RetroPixelPalette.pink,
    (54, 33): RetroPixelPalette.pink,
    (20, 52): _k, (21, 52): _k, (22, 53): RetroPixelPalette.pink,
    (42, 52): _k, (43, 52): _k, (44, 53): RetroPixelPalette.pink,
    (30, 36): RetroPixelPalette.pink, (33, 36): RetroPixelPalette.pink,
  });

  static final cow = _to64(RetroPixelHandAuthoredSprites.cow, patches: {
    (20, 16): _k, (22, 16): _w, (24, 16): _k,
    (40, 16): _k, (42, 16): _w, (44, 16): _k,
    (28, 28): _k, (29, 28): _k, (30, 28): _k, (33, 28): _k, (34, 28): _k, (35, 28): _k,
    (20, 12): _k, (21, 10): _k, (22, 8): _k,
    (44, 12): _k, (45, 10): _k, (46, 8): _k,
    (20, 52): _k, (21, 52): _k, (22, 53): _k,
    (42, 52): _k, (43, 52): _k, (44, 53): _k,
    (56, 36): _k, (57, 36): RetroPixelPalette.pink, (58, 37): _k,
    (18, 24): _k, (46, 24): _k,
  });

  static final sheep = _to64(RetroPixelHandAuthoredSprites.sheep, patches: {
    (24, 28): _k, (25, 28): _w, (26, 28): _k,
    (38, 28): _k, (39, 28): _w, (40, 28): _k,
    (30, 32): _k, (31, 32): _k, (32, 32): _k, (33, 32): _k,
    (16, 20): _w, (18, 18): _w, (20, 20): _w, (22, 18): _w,
    (42, 20): _w, (44, 18): _w, (46, 20): _w, (48, 18): _w,
    (20, 52): _k, (21, 52): _k, (22, 53): _k,
    (42, 52): _k, (43, 52): _k, (44, 53): _k,
    (28, 24): RetroPixelPalette.darkGray, (36, 24): RetroPixelPalette.darkGray,
  });

  static final penguin = _to64(RetroPixelHandAuthoredSprites.penguin, patches: {
    (28, 20): _k, (29, 20): _w, (30, 20): _k, (33, 20): _k, (34, 20): _w, (35, 20): _k,
    (24, 28): RetroPixelPalette.darkGray, (26, 28): _k, (38, 28): _k, (40, 28): RetroPixelPalette.darkGray,
    (20, 48): _o, (21, 48): _o, (22, 49): _k,
    (42, 48): _o, (43, 48): _o, (44, 49): _k,
    (16, 40): RetroPixelPalette.darkGray, (48, 40): RetroPixelPalette.darkGray,
    (30, 36): _k, (31, 36): _w, (32, 36): _w, (33, 36): _k,
  });

  static final frog = _to64(RetroPixelHandAuthoredSprites.frog, patches: {
    (20, 16): _k, (21, 16): _w, (22, 16): _k,
    (42, 16): _k, (43, 16): _w, (44, 16): _k,
    (28, 36): _k, (29, 36): _k, (30, 36): _k, (33, 36): _k, (34, 36): _k, (35, 36): _k,
    (16, 48): _e, (17, 48): RetroPixelPalette.green, (18, 49): _k,
    (46, 48): _e, (47, 48): RetroPixelPalette.green, (48, 49): _k,
    (12, 52): _k, (13, 52): _e, (14, 53): _k,
    (50, 52): _k, (51, 52): _e, (52, 53): _k,
    (24, 12): RetroPixelPalette.green, (40, 12): RetroPixelPalette.green,
  });

  static final moonCat = _to64(RetroPixelHandAuthoredSprites.moonCat, patches: {
    (20, 24): _k, (21, 24): _w, (22, 24): _k,
    (42, 24): _k, (43, 24): _w, (44, 24): _k,
    (28, 30): _p, (29, 31): _k, (30, 31): _k, (33, 31): _k, (34, 31): _k,
    (56, 40): _w, (57, 40): _w, (58, 41): _w, (57, 42): _w,
    (28, 52): _k, (29, 52): _k, (34, 52): _k, (35, 52): _k,
    (30, 56): _k, (33, 56): _k,
    (14, 8): _k, (50, 8): _k,
  });

  static final fish = _to64(RetroPixelHandAuthoredSprites.fish, patches: {
    (36, 24): _k, (37, 24): _w, (38, 24): _k,
    (28, 28): _k, (29, 28): RetroPixelPalette.darkBlue,
    (16, 20): RetroPixelPalette.darkBlue, (16, 21): RetroPixelPalette.blue,
    (16, 36): RetroPixelPalette.darkBlue, (16, 37): RetroPixelPalette.blue,
    (48, 32): RetroPixelPalette.darkBlue, (49, 32): RetroPixelPalette.blue,
    (50, 31): RetroPixelPalette.darkBlue, (50, 32): RetroPixelPalette.blue,
    (50, 33): RetroPixelPalette.darkBlue,
    (32, 30): RetroPixelPalette.lightGray, (33, 30): _w,
    (56, 28): RetroPixelPalette.darkBlue, (57, 28): RetroPixelPalette.blue,
  });

  static final horse = _to64(RetroPixelHandAuthoredSprites.horse, patches: {
    (24, 20): _k, (25, 20): _w, (26, 20): _k,
    (38, 20): _k, (39, 20): _w, (40, 20): _k,
    (28, 28): _k, (29, 28): _k, (30, 28): _k, (33, 28): _k, (34, 28): _k, (35, 28): _k,
    (20, 12): RetroPixelPalette.darkBrown, (21, 10): _b, (22, 8): _b,
    (36, 12): RetroPixelPalette.darkBrown, (37, 10): _b, (38, 8): _b,
    (16, 52): _k, (17, 52): _k, (18, 53): _k,
    (46, 52): _k, (47, 52): _k, (48, 53): _k,
    (56, 28): RetroPixelPalette.darkBrown, (57, 28): _b, (58, 29): _b, (59, 30): _k,
    (44, 12): _b, (45, 12): RetroPixelPalette.darkBrown,
  });

  static final monkey = _to64(RetroPixelHandAuthoredSprites.monkey, patches: {
    (24, 24): _k, (25, 24): _w, (26, 24): _k,
    (38, 24): _k, (39, 24): _w, (40, 24): _k,
    (28, 32): _k, (29, 32): _k, (30, 32): _k, (33, 32): _k, (34, 32): _k, (35, 32): _k,
    (16, 44): _b, (17, 44): RetroPixelPalette.tan,
    (48, 44): _b, (49, 44): RetroPixelPalette.tan,
    (20, 52): _k, (21, 52): _k, (22, 53): _k,
    (42, 52): _k, (43, 52): _k, (44, 53): _k,
    (56, 36): _b, (57, 36): _b, (58, 37): _k,
    (20, 16): RetroPixelPalette.tan, (44, 16): RetroPixelPalette.tan,
  });

  static final parrot = _to64(RetroPixelHandAuthoredSprites.parrot, patches: {
    (28, 20): _k, (29, 20): _w, (30, 20): _k, (33, 20): _k, (34, 20): _w, (35, 20): _k,
    (20, 28): RetroPixelPalette.red, (21, 28): RetroPixelPalette.yellow,
    (22, 32): RetroPixelPalette.green, (23, 32): RetroPixelPalette.blue,
    (36, 28): RetroPixelPalette.red, (38, 32): RetroPixelPalette.blue,
    (16, 36): RetroPixelPalette.darkGreen, (17, 36): RetroPixelPalette.green,
    (20, 48): _o, (21, 48): _o, (22, 49): _k,
    (42, 48): _o, (43, 48): _o, (44, 49): _k,
    (52, 32): RetroPixelPalette.red, (53, 32): RetroPixelPalette.yellow,
    (54, 33): RetroPixelPalette.blue, (55, 34): RetroPixelPalette.green,
  });

  static final deer = _to64(RetroPixelHandAuthoredSprites.deer, patches: {
    (24, 24): _k, (25, 24): _w, (26, 24): _k,
    (38, 24): _k, (39, 24): _w, (40, 24): _k,
    (28, 32): _k, (29, 32): _k, (30, 32): _k, (33, 32): _k, (34, 32): _k, (35, 32): _k,
    (12, 8): _k, (13, 6): _b, (14, 4): _k,
    (50, 8): _k, (51, 6): _b, (52, 4): _k,
    (20, 52): _k, (21, 52): _k, (22, 53): _k,
    (42, 52): _k, (43, 52): _k, (44, 53): _k,
    (56, 36): _b, (57, 36): _k,
    (58, 38): _w, (59, 38): _w,
  });

  static final fox = _to64(RetroPixelHandAuthoredSprites.fox, patches: {
    (20, 24): _k, (21, 24): _w, (22, 24): _k,
    (42, 24): _k, (43, 24): _w, (44, 24): _k,
    (28, 30): _k, (29, 31): _k, (30, 31): _k, (33, 31): _k, (34, 31): _k,
    (24, 40): _w, (25, 40): _w, (26, 41): _w,
    (38, 40): _w, (39, 40): _w,
    (56, 32): _w, (57, 32): _w, (58, 33): _w, (57, 34): _w,
    (28, 52): _k, (29, 52): _k, (34, 52): _k, (35, 52): _k,
    (30, 56): _k, (33, 56): _k,
  });

  static final slimePet = _to64(RetroPixelHandAuthoredSprites.slimePet, patches: {
    (24, 24): _k, (25, 24): _w, (26, 24): _k,
    (38, 24): _k, (39, 24): _w, (40, 24): _k,
    (28, 32): _k, (29, 32): _k, (30, 32): _k, (33, 32): _k, (34, 32): _k, (35, 32): _k,
    (20, 20): _w, (21, 20): _w,
    (16, 44): RetroPixelPalette.slimeDark, (48, 44): RetroPixelPalette.slimeDark,
    (24, 56): RetroPixelPalette.slimeDark, (40, 56): RetroPixelPalette.slimeDark,
    (30, 48): RetroPixelPalette.slimeDark, (33, 48): RetroPixelPalette.slimeDark,
  });

  /// Chicken stays anchored to the user reference, upscaled to 64×64 with
  /// subtle comb/toe/eye refinements at the finer grid.
  static final chicken = RetroPixelChickenReference.definition.withPatches({
    (28, 12): RetroPixelPalette.red, (29, 12): RetroPixelPalette.red,
    (34, 12): RetroPixelPalette.red, (35, 12): RetroPixelPalette.red,
    (30, 14): RetroPixelPalette.red, (33, 14): RetroPixelPalette.red,
    (24, 28): _k, (25, 28): _w, (26, 28): _k,
    (38, 28): _k, (39, 28): _w, (40, 28): _k,
    (28, 36): RetroPixelPalette.red, (29, 36): RetroPixelPalette.red,
    (34, 36): RetroPixelPalette.red, (35, 36): RetroPixelPalette.red,
    (24, 52): _o, (25, 52): _o, (26, 53): _k,
    (38, 52): _o, (39, 52): _o, (40, 53): _k,
    (28, 56): _o, (29, 56): _o, (30, 57): _k, (33, 57): _k,
    (34, 56): _o, (35, 56): _o,
  });

  /// Priority animals upgraded to massive 64×64 grids.
  static final Map<String, RetroPixelSpriteDefinition> priority = {
    'chicken': chicken,
    'mouse': mouse,
    'rabbit': rabbit,
    'cloud_bunny': cloudBunny,
    'turtle': turtle,
    'pig': pig,
    'cow': cow,
    'sheep': sheep,
    'penguin': penguin,
    'alien_slime': frog,
    'moon_cat': moonCat,
    'fish': fish,
    'horse': horse,
    'monkey': monkey,
    'parrot': parrot,
    'deer': deer,
    'fox': fox,
    'slime_pet': slimePet,
  };

  /// Upscale any sprite below [massiveGridSize] to at least 48×48 (64 preferred).
  static RetroPixelSpriteDefinition ensureMassiveGrid(
    RetroPixelSpriteDefinition sprite,
  ) {
    if (sprite.width >= 48 && sprite.height >= 48) return sprite;
    return sprite.scaleToMinDimension(48);
  }
}
