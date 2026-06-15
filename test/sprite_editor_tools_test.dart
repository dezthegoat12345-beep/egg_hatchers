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
}
