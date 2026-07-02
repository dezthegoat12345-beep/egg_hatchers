/// Built-in Retro Pixel sprite grid — not tied to custom sprite editor size.
class RetroPixelSpriteDefinition {
  const RetroPixelSpriteDefinition({
    required this.width,
    required this.height,
    required this.pixels,
  });

  final int width;
  final int height;
  final List<int?> pixels;

  int get cellCount => width * height;

  bool get hasVisiblePixels => pixels.any((color) => color != null);

  int? pixelAt(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return null;
    return pixels[y * width + x];
  }

  RetroPixelSpriteDefinition withPixel(int x, int y, int? color) {
    if (x < 0 || x >= width || y < 0 || y >= height) return this;
    final next = List<int?>.from(pixels);
    next[y * width + x] = color;
    return RetroPixelSpriteDefinition(
      width: width,
      height: height,
      pixels: next,
    );
  }

  RetroPixelSpriteDefinition withPatches(Map<(int x, int y), int?> patches) {
    var result = this;
    for (final entry in patches.entries) {
      result = result.withPixel(entry.key.$1, entry.key.$2, entry.value);
    }
    return result;
  }

  /// Swaps palette colors in-place (null pixels stay null).
  RetroPixelSpriteDefinition recolor(Map<int, int> colorMap) {
    return RetroPixelSpriteDefinition(
      width: width,
      height: height,
      pixels: pixels
          .map((color) => color == null ? null : (colorMap[color] ?? color))
          .toList(),
    );
  }

  /// Nearest-neighbor 2× upscale for preserving existing 16×16 art.
  RetroPixelSpriteDefinition scale2x() {
    final w = width * 2;
    final h = height * 2;
    final next = List<int?>.filled(w * h, null);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final color = pixelAt(x, y);
        if (color == null) continue;
        for (var dy = 0; dy < 2; dy++) {
          for (var dx = 0; dx < 2; dx++) {
            next[(y * 2 + dy) * w + (x * 2 + dx)] = color;
          }
        }
      }
    }

    return RetroPixelSpriteDefinition(width: w, height: h, pixels: next);
  }

  /// Converts a fixed 16×16 [CustomSpriteData] grid for upscale workflows.
  factory RetroPixelSpriteDefinition.fromCustomSpriteGrid({
    required List<int?> pixels,
    int gridSize = 16,
  }) {
    return RetroPixelSpriteDefinition(
      width: gridSize,
      height: gridSize,
      pixels: List<int?>.from(pixels),
    );
  }
}
