// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Generates polished placeholder animal sprites for emoji-only animals.
/// Run: dart run tool/generate_missing_animal_sprites.dart
void main() {
  const size = 128;
  const outDir = 'assets/images/animals';

  final generators = <String, img.Image Function()>{
    'deer': _drawDeer,
    'bear': _drawBear,
    'tiger': _drawTiger,
    'pig': _drawPig,
    'sheep': _drawSheep,
    'horse': _drawHorse,
    'monkey': _drawMonkey,
    'parrot': _drawParrot,
    'snake': _drawSnake,
    'gorilla': _drawGorilla,
    'fish': _drawFish,
    'turtle': _drawTurtle,
    'dolphin': _drawDolphin,
    'penguin': _drawPenguin,
    'seal': _drawSeal,
    'raptor': _drawRaptor,
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

img.Image _canvas() => img.Image(width: 128, height: 128, numChannels: 4);

img.ColorRgba8 _c(int r, int g, int b, [int a = 255]) => img.ColorRgba8(r, g, b, a);

void _set(img.Image image, int x, int y, img.ColorRgba8 color) {
  if (x < 0 || y < 0 || x >= image.width || y >= image.height) return;
  image.setPixel(x, y, color);
}

void _fillCircle(img.Image image, int cx, int cy, int radius, img.ColorRgba8 color) {
  for (var y = cy - radius; y <= cy + radius; y++) {
    for (var x = cx - radius; x <= cx + radius; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy <= radius * radius) {
        _set(image, x, y, color);
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
        _set(image, x, y, color);
      }
    }
  }
}

void _fillRoundedRect(
  img.Image image,
  int left,
  int top,
  int right,
  int bottom,
  int radius,
  img.ColorRgba8 color,
) {
  for (var y = top; y <= bottom; y++) {
    for (var x = left; x <= right; x++) {
      var inside = true;
      if (x < left + radius && y < top + radius) {
        final dx = x - (left + radius);
        final dy = y - (top + radius);
        inside = dx * dx + dy * dy <= radius * radius;
      } else if (x > right - radius && y < top + radius) {
        final dx = x - (right - radius);
        final dy = y - (top + radius);
        inside = dx * dx + dy * dy <= radius * radius;
      } else if (x < left + radius && y > bottom - radius) {
        final dx = x - (left + radius);
        final dy = y - (bottom - radius);
        inside = dx * dx + dy * dy <= radius * radius;
      } else if (x > right - radius && y > bottom - radius) {
        final dx = x - (right - radius);
        final dy = y - (bottom - radius);
        inside = dx * dx + dy * dy <= radius * radius;
      }
      if (inside) _set(image, x, y, color);
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
    final innerRx = math.max(1, rx - t);
    final innerRy = math.max(1, ry - t);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final dx = (x - cx) / outerRx;
        final dy = (y - cy) / outerRy;
        final outer = dx * dx + dy * dy <= 1;
        final idx = (x - cx) / innerRx;
        final idy = (y - cy) / innerRy;
        final inner = idx * idx + idy * idy <= 1;
        if (outer && !inner) _set(image, x, y, color);
      }
    }
  }
}

void _drawEyes(img.Image image, int cx, int cy, int spacing, int radius) {
  _fillCircle(image, cx - spacing, cy, radius, _c(255, 255, 255));
  _fillCircle(image, cx + spacing, cy, radius, _c(255, 255, 255));
  _fillCircle(image, cx - spacing, cy, math.max(1, radius - 2), _c(20, 20, 30));
  _fillCircle(image, cx + spacing, cy, math.max(1, radius - 2), _c(20, 20, 30));
}

void _drawOutlinedBody(
  img.Image image, {
  required int cx,
  required int cy,
  required int rx,
  required int ry,
  required img.ColorRgba8 fill,
  required img.ColorRgba8 outline,
}) {
  _fillEllipse(image, cx, cy, rx + 3, ry + 3, outline);
  _fillEllipse(image, cx, cy, rx, ry, fill);
}

