import '../models/custom_sprite_data.dart';

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

  /// Parses a 16×16 pattern where each character maps to a palette color.
  static CustomSpriteData fromPattern(
    List<String> rows,
    Map<String, int> colors,
  ) {
    if (rows.length != CustomSpriteData.gridSize) {
      throw ArgumentError('Expected ${CustomSpriteData.gridSize} rows');
    }

    final pixels = <int?>[];
    for (final row in rows) {
      if (row.length != CustomSpriteData.gridSize) {
        throw ArgumentError('Each row must be ${CustomSpriteData.gridSize} chars');
      }
      for (var i = 0; i < row.length; i++) {
        final ch = row[i];
        if (ch == '.') {
          pixels.add(null);
        } else {
          final color = colors[ch];
          if (color == null) {
            throw ArgumentError('Unknown color key "$ch"');
          }
          pixels.add(color);
        }
      }
    }

    return CustomSpriteData(pixels: pixels);
  }
}

/// Hand-authored Retro Pixel sprites — not derived from sprite rating references.
class RetroPixelHandAuthoredSprites {
  RetroPixelHandAuthoredSprites._();

  static const _keys = {
    'K': RetroPixelPalette.black,
    'W': RetroPixelPalette.offWhite,
    'G': RetroPixelPalette.lightGray,
    'g': RetroPixelPalette.gray,
    'D': RetroPixelPalette.darkGray,
    'P': RetroPixelPalette.earPink,
    'p': RetroPixelPalette.pink,
    'R': RetroPixelPalette.red,
    'O': RetroPixelPalette.orange,
    'Y': RetroPixelPalette.yellow,
    'E': RetroPixelPalette.green,
    'e': RetroPixelPalette.darkGreen,
    'L': RetroPixelPalette.blue,
    'l': RetroPixelPalette.darkBlue,
    'B': RetroPixelPalette.brown,
    'b': RetroPixelPalette.darkBrown,
    'T': RetroPixelPalette.tan,
    'C': RetroPixelPalette.cream,
    'S': RetroPixelPalette.slimeGreen,
    's': RetroPixelPalette.slimeDark,
  };

  static CustomSpriteData _p(List<String> rows) =>
      RetroPixelPalette.fromPattern(rows, _keys);

  static final mouse = _p([
    '................',
    '................',
    '..KK.....KK.....',
    '.KPPK...KPPK....',
    '.KGGKKKKKGGK....',
    '.KGGGGGGGGGK....',
    'KGGKGKKKGKGGK...',
    'KGGGGGGGGGGGK...',
    '.KGGGGGGGGGK....',
    '.KGGK...KGGK....',
    '..KKK.KKK.......',
    '..KK...KK.......',
    '...KK.KK........',
    '....KKK.........',
    '................',
    '................',
  ]);

  static final rabbit = _p([
    '................',
    '.KK.....KK......',
    'KPPK...KPPK.....',
    'KWWK...KWWK.....',
    'KWWK...KWWK.....',
    '.KWWKKKKKWWK....',
    '..KWWWWWWWK.....',
    '..KWWKOKWWK.....',
    '..KWWWWWWWK.....',
    '...KWWWWWK......',
    '...KWWWKWK......',
    '....KWWWK.......',
    '....KK.KK.......',
    '....KK.KK.......',
    '................',
    '................',
  ]);

