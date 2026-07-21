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
    'chicken': _drawChicken,
    'mouse': _drawMouse,
    'rabbit': _drawRabbit,
    'fox': _drawFox,
    'cow': _drawCow,
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
    'scarab_beetle': _drawScarabBeetle,
    'saber_cub': _drawSaberCub,
    'stone_golem': _drawStoneGolem,
    'royal_chicken': _drawRoyalChicken,
    'crown_fox': _drawCrownFox,
    'gem_dragon': _drawGemDragon,
    'cloud_bunny': _drawCloudBunny,
    'sun_lion': _drawSunLion,
    'cosmic_phoenix': _drawCosmicPhoenix,
    'void_mouse': _drawVoidMouse,
    'eclipse_wolf': _drawEclipseWolf,
    'nebula_hydra': _drawNebulaHydra,
    'dragon': _drawDragon,
    'unicorn': _drawUnicorn,
    'shark': _drawShark,
    'polar_bear': _drawPolarBear,
    'snow_owl': _drawSnowOwl,
    'triceratops': _drawTriceratops,
    't_rex': _drawTRex,
    'fossil_dragon': _drawFossilDragon,
    'moon_cat': _drawMoonCat,
    'star_fox': _drawStarFox,
    'alien_slime': _drawAlienSlime,
    'galaxy_dragon': _drawGalaxyDragon,
    'night_rooster': _drawNightRooster,
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

img.ColorRgba8 _c(int r, int g, int b, [int a = 255]) =>
    img.ColorRgba8(r, g, b, a);

void _set(img.Image image, int x, int y, img.ColorRgba8 color) {
  if (x < 0 || y < 0 || x >= image.width || y >= image.height) return;
  image.setPixel(x, y, color);
}

void _fillCircle(
  img.Image image,
  int cx,
  int cy,
  int radius,
  img.ColorRgba8 color,
) {
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

void _drawWhiskers(img.Image image, int cx, int cy) {
  for (final dy in [-3, 0, 3]) {
    _fillRoundedRect(
      image,
      cx - 24,
      cy + dy,
      cx - 12,
      cy + dy + 2,
      1,
      _c(70, 70, 70),
    );
    _fillRoundedRect(
      image,
      cx + 12,
      cy + dy,
      cx + 24,
      cy + dy + 2,
      1,
      _c(70, 70, 70),
    );
  }
}

void _drawLegSegment(
  img.Image image,
  int x,
  int topY,
  int bottomY,
  int width,
  img.ColorRgba8 color,
) {
  _fillRoundedRect(
    image,
    x - width ~/ 2,
    topY,
    x + width ~/ 2,
    bottomY,
    1,
    color,
  );
}

void _drawPaws(
  img.Image image,
  List<(int x, int y)> positions,
  img.ColorRgba8 color, {
  int rx = 7,
  int ry = 4,
}) {
  for (final pos in positions) {
    _fillEllipse(image, pos.$1, pos.$2, rx, ry, color);
  }
}

void _drawHooves(
  img.Image image,
  List<(int x, int y)> positions,
  img.ColorRgba8 legColor,
  img.ColorRgba8 hoofColor,
) {
  for (final pos in positions) {
    _drawLegSegment(image, pos.$1, pos.$2 - 10, pos.$2 - 2, 4, legColor);
    _fillEllipse(image, pos.$1, pos.$2, 6, 4, hoofColor);
  }
}

void _drawBirdLegs(
  img.Image image,
  List<int> xs,
  int footY,
  img.ColorRgba8 color,
) {
  for (final x in xs) {
    _drawLegSegment(image, x, footY - 12, footY - 2, 3, color);
    _fillEllipse(image, x, footY + 2, 6, 4, color);
    for (final tx in [-2, 0, 2]) {
      _fillCircle(image, x + tx, footY + 5, 1, color);
    }
  }
}

img.Image _drawChicken() {
  final image = _canvas();
  _fillEllipse(image, 48, 72, 14, 18, _c(240, 240, 245));
  _strokeEllipse(image, 48, 72, 14, 18, 2, _c(200, 200, 210));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 70,
    rx: 32,
    ry: 26,
    fill: _c(255, 255, 255),
    outline: _c(210, 210, 215),
  );
  _fillEllipse(image, 64, 74, 18, 12, _c(250, 250, 252));
  _fillCircle(image, 64, 42, 20, _c(255, 255, 255));
  _strokeEllipse(image, 64, 42, 20, 20, 2, _c(210, 210, 215));
  for (final x in [56, 64, 72]) {
    _fillEllipse(image, x, 18, 5, 7, _c(229, 57, 53));
  }
  _fillRoundedRect(image, 56, 18, 72, 26, 3, _c(211, 47, 47));
  _fillEllipse(image, 64, 50, 9, 7, _c(255, 152, 0));
  _fillEllipse(image, 64, 51, 7, 5, _c(255, 193, 7));
  _drawEyes(image, 64, 40, 7, 4);
  _fillEllipse(image, 90, 64, 11, 15, _c(255, 255, 255));
  _fillEllipse(image, 98, 58, 9, 12, _c(235, 235, 240));
  _drawBirdLegs(image, [52, 76], 108, _c(255, 152, 0));
  return image;
}

img.Image _drawRoyalChicken() {
  final image = _drawChicken();
  _fillRoundedRect(image, 50, 18, 78, 28, 2, _c(255, 215, 0));
  for (final x in [54, 64, 74]) {
    _fillEllipse(image, x, 16, 4, 6, _c(255, 235, 59));
  }
  return image;
}

img.Image _drawMouse() {
  final image = _canvas();
  for (final cx in [42, 86]) {
    _fillCircle(image, cx, 30, 17, _c(140, 140, 140));
    _fillCircle(image, cx, 30, 11, _c(255, 182, 193));
  }
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 68,
    rx: 30,
    ry: 24,
    fill: _c(158, 158, 158),
    outline: _c(90, 90, 90),
  );
  _fillEllipse(image, 64, 72, 18, 12, _c(189, 189, 189));
  _fillCircle(image, 64, 44, 18, _c(158, 158, 158));
  _strokeEllipse(image, 64, 44, 18, 18, 2, _c(90, 90, 90));
  _drawEyes(image, 64, 42, 6, 4);
  _fillCircle(image, 64, 50, 4, _c(255, 140, 160));
  _drawWhiskers(image, 64, 50);
  for (var i = 0; i < 10; i++) {
    _fillCircle(image, 90 + i, 68 - i, 3, _c(120, 120, 120));
  }
  _drawLegSegment(image, 48, 88, 98, 3, _c(130, 130, 130));
  _drawLegSegment(image, 80, 88, 98, 3, _c(130, 130, 130));
  _drawPaws(
    image,
    [(46, 104), (50, 104), (78, 104), (82, 104)],
    _c(120, 120, 120),
    rx: 5,
    ry: 3,
  );
  return image;
}

