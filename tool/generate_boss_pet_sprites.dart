// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

/// Generates cute boss pet animal sprites for Boss Egg.
/// Run: dart run tool/generate_boss_pet_sprites.dart
void main() {
  const size = 160;
  const outDir = 'assets/images/animals';

  final generators = <String, img.Image Function()>{
    'slime_pet': _drawSlimePet,
    'egg_golem_pet': _drawEggGolemPet,
  };

  Directory(outDir).createSync(recursive: true);

  for (final entry in generators.entries) {
    final sprite = entry.value();
    final resized = img.copyResize(sprite, width: size, height: size);
    final path = '$outDir/${entry.key}.png';
    File(path).writeAsBytesSync(img.encodePng(resized));
    print('Wrote $path');
  }
}

img.Image _canvas() => img.Image(width: 160, height: 160, numChannels: 4);

img.ColorRgba8 _c(int r, int g, int b, [int a = 255]) =>
    img.ColorRgba8(r, g, b, a);

void _fillCircle(img.Image image, int cx, int cy, int r, img.ColorRgba8 color) {
  for (var y = cy - r; y <= cy + r; y++) {
    for (var x = cx - r; x <= cx + r; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy <= r * r) {
        if (x >= 0 && y >= 0 && x < image.width && y < image.height) {
          image.setPixel(x, y, color);
        }
      }
    }
  }
}

void _fillEllipse(
  img.Image image,
  int cx,
  int cy,
  int rx,
  int ry,
  img.ColorRgba8 color,
) {
  for (var y = cy - ry; y <= cy + ry; y++) {
    for (var x = cx - rx; x <= cx + rx; x++) {
      final dx = (x - cx) / rx;
      final dy = (y - cy) / ry;
      if (dx * dx + dy * dy <= 1) {
        if (x >= 0 && y >= 0 && x < image.width && y < image.height) {
          image.setPixel(x, y, color);
        }
      }
    }
  }
}

void _strokeEllipse(
  img.Image image,
  int cx,
  int cy,
  int rx,
  int ry,
  int thickness,
  img.ColorRgba8 color,
) {
  for (var t = 0; t < thickness; t++) {
    final outerRx = rx + t;
    final outerRy = ry + t;
    for (var y = cy - outerRy; y <= cy + outerRy; y++) {
      for (var x = cx - outerRx; x <= cx + outerRx; x++) {
        final dx = (x - cx) / outerRx;
        final dy = (y - cy) / outerRy;
        final dist = dx * dx + dy * dy;
        final innerRx = rx - thickness;
        final innerRy = ry - thickness;
        final innerDx = innerRx > 0 ? (x - cx) / innerRx : 999.0;
        final innerDy = innerRy > 0 ? (y - cy) / innerRy : 999.0;
        final innerDist = innerDx * innerDx + innerDy * innerDy;
        if (dist <= 1 && innerDist > 1) {
          if (x >= 0 && y >= 0 && x < image.width && y < image.height) {
            image.setPixel(x, y, color);
          }
        }
      }
    }
  }
}

void _drawEyes(img.Image image, int cx, int cy, int spacing, int eyeR) {
  for (final offset in [-spacing, spacing]) {
    _fillCircle(image, cx + offset, cy, eyeR, _c(255, 255, 255));
    _fillCircle(image, cx + offset + 2, cy + 1, eyeR ~/ 2, _c(20, 20, 30));
    _fillCircle(image, cx + offset + 3, cy, eyeR ~/ 4, _c(255, 255, 255));
  }
}

img.Image _drawSlimePet() {
  final image = _canvas();
  _fillEllipse(image, 80, 98, 46, 40, _c(102, 187, 106));
  _strokeEllipse(image, 80, 98, 46, 40, 4, _c(56, 142, 60));
  _fillEllipse(image, 80, 88, 34, 28, _c(165, 214, 167));
  _fillEllipse(image, 80, 78, 28, 22, _c(200, 230, 201));
  _drawEyes(image, 80, 82, 12, 7);
  _fillEllipse(image, 80, 96, 10, 6, _c(46, 125, 50));
  _fillCircle(image, 62, 70, 6, _c(129, 199, 132, 180));
  _fillCircle(image, 98, 74, 5, _c(129, 199, 132, 180));
  _fillCircle(image, 80, 58, 4, _c(255, 255, 255, 200));
  _fillEllipse(image, 58, 124, 8, 5, _c(67, 160, 71));
  _fillEllipse(image, 102, 124, 8, 5, _c(67, 160, 71));
  return image;
}

img.Image _drawEggGolemPet() {
  final image = _canvas();
  _fillEllipse(image, 80, 100, 44, 48, _c(144, 164, 174));
  _strokeEllipse(image, 80, 100, 44, 48, 4, _c(84, 110, 122));
  _fillEllipse(image, 80, 92, 30, 32, _c(207, 216, 220));
  _fillEllipse(image, 80, 78, 24, 20, _c(176, 190, 197));
  _drawEyes(image, 80, 80, 11, 6);
  _fillEllipse(image, 80, 94, 12, 6, _c(96, 125, 139));
  _fillEllipse(image, 64, 66, 8, 10, _c(255, 213, 79));
  _fillEllipse(image, 96, 64, 7, 9, _c(255, 193, 7));
  _fillEllipse(image, 80, 72, 14, 10, _c(255, 248, 225, 180));
  for (final x in [68, 80, 92]) {
    _fillEllipse(image, x, 92, 2, 6, _c(120, 144, 156, 150));
  }
  _fillEllipse(image, 64, 128, 10, 6, _c(69, 90, 100));
  _fillEllipse(image, 96, 128, 10, 6, _c(69, 90, 100));
  return image;
}
