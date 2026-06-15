import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/models/custom_sprite_data.dart';

void main() {
  test('applyBrush paints a 2x2 area', () {
    final empty = CustomSpriteData.empty();
    final painted = empty.applyBrush(5, 5, 2, 0xFFE53935);

    expect(painted.pixelAt(5, 5), 0xFFE53935);
    expect(painted.pixelAt(6, 5), 0xFFE53935);
    expect(painted.pixelAt(5, 6), 0xFFE53935);
    expect(painted.pixelAt(6, 6), 0xFFE53935);
    expect(painted.pixelAt(4, 5), isNull);
  });

  test('applyBrush clamps to grid edges', () {
    final empty = CustomSpriteData.empty();
    final painted = empty.applyBrush(15, 15, 3, 0xFF1E88E5);

    expect(painted.pixelAt(15, 15), 0xFF1E88E5);
    expect(painted.pixelAt(14, 14), 0xFF1E88E5);
    expect(painted.pixelAt(16, 16), isNull);
  });

  test('floodFill fills connected cells of the same color', () {
    var data = CustomSpriteData.empty();
    data = data.setPixel(4, 4, 0xFF43A047);
    data = data.setPixel(5, 4, 0xFF43A047);
    data = data.setPixel(4, 5, 0xFF43A047);
    data = data.setPixel(8, 8, 0xFFE53935);

    final filled = data.floodFill(4, 4, 0xFF1E88E5);

    expect(filled.pixelAt(4, 4), 0xFF1E88E5);
    expect(filled.pixelAt(5, 4), 0xFF1E88E5);
    expect(filled.pixelAt(4, 5), 0xFF1E88E5);
    expect(filled.pixelAt(8, 8), 0xFFE53935);
  });

  test('floodFill can erase connected transparent cells', () {
    var data = CustomSpriteData.empty();
    data = data.setPixel(2, 2, 0xFFFFEB3B);

    final erased = data.floodFill(0, 0, null);

    expect(erased.pixelAt(0, 0), isNull);
    expect(erased.pixelAt(2, 2), 0xFFFFEB3B);
  });

  test('expanded palette keeps legacy colors and grows color count', () {
    const legacyColors = <int>[
      0xFF000000,
      0xFFFFFFFF,
      0xFF9E9E9E,
      0xFFE53935,
      0xFFFF9800,
      0xFFFFEB3B,
      0xFF43A047,
      0xFF1E88E5,
      0xFF8E24AA,
      0xFFF06292,
      0xFF6D4C41,
    ];

    expect(SpritePalette.colors.length, greaterThan(legacyColors.length));
    for (final color in legacyColors) {
      expect(SpritePalette.colors, contains(color));
    }

    final saved = CustomSpriteData(
      pixels: [
        for (var i = 0; i < CustomSpriteData.cellCount; i++)
          i.isEven ? legacyColors[i % legacyColors.length] : null,
      ],
    );
    final restored = CustomSpriteData.fromJson(saved.toJson());

    expect(restored.pixels, saved.pixels);
  });
}
