// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final path = args.first;
  final bytes = File(path).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Failed to decode');
    exit(1);
  }

  print('size ${image.width}x${image.height}');
  const grid = 16;
  final cellW = image.width / grid;
  final cellH = image.height / grid;

  int? mapColor(int r, int g, int b, int a) {
    if (a < 128 || (r > 240 && g > 240 && b > 240)) return null;
    if (g > 180 && b > 180 && r < 200) return null; // teal grid -> transparent
    if (r < 50 && g < 50 && b < 50) return 0xFF000000;
    if (r > 120 && g < 110 && b < 110) return 0xFFE53935; // red comb/wattle
    if (r > 180 && g > 100 && b < 130) return 0xFFFF8A65; // orange beak/feet
    if (r > 210 && g > 210 && b > 210) return 0xFFF5F5F5; // off-white body
    if (r > 150 && g > 150 && b > 150) return 0xFFBDBDBD; // light gray
    return null;
  }

  final pixels = List<int?>.filled(256, null);
  for (var y = 0; y < grid; y++) {
    for (var x = 0; x < grid; x++) {
      final cx = ((x + 0.5) * cellW).floor().clamp(0, image.width - 1);
      final cy = ((y + 0.5) * cellH).floor().clamp(0, image.height - 1);
      final pixel = image.getPixel(cx, cy);
      pixels[y * grid + x] =
          mapColor(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), pixel.a.toInt());
    }
  }

  for (var y = 0; y < grid; y++) {
    final row = StringBuffer();
    for (var x = 0; x < grid; x++) {
      final c = pixels[y * grid + x];
      if (c == null) {
        row.write('.');
      } else if (c == 0xFF000000) {
        row.write('K');
      } else if (c == 0xFFE53935) {
        row.write('R');
      } else if (c == 0xFFFF8A65) {
        row.write('O');
      } else if (c == 0xFFF5F5F5) {
        row.write('W');
      } else if (c == 0xFFBDBDBD) {
        row.write('G');
      } else {
        row.write('?');
      }
    }
    print(row.toString());
  }

  print('\nDart pixels:');
  for (var y = 0; y < grid; y++) {
    final parts = <String>[];
    for (var x = 0; x < grid; x++) {
      final c = pixels[y * grid + x];
      parts.add(c == null ? 'null' : '0x${c.toRadixString(16).toUpperCase()}');
    }
    print('        ${parts.join(', ')},');
  }
}