img.Image _drawDeer() {
  final image = _canvas();
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 72,
    rx: 34,
    ry: 30,
    fill: _c(181, 122, 69),
    outline: _c(109, 76, 47),
  );
  _fillEllipse(image, 64, 58, 22, 20, _c(210, 160, 110));
  _strokeEllipse(image, 64, 58, 22, 20, 2, _c(109, 76, 47));
  _drawEyes(image, 64, 56, 8, 5);
  _fillEllipse(image, 64, 66, 6, 4, _c(80, 50, 30));
  // Antlers
  for (final dx in [-18, 18]) {
    _fillRoundedRect(image, 64 + dx - 3, 24, 64 + dx + 3, 42, 2, _c(215, 185, 142));
    _fillRoundedRect(image, 64 + dx - 8, 30, 64 + dx - 2, 34, 2, _c(215, 185, 142));
    _fillRoundedRect(image, 64 + dx + 2, 30, 64 + dx + 8, 34, 2, _c(215, 185, 142));
  }
  _fillEllipse(image, 40, 78, 8, 6, _c(181, 122, 69));
  _fillEllipse(image, 88, 78, 8, 6, _c(181, 122, 69));
  return image;
}

img.Image _drawBear() {
  final image = _canvas();
  _fillCircle(image, 36, 42, 14, _c(90, 55, 30));
  _fillCircle(image, 92, 42, 14, _c(90, 55, 30));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 68,
    rx: 38,
    ry: 34,
    fill: _c(139, 90, 43),
    outline: _c(80, 50, 25),
  );
  _fillEllipse(image, 64, 66, 20, 18, _c(180, 130, 80));
  _drawEyes(image, 64, 62, 10, 6);
  _fillEllipse(image, 64, 76, 10, 7, _c(70, 40, 20));
  _fillCircle(image, 64, 72, 4, _c(50, 30, 15));
  return image;
}

img.Image _drawTiger() {
  final image = _canvas();
  _fillCircle(image, 34, 40, 13, _c(255, 150, 50));
  _fillCircle(image, 94, 40, 13, _c(255, 150, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 70,
    rx: 36,
    ry: 32,
    fill: _c(255, 167, 38),
    outline: _c(180, 90, 10),
  );
  _fillEllipse(image, 64, 64, 22, 20, _c(255, 210, 120));
  _drawEyes(image, 64, 60, 9, 5);
  _fillEllipse(image, 64, 72, 8, 5, _c(255, 120, 80));
  // Stripes
  for (var i = -2; i <= 2; i++) {
    _fillRoundedRect(image, 58 + i * 8, 78, 62 + i * 8, 92, 2, _c(120, 60, 0));
  }
  return image;
}

img.Image _drawPig() {
  final image = _canvas();
  _fillCircle(image, 30, 48, 10, _c(255, 170, 190));
  _fillCircle(image, 98, 48, 10, _c(255, 170, 190));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 70,
    rx: 36,
    ry: 30,
    fill: _c(255, 182, 193),
    outline: _c(220, 100, 130),
  );
  _fillEllipse(image, 64, 64, 20, 18, _c(255, 210, 220));
  _drawEyes(image, 64, 58, 9, 5);
  _fillEllipse(image, 64, 74, 16, 12, _c(255, 140, 160));
  _fillCircle(image, 58, 74, 3, _c(220, 80, 110));
  _fillCircle(image, 70, 74, 3, _c(220, 80, 110));
  return image;
}

img.Image _drawSheep() {
  final image = _canvas();
  // Fluffy wool
  for (final offset in [
    (-20, -8),
    (0, -12),
    (20, -8),
    (-28, 8),
    (-10, 12),
    (10, 12),
    (28, 8),
  ]) {
    _fillCircle(image, 64 + offset.$1, 60 + offset.$2, 16, _c(245, 245, 245));
  }
  _fillCircle(image, 64, 62, 22, _c(250, 250, 250));
  _strokeEllipse(image, 64, 62, 22, 22, 2, _c(200, 200, 210));
  _fillEllipse(image, 64, 66, 16, 14, _c(60, 50, 50));
  _drawEyes(image, 64, 62, 7, 4);
  return image;
}

img.Image _drawHorse() {
  final image = _canvas();
  _fillEllipse(image, 64, 52, 16, 28, _c(120, 70, 35));
  _strokeEllipse(image, 64, 52, 16, 28, 2, _c(70, 40, 20));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 78,
    rx: 34,
    ry: 24,
    fill: _c(160, 100, 55),
    outline: _c(90, 55, 25),
  );
  _fillEllipse(image, 64, 48, 14, 16, _c(200, 150, 100));
  _drawEyes(image, 64, 44, 6, 4);
  _fillEllipse(image, 64, 54, 8, 5, _c(80, 45, 25));
  // Mane
  _fillRoundedRect(image, 48, 30, 56, 58, 4, _c(70, 40, 20));
  return image;
}