img.Image _drawVoidMouse() {
  final image = _drawMouse();
  _fillEllipse(image, 64, 80, 20, 16, _c(103, 58, 183, 90));
  for (final cx in [42, 86]) {
    _fillCircle(image, cx, 36, 17, _c(66, 66, 66));
    _fillCircle(image, cx, 36, 11, _c(126, 87, 194));
  }
  return image;
}

img.Image _drawRabbit() {
  final image = _canvas();
  for (final cx in [48, 80]) {
    _fillEllipse(image, cx, 22, 11, 28, _c(240, 235, 230));
    _strokeEllipse(image, cx, 22, 11, 28, 2, _c(195, 185, 180));
    _fillEllipse(image, cx, 22, 5, 18, _c(255, 200, 210));
  }
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 68,
    rx: 28,
    ry: 24,
    fill: _c(245, 240, 235),
    outline: _c(195, 185, 180),
  );
  _fillEllipse(image, 64, 72, 16, 12, _c(255, 255, 255));
  _fillCircle(image, 64, 48, 18, _c(245, 240, 235));
  _strokeEllipse(image, 64, 48, 18, 18, 2, _c(195, 185, 180));
  _drawEyes(image, 64, 46, 6, 4);
  _fillCircle(image, 64, 54, 3, _c(255, 180, 190));
  _fillCircle(image, 94, 72, 11, _c(255, 255, 255));
  _strokeEllipse(image, 94, 72, 11, 11, 1, _c(220, 220, 225));
  // Front paws
  _drawLegSegment(image, 50, 88, 98, 3, _c(220, 210, 205));
  _drawLegSegment(image, 78, 88, 98, 3, _c(220, 210, 205));
  _drawPaws(image, [(50, 104), (78, 104)], _c(245, 240, 235), rx: 6, ry: 3);
  // Large back feet
  _drawLegSegment(image, 42, 90, 100, 4, _c(220, 210, 205));
  _drawLegSegment(image, 86, 90, 100, 4, _c(220, 210, 205));
  _fillEllipse(image, 40, 110, 10, 6, _c(245, 240, 235));
  _fillEllipse(image, 88, 110, 10, 6, _c(245, 240, 235));
  return image;
}

img.Image _drawCloudBunny() {
  final image = _drawRabbit();
  for (final cx in [48, 80]) {
    _fillEllipse(image, cx, 28, 11, 30, _c(236, 239, 241));
    _fillEllipse(image, cx, 28, 5, 20, _c(144, 202, 249));
  }
  return image;
}

img.Image _drawFox() {
  final image = _canvas();
  _fillEllipse(image, 38, 28, 12, 22, _c(255, 87, 34));
  _fillEllipse(image, 90, 28, 12, 22, _c(255, 87, 34));
  _fillEllipse(image, 38, 28, 6, 14, _c(30, 30, 30));
  _fillEllipse(image, 90, 28, 6, 14, _c(30, 30, 30));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 32,
    ry: 26,
    fill: _c(255, 87, 34),
    outline: _c(191, 54, 12),
  );
  _fillEllipse(image, 64, 70, 18, 14, _c(255, 224, 178));
  _fillCircle(image, 64, 44, 20, _c(255, 87, 34));
  _strokeEllipse(image, 64, 44, 20, 20, 2, _c(191, 54, 12));
  _fillEllipse(image, 64, 50, 10, 8, _c(255, 255, 255));
  _drawEyes(image, 64, 40, 7, 4);
  _fillCircle(image, 64, 50, 3, _c(30, 30, 30));
  _fillEllipse(image, 96, 68, 16, 12, _c(255, 87, 34));
  _fillEllipse(image, 104, 64, 12, 10, _c(255, 255, 255));
  _drawHooves(image, [(50, 108), (78, 108)], _c(191, 54, 12), _c(80, 45, 25));
  return image;
}

img.Image _drawCow() {
  final image = _canvas();
  _fillCircle(image, 36, 34, 12, _c(255, 255, 255));
  _fillCircle(image, 92, 34, 12, _c(255, 255, 255));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 36,
    ry: 28,
    fill: _c(255, 255, 255),
    outline: _c(120, 120, 130),
  );
  _fillEllipse(image, 48, 62, 14, 12, _c(50, 50, 55));
  _fillEllipse(image, 80, 70, 12, 10, _c(50, 50, 55));
  _fillEllipse(image, 64, 70, 20, 16, _c(255, 220, 220));
  _fillCircle(image, 64, 42, 20, _c(255, 255, 255));
  _strokeEllipse(image, 64, 42, 20, 20, 2, _c(120, 120, 130));
  _fillEllipse(image, 64, 50, 14, 10, _c(255, 200, 210));
  _fillCircle(image, 58, 50, 2, _c(80, 50, 50));
  _fillCircle(image, 70, 50, 2, _c(80, 50, 50));
  _drawEyes(image, 64, 38, 7, 4);
  for (final dx in [-14, 14]) {
    _fillEllipse(image, 64 + dx, 28, 4, 8, _c(240, 240, 245));
  }
  _fillEllipse(image, 98, 68, 8, 4, _c(255, 255, 255));
  _drawHooves(image, [(48, 108), (80, 108)], _c(255, 255, 255), _c(50, 50, 55));
  return image;
}

