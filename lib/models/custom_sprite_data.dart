import 'dart:convert';

/// A 16×16 pixel art sprite stored as ARGB color values (null = transparent).
class CustomSpriteData {
  const CustomSpriteData({required this.pixels});

  static const int gridSize = 16;
  static const int cellCount = gridSize * gridSize;

  final List<int?> pixels;

  factory CustomSpriteData.empty() {
    return CustomSpriteData(
      pixels: List<int?>.filled(cellCount, null),
    );
  }

  factory CustomSpriteData.fromJson(Map<String, dynamic> json) {
    final size = json['size'] as int? ?? gridSize;
    if (size != gridSize) {
      throw FormatException('Unsupported custom sprite size: $size');
    }

    final raw = json['pixels'] as List<dynamic>? ?? [];
    final pixels = List<int?>.filled(cellCount, null);
    for (var i = 0; i < cellCount && i < raw.length; i++) {
      final value = raw[i];
      pixels[i] = value == null ? null : (value as num).toInt();
    }
    return CustomSpriteData(pixels: pixels);
  }

  factory CustomSpriteData.fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Custom sprite JSON must be an object');
    }
    return CustomSpriteData.fromJson(decoded);
  }

  Map<String, dynamic> toJson() => {
        'size': gridSize,
        'pixels': pixels,
      };

  String toJsonString() => jsonEncode(toJson());

  bool get hasVisiblePixels => pixels.any((color) => color != null);

  CustomSpriteData copyWith({List<int?>? pixels}) {
    return CustomSpriteData(pixels: pixels ?? List<int?>.from(this.pixels));
  }

  CustomSpriteData setPixel(int x, int y, int? color) {
    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) {
      return this;
    }
    final next = List<int?>.from(pixels);
    next[y * gridSize + x] = color;
    return CustomSpriteData(pixels: next);
  }

  int? pixelAt(int x, int y) {
    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) return null;
    return pixels[y * gridSize + x];
  }

  /// Paints a square brush anchored at the tapped cell (clamped to the grid).
  CustomSpriteData applyBrush(int x, int y, int brushSize, int? color) {
    if (brushSize <= 1) {
      return setPixel(x, y, color);
    }

    final offset = brushSize == 3 ? -1 : 0;
    var result = this;
    for (var dy = 0; dy < brushSize; dy++) {
      for (var dx = 0; dx < brushSize; dx++) {
        result = result.setPixel(x + offset + dx, y + offset + dy, color);
      }
    }
    return result;
  }

  /// Flood-fills connected cells matching the tapped cell's starting color.
  CustomSpriteData floodFill(int x, int y, int? fillColor) {
    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) return this;

    final targetColor = pixelAt(x, y);
    if (targetColor == fillColor) return this;

    final next = List<int?>.from(pixels);
    final queue = <(int, int)>[(x, y)];
    final visited = <int>{};

    while (queue.isNotEmpty) {
      final (cx, cy) = queue.removeLast();
      final idx = cy * gridSize + cx;
      if (visited.contains(idx)) continue;
      if (cx < 0 || cx >= gridSize || cy < 0 || cy >= gridSize) continue;
      if (next[idx] != targetColor) continue;

      visited.add(idx);
      next[idx] = fillColor;
      queue.add((cx + 1, cy));
      queue.add((cx - 1, cy));
      queue.add((cx, cy + 1));
      queue.add((cx, cy - 1));
    }

    return CustomSpriteData(pixels: next);
  }
}

/// Editor palette colors (ARGB integers).
class SpritePalette {
  SpritePalette._();

  static const transparent = null;

  static const groups = <SpritePaletteGroup>[
    SpritePaletteGroup('Basic', [
      SpritePaletteEntry(0xFFFFFFFF, 'White'),
      SpritePaletteEntry(0xFFE0E0E0, 'Light gray'),
      SpritePaletteEntry(0xFF9E9E9E, 'Gray'),
      SpritePaletteEntry(0xFF616161, 'Dark gray'),
      SpritePaletteEntry(0xFF000000, 'Black'),
    ]),
    SpritePaletteGroup('Fur', [
      SpritePaletteEntry(0xFFD7CCC8, 'Tan'),
      SpritePaletteEntry(0xFFA1887F, 'Light brown'),
      SpritePaletteEntry(0xFF6D4C41, 'Brown'),
      SpritePaletteEntry(0xFF4E342E, 'Dark brown'),
    ]),
    SpritePaletteGroup('Warm', [
      SpritePaletteEntry(0xFFE53935, 'Red'),
      SpritePaletteEntry(0xFFB71C1C, 'Dark red'),
      SpritePaletteEntry(0xFFF06292, 'Pink'),
      SpritePaletteEntry(0xFFF8BBD9, 'Light pink'),
      SpritePaletteEntry(0xFFFF9800, 'Orange'),
      SpritePaletteEntry(0xFFE65100, 'Dark orange'),
      SpritePaletteEntry(0xFFFFEB3B, 'Yellow'),
      SpritePaletteEntry(0xFFFFF9C4, 'Cream'),
    ]),
    SpritePaletteGroup('Greens', [
      SpritePaletteEntry(0xFF81C784, 'Light green'),
      SpritePaletteEntry(0xFF43A047, 'Green'),
      SpritePaletteEntry(0xFF2E7D32, 'Dark green'),
      SpritePaletteEntry(0xFF80CBC4, 'Mint'),
    ]),
    SpritePaletteGroup('Cool', [
      SpritePaletteEntry(0xFF64B5F6, 'Light blue'),
      SpritePaletteEntry(0xFF1E88E5, 'Blue'),
      SpritePaletteEntry(0xFF1565C0, 'Dark blue'),
      SpritePaletteEntry(0xFF26C6DA, 'Cyan'),
      SpritePaletteEntry(0xFF8E24AA, 'Purple'),
      SpritePaletteEntry(0xFF4A148C, 'Dark purple'),
      SpritePaletteEntry(0xFFCE93D8, 'Lavender'),
    ]),
    SpritePaletteGroup('Special', [
      SpritePaletteEntry(0xFFFFC107, 'Gold'),
      SpritePaletteEntry(0xFFE040FB, 'Bright magenta'),
      SpritePaletteEntry(0xFF1A1028, 'Shadow'),
    ]),
  ];

  static final colors = <int?>[
    for (final group in groups)
      for (final entry in group.entries) entry.color,
  ];

  static final labels = <String>[
    for (final group in groups)
      for (final entry in group.entries) entry.label,
  ];
}

class SpritePaletteGroup {
  const SpritePaletteGroup(this.name, this.entries);

  final String name;
  final List<SpritePaletteEntry> entries;
}

class SpritePaletteEntry {
  const SpritePaletteEntry(this.color, this.label);

  final int color;
  final String label;
}