img.Image _drawMonkey() {
  final image = _canvas();
  _fillCircle(image, 34, 42, 13, _c(140, 90, 50));
  _fillCircle(image, 94, 42, 13, _c(140, 90, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 70,
    rx: 34,
    ry: 30,
    fill: _c(161, 107, 60),
    outline: _c(100, 60, 30),
  );
  _fillEllipse(image, 64, 66, 22, 20, _c(230, 190, 150));
  _drawEyes(image, 64, 60, 9, 5);
  _fillEllipse(image, 64, 74, 12, 8, _c(200, 150, 120));
  return image;
}

img.Image _drawParrot() {
  final image = _canvas();
  _fillRoundedRect(image, 58, 24, 70, 40, 4, _c(255, 80, 80));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 68,
    rx: 30,
    ry: 32,
    fill: _c(67, 160, 71),
    outline: _c(30, 100, 40),
  );
  _fillEllipse(image, 64, 58, 18, 16, _c(120, 200, 90));
  _drawEyes(image, 64, 54, 7, 4);
  _fillEllipse(image, 78, 62, 10, 6, _c(255, 200, 0));
  _fillEllipse(image, 86, 64, 4, 3, _c(30, 30, 30));
  // Wing
  _fillEllipse(image, 48, 72, 12, 18, _c(30, 120, 50));
  // Tail
  _fillEllipse(image, 40, 84, 10, 16, _c(30, 136, 229));
  _fillEllipse(image, 30, 90, 8, 12, _c(229, 57, 53));
  return image;
}

img.Image _drawSnake() {
  final image = _canvas();
  final points = <(int, int)>[
    (40, 90),
    (50, 70),
    (64, 58),
    (78, 48),
    (88, 36),
    (92, 28),
  ];
  for (var i = 0; i < points.length - 1; i++) {
    final a = points[i];
    final b = points[i + 1];
    final steps = 20;
    for (var s = 0; s <= steps; s++) {
      final t = s / steps;
      final x = (a.$1 + (b.$1 - a.$1) * t).round();
      final y = (a.$2 + (b.$2 - a.$2) * t).round();
      _fillCircle(image, x, y, 12 - i, _c(76, 175, 80));
      _fillCircle(image, x, y, 10 - i, _c(129, 199, 132));
    }
  }
  _fillCircle(image, 92, 26, 10, _c(56, 142, 60));
  _fillCircle(image, 88, 24, 3, _c(255, 255, 255));
  _fillCircle(image, 96, 24, 3, _c(255, 255, 255));
  _fillCircle(image, 88, 24, 1, _c(20, 20, 20));
  _fillCircle(image, 96, 24, 1, _c(20, 20, 20));
  return image;
}

img.Image _drawGorilla() {
  final image = _canvas();
  _fillCircle(image, 32, 44, 14, _c(50, 50, 55));
  _fillCircle(image, 96, 44, 14, _c(50, 50, 55));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 72,
    rx: 38,
    ry: 32,
    fill: _c(70, 70, 78),
    outline: _c(35, 35, 40),
  );
  _fillEllipse(image, 64, 68, 22, 18, _c(120, 120, 130));
  _drawEyes(image, 64, 62, 9, 5);
  _fillRoundedRect(image, 58, 74, 70, 82, 3, _c(90, 90, 95));
  return image;
}

img.Image _drawFish() {
  final image = _canvas();
  _drawOutlinedBody(
    image,
    cx: 58,
    cy: 64,
    rx: 32,
    ry: 22,
    fill: _c(66, 165, 245),
    outline: _c(25, 100, 180),
  );
  // Tail
  _fillEllipse(image, 98, 64, 14, 20, _c(30, 136, 229));
  _fillEllipse(image, 108, 64, 8, 14, _c(21, 101, 192));
  _drawEyes(image, 44, 58, 0, 5);
  _fillCircle(image, 44, 58, 2, _c(20, 20, 30));
  // Fin
  _fillEllipse(image, 58, 48, 8, 12, _c(30, 136, 229));
  return image;
}