img.Image _drawDeer() {
  final image = _canvas();
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 34,
    ry: 26,
    fill: _c(181, 122, 69),
    outline: _c(109, 76, 47),
  );
  _fillEllipse(image, 64, 50, 22, 18, _c(210, 160, 110));
  _strokeEllipse(image, 64, 50, 22, 18, 2, _c(109, 76, 47));
  _drawEyes(image, 64, 48, 8, 5);
  _fillEllipse(image, 64, 58, 6, 4, _c(80, 50, 30));
  for (final dx in [-18, 18]) {
    _fillRoundedRect(
      image,
      64 + dx - 3,
      16,
      64 + dx + 3,
      34,
      2,
      _c(215, 185, 142),
    );
    _fillRoundedRect(
      image,
      64 + dx - 8,
      22,
      64 + dx - 2,
      26,
      2,
      _c(215, 185, 142),
    );
    _fillRoundedRect(
      image,
      64 + dx + 2,
      22,
      64 + dx + 8,
      26,
      2,
      _c(215, 185, 142),
    );
  }
  _fillEllipse(image, 98, 66, 6, 4, _c(181, 122, 69));
  _drawHooves(image, [(48, 108), (80, 108)], _c(181, 122, 69), _c(80, 50, 30));
  return image;
}

img.Image _drawBear() {
  final image = _canvas();
  _fillCircle(image, 36, 36, 14, _c(90, 55, 30));
  _fillCircle(image, 92, 36, 14, _c(90, 55, 30));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 62,
    rx: 38,
    ry: 30,
    fill: _c(139, 90, 43),
    outline: _c(80, 50, 25),
  );
  _fillEllipse(image, 64, 60, 20, 16, _c(180, 130, 80));
  _drawEyes(image, 64, 56, 10, 6);
  _fillEllipse(image, 64, 68, 10, 7, _c(70, 40, 20));
  _fillCircle(image, 64, 64, 4, _c(50, 30, 15));
  _drawHooves(image, [(48, 108), (80, 108)], _c(139, 90, 43), _c(60, 35, 20));
  return image;
}

img.Image _drawTiger() {
  final image = _canvas();
  _fillCircle(image, 34, 34, 13, _c(255, 150, 50));
  _fillCircle(image, 94, 34, 13, _c(255, 150, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 36,
    ry: 28,
    fill: _c(255, 167, 38),
    outline: _c(180, 90, 10),
  );
  _fillEllipse(image, 64, 58, 22, 18, _c(255, 210, 120));
  _drawEyes(image, 64, 54, 9, 5);
  _fillEllipse(image, 64, 66, 8, 5, _c(255, 120, 80));
  for (var i = -2; i <= 2; i++) {
    _fillRoundedRect(image, 58 + i * 8, 72, 62 + i * 8, 86, 2, _c(120, 60, 0));
  }
  _drawHooves(image, [(48, 108), (80, 108)], _c(255, 167, 38), _c(80, 45, 20));
  return image;
}

img.Image _drawPig() {
  final image = _canvas();
  _fillCircle(image, 30, 40, 10, _c(255, 170, 190));
  _fillCircle(image, 98, 40, 10, _c(255, 170, 190));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 36,
    ry: 26,
    fill: _c(255, 182, 193),
    outline: _c(220, 100, 130),
  );
  _fillEllipse(image, 64, 58, 20, 16, _c(255, 210, 220));
  _drawEyes(image, 64, 52, 9, 5);
  _fillEllipse(image, 64, 68, 16, 12, _c(255, 140, 160));
  _fillCircle(image, 58, 68, 3, _c(220, 80, 110));
  _fillCircle(image, 70, 68, 3, _c(220, 80, 110));
  // Curly tail
  for (var i = 0; i < 8; i++) {
    final angle = i * 0.8;
    _fillCircle(
      image,
      (96 + math.cos(angle) * 8).round(),
      (66 + math.sin(angle) * 8).round(),
      3,
      _c(255, 170, 190),
    );
  }
  _drawHooves(
    image,
    [(48, 108), (80, 108)],
    _c(255, 182, 193),
    _c(180, 100, 120),
  );
  return image;
}

img.Image _drawSheep() {
  final image = _canvas();
  for (final offset in [
    (-20, -8),
    (0, -12),
    (20, -8),
    (-28, 8),
    (-10, 12),
    (10, 12),
    (28, 8),
  ]) {
    _fillCircle(image, 64 + offset.$1, 52 + offset.$2, 16, _c(245, 245, 245));
  }
  _fillCircle(image, 64, 54, 22, _c(250, 250, 250));
  _strokeEllipse(image, 64, 54, 22, 22, 2, _c(200, 200, 210));
  _fillEllipse(image, 64, 58, 16, 12, _c(60, 50, 50));
  _drawEyes(image, 64, 54, 7, 4);
  _fillEllipse(image, 64, 64, 5, 3, _c(80, 60, 60));
  _fillEllipse(image, 40, 48, 6, 8, _c(245, 245, 245));
  _fillEllipse(image, 88, 48, 6, 8, _c(245, 245, 245));
  _drawHooves(image, [(48, 110), (80, 110)], _c(60, 50, 50), _c(40, 30, 30));
  return image;
}

img.Image _drawHorse() {
  final image = _canvas();
  _fillEllipse(image, 64, 44, 16, 26, _c(120, 70, 35));
  _strokeEllipse(image, 64, 44, 16, 26, 2, _c(70, 40, 20));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 68,
    rx: 34,
    ry: 22,
    fill: _c(160, 100, 55),
    outline: _c(90, 55, 25),
  );
  _fillEllipse(image, 64, 40, 14, 14, _c(200, 150, 100));
  _drawEyes(image, 64, 36, 6, 4);
  _fillEllipse(image, 64, 46, 8, 5, _c(80, 45, 25));
  _fillRoundedRect(image, 48, 22, 56, 50, 4, _c(70, 40, 20));
  _fillEllipse(image, 28, 70, 10, 6, _c(160, 100, 55));
  _drawLegSegment(image, 48, 86, 104, 4, _c(120, 70, 35));
  _drawLegSegment(image, 80, 86, 104, 4, _c(120, 70, 35));
  _drawLegSegment(image, 54, 88, 106, 3, _c(120, 70, 35));
  _drawLegSegment(image, 74, 88, 106, 3, _c(120, 70, 35));
  _drawHooves(
    image,
    [(48, 110), (54, 112), (74, 112), (80, 110)],
    _c(120, 70, 35),
    _c(50, 30, 20),
  );
  return image;
}

