import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/retro_pixel_boss_projectiles.dart';
import '../models/animal_sprite_theme.dart';
import '../utils/boss_visual_config.dart';
import 'animal_sprite_theme_scope.dart';
import 'realistic_boss_projectile.dart';
import 'retro_pixel_sprite.dart';
import 'rotten_egg_projectile.dart';

/// Boss-specific falling projectile visual (same hitbox as rotten egg).
class BossProjectileWidget extends StatelessWidget {
  const BossProjectileWidget({super.key, required this.bossId, this.size = 22});

  final String bossId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final type = BossVisualConfig.projectileTypeForBossId(bossId);
    if (type == BossProjectileVisualType.rottenEgg) {
      return RottenEggProjectile(size: size);
    }

    final animalTheme = AnimalSpriteThemeScope.of(context);
    if (animalTheme.id == AnimalSpriteThemes.realistic.id) {
      return RealisticBossProjectile(type: type, size: size);
    }

    if (animalTheme.id == AnimalSpriteThemes.retroPixel.id) {
      final pixelArt = RetroPixelBossProjectiles.forType(type);
      if (pixelArt != null) {
        return RetroPixelSprite(definition: pixelArt, size: size);
      }
    }

    return SizedBox(
      width: size,
      height: size * 1.12,
      child: CustomPaint(
        size: Size(size, size * 1.12),
        painter: _BossProjectilePainter(type: type),
      ),
    );
  }
}

class _BossProjectilePainter extends CustomPainter {
  _BossProjectilePainter({required this.type});

  final BossProjectileVisualType type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case BossProjectileVisualType.slimeGlob:
        _paintSlimeGlob(canvas, size);
      case BossProjectileVisualType.rockEgg:
        _paintRockEgg(canvas, size);
      case BossProjectileVisualType.shadowFeather:
        _paintShadowFeather(canvas, size);
      case BossProjectileVisualType.royalSlime:
        _paintRoyalSlime(canvas, size);
      case BossProjectileVisualType.guardianShard:
        _paintGuardianShard(canvas, size);
      case BossProjectileVisualType.phoenixFlame:
        _paintPhoenixFlame(canvas, size);
      case BossProjectileVisualType.rottenShell:
        _paintRottenShell(canvas, size);
      case BossProjectileVisualType.rottenEgg:
        break;
    }
  }

  void _paintRottenShell(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.8,
        height: size.height * 0.82,
      ),
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0xFFDCEDC8), Color(0xFF81C784), Color(0xFF6A1B9A)],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.45),
            ),
    );
    final crack = Paint()
      ..color = const Color(0xFF1B5E20)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.55),
      crack,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.32),
      Offset(size.width * 0.52, size.height * 0.58),
      crack,
    );
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.46),
      size.width * 0.06,
      Paint()..color = const Color(0xFFE53935).withValues(alpha: 0.85),
    );
  }

  void _paintSlimeGlob(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFA5D6A7), Color(0xFF66BB6A), Color(0xFF388E3C)],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.5));
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.82,
        height: size.height * 0.78,
      ),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.38, size.height * 0.42),
      size.width * 0.08,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _paintRockEgg(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    final shell = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFD7CCC8), Color(0xFF8D6E63), Color(0xFF5D4037)],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.5));
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.78,
        height: size.height * 0.82,
      ),
      shell,
    );
    final crack = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.4, size.height * 0.28)
      ..lineTo(size.width * 0.5, size.height * 0.45)
      ..lineTo(size.width * 0.42, size.height * 0.58);
    canvas.drawPath(path, crack);
  }

  void _paintShadowFeather(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);
    final featherPaint = Paint()..color = const Color(0xFF311B92);
    final path = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.35)
      ..quadraticBezierTo(
        center.dx + size.width * 0.42,
        center.dy,
        center.dx,
        center.dy + size.height * 0.35,
      )
      ..quadraticBezierTo(
        center.dx - size.width * 0.42,
        center.dy,
        center.dx,
        center.dy - size.height * 0.35,
      );
    canvas.drawPath(path, featherPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.62, size.height * 0.48),
        width: size.width * 0.35,
        height: size.height * 0.55,
      ),
      Paint()..color = const Color(0xFF1A237E).withValues(alpha: 0.85),
    );
  }

  void _paintRoyalSlime(Canvas canvas, Size size) {
    _paintSlimeGlob(canvas, size);
    final crown = Paint()..color = const Color(0xFFFFD54F);
    final cx = size.width / 2;
    final top = size.height * 0.22;
    final path = Path()
      ..moveTo(cx - size.width * 0.22, top + 8)
      ..lineTo(cx - size.width * 0.12, top)
      ..lineTo(cx, top + 6)
      ..lineTo(cx + size.width * 0.12, top)
      ..lineTo(cx + size.width * 0.22, top + 8)
      ..lineTo(cx + size.width * 0.18, top + 12)
      ..lineTo(cx - size.width * 0.18, top + 12)
      ..close();
    canvas.drawPath(path, crown);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.38),
      2,
      Paint()..color = const Color(0xFFFFEB3B),
    );
  }

  void _paintGuardianShard(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    final shard = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.32)
      ..lineTo(center.dx + size.width * 0.28, center.dy + size.height * 0.08)
      ..lineTo(center.dx, center.dy + size.height * 0.32)
      ..lineTo(center.dx - size.width * 0.28, center.dy + size.height * 0.08)
      ..close();
    canvas.drawPath(
      shard,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [
                Color(0xFFFFF8E1),
                Color(0xFFFFD54F),
                Color(0xFF8D6E63),
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.4),
            ),
    );
    canvas.drawPath(
      shard,
      Paint()
        ..color = const Color(0xFF42A5F5).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _paintPhoenixFlame(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.56);
    final flame = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFF64B5F6), Color(0xFF1565C0), Color(0xFF0D47A1)],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.5));

    for (var i = 0; i < 3; i++) {
      final angle = -math.pi / 2 + (i - 1) * 0.35;
      final tip = Offset(
        center.dx + math.cos(angle) * size.width * 0.08,
        center.dy + math.sin(angle) * size.height * 0.38,
      );
      final path = Path()
        ..moveTo(center.dx - size.width * 0.18, center.dy + size.height * 0.1)
        ..quadraticBezierTo(center.dx, tip.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(
          center.dx + size.width * 0.18,
          center.dy + size.height * 0.1,
          center.dx - size.width * 0.18,
          center.dy + size.height * 0.1,
        );
      canvas.drawPath(path, flame);
    }
  }

  @override
  bool shouldRepaint(covariant _BossProjectilePainter oldDelegate) =>
      oldDelegate.type != type;
}
