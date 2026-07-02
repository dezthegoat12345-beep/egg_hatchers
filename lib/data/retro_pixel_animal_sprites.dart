import '../models/custom_sprite_data.dart';
import 'sprite_reference_data.dart';

/// Retro Pixel animal sprites — 16×16 grids rendered with crisp scaling.
///
/// Chicken uses the polished sprite reference grid directly (player style guide).
/// Other v1 animals reuse reference silhouettes with a black outline pass.
class RetroPixelAnimalSprites {
  RetroPixelAnimalSprites._();

  static const int outlineBlack = 0xFF000000;

  /// Animals with dedicated Retro Pixel art in v1.
  static const v1AnimalIds = <String>{
    'chicken',
    'mouse',
    'rabbit',
    'turtle',
    'pig',
    'cow',
    'sheep',
    'fox',
    'penguin',
    'moon_cat',
  };

  static final Map<String, CustomSpriteData> _sprites = _buildSprites();

  static Map<String, CustomSpriteData> _buildSprites() {
    final sprites = <String, CustomSpriteData>{};

    for (final animalId in v1AnimalIds) {
      final reference = SpriteReferenceData.referenceFor(animalId);
      if (reference == null) continue;

      if (animalId == 'chicken') {
        // Match the uploaded / editor reference chicken pixel-for-pixel.
        sprites[animalId] = reference;
      } else {
        sprites[animalId] = _withBlackOutline(reference);
      }
    }

    return sprites;
  }

  static bool hasSprite(String animalId) => _sprites.containsKey(animalId);

  static CustomSpriteData? spriteFor(String animalId) => _sprites[animalId];

  /// Adds a 1-cell black outline around visible pixels (4-direction neighbors).
  static CustomSpriteData _withBlackOutline(CustomSpriteData source) {
    final size = CustomSpriteData.gridSize;
    final filled = source.pixels;

    bool isColored(int x, int y) {
      if (x < 0 || x >= size || y < 0 || y >= size) return false;
      return filled[y * size + x] != null;
    }

    final next = List<int?>.filled(CustomSpriteData.cellCount, null);

    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final index = y * size + x;
        final color = filled[index];
        if (color != null) {
          next[index] = color;
          continue;
        }

        if (isColored(x - 1, y) ||
            isColored(x + 1, y) ||
            isColored(x, y - 1) ||
            isColored(x, y + 1)) {
          next[index] = outlineBlack;
        }
      }
    }

    return CustomSpriteData(pixels: next);
  }
}