img.Image _drawMonkey() {
  final image = _canvas();
  _fillCircle(image, 34, 34, 13, _c(140, 90, 50));
  _fillCircle(image, 94, 34, 13, _c(140, 90, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 34,
    ry: 26,
    fill: _c(161, 107, 60),
    outline: _c(100, 60, 30),
  );
  _fillEllipse(image, 64, 60, 22, 18, _c(230, 190, 150));
  _drawEyes(image, 64, 54, 9, 5);
  _fillEllipse(image, 64, 68, 12, 8, _c(200, 150, 120));
  // Tail
  for (var i = 0; i < 12; i++) {
    _fillCircle(image, 96 + i, 70 + (i % 2) * 4, 4, _c(140, 90, 50));
  }
  // Arms
  _fillEllipse(image, 32, 68, 8, 14, _c(161, 107, 60));
  _fillEllipse(image, 96, 68, 8, 14, _c(161, 107, 60));
  _drawPaws(image, [(30, 78), (98, 78)], _c(200, 150, 120), rx: 6, ry: 4);
  _drawHooves(image, [(48, 108), (80, 108)], _c(161, 107, 60), _c(100, 60, 30));
  return image;
}

img.Image _drawParrot() {
  final image = _canvas();
  _fillRoundedRect(image, 58, 18, 70, 34, 4, _c(255, 80, 80));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 62,
    rx: 28,
    ry: 26,
    fill: _c(67, 160, 71),
    outline: _c(30, 100, 40),
  );
  _fillEllipse(image, 64, 52, 18, 14, _c(120, 200, 90));
  _drawEyes(image, 64, 48, 7, 4);
  _fillEllipse(image, 78, 56, 10, 6, _c(255, 200, 0));
  _fillEllipse(image, 86, 58, 4, 3, _c(30, 30, 30));
  _fillEllipse(image, 48, 66, 12, 16, _c(30, 120, 50));
  _fillEllipse(image, 36, 78, 10, 14, _c(30, 136, 229));
  _fillEllipse(image, 28, 84, 8, 10, _c(229, 57, 53));
  _drawBirdLegs(image, [54, 74], 106, _c(255, 143, 0));
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
  _fillCircle(image, 32, 36, 14, _c(50, 50, 55));
  _fillCircle(image, 96, 36, 14, _c(50, 50, 55));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 38,
    ry: 28,
    fill: _c(70, 70, 78),
    outline: _c(35, 35, 40),
  );
  _fillEllipse(image, 64, 60, 22, 16, _c(120, 120, 130));
  _drawEyes(image, 64, 54, 9, 5);
  _fillRoundedRect(image, 58, 66, 70, 74, 3, _c(90, 90, 95));
  _fillEllipse(image, 30, 66, 10, 16, _c(70, 70, 78));
  _fillEllipse(image, 98, 66, 10, 16, _c(70, 70, 78));
  _drawHooves(image, [(48, 108), (80, 108)], _c(70, 70, 78), _c(40, 40, 45));
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
  _fillEllipse(image, 64, 62, 36, 26, _c(46, 125, 50));
  _strokeEllipse(image, 64, 62, 36, 26, 3, _c(27, 94, 32));
  for (var row = 0; row < 3; row++) {
    for (var col = 0; col < 3; col++) {
      _fillEllipse(
        image,
        52 + col * 12,
        52 + row * 10,
        5,
        4,
        _c(102, 187, 106),
      );
    }
  }
  _fillEllipse(image, 64, 34, 14, 12, _c(129, 199, 132));
  _strokeEllipse(image, 64, 34, 14, 12, 2, _c(46, 125, 50));
  _drawEyes(image, 64, 32, 5, 3);
  _fillEllipse(image, 64, 40, 4, 3, _c(80, 140, 80));
  _fillEllipse(image, 64, 86, 4, 3, _c(129, 199, 132));
  for (final pos in [(38, 78), (90, 78), (44, 88), (84, 88)]) {
    _drawLegSegment(image, pos.$1, pos.$2 - 6, pos.$2, 3, _c(100, 160, 100));
    _fillEllipse(image, pos.$1, pos.$2 + 2, 7, 4, _c(129, 199, 132));
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
    cy: 64,
    rx: 28,
    ry: 32,
    fill: _c(30, 30, 35),
    outline: _c(10, 10, 15),
  );
  _fillEllipse(image, 64, 68, 18, 24, _c(250, 250, 250));
  _drawEyes(image, 64, 44, 8, 5);
  _fillEllipse(image, 64, 56, 6, 8, _c(255, 160, 0));
  _fillEllipse(image, 34, 68, 8, 16, _c(30, 30, 35));
  _fillEllipse(image, 94, 68, 8, 16, _c(30, 30, 35));
  _drawLegSegment(image, 54, 92, 102, 3, _c(255, 160, 0));
  _drawLegSegment(image, 74, 92, 102, 3, _c(255, 160, 0));
  _fillEllipse(image, 54, 108, 10, 5, _c(255, 160, 0));
  _fillEllipse(image, 74, 108, 10, 5, _c(255, 160, 0));
  return image;
}

img.Image _drawSeal() {
  final image = _canvas();
  _fillEllipse(image, 64, 66, 38, 20, _c(144, 164, 174));
  _strokeEllipse(image, 64, 66, 38, 20, 3, _c(96, 125, 139));
  _fillEllipse(image, 64, 44, 20, 16, _c(176, 190, 197));
  _drawEyes(image, 64, 40, 7, 4);
  _fillEllipse(image, 64, 50, 8, 5, _c(120, 130, 140));
  _drawWhiskers(image, 64, 50);
  _fillEllipse(image, 28, 68, 12, 8, _c(120, 144, 156));
  _fillEllipse(image, 100, 68, 12, 8, _c(120, 144, 156));
  _fillEllipse(image, 64, 82, 10, 6, _c(120, 144, 156));
  _fillEllipse(image, 52, 104, 8, 4, _c(96, 125, 139));
  _fillEllipse(image, 76, 104, 8, 4, _c(96, 125, 139));
  return image;
}

