import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/animal_sprite_theme.dart';
import 'animal_sprite_theme_scope.dart';
import 'realistic_boss_battle_background.dart';
import 'retro_pixel_boss_battle_background.dart';

/// Forest clearing backdrop for the Slime Boss defeat cinematic only.
class SlimeBossForestBackground extends StatelessWidget {
  const SlimeBossForestBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final animalTheme = AnimalSpriteThemeScope.of(context);
    if (animalTheme.id == AnimalSpriteThemes.retroPixel.id) {
      return const RetroPixelBossBattleBackground(
        bossId: 'slime_boss',
        showOverlay: false,
      );
    }
    if (animalTheme.id == AnimalSpriteThemes.realistic.id) {
      return const RealisticBossBattleBackground(
        bossId: 'slime_boss',
        showOverlay: false,
      );
    }

    return const CustomPaint(painter: _SlimeBossForestPainter());
  }
}

class _SlimeBossForestPainter extends CustomPainter {
  const _SlimeBossForestPainter();

  static const _treeSpecs = <_TreeSpec>[
    _TreeSpec(0.08, 0.52, 0.72, 0.38, 0xFF1B3A1A, 0xFF2E5930, back: true),
    _TreeSpec(0.22, 0.48, 0.82, 0.42, 0xFF234526, 0xFF3D6B3F, back: true),
    _TreeSpec(0.78, 0.5, 0.76, 0.4, 0xFF1B3A1A, 0xFF2E5930, back: true),
    _TreeSpec(0.92, 0.54, 0.7, 0.36, 0xFF234526, 0xFF3D6B3F, back: true),
    _TreeSpec(0.14, 0.62, 0.95, 0.52, 0xFF3E2723, 0xFF4CAF50, back: false),
    _TreeSpec(0.32, 0.58, 1.0, 0.48, 0xFF4E342E, 0xFF66BB6A, back: false),
    _TreeSpec(0.68, 0.58, 1.02, 0.5, 0xFF3E2723, 0xFF57A85A, back: false),
    _TreeSpec(0.86, 0.63, 0.92, 0.46, 0xFF4E342E, 0xFF4CAF50, back: false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    _paintFarHills(canvas, size);
    for (final tree in _treeSpecs.where((t) => t.back)) {
      _paintTree(canvas, size, tree);
    }
    for (final tree in _treeSpecs.where((t) => !t.back)) {
      _paintTree(canvas, size, tree);
    }
    _paintGrassClearing(canvas, size);
    _paintForestFloor(canvas, size);
    _paintAccentDetails(canvas, size);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFFB2DFDB),
            Color(0xFFC8E6C9),
            Color(0xFF81C784),
          ],
          stops: [0.0, 0.35, 0.62, 1.0],
        ).createShader(rect),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.12),
        width: 56,
        height: 56,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _paintFarHills(Canvas canvas, Size size) {
    final hill = Paint()
      ..color = const Color(0xFF558B2F).withValues(alpha: 0.35);
    final path = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.28,
        size.width * 0.5,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.3,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(0, size.height * 0.52)
      ..close();
    canvas.drawPath(path, hill);
  }

  void _paintTree(Canvas canvas, Size size, _TreeSpec tree) {
    final baseX = size.width * tree.x;
    final baseY = size.height * tree.baseY;
    final trunkW = size.width * 0.045 * tree.scale;
    final trunkH = size.height * tree.trunkHeight;

    final trunkPaint = Paint()..color = Color(tree.trunkColor);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(baseX, baseY - trunkH * 0.45),
          width: trunkW,
          height: trunkH,
        ),
        Radius.circular(trunkW * 0.25),
      ),
      trunkPaint,
    );

    final canopyPaint = Paint()
      ..color = Color(
        tree.canopyColor,
      ).withValues(alpha: tree.back ? 0.72 : 0.92);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX, baseY - trunkH * 0.82),
        width: size.width * 0.16 * tree.scale,
        height: size.height * 0.14 * tree.scale,
      ),
      canopyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX - trunkW * 0.6, baseY - trunkH * 0.72),
        width: size.width * 0.11 * tree.scale,
        height: size.height * 0.1 * tree.scale,
      ),
      canopyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX + trunkW * 0.55, baseY - trunkH * 0.74),
        width: size.width * 0.12 * tree.scale,
        height: size.height * 0.1 * tree.scale,
      ),
      canopyPaint,
    );
  }

  void _paintGrassClearing(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.56);
    final patchW = size.width * 0.58;
    final patchH = size.height * 0.2;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: patchW + 18, height: patchH + 10),
      Paint()..color = const Color(0xFF1B5E20).withValues(alpha: 0.28),
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: patchW, height: patchH),
      Paint()
        ..shader =
            RadialGradient(
              colors: const [
                Color(0xFF9CCC65),
                Color(0xFF7CB342),
                Color(0xFF558B2F),
              ],
              stops: const [0.2, 0.65, 1.0],
            ).createShader(
              Rect.fromCenter(center: center, width: patchW, height: patchH),
            ),
    );

    final rim = Paint()
      ..color = const Color(0xFF33691E).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: patchW, height: patchH),
      rim,
    );

    final blade = Paint()
      ..color = const Color(0xFF689F38)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final random = math.Random(17);
    for (var i = 0; i < 36; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distX = math.cos(angle) * patchW * 0.46;
      final distY = math.sin(angle) * patchH * 0.42;
      final start = center + Offset(distX * 0.88, distY * 0.88);
      final tip =
          start +
          Offset(
            math.cos(angle - math.pi / 2) * (6 + random.nextDouble() * 8),
            math.sin(angle - math.pi / 2) * (6 + random.nextDouble() * 8),
          );
      canvas.drawLine(start, tip, blade);
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, patchH * 0.08),
        width: patchW * 0.35,
        height: patchH * 0.18,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
  }

  void _paintForestFloor(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.68, size.width, size.height * 0.32),
      Paint()..color = const Color(0xFF33691E).withValues(alpha: 0.35),
    );
  }

  void _paintAccentDetails(Canvas canvas, Size size) {
    final mushroom = Paint()..color = const Color(0xFFE57373);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.18, size.height * 0.72),
        width: 14,
        height: 10,
      ),
      mushroom,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.18, size.height * 0.74),
        width: 6,
        height: 8,
      ),
      Paint()..color = const Color(0xFFEFEBE9),
    );

    final flower = Paint()..color = const Color(0xFFFFF176);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.7), 4, flower);
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.72),
      3.5,
      flower,
    );

    final bush = Paint()
      ..color = const Color(0xFF43A047).withValues(alpha: 0.65);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.06, size.height * 0.66),
        width: 48,
        height: 28,
      ),
      bush,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.94, size.height * 0.67),
        width: 52,
        height: 30,
      ),
      bush,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TreeSpec {
  const _TreeSpec(
    this.x,
    this.baseY,
    this.scale,
    this.trunkHeight,
    this.trunkColor,
    this.canopyColor, {
    required this.back,
  });

  final double x;
  final double baseY;
  final double scale;
  final double trunkHeight;
  final int trunkColor;
  final int canopyColor;
  final bool back;
}
