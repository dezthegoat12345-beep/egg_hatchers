import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/realistic_boss_background_assets.dart';
import '../utils/boss_visual_config.dart';

/// Richer shaded arena backdrop for the Realistic animal style.
class RealisticBossBattleBackground extends StatelessWidget {
  const RealisticBossBattleBackground({
    super.key,
    required this.bossId,
    this.showOverlay = true,
    this.topViewPhase = 0,
  });

  final String bossId;
  final bool showOverlay;
  final double topViewPhase;

  @override
  Widget build(BuildContext context) {
    final type = BossVisualConfig.backgroundTypeForBossId(bossId);
    final fallback = CustomPaint(
      painter: _RealisticBossBattleBackgroundPainter(
        type: type,
        topViewPhase: topViewPhase,
      ),
    );
    final assetPath = RealisticBossBackgroundAssets.assetPathForBossId(bossId);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (assetPath == null)
          fallback
        else
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, _, _) => fallback,
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
      BossBattleBackgroundType.slimeSwamp => 0.08,
      BossBattleBackgroundType.eggCave => 0.16,
      BossBattleBackgroundType.shadowRoost => 0.12,
      BossBattleBackgroundType.royalPalace => 0.13,
      BossBattleBackgroundType.guardianNest => 0.17,
      BossBattleBackgroundType.phoenixLair => 0.1,
      BossBattleBackgroundType.rottenNest => 0.12,
      BossBattleBackgroundType.genericArena => 0.18,
    };
  }
}

class _RealisticBossBattleBackgroundPainter extends CustomPainter {
  _RealisticBossBattleBackgroundPainter({
    required this.type,
    required this.topViewPhase,
  });

