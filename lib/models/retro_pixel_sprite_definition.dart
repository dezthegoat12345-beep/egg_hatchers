/// Built-in Retro Pixel sprite grid — not tied to custom sprite editor size.
///
/// Supports variable dimensions (16×16 through 64×64+). Optional render metadata
/// adjusts fit inside the standard sprite display box without changing pixels.
class RetroPixelSpriteDefinition {
  const RetroPixelSpriteDefinition({
    required this.width,
    required this.height,
    required this.pixels,
    this.displayScale = 1.0,
    this.horizontalOffset = 0.0,
    this.verticalOffset = 0.0,
  });

  final int width;
  final int height;
  final List<int?> pixels;

  /// Multiplier applied when fitting into the display box (1.0 = default fit).
  final double displayScale;

  /// Extra offset in grid-cell units after centering (positive = right/down).
  final double horizontalOffset;
  final double verticalOffset;

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
      displayScale: displayScale,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
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
      displayScale: displayScale,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
    );
  }

  RetroPixelSpriteDefinition copyWith({
    int? width,
    int? height,
    List<int?>? pixels,
    double? displayScale,
    double? horizontalOffset,
    double? verticalOffset,
  }) {
    return RetroPixelSpriteDefinition(
      width: width ?? this.width,
      height: height ?? this.height,
      pixels: pixels ?? this.pixels,
      displayScale: displayScale ?? this.displayScale,
      horizontalOffset: horizontalOffset ?? this.horizontalOffset,
      verticalOffset: verticalOffset ?? this.verticalOffset,
    );
  }

  /// Nearest-neighbor integer upscale (blocky, no blur).
  RetroPixelSpriteDefinition scale(int factor) {
    if (factor <= 1) return this;
    final w = width * factor;
    final h = height * factor;
    final next = List<int?>.filled(w * h, null);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final color = pixelAt(x, y);
        if (color == null) continue;
        for (var dy = 0; dy < factor; dy++) {
          for (var dx = 0; dx < factor; dx++) {
            next[(y * factor + dy) * w + (x * factor + dx)] = color;
          }
        }
      }
    }

    return copyWith(width: w, height: h, pixels: next);
  }

  /// Nearest-neighbor 2× upscale for preserving existing art.
  RetroPixelSpriteDefinition scale2x() => scale(2);

  /// Upscale until both dimensions are at least [minDimension].
  RetroPixelSpriteDefinition scaleToMinDimension(int minDimension) {
    var result = this;
    while (result.width < minDimension || result.height < minDimension) {
      result = result.scale2x();
    }
    return result;
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
