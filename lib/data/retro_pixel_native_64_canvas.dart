import '../models/retro_pixel_sprite_definition.dart';
import 'retro_pixel_palette.dart';

/// Mutable 64×64 grid for native Retro Pixel authoring (not editor sprites).
class RetroPixelNative64Canvas {
  RetroPixelNative64Canvas();

  static const int gridSize = 64;

  static const _k = RetroPixelPalette.black;
  static const _w = RetroPixelPalette.offWhite;

  final List<int?> _pixels = List<int?>.filled(gridSize * gridSize, null);

  void set(int x, int y, int? color) {
    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) return;
    _pixels[y * gridSize + x] = color;
  }

  int? at(int x, int y) {
    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) return null;
    return _pixels[y * gridSize + x];
  }

  void fillRect(int x, int y, int w, int h, int color) {
    for (var py = y; py < y + h; py++) {
      for (var px = x; px < x + w; px++) {
        set(px, py, color);
      }
    }
  }

  void fillEllipse(int cx, int cy, int rx, int ry, int color) {
    for (var y = cy - ry; y <= cy + ry; y++) {
      for (var x = cx - rx; x <= cx + rx; x++) {
        final nx = (x - cx) / (rx + 0.5);
        final ny = (y - cy) / (ry + 0.5);
        if (nx * nx + ny * ny <= 1.0) set(x, y, color);
      }
    }
  }

  void outlineEllipse(int cx, int cy, int rx, int ry, int fill, int outline) {
    fillEllipse(cx, cy, rx, ry, fill);
    for (var y = cy - ry - 1; y <= cy + ry + 1; y++) {
      for (var x = cx - rx - 1; x <= cx + rx + 1; x++) {
        if (at(x, y) != null) continue;
        final nx = (x - cx) / (rx + 0.5);
        final ny = (y - cy) / (ry + 0.5);
        final d = nx * nx + ny * ny;
        if (d <= 1.35 && d >= 0.75) set(x, y, outline);
      }
    }
  }

  void rectOutline(int x, int y, int w, int h, int fill, int outline) {
    fillRect(x, y, w, h, fill);
    for (var px = x; px < x + w; px++) {
      set(px, y - 1, outline);
      set(px, y + h, outline);
    }
    for (var py = y; py < y + h; py++) {
      set(x - 1, py, outline);
      set(x + w, py, outline);
    }
  }

  /// 4×4 eye with white sclera and black pupil.
  void eye(int cx, int cy, {int sclera = _w}) {
    fillRect(cx - 1, cy - 1, 4, 4, _k);
    fillRect(cx, cy, 2, 2, sclera);
    set(cx + 1, cy + 1, _k);
  }

  /// Side-view eye (black ring + white + pupil).
  void sideEye(int x, int y) {
    fillRect(x, y, 3, 3, _k);
    set(x + 1, y + 1, _w);
    set(x + 2, y + 1, _k);
  }

  void paw(int x, int y, int color) {
    fillRect(x, y, 4, 3, _k);
    fillRect(x + 1, y + 1, 2, 2, color);
    set(x, y + 3, _k);
    set(x + 1, y + 3, _k);
    set(x + 3, y + 3, _k);
  }

  void hoof(int x, int y, int legColor) {
    fillRect(x, y, 3, 5, legColor);
    fillRect(x - 1, y + 5, 5, 2, _k);
    fillRect(x, y + 5, 3, 1, RetroPixelPalette.darkBrown);
  }

  void stampPattern(int ox, int oy, List<String> rows, Map<String, int> keys) {
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        final ch = row[x];
        if (ch == '.') continue;
        final color = keys[ch];
        if (color != null) set(ox + x, oy + y, color);
      }
    }
  }

  RetroPixelSpriteDefinition build({double displayScale = 1.0}) {
    return RetroPixelSpriteDefinition(
      width: gridSize,
      height: gridSize,
      pixels: List<int?>.from(_pixels),
      displayScale: displayScale,
    );
  }
}