  final BossBattleBackgroundType type;
  final double topViewPhase;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case BossBattleBackgroundType.slimeSwamp:
        _paintSlimeSwamp(canvas, size);
      case BossBattleBackgroundType.eggCave:
        _paintEggCave(canvas, size);
      case BossBattleBackgroundType.shadowRoost:
        _paintShadowRoost(canvas, size);
      case BossBattleBackgroundType.royalPalace:
        _paintRoyalPalace(canvas, size);
      case BossBattleBackgroundType.guardianNest:
        _paintGuardianNest(canvas, size);
      case BossBattleBackgroundType.phoenixLair:
        _paintPhoenixLair(canvas, size);
      case BossBattleBackgroundType.rottenNest:
        _paintRottenNest(canvas, size);
      case BossBattleBackgroundType.genericArena:
        _paintGenericArena(canvas, size);
    }
  }

  void _paintSlimeSwamp(Canvas canvas, Size size) {
    _paintGradient(canvas, size, const [
      Color(0xFF183D21),
      Color(0xFF295C2A),
      Color(0xFF17351D),
    ]);
    _paintHaze(canvas, size, const Color(0xFF7DFF6B), 0.22);
    _drawOrganicGround(canvas, size, const Color(0xFF163C22));
    final slime = Paint()
      ..color = const Color(0xFF74E36B).withValues(alpha: 0.38);
    for (final spec in const [(0.26, 0.72, 0.42), (0.7, 0.8, 0.32)]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * spec.$1, size.height * spec.$2),
          width: size.width * spec.$3,
          height: size.height * 0.1,
        ),
        slime,
      );
    }
    _paintSpeckles(canvas, size, const Color(0xFFC7FFBA), 18, seed: 1);
  }

  void _paintEggCave(Canvas canvas, Size size) {
    _paintGradient(canvas, size, const [
      Color(0xFF18212A),
      Color(0xFF4E3A2E),
      Color(0xFF1C1110),
    ]);
    _drawCavernArch(canvas, size, const Color(0xFF6D5845));
    _drawOrganicGround(canvas, size, const Color(0xFF3A251B));
    final glow = Paint()
      ..color = const Color(0xFFFFF1A8).withValues(alpha: 0.17);
    for (var i = 0; i < 4; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.18 + i * 0.2), size.height * 0.67),
          width: 24,
          height: 34,
        ),
        glow,
      );
    }
  }

  void _paintShadowRoost(Canvas canvas, Size size) {
    _paintGradient(canvas, size, const [
      Color(0xFF081323),
      Color(0xFF18245A),
      Color(0xFF160D2D),
    ]);
    _paintMoon(canvas, size, Offset(size.width * 0.82, size.height * 0.16));
    _paintSpeckles(canvas, size, Colors.white, 34, seed: 4, topOnly: true);
    final fence = Paint()..color = Colors.black.withValues(alpha: 0.52);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.78, size.width, 5), fence);
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.05 + i * 0.13);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * 0.7, 9, size.height * 0.2),
          const Radius.circular(4),
        ),
        fence,
      );
    }
  }

  void _paintRoyalPalace(Canvas canvas, Size size) {
    _paintGradient(canvas, size, const [
      Color(0xFF0C2515),
      Color(0xFF1D5B31),
      Color(0xFF0A1F13),
    ]);
    final gold = Paint()
      ..color = const Color(0xFFFFD46A).withValues(alpha: 0.5);
    for (final x in [0.12, 0.84]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * x,
            size.height * 0.18,
            18,
            size.height * 0.66,
          ),
          const Radius.circular(9),
        ),
        gold,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.76),
        width: size.width * 0.62,
        height: size.height * 0.2,
      ),
      Paint()..color = const Color(0xFF08391E).withValues(alpha: 0.78),
    );
    _paintSpeckles(canvas, size, const Color(0xFFFFF0A0), 18, seed: 7);
  }

  void _paintGuardianNest(Canvas canvas, Size size) {
    _paintGradient(canvas, size, const [
      Color(0xFF04111D),
      Color(0xFF183352),
      Color(0xFF1B1728),
    ]);
    _drawCavernArch(canvas, size, const Color(0xFF203C54));
    _paintHaze(canvas, size, const Color(0xFF6EDBFF), 0.16);
    final nest = Paint()
      ..color = const Color(0xFF8C6D42).withValues(alpha: 0.48);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.72),
        width: size.width * 0.7,
        height: size.height * 0.18,
      ),
      nest,
    );
  }

  void _paintPhoenixLair(Canvas canvas, Size size) {
    final tv = topViewPhase.clamp(0.0, 1.0);
    _paintGradient(canvas, size, [
      Color.lerp(const Color(0xFF0A1328), const Color(0xFF1C1738), tv)!,
      Color.lerp(const Color(0xFF202D55), const Color(0xFF53366E), tv)!,
      Color.lerp(const Color(0xFF0A1220), const Color(0xFF160A20), tv)!,
    ]);
    _paintHaze(canvas, size, const Color(0xFF5AA8FF), 0.18);
    _drawOrganicGround(canvas, size, const Color(0xFF122341));
    final random = math.Random(11);
    final ember = Paint()
      ..color = const Color(0xFF6AB7FF).withValues(alpha: 0.42);
    for (var i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(
          size.width * random.nextDouble(),
          size.height * (0.2 + random.nextDouble() * 0.6),
        ),
        1.5 + random.nextDouble() * 3,
        ember,
      );
    }
  }

  void _paintRottenNest(Canvas canvas, Size size) {
    _paintGradient(canvas, size, const [
      Color(0xFF080D0D),
      Color(0xFF23112C),
      Color(0xFF2B3E16),
      Color(0xFF090D08),
    ]);
    _paintHaze(canvas, size, const Color(0xFFB6FF39), 0.22);
    _paintHaze(canvas, size, const Color(0xFF8A3FDB), 0.12);
    _drawOrganicGround(canvas, size, const Color(0xFF1D1A0E));
    final shell = Paint()
      ..color = const Color(0xFFCABF8C).withValues(alpha: 0.36);
    for (var i = 0; i < 7; i++) {
      final x = size.width * (0.08 + i * 0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * 0.76, 28, 13 + (i % 2) * 8),
          const Radius.circular(4),
        ),
        shell,
      );
    }
    _paintSpeckles(canvas, size, const Color(0xFFCBFF4D), 20, seed: 13);
  }

  void _paintGenericArena(Canvas canvas, Size size) {
    _paintGradient(canvas, size, const [
      Color(0xFF24313A),
      Color(0xFF18252D),
      Color(0xFF0D161C),
    ]);
    _drawOrganicGround(canvas, size, const Color(0xFF1A252C));
  }

  void _paintGradient(Canvas canvas, Size size, List<Color> colors) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.28),
          radius: 1.0,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.22),
          ],
          stops: const [0.0, 0.58, 1.0],
        ).createShader(rect),
    );
  }

  void _paintHaze(Canvas canvas, Size size, Color color, double alpha) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.68),
        width: size.width * 1.05,
        height: size.height * 0.42,
      ),
      Paint()..color = color.withValues(alpha: alpha),
    );
  }

  void _paintMoon(Canvas canvas, Size size, Offset center) {
    canvas.drawCircle(
      center,
      size.shortestSide * 0.08,
      Paint()
        ..shader =
            RadialGradient(
              colors: const [Color(0xFFFFFFFF), Color(0xFFB7C8FF)],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.shortestSide * 0.08),
            ),
    );
  }

  void _paintSpeckles(
    Canvas canvas,
    Size size,
    Color color,
    int count, {
    required int seed,
    bool topOnly = false,
  }) {
    final random = math.Random(seed);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      paint.color = color.withValues(alpha: 0.18 + random.nextDouble() * 0.38);
      canvas.drawCircle(
        Offset(
          size.width * random.nextDouble(),
          size.height * random.nextDouble() * (topOnly ? 0.48 : 0.86),
        ),
        0.8 + random.nextDouble() * 2.2,
        paint,
      );
    }
  }

  void _drawCavernArch(Canvas canvas, Size size, Color color) {
    final path = Path()
      ..moveTo(0, size.height * 0.36)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.03,
        size.width,
        size.height * 0.34,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.46));
  }

  void _drawOrganicGround(Canvas canvas, Size size, Color color) {
    final path = Path()
      ..moveTo(0, size.height * 0.76)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.62,
        size.height * 0.86,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.75));
  }

  @override
  bool shouldRepaint(
    covariant _RealisticBossBattleBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.type != type || oldDelegate.topViewPhase != topViewPhase;
  }
}
