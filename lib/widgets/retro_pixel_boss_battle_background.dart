import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/boss_visual_config.dart';

/// Blocky pixel-art boss battle / cinematic background for Retro Pixel style.
class RetroPixelBossBattleBackground extends StatelessWidget {
  const RetroPixelBossBattleBackground({
    super.key,
    required this.bossId,
    this.showOverlay = true,
    this.topViewPhase = 0,
  });

  final String bossId;
  final bool showOverlay;

  /// 0 = side view; 1 = top-down (Shadow Phoenix cinematic only).
  final double topViewPhase;

  @override
  Widget build(BuildContext context) {
    final type = BossVisualConfig.backgroundTypeForBossId(bossId);
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _RetroPixelBossBattleBackgroundPainter(
            type: type,
            topViewPhase: topViewPhase,
          ),
        ),
        if (showOverlay)
          ColoredBox(
            color: Colors.black.withValues(alpha: _overlayAlpha(type)),
          ),
      ],
    );
  }

  static double _overlayAlpha(BossBattleBackgroundType type) {
    return switch (type) {
      BossBattleBackgroundType.royalPalace => 0.18,
      BossBattleBackgroundType.guardianNest => 0.22,
      BossBattleBackgroundType.phoenixLair => 0.12,
      BossBattleBackgroundType.slimeSwamp => 0.15,
      _ => 0.2,
    };
  }
}

class _RetroPixelBossBattleBackgroundPainter extends CustomPainter {
  _RetroPixelBossBattleBackgroundPainter({
    required this.type,
    this.topViewPhase = 0,
  });

  final BossBattleBackgroundType type;
  final double topViewPhase;

