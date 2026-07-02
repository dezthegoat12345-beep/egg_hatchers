import '../models/retro_pixel_sprite_definition.dart';

/// Retro Pixel chicken transcribed from the user-provided reference image.
///
/// Stored at 16×16 then upscaled to 64×64 for massive-grid Retro Pixel theme
/// rendering — separate from the custom sprite editor grid.
class RetroPixelChickenReference {
  RetroPixelChickenReference._();

  static const int black = 0xFF000000;
  static const int offWhite = 0xFFF5F5F5;
  static const int red = 0xFFE53935;
  static const int orange = 0xFFFF8A65;

  static final List<int?> _pixels16 = [
    null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
    null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
    null, null, null, null, null, black, red, red, black, null, null, null, null, null, null, null,
    null, null, null, black, black, black, black, black, black, black, black, null, null, null, null, null,
    null, null, black, orange, black, offWhite, offWhite, offWhite, offWhite, offWhite, black, null, null, black, null, null,
    null, black, orange, orange, orange, offWhite, offWhite, offWhite, black, offWhite, black, null, null, black, black, null,
    black, orange, black, black, black, offWhite, offWhite, offWhite, offWhite, offWhite, black, black, black, offWhite, black, null,
    null, black, red, black, offWhite, offWhite, offWhite, offWhite, offWhite, offWhite, black, offWhite, offWhite, offWhite, black, null,
    null, black, red, black, black, offWhite, offWhite, black, offWhite, offWhite, offWhite, offWhite, offWhite, offWhite, black, null,
    null, null, black, black, offWhite, offWhite, offWhite, black, black, black, offWhite, offWhite, black, black, black, null,
    null, null, null, black, offWhite, offWhite, offWhite, offWhite, offWhite, offWhite, offWhite, offWhite, offWhite, black, null, null,
    null, null, null, null, black, offWhite, offWhite, offWhite, offWhite, black, offWhite, offWhite, black, black, null, null,
    null, null, null, black, offWhite, offWhite, offWhite, black, offWhite, black, offWhite, offWhite, black, black, null, null,
    null, null, null, null, black, offWhite, offWhite, offWhite, offWhite, black, offWhite, black, black, black, null, null,
    null, null, null, null, null, black, offWhite, offWhite, offWhite, black, offWhite, black, black, null, null, null,
    null, null, null, null, null, null, black, black, black, black, black, null, null, null, null, null,
  ];

  static final RetroPixelSpriteDefinition definition32 =
      RetroPixelSpriteDefinition.fromCustomSpriteGrid(
        pixels: _pixels16,
      ).scale2x();

  /// 64×64 massive-grid chicken (4× upscale from user reference).
  static final RetroPixelSpriteDefinition definition = definition32.scale2x();
}