  static final turtle = _p([
    '................',
    '................',
    '......KKK.......',
    '.....KeKKK......',
    '....KeWWWeK.....',
    '...KeWWWWWeK....',
    '..KeWWWWWWWeK...',
    '..KeWWWWWWWeK...',
    '...KeWWWWWeK....',
    '....KeEeEeK.....',
    '.....KeKeK......',
    '......KKK.......',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final pig = _p([
    '................',
    '................',
    '.....KKKKK......',
    '....KppppppK....',
    '...KppKppKppK...',
    '...KppppppppK...',
    '...KppppppppK...',
    '...KppppppppK...',
    '....KppppppK....',
    '....KpKppKpK....',
    '.....KKKKKK.....',
    '.....KK..KK.....',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final cow = _p([
    '................',
    '................',
    '.....KKKKK......',
    '....KWWKWWWK....',
    '...KWWWWWWWWK...',
    '...KWKWWWKWWK...',
    '...KWWWWWWWWK...',
    '...KWWWWWWWWK...',
    '....KWWWWWWK....',
    '....KWWWWWWK....',
    '.....KKKKKK.....',
    '.....KK..KK.....',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final sheep = _p([
    '................',
    '................',
    '....KKKKKKK.....',
    '...KWWWWWWWK....',
    '...KWWWWWWWK....',
    '...KWWWWWWWK....',
    '...KWWWWWWWK....',
    '....KDDDDDDK....',
    '.....KDDDDK.....',
    '.....KK..KK.....',
    '.....KK..KK.....',
    '................',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final penguin = _p([
    '................',
    '................',
    '......KKK.......',
    '.....KWWWGK.....',
    '....KWWWWWK.....',
    '....KWKWWWK.....',
    '....KWWWWWK.....',
    '....KWWWWWK.....',
    '....KWWWWWK.....',
    '.....KWWWK......',
    '.....KOOOK......',
    '.....KOOOK......',
    '.....KKKKK......',
    '................',
    '................',
    '................',
  ]);

  static final frog = _p([
    '................',
    '................',
    '....KK...KK.....',
    '...KWWK.KWWK....',
    '...KWWKOKWWK....',
    '..KWWWWWWWWWK...',
    '..KWWWWWWWWWK...',
    '..KWWWWWWWWWK...',
    '...KWWWWWWWK....',
    '....KeE.EeK.....',
    '....KeE.EeK.....',
    '.....KKKKK......',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final moonCat = _p([
    '................',
    '................',
    '..KK.....KK.....',
    '.KWWK...KWWK....',
    '.KWWKKKKKWWK....',
    '..KWWWWWWWK.....',
    '..KWWKOKWWK.....',
    '..KWWWWWWWK.....',
    '...KWWWWWK......',
    '...KWWWWWK......',
    '....KWWWK.......',
    '....KK.KK.......',
    '.....KKK........',
    '................',
    '................',
    '................',
  ]);

  static final fish = _p([
    '................',
    '................',
    '................',
    '....KKKKKKK.....',
    '...KLLLLLLLK....',
    '..KLLLLLLLLLK...',
    '.KLLLKLLLLLLLK..',
    '..KLLLLLLLLLK...',
    '....KKKKKKK.....',
    '................',
    '................',
    '................',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final horse = _p([
    '................',
    '................',
    '......KKKK......',
    '.....KBBBBK.....',
    '....KBBBBBBK....',
    '....KBBKBBBK....',
    '....KBBBBBBK....',
    '....KBBBBBBK....',
    '....KBBBBBBK....',
    '.....KBBBBK.....',
    '.....KK.KK......',
    '.....KK.KK......',
    '.....KK.KK......',
    '................',
    '................',
    '................',
  ]);

  static final monkey = _p([
    '................',
    '................',
    '...KK.....KK....',
    '..KTTK...KTTK...',
    '..KBBKTTTKBBK...',
    '..KBBBBBBBBBK...',
    '..KBBKOKKBBK....',
    '..KBBBBBBBBK....',
    '...KBBBBBBK.....',
    '....KBBBBK......',
    '....KK.KK.......',
    '.....KKK........',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final parrot = _p([
    '................',
    '................',
    '......KKK.......',
    '.....KRYYK......',
    '....KRYYYYK.....',
    '....KRYYYYK.....',
    '....KRYYYYK.....',
    '....KRYYYYK.....',
    '.....KRYYK......',
    '.....KOOOK......',
    '.....KOOOK......',
    '.....KKKKK......',
    '................',
    '................',
    '................',
    '................',
  ]);

  static final deer = _p([
    '................',
    '...KK...KK......',
    '..KBBK.KBBK.....',
    '..KBBKKKBBK.....',
    '...KBBBBBK......',
    '...KBBKBBK......',
    '...KBBBBBK......',
    '...KBBBBBK......',
    '....KBBBBK......',
    '....KBBBBK......',
    '.....KKKKK......',
    '.....KK.KK......',
    '.....KK.KK......',
    '................',
    '................',
    '................',
  ]);

  static final fox = _p([
    '................',
    '................',
    '..KK.....KK.....',
    '.KOOK...KOOK....',
    '.KOWWKKKOWWK....',
    '..KOWWWWWWK.....',
    '..KOWKOKWWK.....',
    '..KOWWWWWWK.....',
    '...KOWWWWK......',
    '...KOWWWWK......',
    '....KOWWK.......',
    '....KK.KK.......',
    '.....KKK........',
    '................',
    '................',
    '................',
  ]);

  static final slimePet = _p([
    '................',
    '................',
    '.....KKKKK......',
    '....KSSSSSK.....',
    '...KSSWWSSK.....',
    '...KSSKOKSK.....',
    '...KSSSSSSK.....',
    '....KSSSSSK.....',
    '.....KSSSK......',
    '......KsK.......',
    '......KsK.......',
    '......KKK.......',
    '................',
    '................',
    '................',
    '................',
  ]);

  /// All explicit hand-authored sprites keyed by animal id.
  static final Map<String, CustomSpriteData> all = {
    'mouse': mouse,
    'rabbit': rabbit,
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
}