img.Image _drawRaptor() {
  final image = _canvas();
  _fillEllipse(image, 64, 48, 18, 20, _c(102, 187, 106));
  _strokeEllipse(image, 64, 48, 18, 20, 2, _c(46, 125, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 70,
    rx: 26,
    ry: 22,
    fill: _c(67, 160, 71),
    outline: _c(27, 94, 32),
  );
  _drawEyes(image, 64, 44, 7, 4);
  _fillEllipse(image, 70, 52, 8, 5, _c(255, 80, 80));
  _fillEllipse(image, 96, 76, 18, 8, _c(56, 142, 60));
  _drawLegSegment(image, 48, 88, 100, 4, _c(67, 160, 71));
  _drawLegSegment(image, 80, 88, 100, 4, _c(67, 160, 71));
  for (final x in [44, 48, 52, 76, 80, 84]) {
    _fillRoundedRect(image, x, 100, x + 2, 108, 1, _c(255, 235, 59));
  }
  return image;
}

img.Image _drawCrownFox() {
  final image = _drawFox();
  _fillRoundedRect(image, 50, 12, 78, 22, 2, _c(255, 215, 0));
  for (final x in [54, 64, 74]) {
    _fillEllipse(image, x, 10, 4, 6, _c(255, 235, 59));
  }
  return image;
}

img.Image _drawSunLion() {
  final image = _canvas();
  _fillEllipse(image, 64, 38, 34, 30, _c(255, 193, 7));
  for (var i = 0; i < 12; i++) {
    final angle = i * math.pi / 6;
    _fillEllipse(
      image,
      (64 + math.cos(angle) * 38).round(),
      (38 + math.sin(angle) * 32).round(),
      6,
      10,
      _c(255, 152, 0),
    );
  }
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 32,
    ry: 26,
    fill: _c(255, 193, 7),
    outline: _c(255, 152, 0),
  );
  _fillEllipse(image, 64, 70, 18, 14, _c(255, 236, 179));
  _fillCircle(image, 64, 44, 20, _c(255, 193, 7));
  _strokeEllipse(image, 64, 44, 20, 20, 2, _c(255, 152, 0));
  _drawEyes(image, 64, 40, 7, 4);
  _fillEllipse(image, 64, 50, 8, 6, _c(255, 236, 179));
  _fillCircle(image, 64, 50, 3, _c(50, 30, 15));
  for (var i = 0; i < 8; i++) {
    _fillCircle(image, 98 + i, 64 + (i % 2), 3, _c(255, 193, 7));
  }
  _drawHooves(image, [(48, 108), (80, 108)], _c(255, 193, 7), _c(180, 120, 20));
  return image;
}

img.Image _drawEclipseWolf() {
  final image = _canvas();
  _fillEllipse(image, 38, 28, 10, 20, _c(55, 71, 79));
  _fillEllipse(image, 90, 28, 10, 20, _c(55, 71, 79));
  _fillEllipse(image, 38, 28, 5, 12, _c(176, 190, 197));
  _fillEllipse(image, 90, 28, 5, 12, _c(176, 190, 197));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 32,
    ry: 26,
    fill: _c(55, 71, 79),
    outline: _c(38, 50, 56),
  );
  _fillEllipse(image, 64, 70, 18, 14, _c(120, 144, 156));
  _fillCircle(image, 64, 44, 20, _c(55, 71, 79));
  _strokeEllipse(image, 64, 44, 20, 20, 2, _c(38, 50, 56));
  _fillEllipse(image, 64, 50, 10, 8, _c(176, 190, 197));
  _drawEyes(image, 64, 40, 7, 4);
  _fillCircle(image, 64, 50, 3, _c(30, 30, 30));
  _fillEllipse(image, 96, 68, 14, 10, _c(55, 71, 79));
  _drawHooves(image, [(48, 108), (80, 108)], _c(55, 71, 79), _c(40, 50, 55));
  return image;
}

img.Image _drawSaberCub() {
  final image = _canvas();
  _fillCircle(image, 34, 34, 13, _c(255, 152, 0));
  _fillCircle(image, 94, 34, 13, _c(255, 152, 0));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 34,
    ry: 26,
    fill: _c(255, 152, 0),
    outline: _c(230, 120, 0),
  );
  _fillEllipse(image, 64, 60, 20, 16, _c(255, 236, 179));
  _drawEyes(image, 64, 54, 9, 5);
  _fillEllipse(image, 64, 66, 10, 7, _c(255, 200, 140));
  // Saber fangs
  _fillRoundedRect(image, 54, 66, 58, 76, 1, _c(255, 255, 240));
  _fillRoundedRect(image, 70, 66, 74, 76, 1, _c(255, 255, 240));
  _fillEllipse(image, 28, 70, 8, 14, _c(255, 152, 0));
  _fillEllipse(image, 100, 70, 8, 14, _c(255, 152, 0));
  _drawHooves(image, [(48, 108), (80, 108)], _c(255, 152, 0), _c(180, 100, 20));
  return image;
}

img.Image _drawNebulaHydra() {
  final image = _canvas();
  _fillEllipse(image, 34, 70, 14, 22, _c(171, 71, 188, 180));
  _fillEllipse(image, 94, 70, 14, 22, _c(171, 71, 188, 180));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 68,
    rx: 30,
    ry: 26,
    fill: _c(63, 81, 181),
    outline: _c(171, 71, 188),
  );
  _fillEllipse(image, 64, 72, 18, 14, _c(121, 134, 203));
  // Three heads
  for (final dx in [-22, 0, 22]) {
    _fillCircle(image, 64 + dx, 38, 14, _c(63, 81, 181));
    _strokeEllipse(image, 64 + dx, 38, 14, 14, 2, _c(171, 71, 188));
    _drawEyes(image, 64 + dx, 36, 5, 3);
    _fillEllipse(image, 64 + dx, 44, 5, 4, _c(171, 71, 188));
  }
  _drawHooves(image, [(48, 108), (80, 108)], _c(63, 81, 181), _c(40, 50, 100));
  return image;
}

img.Image _drawDragon() {
  final image = _canvas();
  _fillEllipse(image, 34, 70, 14, 22, _c(76, 175, 80));
  _fillEllipse(image, 94, 70, 14, 22, _c(76, 175, 80));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 34,
    ry: 26,
    fill: _c(46, 125, 50),
    outline: _c(27, 94, 32),
  );
  _fillEllipse(image, 64, 70, 18, 14, _c(129, 199, 132));
  _fillCircle(image, 64, 42, 20, _c(46, 125, 50));
  _strokeEllipse(image, 64, 42, 20, 20, 2, _c(27, 94, 32));
  _fillEllipse(image, 64, 48, 10, 8, _c(129, 199, 132));
  _drawEyes(image, 64, 38, 7, 4);
  _fillEllipse(image, 64, 52, 8, 5, _c(244, 67, 54));
  _fillEllipse(image, 52, 30, 5, 10, _c(46, 125, 50));
  _fillEllipse(image, 76, 30, 5, 10, _c(46, 125, 50));
  for (var i = 0; i < 10; i++) {
    _fillCircle(image, 100 + i, 60 - i, 4, _c(46, 125, 50));
  }
  _drawHooves(image, [(48, 108), (80, 108)], _c(46, 125, 50), _c(30, 70, 30));
  return image;
}

