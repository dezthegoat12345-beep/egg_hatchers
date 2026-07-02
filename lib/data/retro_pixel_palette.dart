import '../models/retro_pixel_sprite_definition.dart';

/// Shared colors for hand-authored Retro Pixel animal sprites.
class RetroPixelPalette {
  RetroPixelPalette._();

  static const black = 0xFF000000;
  static const offWhite = 0xFFF5F5F5;
  static const lightGray = 0xFFBDBDBD;
  static const gray = 0xFF9E9E9E;
  static const darkGray = 0xFF616161;
  static const earPink = 0xFFFFCDD2;
  static const pink = 0xFFF06292;
  static const red = 0xFFE53935;
  static const orange = 0xFFFF8A65;
  static const yellow = 0xFFFFEB3B;
  static const green = 0xFF66BB6A;
  static const darkGreen = 0xFF43A047;
  static const blue = 0xFF64B5F6;
  static const darkBlue = 0xFF1565C0;
  static const brown = 0xFF795548;
  static const darkBrown = 0xFF5D4037;
  static const tan = 0xFFD7CCC8;
  static const cream = 0xFFFFF9C4;
  static const slimeGreen = 0xFF81C784;
  static const slimeDark = 0xFF388E3C;
  static const white = 0xFFFFFFFF;
  static const purple = 0xFF8E24AA;

  static const colorKeys = {
    'K': black,
    'W': offWhite,
    'G': lightGray,
    'g': gray,
    'D': darkGray,
    'P': earPink,
    'p': pink,
    'R': red,
    'O': orange,
    'Y': yellow,
    'E': green,
    'e': darkGreen,
    'L': blue,
    'l': darkBlue,
    'B': brown,
    'b': darkBrown,
    'T': tan,
    'C': cream,
    'S': slimeGreen,
    's': slimeDark,
    'w': white,
  };

  /// Parses any rectangular ASCII pattern into a [RetroPixelSpriteDefinition].
  static RetroPixelSpriteDefinition fromPattern(List<String> rows) {
    if (rows.isEmpty) {
      throw ArgumentError('Pattern must have at least one row');
    }

    final height = rows.length;
    final width = rows.first.length;
    final pixels = <int?>[];

    for (final row in rows) {
      if (row.length != width) {
        throw ArgumentError('All pattern rows must have the same width');
      }
      for (var i = 0; i < row.length; i++) {
        final ch = row[i];
        if (ch == '.') {
          pixels.add(null);
        } else {
          final color = colorKeys[ch];
          if (color == null) {
            throw ArgumentError('Unknown color key "$ch"');
          }
          pixels.add(color);
        }
      }
    }

    return RetroPixelSpriteDefinition(
      width: width,
      height: height,
      pixels: pixels,
    );
  }
}
