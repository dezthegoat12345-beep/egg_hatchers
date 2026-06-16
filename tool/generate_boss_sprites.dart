// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

/// Generates polished boss sprites for Boss Battles.
/// Run: dart run tool/generate_boss_sprites.dart
void main() {
  const size = 160;
  const outDir = 'assets/images/bosses';

  final generators = <String, img.Image Function()>{
    'slime_boss': _drawSlimeBoss,
    'egg_golem': _drawEggGolem,
    'shadow_rooster': _drawShadowRooster,
    'slime_king': _drawSlimeKing,
    'egg_guardian': _drawEggGuardian,
    'shadow_phoenix': _drawShadowPhoenix,
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

void _set(img.Image image, int x, int y, img.ColorRgba8 color) {
  if (x >= 0 && y >= 0 && x < image.width && y < image.height) {
    image.setPixel(x, y, color);
  }
}

void _fillRect(
  img.Image image,
  int x,
  int y,
  int w,
  int h,
  img.ColorRgba8 color,
) {
  for (var py = y; py < y + h; py++) {
    for (var px = x; px < x + w; px++) {
      _set(image, px, py, color);
    }
  }
}

void _fillCircle(img.Image image, int cx, int cy, int r, img.ColorRgba8 color) {
  for (var y = cy - r; y <= cy + r; y++) {
    for (var x = cx - r; x <= cx + r; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy <= r * r) {
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

void _drawTriangle(
  img.Image image,
  int x1,
  int y1,
  int x2,
  int y2,
  int x3,
  int y3,
  img.ColorRgba8 color,
) {
  final minX = [x1, x2, x3].reduce((a, b) => a < b ? a : b);
  final maxX = [x1, x2, x3].reduce((a, b) => a > b ? a : b);
  final minY = [y1, y2, y3].reduce((a, b) => a < b ? a : b);
  final maxY = [y1, y2, y3].reduce((a, b) => a > b ? a : b);

  double area(int ax, int ay, int bx, int by, int cx, int cy) =>
      (bx - ax) * (cy - ay).toDouble() - (cx - ax) * (by - ay).toDouble();

  final total = area(x1, y1, x2, y2, x3, y3);
  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final a1 = area(x, y, x1, y1, x2, y2);
      final a2 = area(x, y, x2, y2, x3, y3);
      final a3 = area(x, y, x3, y3, x1, y1);
      final hasNeg = (a1 < 0) || (a2 < 0) || (a3 < 0);
      final hasPos = (a1 > 0) || (a2 > 0) || (a3 > 0);
      if (total < 0 ? (hasNeg && hasPos) : !(hasNeg && hasPos)) {
        _set(image, x, y, color);
      }
    }
  }
}

void _drawAngryEyes(
  img.Image image,
  int cx,
  int cy,
  int spacing,
  int radius, {
  img.ColorRgba8? sclera,
  img.ColorRgba8? pupil,
}) {
  final eyeWhite = sclera ?? _c(255, 255, 255);
  final eyePupil = pupil ?? _c(20, 20, 30);
  for (final ox in [-spacing, spacing]) {
    _fillCircle(image, cx + ox, cy, radius, eyeWhite);
    _fillCircle(image, cx + ox + 1, cy + 1, radius - 2, eyePupil);
    _fillCircle(image, cx + ox + 2, cy, 2, _c(255, 255, 255));
    _fillRect(image, cx + ox - radius, cy - radius - 2, radius * 2, 2, eyePupil);
  }
}

void _drawGlowEye(img.Image image, int cx, int cy, img.ColorRgba8 glow) {
  _fillCircle(image, cx, cy, 8, _c(glow.r.toInt(), glow.g.toInt(), glow.b.toInt(), 80));
  _fillCircle(image, cx, cy, 5, glow);
  _fillCircle(image, cx + 1, cy - 1, 2, _c(255, 255, 255));
}

img.Image _drawSlimeBoss() {
  final image = _canvas();
  // Dripping puddle base
  _fillEllipse(image, 80, 118, 62, 18, _c(46, 125, 50));
  // Main body layers
  _fillEllipse(image, 80, 96, 58, 46, _c(76, 175, 80));
  _strokeEllipse(image, 80, 96, 58, 46, 4, _c(27, 94, 32));
  _fillEllipse(image, 80, 84, 46, 36, _c(102, 187, 106));
  _fillEllipse(image, 80, 70, 34, 28, _c(129, 199, 132));
  // Slime spikes / crown bumps
  for (final pos in [(58, 52), (72, 44), (88, 44), (102, 52)]) {
    _fillEllipse(image, pos.$1, pos.$2, 8, 12, _c(129, 199, 132));
    _fillEllipse(image, pos.$1, pos.$2 - 4, 5, 7, _c(165, 214, 167));
  }
  // Goo highlights
  _fillEllipse(image, 64, 78, 10, 6, _c(200, 230, 201, 180));
  _fillEllipse(image, 96, 88, 8, 5, _c(200, 230, 201, 140));
  // Angry eyes
  _drawAngryEyes(image, 80, 68, 14, 8);
  // Frown mouth
  _fillEllipse(image, 80, 84, 12, 6, _c(27, 94, 32));
  _fillEllipse(image, 80, 82, 10, 4, _c(129, 199, 132));
  // Stub arms
  _fillEllipse(image, 38, 88, 12, 18, _c(102, 187, 106));
  _fillEllipse(image, 122, 88, 12, 18, _c(102, 187, 106));
  // Feet blobs
  for (final pos in [(52, 128), (80, 132), (108, 128)]) {
    _fillEllipse(image, pos.$1, pos.$2, 14, 8, _c(67, 160, 71));
  }
  return image;
}

img.Image _drawEggGolem() {
  final image = _canvas();
  // Rocky legs
  _fillRect(image, 52, 118, 22, 28, _c(69, 90, 100));
  _fillRect(image, 86, 118, 22, 28, _c(69, 90, 100));
  _fillRect(image, 48, 140, 28, 8, _c(55, 71, 79));
  _fillRect(image, 84, 140, 28, 8, _c(55, 71, 79));
  // Main egg-rock body
  _fillEllipse(image, 80, 88, 50, 56, _c(96, 125, 139));
  _strokeEllipse(image, 80, 88, 50, 56, 5, _c(55, 71, 79));
  _fillEllipse(image, 80, 82, 38, 42, _c(144, 164, 174));
  // Rocky shoulder plates
  _fillRect(image, 34, 68, 18, 22, _c(84, 110, 122));
  _fillRect(image, 108, 68, 18, 22, _c(84, 110, 122));
  _fillRect(image, 30, 84, 14, 16, _c(69, 90, 100));
  _fillRect(image, 116, 84, 14, 16, _c(69, 90, 100));
  // Glowing cracks
  for (final seg in [(68, 58, 76, 72), (88, 54, 96, 70), (74, 78, 82, 92)]) {
    _fillRect(image, seg.$1, seg.$2, 3, seg.$4 - seg.$2 + 4, _c(255, 213, 79));
    _fillRect(image, seg.$3, seg.$2, 2, seg.$4 - seg.$2 + 2, _c(255, 193, 7));
  }
  // Face plate
  _fillEllipse(image, 80, 72, 28, 24, _c(176, 190, 197));
  _drawAngryEyes(image, 80, 68, 14, 7);
  _fillRect(image, 72, 82, 16, 4, _c(69, 90, 100));
  // Forehead rune
  _fillCircle(image, 80, 52, 6, _c(255, 224, 130));
  _fillCircle(image, 80, 52, 3, _c(255, 193, 7));
  return image;
}

img.Image _drawShadowRooster() {
  final image = _canvas();
  // Tail feathers
  for (var i = 0; i < 5; i++) {
    final fx = 108 + i * 6;
    _fillRect(image, fx, 48 + i * 4, 8, 36 - i * 4, _c(30, 30, 38));
    _fillRect(image, fx + 2, 50 + i * 4, 4, 28 - i * 4, _c(45, 45, 55));
  }
  // Body
  _fillEllipse(image, 78, 98, 42, 40, _c(45, 45, 52));
  _strokeEllipse(image, 78, 98, 42, 40, 3, _c(20, 20, 28));
  // Chest
  _fillEllipse(image, 78, 102, 22, 24, _c(66, 66, 74));
  // Head
  _fillEllipse(image, 72, 52, 28, 24, _c(55, 55, 62));
  _strokeEllipse(image, 72, 52, 28, 24, 2, _c(25, 25, 32));
  // Comb
  for (final pos in [(62, 36), (72, 32), (82, 36)]) {
    _fillEllipse(image, pos.$1, pos.$2, 6, 8, _c(183, 28, 28));
  }
  // Beak
  _drawTriangle(image, 88, 54, 108, 58, 88, 62, _c(255, 193, 7));
  _drawTriangle(image, 88, 58, 104, 62, 88, 66, _c(255, 160, 0));
  // Wing
  _fillEllipse(image, 58, 92, 16, 28, _c(35, 35, 42));
  _fillRect(image, 52, 88, 6, 20, _c(25, 25, 32));
  // Glowing red eye
  _drawGlowEye(image, 64, 50, _c(244, 67, 54));
  _fillCircle(image, 78, 52, 4, _c(20, 20, 28));
  // Claws
  for (final pos in [(62, 132), (78, 136), (94, 132)]) {
    _fillRect(image, pos.$1, pos.$2, 4, 10, _c(255, 160, 0));
    _fillRect(image, pos.$1 - 2, pos.$2 + 8, 3, 4, _c(255, 193, 7));
    _fillRect(image, pos.$1 + 3, pos.$2 + 8, 3, 4, _c(255, 193, 7));
  }
  return image;
}

img.Image _drawSlimeKing() {
  final image = _canvas();
  // Royal cape
  _fillTriangle(image, 80, 56, 36, 130, 124, 130, _c(106, 27, 154, 220));
  _fillTriangle(image, 80, 64, 44, 128, 116, 128, _c(142, 36, 170, 200));
  // Throne-like puddle
  _fillEllipse(image, 80, 124, 66, 16, _c(46, 125, 50));
  // King body — larger than slime boss
  _fillEllipse(image, 80, 92, 54, 44, _c(56, 142, 60));
  _strokeEllipse(image, 80, 92, 54, 44, 4, _c(27, 94, 32));
  _fillEllipse(image, 80, 78, 42, 34, _c(102, 187, 106));
  _fillEllipse(image, 80, 64, 32, 26, _c(129, 199, 132));
  // Gold crown
  _fillRect(image, 58, 38, 44, 10, _c(255, 193, 7));
  _fillRect(image, 54, 30, 8, 14, _c(255, 215, 64));
  _fillRect(image, 68, 26, 8, 18, _c(255, 215, 64));
  _fillRect(image, 84, 26, 8, 18, _c(255, 215, 64));
  _fillRect(image, 98, 30, 8, 14, _c(255, 215, 64));
  for (final x in [58, 72, 86, 100]) {
    _fillCircle(image, x, 34, 3, _c(255, 87, 34));
  }
  // Regal eyes
  _drawAngryEyes(
    image,
    80,
    62,
    12,
    7,
    sclera: _c(255, 249, 196),
    pupil: _c(46, 125, 50),
  );
  // Mustache drip
  _fillEllipse(image, 68, 76, 8, 5, _c(76, 175, 80));
  _fillEllipse(image, 92, 76, 8, 5, _c(76, 175, 80));
  // Scepter
  _fillRect(image, 118, 72, 4, 48, _c(141, 110, 99));
  _fillCircle(image, 120, 68, 8, _c(255, 193, 7));
  _fillCircle(image, 120, 68, 4, _c(255, 87, 34));
  // Royal arms
  _fillEllipse(image, 40, 86, 14, 20, _c(102, 187, 106));
  _fillEllipse(image, 120, 86, 14, 20, _c(102, 187, 106));
  return image;
}

void _fillTriangle(
  img.Image image,
  int x1,
  int y1,
  int x2,
  int y2,
  int x3,
  int y3,
  img.ColorRgba8 color,
) {
  _drawTriangle(image, x1, y1, x2, y2, x3, y3, color);
}

img.Image _drawEggGuardian() {
  final image = _canvas();
  // Shield behind
  _fillEllipse(image, 80, 88, 56, 64, _c(255, 193, 7, 120));
  _strokeEllipse(image, 80, 88, 56, 64, 4, _c(255, 160, 0));
  // Armored legs
  _fillRect(image, 54, 118, 20, 26, _c(69, 90, 100));
  _fillRect(image, 86, 118, 20, 26, _c(69, 90, 100));
  // Main sentinel egg body
  _fillEllipse(image, 80, 86, 48, 54, _c(84, 110, 122));
  _strokeEllipse(image, 80, 86, 48, 54, 5, _c(55, 71, 79));
  _fillEllipse(image, 80, 80, 36, 40, _c(144, 164, 174));
  // Gold trim bands
  _fillRect(image, 44, 72, 72, 6, _c(255, 193, 7));
  _fillRect(image, 48, 98, 64, 5, _c(255, 193, 7));
  // Helmet visor
  _fillRect(image, 52, 52, 56, 18, _c(96, 125, 139));
  _fillRect(image, 48, 48, 64, 8, _c(69, 90, 100));
  _fillRect(image, 56, 58, 48, 6, _c(255, 213, 79, 180));
  // Ancient glowing eye slit
  _fillRect(image, 62, 60, 36, 4, _c(255, 213, 79));
  _fillRect(image, 70, 59, 8, 6, _c(255, 87, 34));
  _fillRect(image, 82, 59, 8, 6, _c(255, 87, 34));
  // Shoulder pauldrons
  _fillEllipse(image, 38, 78, 16, 14, _c(255, 193, 7));
  _fillEllipse(image, 122, 78, 16, 14, _c(255, 193, 7));
  _fillEllipse(image, 38, 78, 10, 8, _c(255, 215, 64));
  _fillEllipse(image, 122, 78, 10, 8, _c(255, 215, 64));
  // Shield emblem on chest
  _fillEllipse(image, 80, 88, 14, 16, _c(255, 193, 7));
  _fillEllipse(image, 80, 88, 8, 10, _c(255, 87, 34));
  // Wing-like armor plates
  _fillRect(image, 28, 82, 10, 28, _c(69, 90, 100));
  _fillRect(image, 122, 82, 10, 28, _c(69, 90, 100));
  return image;
}

img.Image _drawShadowPhoenix() {
  final image = _canvas();
  // Dark blue glow aura
  _fillEllipse(image, 80, 80, 70, 68, _c(13, 71, 161, 60));
  _fillEllipse(image, 80, 80, 58, 56, _c(21, 101, 192, 40));
  // Blue flame wings
  for (var i = 0; i < 6; i++) {
    final wingY = 56 + i * 6;
    _fillEllipse(image, 42 - i * 2, wingY, 18 - i, 22, _c(25, 118, 210, 200 - i * 20));
    _fillEllipse(image, 118 + i * 2, wingY, 18 - i, 22, _c(25, 118, 210, 200 - i * 20));
    _fillEllipse(image, 38 - i * 2, wingY + 4, 10 - i, 14, _c(100, 181, 246, 180 - i * 20));
    _fillEllipse(image, 122 + i * 2, wingY + 4, 10 - i, 14, _c(100, 181, 246, 180 - i * 20));
  }
  // Body — dark phoenix
  _fillEllipse(image, 80, 96, 28, 36, _c(20, 20, 30));
  _strokeEllipse(image, 80, 96, 28, 36, 3, _c(13, 13, 20));
  // Head
  _fillEllipse(image, 80, 58, 22, 20, _c(30, 30, 42));
  // Crest feathers
  for (final pos in [(68, 38), (80, 32), (92, 38)]) {
    _fillEllipse(image, pos.$1, pos.$2, 5, 12, _c(25, 118, 210));
    _fillEllipse(image, pos.$1, pos.$2 - 4, 3, 8, _c(100, 181, 246));
  }
  // Glowing blue eyes
  _drawGlowEye(image, 72, 56, _c(100, 181, 246));
  _drawGlowEye(image, 88, 56, _c(100, 181, 246));
  // Beak
  _drawTriangle(image, 80, 62, 92, 66, 80, 70, _c(21, 101, 192));
  // Tail flames
  for (var i = 0; i < 4; i++) {
    _fillEllipse(image, 72 + i * 6, 128 - i * 4, 8, 16 + i * 4, _c(25, 118, 210, 220 - i * 30));
    _fillEllipse(image, 74 + i * 6, 130 - i * 4, 4, 10 + i * 2, _c(144, 202, 249, 200 - i * 30));
  }
  // Blue flame chest glow
  _fillEllipse(image, 80, 92, 14, 18, _c(21, 101, 192, 120));
  _fillEllipse(image, 80, 90, 8, 10, _c(100, 181, 246, 180));
  // Talons
  for (final pos in [(68, 124), (80, 128), (92, 124)]) {
    _fillRect(image, pos.$1, pos.$2, 3, 8, _c(21, 101, 192));
    _fillRect(image, pos.$1 - 2, pos.$2 + 6, 2, 4, _c(100, 181, 246));
    _fillRect(image, pos.$1 + 3, pos.$2 + 6, 2, 4, _c(100, 181, 246));
  }
  return image;
}