img.Image _drawMoonCat() {
  final image = _canvas();
  _fillEllipse(image, 38, 24, 10, 18, _c(120, 130, 160));
  _fillEllipse(image, 90, 24, 10, 18, _c(120, 130, 160));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 30,
    ry: 26,
    fill: _c(144, 164, 174),
    outline: _c(96, 125, 139),
  );
  _fillEllipse(image, 64, 70, 18, 14, _c(220, 230, 240));
  _fillCircle(image, 64, 44, 20, _c(144, 164, 174));
  _strokeEllipse(image, 64, 44, 20, 20, 2, _c(96, 125, 139));
  _drawEyes(image, 64, 40, 7, 4);
  _fillEllipse(image, 64, 50, 8, 6, _c(220, 230, 240));
  _fillCircle(image, 64, 50, 3, _c(50, 50, 60));
  _drawWhiskers(image, 64, 50);
  for (var i = 0; i < 10; i++) {
    _fillCircle(image, 98 + i, 62 + (i % 2), 3, _c(144, 164, 174));
  }
  _drawHooves(
    image,
    [(48, 108), (80, 108)],
    _c(144, 164, 174),
    _c(80, 90, 100),
  );
  return image;
}

img.Image _drawNightRooster() {
  final image = _drawChicken();
  _fillEllipse(image, 64, 70, 30, 24, _c(45, 45, 65, 200));
  _fillCircle(image, 64, 42, 18, _c(45, 45, 65, 200));
  _fillEllipse(image, 64, 70, 16, 12, _c(70, 70, 90, 180));
  _fillCircle(image, 64, 18, 3, _c(255, 235, 59));
  return image;
}

img.Image _drawScarabBeetle() {
  final image = _canvas();
  _fillEllipse(image, 64, 66, 34, 28, _c(121, 85, 72));
  _strokeEllipse(image, 64, 66, 34, 28, 3, _c(78, 52, 46));
  _fillEllipse(image, 48, 62, 14, 20, _c(93, 64, 55));
  _fillEllipse(image, 80, 62, 14, 20, _c(93, 64, 55));
  _fillEllipse(image, 64, 58, 12, 10, _c(255, 193, 7));
  _fillEllipse(image, 64, 58, 6, 5, _c(255, 224, 130));
  _drawEyes(image, 64, 48, 8, 4);
  for (final dx in [-10, 10]) {
    _fillRoundedRect(
      image,
      64 + dx - 2,
      28,
      64 + dx + 2,
      42,
      1,
      _c(78, 52, 46),
    );
  }
  for (final pos in [
    (44, 88),
    (54, 92),
    (64, 94),
    (74, 92),
    (84, 88),
    (50, 96),
  ]) {
    _drawLegSegment(image, pos.$1, pos.$2 - 6, pos.$2, 2, _c(78, 52, 46));
    _fillCircle(image, pos.$1, pos.$2 + 1, 2, _c(62, 39, 35));
  }
  return image;
}

img.Image _drawStoneGolem() {
  final image = _canvas();
  _fillRoundedRect(image, 38, 52, 90, 92, 8, _c(120, 144, 156));
  _fillRoundedRect(image, 44, 58, 84, 86, 6, _c(176, 190, 197));
  _fillRoundedRect(image, 50, 64, 78, 80, 4, _c(144, 164, 174));
  _fillRoundedRect(image, 48, 28, 80, 56, 6, _c(120, 144, 156));
  _fillRoundedRect(image, 54, 34, 74, 50, 4, _c(176, 190, 197));
  _drawEyes(image, 64, 42, 10, 5);
  _fillRoundedRect(image, 58, 52, 70, 58, 2, _c(69, 90, 100));
  for (final x in [52, 64, 76]) {
    _fillRoundedRect(image, x - 2, 48, x + 2, 92, 1, _c(96, 125, 139, 120));
  }
  _drawLegSegment(image, 48, 90, 106, 8, _c(96, 125, 139));
  _drawLegSegment(image, 80, 90, 106, 8, _c(96, 125, 139));
  _fillRoundedRect(image, 40, 104, 56, 112, 3, _c(69, 90, 100));
  _fillRoundedRect(image, 72, 104, 88, 112, 3, _c(69, 90, 100));
  return image;
}

img.Image _drawGemDragon() {
  final image = _canvas();
  _fillEllipse(image, 34, 68, 14, 22, _c(186, 104, 200));
  _fillEllipse(image, 94, 68, 14, 22, _c(186, 104, 200));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 32,
    ry: 26,
    fill: _c(171, 71, 188),
    outline: _c(233, 30, 99),
  );
  _fillEllipse(image, 64, 68, 18, 14, _c(225, 190, 231));
  _fillCircle(image, 64, 40, 20, _c(171, 71, 188));
  _strokeEllipse(image, 64, 40, 20, 20, 2, _c(233, 30, 99));
  _drawEyes(image, 64, 36, 7, 4);
  _fillEllipse(image, 64, 48, 8, 5, _c(233, 30, 99));
  _fillEllipse(image, 52, 26, 6, 12, _c(233, 30, 99));
  _fillEllipse(image, 76, 26, 6, 12, _c(233, 30, 99));
  _fillEllipse(image, 52, 24, 4, 6, _c(186, 104, 200));
  _fillEllipse(image, 76, 24, 4, 6, _c(186, 104, 200));
  for (var i = 0; i < 10; i++) {
    _fillCircle(image, 98 + i, 58 - i, 4, _c(171, 71, 188));
  }
  _drawHooves(
    image,
    [(48, 108), (80, 108)],
    _c(171, 71, 188),
    _c(126, 87, 194),
  );
  return image;
}

