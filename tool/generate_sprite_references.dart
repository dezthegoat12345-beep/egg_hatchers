// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

/// Generates lib/data/sprite_reference_data.dart from built-in animal PNGs.
/// Run: dart run tool/generate_sprite_references.dart
void main() {
  const palette = <int>[
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

  const animals = <String, String>{
    'chicken': 'assets/images/animals/chicken.png',
    'mouse': 'assets/images/animals/mouse.png',
    'rabbit': 'assets/images/animals/rabbit.png',
    'fox': 'assets/images/animals/fox.png',
    'deer': 'assets/images/animals/deer.png',
    'bear': 'assets/images/animals/bear.png',
    'tiger': 'assets/images/animals/tiger.png',
    'dragon': 'assets/images/animals/dragon.png',
    'unicorn': 'assets/images/animals/unicorn.png',
    'cow': 'assets/images/animals/cow.png',
    'pig': 'assets/images/animals/pig.png',
    'sheep': 'assets/images/animals/sheep.png',
    'horse': 'assets/images/animals/horse.png',
    'monkey': 'assets/images/animals/monkey.png',
    'parrot': 'assets/images/animals/parrot.png',
    'snake': 'assets/images/animals/snake.png',
    'gorilla': 'assets/images/animals/gorilla.png',
    'fish': 'assets/images/animals/fish.png',
    'turtle': 'assets/images/animals/turtle.png',
    'dolphin': 'assets/images/animals/dolphin.png',
    'shark': 'assets/images/animals/shark.png',
    'penguin': 'assets/images/animals/penguin.png',
    'seal': 'assets/images/animals/seal.png',
    'polar_bear': 'assets/images/animals/polar_bear.png',
    'snow_owl': 'assets/images/animals/snow_owl.png',
    'raptor': 'assets/images/animals/raptor.png',
    'triceratops': 'assets/images/animals/triceratops.png',
    't_rex': 'assets/images/animals/t_rex.png',
    'fossil_dragon': 'assets/images/animals/fossil_dragon.png',
    'moon_cat': 'assets/images/animals/moon_cat.png',
    'star_fox': 'assets/images/animals/star_fox.png',
    'alien_slime': 'assets/images/animals/alien_slime.png',
    'galaxy_dragon': 'assets/images/animals/galaxy_dragon.png',
  };

  final buffer = StringBuffer()
    ..writeln("import '../models/custom_sprite_data.dart';")
    ..writeln()
    ..writeln('/// Pre-baked 16×16 reference grids for built-in animal PNG sprites.')
    ..writeln('class SpriteReferenceData {')
    ..writeln('  SpriteReferenceData._();')
    ..writeln()
    ..writeln('  static const Map<String, CustomSpriteData> references = {');

  for (final entry in animals.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) {
      print('Missing ${entry.value}, skipping ${entry.key}');
      continue;
    }

    final bytes = file.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      print('Failed to decode ${entry.value}');
      continue;
    }

    final resized = img.copyResize(
      decoded,
      width: 16,
      height: 16,
      interpolation: img.Interpolation.average,
    );

    final pixels = <String>[];
    for (var y = 0; y < 16; y++) {
      for (var x = 0; x < 16; x++) {
        final pixel = resized.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final a = pixel.a.toInt();

        if (a < 40 || (r < 30 && g < 30 && b < 30)) {
          pixels.add('null');
          continue;
        }

        final mapped = _nearestPaletteColor(r, g, b, palette);
        pixels.add('0x${mapped.toRadixString(16).toUpperCase().padLeft(8, '0')}');
      }
    }

    buffer.writeln("    '${entry.key}': CustomSpriteData(");
    buffer.writeln('      pixels: [');
    for (var i = 0; i < pixels.length; i += 16) {
      final row = pixels.sublist(i, min(i + 16, pixels.length));
      buffer.writeln('        ${row.join(', ')},');
    }
    buffer.writeln('      ],');
    buffer.writeln('    ),');
    print('Generated ${entry.key}');
  }

  buffer
    ..writeln('  };')
    ..writeln()
    ..writeln('  static bool hasReference(String animalId) =>')
    ..writeln('      references.containsKey(animalId);')
    ..writeln()
    ..writeln('  static CustomSpriteData? referenceFor(String animalId) =>')
    ..writeln('      references[animalId];')
    ..writeln('}');

  final out = File('lib/data/sprite_reference_data.dart');
  out.writeAsStringSync(buffer.toString());
  print('Wrote ${out.path}');
}

int _nearestPaletteColor(int r, int g, int b, List<int> palette) {
  var best = palette.first;
  var bestDistance = double.infinity;

  for (final color in palette) {
    final pr = (color >> 16) & 0xFF;
    final pg = (color >> 8) & 0xFF;
    final pb = color & 0xFF;
    final dr = r - pr;
    final dg = g - pg;
    final db = b - pb;
    final distance = dr * dr + dg * dg + db * db;
    if (distance < bestDistance) {
      bestDistance = distance.toDouble();
      best = color;
    }
  }

  return best;
}
