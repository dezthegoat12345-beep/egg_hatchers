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
}

/// Editor palette colors (ARGB integers).
class SpritePalette {
  SpritePalette._();

  static const transparent = null;

  static const colors = <int?>[
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

  static const labels = <String>[
    'Black',
    'White',
    'Gray',
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'Blue',
    'Purple',
    'Pink',
    'Brown',
  ];
}