img.Image _drawCosmicPhoenix() {
  final image = _canvas();
  _fillEllipse(image, 28, 66, 16, 24, _c(244, 67, 54, 200));
  _fillEllipse(image, 100, 66, 16, 24, _c(156, 39, 176, 200));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 28,
    ry: 24,
    fill: _c(244, 67, 54),
    outline: _c(156, 39, 176),
  );
  _fillEllipse(image, 64, 68, 16, 12, _c(255, 183, 77));
  _fillCircle(image, 64, 42, 18, _c(244, 67, 54));
  _strokeEllipse(image, 64, 42, 18, 18, 2, _c(156, 39, 176));
  _drawEyes(image, 64, 38, 6, 4);
  _fillEllipse(image, 64, 48, 8, 6, _c(255, 193, 7));
  _fillEllipse(image, 36, 84, 12, 16, _c(255, 152, 0));
  _fillEllipse(image, 48, 92, 10, 14, _c(156, 39, 176));
  _fillEllipse(image, 80, 92, 10, 14, _c(255, 87, 34));
  _drawBirdLegs(image, [54, 74], 106, _c(255, 152, 0));
  return image;
}

img.Image _drawUnicorn() {
  final image = _canvas();
  _fillEllipse(image, 64, 40, 14, 24, _c(255, 255, 255));
  _strokeEllipse(image, 64, 40, 14, 24, 2, _c(220, 220, 230));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 32,
    ry: 24,
    fill: _c(255, 255, 255),
    outline: _c(220, 220, 230),
  );
  _fillEllipse(image, 64, 36, 12, 12, _c(255, 240, 250));
  _drawEyes(image, 64, 32, 6, 4);
  _fillEllipse(image, 64, 40, 6, 4, _c(255, 180, 200));
  _fillRoundedRect(image, 50, 20, 58, 36, 3, _c(255, 200, 230));
  _fillEllipse(image, 64, 14, 4, 14, _c(255, 215, 0));
  _fillEllipse(image, 64, 10, 3, 5, _c(255, 255, 200));
  _fillEllipse(image, 28, 66, 10, 6, _c(255, 255, 255));
  for (final x in [48, 54, 74, 80]) {
    _drawLegSegment(image, x, 86, 102, 3, _c(255, 240, 250));
  }
  _drawHooves(
    image,
    [(48, 108), (54, 110), (74, 110), (80, 108)],
    _c(255, 240, 250),
    _c(200, 180, 200),
  );
  return image;
}

img.Image _drawShark() {
  final image = _canvas();
  _drawOutlinedBody(
    image,
    cx: 58,
    cy: 64,
    rx: 36,
    ry: 20,
    fill: _c(96, 125, 139),
    outline: _c(55, 71, 79),
  );
  _fillEllipse(image, 58, 68, 24, 12, _c(236, 239, 241));
  _fillEllipse(image, 96, 64, 16, 18, _c(69, 90, 100));
  _fillEllipse(image, 108, 64, 8, 12, _c(55, 71, 79));
  _fillEllipse(image, 64, 42, 8, 16, _c(69, 90, 100));
  _drawEyes(image, 44, 58, 0, 5);
  _fillCircle(image, 44, 58, 2, _c(20, 20, 30));
  for (final dx in [52, 58, 64]) {
    _fillEllipse(image, 72 + dx - 58, 62, 2, 3, _c(255, 255, 255));
  }
  _fillEllipse(image, 24, 66, 10, 8, _c(69, 90, 100));
  return image;
}

img.Image _drawPolarBear() {
  final image = _canvas();
  _fillCircle(image, 36, 36, 14, _c(230, 240, 250));
  _fillCircle(image, 92, 36, 14, _c(230, 240, 250));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 62,
    rx: 38,
    ry: 30,
    fill: _c(255, 255, 255),
    outline: _c(200, 220, 235),
  );
  _fillEllipse(image, 64, 60, 20, 16, _c(240, 248, 255));
  _drawEyes(image, 64, 56, 10, 6);
  _fillEllipse(image, 64, 68, 10, 7, _c(180, 200, 220));
  _fillCircle(image, 64, 64, 4, _c(120, 140, 160));
  _drawHooves(
    image,
    [(48, 108), (80, 108)],
    _c(255, 255, 255),
    _c(180, 200, 215),
  );
  return image;
}

img.Image _drawSnowOwl() {
  final image = _canvas();
  _fillEllipse(image, 64, 62, 32, 30, _c(250, 250, 255));
  _strokeEllipse(image, 64, 62, 32, 30, 3, _c(200, 210, 225));
  _fillEllipse(image, 64, 66, 20, 22, _c(255, 255, 255));
  _fillCircle(image, 64, 48, 22, _c(250, 250, 255));
  _fillCircle(image, 52, 46, 10, _c(255, 255, 255));
  _fillCircle(image, 76, 46, 10, _c(255, 255, 255));
  _fillCircle(image, 52, 46, 7, _c(255, 235, 59));
  _fillCircle(image, 76, 46, 7, _c(255, 235, 59));
  _fillCircle(image, 52, 46, 4, _c(20, 20, 30));
  _fillCircle(image, 76, 46, 4, _c(20, 20, 30));
  _fillEllipse(image, 64, 56, 6, 8, _c(255, 160, 0));
  _fillEllipse(image, 28, 68, 14, 22, _c(240, 240, 248));
  _fillEllipse(image, 100, 68, 14, 22, _c(240, 240, 248));
  _drawBirdLegs(image, [54, 74], 106, _c(255, 160, 0));
  return image;
}

