// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

/// Generates cute boss sprites for Boss Battles v2.
/// Run: dart run tool/generate_boss_sprites.dart
void main() {
  const size = 160;
  const outDir = 'assets/images/bosses';

  final generators = <String, img.Image Function()>{
    'slime_boss': _drawSlimeBoss,
    'egg_golem': _drawEggGolem,
    'shadow_rooster': _drawShadowRooster,
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
    _fillEllipse(image, cx, cy, rx - t, ry - t, color);
  }
}

void _drawEyes(img.Image image, int cx, int cy, int spacing, int radius) {
  for (final ox in [-spacing, spacing]) {
    _fillCircle(image, cx + ox, cy, radius, _c(255, 255, 255));
    _fillCircle(image, cx + ox + 1, cy + 1, radius - 2, _c(20, 20, 30));
    _fillCircle(image, cx + ox + 2, cy, 2, _c(255, 255, 255));
  }
}

img.Image _drawSlimeBoss() {
  final image = _canvas();
  _fillEllipse(image, 80, 98, 58, 48, _c(102, 187, 106));
  _strokeEllipse(image, 80, 98, 58, 48, 4, _c(46, 125, 50));
  _fillEllipse(image, 80, 88, 44, 34, _c(129, 199, 132));
  _fillEllipse(image, 80, 70, 36, 28, _c(165, 214, 167));
  _drawEyes(image, 80, 68, 14, 8);
  _fillEllipse(image, 80, 88, 10, 6, _c(27, 94, 32));
  for (final pos in [(52, 118), (80, 124), (108, 118)]) {
    _fillEllipse(image, pos.$1, pos.$2, 10, 6, _c(67, 160, 71));
  }
  _fillEllipse(image, 48, 78, 8, 12, _c(129, 199, 132));
  _fillEllipse(image, 112, 78, 8, 12, _c(129, 199, 132));
  return image;
}

img.Image _drawEggGolem() {
  final image = _canvas();
  _fillEllipse(image, 80, 96, 52, 56, _c(120, 144, 156));
  _strokeEllipse(image, 80, 96, 52, 56, 5, _c(69, 90, 100));
  _fillEllipse(image, 80, 88, 38, 40, _c(176, 190, 197));
  for (var i = -2; i <= 2; i++) {
    _fillEllipse(image, 80 + i * 14, 72 + i.abs() * 4, 8, 14, _c(96, 125, 139));
  }
  _drawEyes(image, 80, 72, 16, 9);
  _fillEllipse(image, 80, 92, 14, 8, _c(84, 110, 122));
  for (final pos in [(56, 124), (104, 124), (68, 132), (92, 132)]) {
    _fillEllipse(image, pos.$1, pos.$2, 12, 8, _c(69, 90, 100));
  }
  _fillEllipse(image, 58, 58, 10, 14, _c(255, 224, 130));
  _fillEllipse(image, 102, 54, 8, 12, _c(255, 193, 7));
  return image;
}

img.Image _drawShadowRooster() {
  final image = _canvas();
  _fillEllipse(image, 80, 52, 34, 28, _c(66, 66, 66));
  _strokeEllipse(image, 80, 52, 34, 28, 3, _c(30, 30, 35));
  _fillEllipse(image, 80, 96, 46, 44, _c(45, 45, 50));
  _strokeEllipse(image, 80, 96, 46, 44, 4, _c(20, 20, 24));
  _fillEllipse(image, 80, 98, 24, 28, _c(80, 80, 88));
  _fillEllipse(image, 102, 48, 16, 22, _c(35, 35, 40));
  _fillEllipse(image, 58, 48, 16, 22, _c(35, 35, 40));
  _fillEllipse(image, 118, 72, 18, 10, _c(244, 67, 54));
  _fillEllipse(image, 68, 44, 8, 10, _c(244, 67, 54));
  _drawEyes(image, 80, 50, 12, 6);
  for (final pos in [(58, 132), (102, 132), (80, 138)]) {
    _fillEllipse(image, pos.$1, pos.$2, 10, 6, _c(255, 160, 0));
  }
  _fillEllipse(image, 80, 62, 8, 10, _c(255, 193, 7));
  return image;
}
