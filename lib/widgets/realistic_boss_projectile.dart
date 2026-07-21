import 'package:flutter/material.dart';

import '../utils/boss_visual_config.dart';

/// Softer shaded projectile art for the Realistic animal style.
class RealisticBossProjectile extends StatelessWidget {
  const RealisticBossProjectile({
    super.key,
    required this.type,
    this.size = 22,
  });

  final BossProjectileVisualType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: CustomPaint(
        size: Size(size, size * 1.12),
        painter: _RealisticBossProjectilePainter(type: type),
      ),
    );
  }
}

class _RealisticBossProjectilePainter extends CustomPainter {
  const _RealisticBossProjectilePainter({required this.type});

  final BossProjectileVisualType type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case BossProjectileVisualType.slimeGlob:
        _paintGlossySlime(canvas, size, crowned: false);
      case BossProjectileVisualType.rockEgg:
        _paintCrackedRockEgg(canvas, size);
      case BossProjectileVisualType.shadowFeather:
        _paintShadowFeather(canvas, size);
      case BossProjectileVisualType.royalSlime:
        _paintGlossySlime(canvas, size, crowned: true);
      case BossProjectileVisualType.guardianShard:
        _paintGuardianShard(canvas, size);
      case BossProjectileVisualType.phoenixFlame:
        _paintPhoenixFlame(canvas, size);
      case BossProjectileVisualType.rottenShell:
        _paintRottenShard(canvas, size);
      case BossProjectileVisualType.rottenEgg:
        _paintRottenShard(canvas, size);
    }
  }

  void _paintGlossySlime(Canvas canvas, Size size, {required bool crowned}) {
    final center = Offset(size.width / 2, size.height * 0.58);
    _drawSoftGlow(canvas, center, size.width * 0.58, const Color(0xFF7CFF6B));
    final bodyRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.86,
      height: size.height * 0.72,
    );
    canvas.drawOval(
      bodyRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.9,
          colors: const [
            Color(0xFFE8FFE1),
            Color(0xFF8BE86D),
            Color(0xFF1B8A39),
            Color(0xFF07551F),
          ],
        ).createShader(bodyRect),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.36, size.height * 0.43),
        width: size.width * 0.18,
        height: size.height * 0.1,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    if (crowned) {
      final crown = Path()
        ..moveTo(size.width * 0.28, size.height * 0.26)
        ..lineTo(size.width * 0.38, size.height * 0.14)
        ..lineTo(size.width * 0.5, size.height * 0.25)
        ..lineTo(size.width * 0.62, size.height * 0.14)
        ..lineTo(size.width * 0.72, size.height * 0.26)
        ..lineTo(size.width * 0.68, size.height * 0.34)
        ..lineTo(size.width * 0.32, size.height * 0.34)
        ..close();
      canvas.drawPath(crown, Paint()..color = const Color(0xFFFFD866));
      canvas.drawPath(
        crown,
        Paint()
          ..color = const Color(0xFF8D5C00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    }
  }

  void _paintCrackedRockEgg(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.56);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.82,
      height: size.height * 0.88,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          colors: const [
            Color(0xFFFFF6D2),
            Color(0xFFB7A079),
            Color(0xFF6A5742),
          ],
        ).createShader(rect),
    );
    final crack = Paint()
      ..color = const Color(0xFF2F241B)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.42, size.height * 0.22)
        ..lineTo(size.width * 0.52, size.height * 0.38)
        ..lineTo(size.width * 0.45, size.height * 0.52)
        ..lineTo(size.width * 0.57, size.height * 0.68),
      crack,
    );
  }

  void _paintShadowFeather(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    _drawSoftGlow(canvas, center, size.width * 0.55, const Color(0xFF7C4DFF));
    final feather = Path()
      ..moveTo(center.dx + size.width * 0.06, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.48,
        size.width * 0.5,
        size.height * 0.96,
      )
      ..quadraticBezierTo(
        size.width * 0.12,
        size.height * 0.52,
        center.dx + size.width * 0.06,
        size.height * 0.12,
      );
    canvas.drawPath(
      feather,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A2D86), Color(0xFF120A2A), Color(0xFF1B2C68)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.56, size.height * 0.18)
        ..quadraticBezierTo(
          size.width * 0.48,
          size.height * 0.52,
          size.width * 0.48,
          size.height * 0.9,
        ),
      Paint()
        ..color = const Color(0xFFB39DDB).withValues(alpha: 0.72)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintGuardianShard(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    _drawSoftGlow(canvas, center, size.width * 0.55, const Color(0xFF7FD8FF));
    final shard = Path()
      ..moveTo(center.dx, size.height * 0.1)
      ..lineTo(size.width * 0.78, size.height * 0.46)
      ..lineTo(size.width * 0.54, size.height * 0.94)
      ..lineTo(size.width * 0.2, size.height * 0.58)
      ..close();
    canvas.drawPath(
      shard,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFC9F2FF), Color(0xFF7B6A4E)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      shard,
      Paint()
        ..color = const Color(0xFF256D92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintPhoenixFlame(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);
    _drawSoftGlow(canvas, center, size.width * 0.68, const Color(0xFF6EA8FF));
    for (var i = 0; i < 4; i++) {
      final phase = (i - 1.5) * 0.22;
      final path = Path()
        ..moveTo(size.width * (0.32 + phase), size.height * 0.9)
        ..cubicTo(
          size.width * (0.1 + phase),
          size.height * 0.55,
          size.width * (0.42 + phase),
          size.height * 0.35,
          size.width * (0.5 + phase),
          size.height * 0.1,
        )
        ..cubicTo(
          size.width * (0.72 + phase),
          size.height * 0.42,
          size.width * (0.85 + phase),
          size.height * 0.62,
          size.width * (0.58 + phase),
          size.height * 0.9,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = [
            const Color(0xFFB3E5FC),
            const Color(0xFF42A5F5),
            const Color(0xFF283593),
            const Color(0xFF7E57C2),
          ][i].withValues(alpha: 0.72),
      );
    }
  }

  void _paintRottenShard(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.56);
    _drawSoftGlow(canvas, center, size.width * 0.62, const Color(0xFFC7FF35));
    final shell = Path()
      ..moveTo(size.width * 0.5, size.height * 0.08)
      ..lineTo(size.width * 0.76, size.height * 0.34)
      ..lineTo(size.width * 0.68, size.height * 0.9)
      ..lineTo(size.width * 0.36, size.height * 0.88)
      ..lineTo(size.width * 0.22, size.height * 0.38)
      ..close();
    canvas.drawPath(
      shell,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.25),
          colors: [Color(0xFFF5E7B2), Color(0xFF8B7B4A), Color(0xFF2C1A1D)],
        ).createShader(Offset.zero & size),
    );
    final ooze = Paint()
      ..color = const Color(0xFFB2FF59).withValues(alpha: 0.8);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.48),
      size.width * 0.12,
      ooze,
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.38 + i * 0.12), size.height * (0.64 + i * 0.04)),
        size.width * 0.035,
        ooze,
      );
    }
    final crack = Paint()
      ..color = const Color(0xFF120A12)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.34, size.height * 0.25)
        ..lineTo(size.width * 0.5, size.height * 0.44)
        ..lineTo(size.width * 0.42, size.height * 0.72)
        ..moveTo(size.width * 0.66, size.height * 0.32)
        ..lineTo(size.width * 0.54, size.height * 0.5),
      crack,
    );
  }

  void _drawSoftGlow(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.35), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _RealisticBossProjectilePainter oldDelegate) =>
      oldDelegate.type != type;
}