img.Image _drawTriceratops() {
  final image = _canvas();
  _fillEllipse(image, 64, 52, 28, 16, _c(255, 183, 77));
  _strokeEllipse(image, 64, 52, 28, 16, 2, _c(230, 140, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 72,
    rx: 34,
    ry: 22,
    fill: _c(255, 167, 38),
    outline: _c(230, 120, 0),
  );
  _fillCircle(image, 64, 44, 16, _c(255, 183, 77));
  _drawEyes(image, 64, 42, 6, 3);
  for (final dx in [-12, 0, 12]) {
    _fillEllipse(image, 64 + dx, 36, 4, 10, _c(240, 240, 245));
  }
  _drawLegSegment(image, 44, 90, 104, 5, _c(255, 167, 38));
  _drawLegSegment(image, 84, 90, 104, 5, _c(255, 167, 38));
  _drawLegSegment(image, 52, 92, 106, 4, _c(255, 167, 38));
  _drawLegSegment(image, 76, 92, 106, 4, _c(255, 167, 38));
  _drawHooves(
    image,
    [(44, 108), (52, 110), (76, 110), (84, 108)],
    _c(255, 167, 38),
    _c(180, 100, 20),
  );
  return image;
}

img.Image _drawTRex() {
  final image = _canvas();
  _fillEllipse(image, 64, 44, 26, 22, _c(76, 175, 80));
  _strokeEllipse(image, 64, 44, 26, 22, 3, _c(46, 125, 50));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 72,
    rx: 28,
    ry: 20,
    fill: _c(67, 160, 71),
    outline: _c(27, 94, 32),
  );
  _drawEyes(image, 64, 38, 8, 5);
  _fillEllipse(image, 64, 50, 14, 8, _c(46, 125, 50));
  for (final dx in [-4, 4]) {
    _fillRoundedRect(
      image,
      64 + dx - 1,
      50,
      64 + dx + 1,
      58,
      1,
      _c(255, 255, 240),
    );
  }
  _fillEllipse(image, 38, 70, 6, 10, _c(67, 160, 71));
  _fillEllipse(image, 90, 70, 6, 10, _c(67, 160, 71));
  _fillEllipse(image, 98, 78, 20, 10, _c(56, 142, 60));
  _drawLegSegment(image, 48, 88, 104, 6, _c(67, 160, 71));
  _drawLegSegment(image, 80, 88, 104, 6, _c(67, 160, 71));
  _drawHooves(image, [(48, 110), (80, 110)], _c(67, 160, 71), _c(40, 80, 40));
  return image;
}

img.Image _drawFossilDragon() {
  final image = _canvas();
  _fillEllipse(image, 34, 68, 14, 22, _c(188, 170, 140, 180));
  _fillEllipse(image, 94, 68, 14, 22, _c(188, 170, 140, 180));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 66,
    rx: 32,
    ry: 26,
    fill: _c(215, 204, 200),
    outline: _c(141, 110, 99),
  );
  _fillEllipse(image, 64, 70, 18, 14, _c(240, 235, 230));
  _fillCircle(image, 64, 42, 20, _c(215, 204, 200));
  _strokeEllipse(image, 64, 42, 20, 20, 2, _c(141, 110, 99));
  _drawEyes(image, 64, 38, 7, 4);
  _fillEllipse(image, 64, 52, 10, 6, _c(188, 170, 140));
  for (var i = 0; i < 5; i++) {
    _fillRoundedRect(
      image,
      52 + i * 6,
      74,
      56 + i * 6,
      82,
      1,
      _c(141, 110, 99),
    );
  }
  _fillEllipse(image, 52, 28, 5, 10, _c(188, 170, 140));
  _fillEllipse(image, 76, 28, 5, 10, _c(188, 170, 140));
  for (var i = 0; i < 10; i++) {
    _fillCircle(image, 98 + i, 58 - i, 4, _c(188, 170, 140));
  }
  _drawHooves(
    image,
    [(48, 108), (80, 108)],
    _c(188, 170, 140),
    _c(109, 76, 65),
  );
  return image;
}

img.Image _drawStarFox() {
  final image = _drawFox();
  for (final pos in [(24, 24), (104, 20), (64, 12), (20, 64), (108, 72)]) {
    _fillCircle(image, pos.$1, pos.$2, 3, _c(255, 235, 59));
    _fillCircle(image, pos.$1, pos.$2, 1, _c(255, 255, 255));
  }
  return image;
}

img.Image _drawAlienSlime() {
  final image = _canvas();
  _fillEllipse(image, 64, 72, 36, 30, _c(102, 187, 106));
  _strokeEllipse(image, 64, 72, 36, 30, 3, _c(56, 142, 60));
  _fillEllipse(image, 64, 64, 26, 22, _c(165, 214, 167));
  _fillEllipse(image, 64, 56, 18, 14, _c(200, 230, 201));
  _drawEyes(image, 64, 58, 10, 6);
  _fillEllipse(image, 64, 68, 8, 5, _c(46, 125, 50));
  _fillCircle(image, 48, 48, 5, _c(129, 199, 132, 180));
  _fillCircle(image, 80, 52, 4, _c(129, 199, 132, 180));
  for (final dx in [-14, 14]) {
    _fillRoundedRect(
      image,
      64 + dx - 2,
      24,
      64 + dx + 2,
      40,
      2,
      _c(156, 39, 176),
    );
    _fillCircle(image, 64 + dx, 22, 4, _c(186, 104, 200));
  }
  _fillEllipse(image, 52, 98, 8, 5, _c(76, 175, 80));
  _fillEllipse(image, 76, 98, 8, 5, _c(76, 175, 80));
  return image;
}

img.Image _drawGalaxyDragon() {
  final image = _canvas();
  _fillEllipse(image, 34, 68, 14, 22, _c(63, 81, 181, 200));
  _fillEllipse(image, 94, 68, 14, 22, _c(156, 39, 176, 200));
  _drawOutlinedBody(
    image,
    cx: 64,
    cy: 64,
    rx: 32,
    ry: 26,
    fill: _c(40, 53, 147),
    outline: _c(171, 71, 188),
  );
  _fillEllipse(image, 64, 68, 18, 14, _c(92, 107, 192));
  _fillCircle(image, 64, 40, 20, _c(40, 53, 147));
  _strokeEllipse(image, 64, 40, 20, 20, 2, _c(171, 71, 188));
  _drawEyes(image, 64, 36, 7, 4);
  _fillEllipse(image, 64, 48, 8, 5, _c(171, 71, 188));
  for (final pos in [(52, 70), (76, 74), (60, 58), (72, 62), (64, 78)]) {
    _fillCircle(image, pos.$1, pos.$2, 2, _c(255, 255, 255));
  }
  _fillEllipse(image, 52, 26, 5, 10, _c(171, 71, 188));
  _fillEllipse(image, 76, 26, 5, 10, _c(171, 71, 188));
  for (var i = 0; i < 10; i++) {
    _fillCircle(image, 98 + i, 58 - i, 4, _c(63, 81, 181));
  }
  _drawHooves(image, [(48, 108), (80, 108)], _c(40, 53, 147), _c(26, 35, 126));
  return image;
}
