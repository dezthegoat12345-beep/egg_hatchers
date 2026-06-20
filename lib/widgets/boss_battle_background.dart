import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/boss_visual_config.dart';

/// Full-arena boss-specific battle background for manual battles.
class BossBattleBackground extends StatelessWidget {
  const BossBattleBackground({
    super.key,
    required this.bossId,
    this.showOverlay = true,
  });

  final String bossId;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    final type = BossVisualConfig.backgroundTypeForBossId(bossId);
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _BossBattleBackgroundPainter(type: type),
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

class _BossBattleBackgroundPainter extends CustomPainter {
  _BossBattleBackgroundPainter({required this.type});

  final BossBattleBackgroundType type;

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
      case BossBattleBackgroundType.genericArena:
        _paintGenericArena(canvas, size);
    }
  }

  void _paintSlimeSwamp(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B5E20), Color(0xFF33691E), Color(0xFF2E4F1C)],
        ).createShader(rect),
    );

    final puddle = Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.45);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.28, size.height * 0.72),
        width: size.width * 0.42,
        height: 28,
      ),
      puddle,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.82),
        width: size.width * 0.35,
        height: 22,
      ),
      puddle,
    );

    final bubble = Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.35);
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.12 + i * 0.11);
      final y = size.height * (0.18 + (i % 3) * 0.12);
      canvas.drawCircle(Offset(x, y), 4 + (i % 3) * 2.0, bubble);
    }
  }

  void _paintEggCave(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4E342E), Color(0xFF3E2723), Color(0xFF2C1810)],
        ).createShader(rect),
    );

    final stone = Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.55);
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.08 + i * 0.16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * 0.55, 28, 36 + (i % 2) * 8.0),
          const Radius.circular(6),
        ),
        stone,
      );
    }

    final crack = Paint()
      ..color = const Color(0xFFD7CCC8).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..lineTo(size.width * 0.35, size.height * 0.45)
      ..lineTo(size.width * 0.28, size.height * 0.62);
    canvas.drawPath(path, crack);

    final eggGlow = Paint()..color = const Color(0xFFFFF8E1).withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.68),
        width: 34,
        height: 42,
      ),
      eggGlow,
    );
  }

  void _paintShadowRoost(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF311B92), Color(0xFF1A1A2E)],
        ).createShader(rect),
    );

    final moon = Paint()..color = const Color(0xFFE8EAF6).withValues(alpha: 0.75);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.14), 18, moon);

    final fence = Paint()..color = const Color(0xFF0D0D1A).withValues(alpha: 0.65);
    for (var i = 0; i < 7; i++) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * (0.08 + i * 0.13), size.height * 0.78, 8, 28),
        fence,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.78, size.width * 0.88, 4),
      fence,
    );

    final feather = Paint()..color = const Color(0xFF4527A0).withValues(alpha: 0.35);
    for (var i = 0; i < 5; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.15 + i * 0.17), size.height * (0.35 + (i % 2) * 0.08)),
          width: 16,
          height: 8,
        ),
        feather,
      );
    }
  }

  void _paintRoyalPalace(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B5E20), Color(0xFF33691E), Color(0xFF1B4332)],
        ).createShader(rect),
    );

    final pillar = Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.7);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.22, 14, size.height * 0.58),
      pillar,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.84, size.height * 0.22, 14, size.height * 0.58),
      pillar,
    );

    final gold = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.55);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.18, size.width, 10),
      gold,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.28, size.width * 0.6, 8),
      gold,
    );

    final banner = Paint()..color = const Color(0xFF43A047).withValues(alpha: 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.42),
          width: 36,
          height: 48,
        ),
        const Radius.circular(4),
      ),
      banner,
    );

    final throne = Paint()..color = const Color(0xFF1B5E20).withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.72),
          width: 72,
          height: 40,
        ),
        const Radius.circular(8),
      ),
      throne,
    );

    final sparkle = Paint()..color = const Color(0xFFFFEB3B).withValues(alpha: 0.45);
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.25 + i * 0.1);
      canvas.drawCircle(Offset(x, size.height * 0.32), 2.5, sparkle);
    }
  }

  void _paintGuardianNest(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF263238), Color(0xFF37474F), Color(0xFF1C313A)],
        ).createShader(rect),
    );

    final cave = Paint()..color = const Color(0xFF102027).withValues(alpha: 0.75);
    final cavePath = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.05,
        size.width,
        size.height * 0.35,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(cavePath, cave);

    final nest = Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.55);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.28 + i * 0.22), size.height * 0.68),
          width: 44,
          height: 22,
        ),
        nest,
      );
    }

    final glow = Paint()..color = const Color(0xFF42A5F5).withValues(alpha: 0.35);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.28 + i * 0.22), size.height * 0.64),
          width: 18,
          height: 22,
        ),
        glow,
      );
    }

    final gold = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.25);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 6, gold);
  }

  void _paintPhoenixLair(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF0A1628)],
        ).createShader(rect),
    );

    final ruin = Paint()..color = const Color(0xFF415A77).withValues(alpha: 0.45);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.62, 22, size.height * 0.28),
      ruin,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.78, size.height * 0.58, 18, size.height * 0.32),
      ruin,
    );

    final ember = Paint()..color = const Color(0xFF1565C0).withValues(alpha: 0.5);
    final random = math.Random(7);
    for (var i = 0; i < 14; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * (0.25 + random.nextDouble() * 0.55);
      canvas.drawCircle(Offset(x, y), 2 + random.nextDouble() * 3, ember);
    }

    final flame = Paint()..color = const Color(0xFF1E88E5).withValues(alpha: 0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.82),
        width: size.width * 0.7,
        height: 36,
      ),
      flame,
    );
  }

  void _paintGenericArena(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF37474F).withValues(alpha: 0.9),
            const Color(0xFF263238),
          ],
        ).createShader(rect),
    );

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _BossBattleBackgroundPainter oldDelegate) =>
      oldDelegate.type != type;
}