img.Image _drawTurtle() {
  final image = _canvas();
  _fillEllipse(image, 64, 70, 36, 28, _c(46, 125, 50));
  _strokeEllipse(image, 64, 70, 36, 28, 3, _c(27, 94, 32));
  // Shell pattern
  for (var row = 0; row < 3; row++) {
    for (var col = 0; col < 3; col++) {
      _fillEllipse(
        image,
        52 + col * 12,
        60 + row * 10,
        5,
        4,
        _c(102, 187, 106),
      );
    }
  }
  _fillEllipse(image, 64, 42, 14, 12, _c(129, 199, 132));
  _strokeEllipse(image, 64, 42, 14, 12, 2, _c(46, 125, 50));
  _drawEyes(image, 64, 40, 5, 3);
  // Feet
  for (final pos in [(40, 82), (88, 82), (46, 92), (82, 92)]) {
    _fillEllipse(image, pos.$1, pos.$2, 8, 5, _c(129, 199, 132));
  }
  return image;
}

img.Image _drawDolphin() {
  final image = _canvas();
  _fillEllipse(image, 64, 68, 40, 18, _c(79, 195, 247));
  _strokeEllipse(image, 64, 68, 40, 18, 3, _c(2, 136, 209));
  _fillEllipse(image, 92, 58, 16, 10, _c(3, 169, 244));
  _fillEllipse(image, 40, 72, 10, 6, _c(129, 212, 250));
  _drawEyes(image, 78, 58, 0, 4);
  _fillCircle(image, 78, 58, 2, _c(20, 20, 30));
  // Dorsal fin
  _fillEllipse(image, 64, 46, 6, 14, _c(3, 155, 229));
  // Tail
  _fillEllipse(image, 28, 70, 10, 14, _c(3, 169, 244));
  return image;
}

img.Image _drawPenguin() {
  final image = _canvas();
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 72,
    rx: 28,
    ry: 36,
    fill: _c(30, 30, 35),
    outline: _c(10, 10, 15),
  );
  _fillEllipse(image, 64, 76, 18, 26, _c(250, 250, 250));
  _drawEyes(image, 64, 52, 8, 5);
  _fillEllipse(image, 64, 64, 6, 8, _c(255, 160, 0));
  // Flippers
  _fillEllipse(image, 34, 76, 8, 16, _c(30, 30, 35));
  _fillEllipse(image, 94, 76, 8, 16, _c(30, 30, 35));
  // Feet
  _fillEllipse(image, 54, 104, 10, 5, _c(255, 160, 0));
  _fillEllipse(image, 74, 104, 10, 5, _c(255, 160, 0));
  return image;
}

img.Image _drawSeal() {
  final image = _canvas();
  _fillEllipse(image, 64, 74, 38, 22, _c(144, 164, 174));
  _strokeEllipse(image, 64, 74, 38, 22, 3, _c(96, 125, 139));
  _fillEllipse(image, 64, 52, 20, 18, _c(176, 190, 197));
  _drawEyes(image, 64, 48, 7, 4);
  _fillEllipse(image, 64, 58, 8, 5, _c(120, 130, 140));
  // Flippers
  _fillEllipse(image, 30, 78, 12, 8, _c(120, 144, 156));
  _fillEllipse(image, 98, 78, 12, 8, _c(120, 144, 156));
  return image;
}

img.Image _drawRaptor() {
  final image = _canvas();
  _fillEllipse(image, 64, 58, 18, 22, _c(102, 187, 106));
  _strokeEllipse(image, 64, 58, 18, 22, 2, _c(46, 125, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 82,
    rx: 26,
    ry: 18,
    fill: _c(67, 160, 71),
    outline: _c(27, 94, 32),
  );
  _drawEyes(image, 64, 52, 7, 4);
  _fillEllipse(image, 70, 60, 8, 5, _c(255, 80, 80));
  // Tail
  _fillEllipse(image, 92, 86, 16, 8, _c(56, 142, 60));
  // Claws
  for (final dx in [-10, 0, 10]) {
    _fillRoundedRect(image, 58 + dx, 96, 62 + dx, 108, 1, _c(255, 235, 59));
  }
  return image;
}