  static const _sky2 = Color(0xFF4A148C);
  static const _sky3 = Color(0xFF1B5E20);
  static const _ground1 = Color(0xFF33691E);
  static const _ground2 = Color(0xFF4E342E);
  static const _ground3 = Color(0xFF5D4037);
  static const _stone = Color(0xFF78909C);
  static const _stoneDark = Color(0xFF455A64);
  static const _glow = Color(0xFF64B5F6);
  static const _gold = Color(0xFFFFD54F);
  static const _slime = Color(0xFF66BB6A);
  static const _tree = Color(0xFF2E7D32);
  static const _trunk = Color(0xFF5D4037);
  static const _night = Color(0xFF1A237E);
  static const _sand = Color(0xFFD7CCC8);
  static const _cliff = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    final block = math.max(6.0, (size.width / 48).floorToDouble());
    switch (type) {
      case BossBattleBackgroundType.slimeSwamp:
        _paintSlimeSwamp(canvas, size, block);
      case BossBattleBackgroundType.eggCave:
        _paintEggCave(canvas, size, block);
      case BossBattleBackgroundType.shadowRoost:
        _paintShadowRoost(canvas, size, block);
      case BossBattleBackgroundType.royalPalace:
        _paintRoyalPalace(canvas, size, block);
      case BossBattleBackgroundType.guardianNest:
        _paintGuardianNest(canvas, size, block);
      case BossBattleBackgroundType.phoenixLair:
        _paintPhoenixLair(canvas, size, block, topViewPhase);
      case BossBattleBackgroundType.rottenNest:
        _paintRottenNest(canvas, size, block);
      case BossBattleBackgroundType.genericArena:
        _paintGenericArena(canvas, size, block);
    }
  }

  void _fillBand(
    Canvas canvas,
    Size size,
    double yStart,
    double yEnd,
    Color color,
  ) {
    canvas.drawRect(
      Rect.fromLTRB(0, size.height * yStart, size.width, size.height * yEnd),
      Paint()..color = color,
    );
  }

  void _block(
    Canvas canvas,
    Size size,
    double block,
    int gx,
    int gy,
    Color color, {
    int gw = 1,
    int gh = 1,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(gx * block, gy * block, gw * block, gh * block),
      Paint()..color = color,
    );
  }

  void _ditherGround(Canvas canvas, Size size, double block, Color base, Color alt) {
    final cols = (size.width / block).ceil();
    final rows = ((size.height * 0.35) / block).ceil();
    final startRow = ((size.height * 0.65) / block).floor();
    for (var row = startRow; row < startRow + rows; row++) {
      for (var col = 0; col < cols; col++) {
        _block(
          canvas,
          size,
          block,
          col,
          row,
          (col + row) % 2 == 0 ? base : alt,
        );
      }
    }
  }

  void _paintSlimeSwamp(Canvas canvas, Size size, double block) {
    _fillBand(canvas, size, 0, 0.55, _sky3);
    _fillBand(canvas, size, 0.55, 0.68, _ground1);
    _ditherGround(canvas, size, block, _ground1, const Color(0xFF2E5930));

    // Blocky trees
    for (final tree in [
      (0.08, 0.42, 3, 5),
      (0.22, 0.38, 4, 6),
      (0.78, 0.4, 3, 5),
      (0.9, 0.44, 3, 4),
    ]) {
      final tx = size.width * tree.$1;
      final ty = size.height * tree.$2;
      canvas.drawRect(
        Rect.fromLTWH(tx, ty, block * tree.$3, block * tree.$4),
        Paint()..color = _tree,
      );
      canvas.drawRect(
        Rect.fromLTWH(tx + block, ty + block * tree.$4, block, block * 3),
        Paint()..color = _trunk,
      );
    }

    // Goo puddles
    for (final puddle in [
      (0.2, 0.78, 6, 2),
      (0.55, 0.82, 5, 2),
      (0.75, 0.76, 4, 2),
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * puddle.$1,
          size.height * puddle.$2,
          block * puddle.$3,
          block * puddle.$4,
        ),
        Paint()..color = _slime,
      );
    }
  }

  void _paintEggCave(Canvas canvas, Size size, double block) {
    _fillBand(canvas, size, 0, 0.5, _stoneDark);
    _fillBand(canvas, size, 0.5, 0.68, _stone);
    _ditherGround(canvas, size, block, _ground2, _ground3);

    // Cave walls
    for (var i = 0; i < 8; i++) {
      _block(canvas, size, block, 0, 4 + i, _stoneDark, gh: 2);
      _block(canvas, size, block, (size.width / block).floor() - 1, 3 + i, _stoneDark, gh: 2);
    }

    // Cracked rocks & glow
    for (final crack in [
      (0.3, 0.55, 4, 3),
      (0.6, 0.48, 3, 4),
      (0.45, 0.72, 5, 2),
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * crack.$1,
          size.height * crack.$2,
          block * crack.$3,
          block * crack.$4,
        ),
        Paint()..color = _ground3,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.48, size.height * 0.52, block * 2, block * 4),
      Paint()..color = _glow,
    );
  }

  void _paintShadowRoost(Canvas canvas, Size size, double block) {
    _fillBand(canvas, size, 0, 0.45, _night);
    _fillBand(canvas, size, 0.45, 0.55, _sky2);
    _fillBand(canvas, size, 0.55, 0.7, _ground2);
    _ditherGround(canvas, size, block, const Color(0xFF3E2723), _ground2);

    // Moon
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.72, size.height * 0.08, block * 4, block * 4),
      Paint()..color = const Color(0xFFFFF59D),
    );

    // Barn silhouette
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.42, block * 8, block * 6),
      Paint()..color = const Color(0xFF4A148C),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.16, size.height * 0.38, block * 6, block * 2),
      Paint()..color = const Color(0xFF311B92),
    );

    // Fence
    for (var i = 0; i < 10; i++) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.05 + i * block * 1.2, size.height * 0.68, block, block * 3),
        Paint()..color = _trunk,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.04, size.height * 0.7, size.width * 0.55, block),
      Paint()..color = _trunk,
    );
  }

  void _paintRoyalPalace(Canvas canvas, Size size, double block) {
    _fillBand(canvas, size, 0, 0.5, const Color(0xFF1B5E20));
    _fillBand(canvas, size, 0.5, 0.65, const Color(0xFF33691E));
    _ditherGround(canvas, size, block, const Color(0xFF2E5930), _ground1);

    // Pillars
    for (final pillar in [0.15, 0.35, 0.65, 0.85]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * pillar, size.height * 0.35, block * 2, block * 8),
        Paint()..color = _stone,
      );
      canvas.drawRect(
        Rect.fromLTWH(size.width * pillar - block * 0.5, size.height * 0.33, block * 3, block),
        Paint()..color = _gold,
      );
    }

    // Throne platform
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.72, size.width * 0.44, block * 2),
      Paint()..color = _gold,
    );

    // Banners
    for (final banner in [0.22, 0.78]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * banner, size.height * 0.28, block * 2, block * 5),
        Paint()..color = const Color(0xFF8E24AA),
      );
      canvas.drawRect(
        Rect.fromLTWH(size.width * banner + block * 0.5, size.height * 0.3, block, block * 3),
        Paint()..color = _gold,
      );
    }
  }

  void _paintGuardianNest(Canvas canvas, Size size, double block) {
    _fillBand(canvas, size, 0, 0.48, _stoneDark);
    _fillBand(canvas, size, 0.48, 0.62, _stone);
    _ditherGround(canvas, size, block, _ground3, _stoneDark);

    // Circular nest platform
    final center = Offset(size.width * 0.5, size.height * 0.78);
    for (var ring = 0; ring < 6; ring++) {
      final r = block * (4 + ring);
      canvas.drawRect(
        Rect.fromCenter(center: center, width: r * 2, height: block * 2),
        Paint()..color = ring.isEven ? _gold : _ground3,
      );
    }

    // Glowing egg nests
    for (final nest in [
      (0.25, 0.58),
      (0.5, 0.52),
      (0.72, 0.6),
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * nest.$1,
          size.height * nest.$2,
          block * 3,
          block * 4,
        ),
        Paint()..color = _glow,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * nest.$1 + block * 0.5,
          size.height * nest.$2 + block * 0.5,
          block * 2,
          block * 2,
        ),
        Paint()..color = const Color(0xFFFFF9C4),
      );
    }

    // Rune stones
    for (final rune in [0.12, 0.88]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * rune, size.height * 0.65, block * 2, block * 4),
        Paint()..color = _stone,
      );
      canvas.drawRect(
        Rect.fromLTWH(size.width * rune + block * 0.5, size.height * 0.68, block, block * 2),
        Paint()..color = _glow,
      );
    }
  }

  void _paintPhoenixLair(
    Canvas canvas,
    Size size,
    double block,
    double topView,
  ) {
    final tv = topView.clamp(0.0, 1.0);
    final skyTop = Color.lerp(const Color(0xFF1A1033), const Color(0xFF2D1B4E), tv)!;
    final skyMid = Color.lerp(const Color(0xFF4A2C6A), const Color(0xFF6D4C41), tv * 0.35)!;
    _fillBand(canvas, size, 0, 0.35, skyTop);
    _fillBand(canvas, size, 0.35, 0.55, skyMid);
    _fillBand(canvas, size, 0.55, 0.72, _cliff);
    _ditherGround(canvas, size, block, _sand, const Color(0xFFBCAAA4));

    // Canyon cliffs
    final cliffH = size.height * (0.35 + tv * 0.15);
    canvas.drawRect(
      Rect.fromLTWH(0, cliffH, size.width * (0.22 + tv * 0.05), size.height - cliffH),
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * (0.78 - tv * 0.05), cliffH, size.width * 0.22, size.height - cliffH),
      Paint()..color = const Color(0xFF5D4037),
    );

    // Blocky strata lines
    for (var i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          cliffH + i * block * 2,
          size.width * 0.2,
          block,
        ),
        Paint()..color = const Color(0xFF8D6E63),
      );
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.8,
          cliffH + i * block * 2.2,
          size.width * 0.2,
          block,
        ),
        Paint()..color = const Color(0xFF795548),
      );
    }

    // Impact area on floor when top-view increases
    if (tv > 0.2) {
      final impactSize = block * (4 + tv * 4);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * (0.82 - tv * 0.05)),
          width: impactSize,
          height: block * 2,
        ),
        Paint()..color = const Color(0xFF4E342E),
      );
    }
  }

  void _paintRottenNest(Canvas canvas, Size size, double block) {
    _fillBand(canvas, size, 0, 0.45, const Color(0xFF1A1028));
    _fillBand(canvas, size, 0.45, 0.62, const Color(0xFF311B92));
    _ditherGround(canvas, size, block, const Color(0xFF33691E), const Color(0xFF4A148C));

    // Cracked shell floor tiles
    for (final tile in [
      (0.12, 0.72, 4, 2),
      (0.35, 0.78, 5, 2),
      (0.58, 0.74, 4, 2),
      (0.78, 0.8, 3, 2),
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * tile.$1,
          size.height * tile.$2,
          block * tile.$3,
          block * tile.$4,
        ),
        Paint()..color = const Color(0xFF8D6E63),
      );
    }

    // Toxic fog bands
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          size.height * (0.5 + i * 0.06),
          size.width,
          block * 1.5,
        ),
        Paint()
          ..color = Color.lerp(
            const Color(0xFF66BB6A),
            const Color(0xFF8E24AA),
            i / 3,
          )!
          .withValues(alpha: 0.35),
      );
    }
  }

  void _paintGenericArena(Canvas canvas, Size size, double block) {
    _fillBand(canvas, size, 0, 0.55, const Color(0xFF37474F));
    _fillBand(canvas, size, 0.55, 0.7, _stone);
    _ditherGround(canvas, size, block, _stoneDark, _stone);
  }

  @override
  bool shouldRepaint(covariant _RetroPixelBossBattleBackgroundPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.topViewPhase != topViewPhase;
  }
}
