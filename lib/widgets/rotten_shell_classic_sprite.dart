import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hand-painted Classic Rotten Shell boss portrait (no PNG asset).
class RottenShellClassicSprite extends StatelessWidget {
  const RottenShellClassicSprite({
    super.key,
    required this.size,
    this.semanticLabel,
  });

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final sprite = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RottenShellClassicPainter(),
      ),
    );

    if (semanticLabel == null) return sprite;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: sprite,
    );
  }
}

class _RottenShellClassicPainter extends CustomPainter {
  static const _shellLight = Color(0xFFF0EBE3);
  static const _shellMid = Color(0xFFC8BFB0);
  static const _shellDark = Color(0xFF8D8478);
  static const _rotGreen = Color(0xFF558B2F);
  static const _rotDark = Color(0xFF33691E);
  static const _corruptPurple = Color(0xFF7B1FA2);
  static const _corruptGlow = Color(0xFFAB47BC);
  static const _yolkDark = Color(0xFF4E342E);
  static const _yolkGlow = Color(0xFFFFEB3B);
  static const _eyeRed = Color(0xFFD32F2F);
  static const _toxic = Color(0xFF9CCC65);
  static const _outline = Color(0xFF1A1510);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    final scale = size.width / 64;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 28), width: 46, height: 10),
      Paint()..color = _outline.withValues(alpha: 0.35),
    );

    // Toxic aura / fumes
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.35;
      final puff = Paint()
        ..color = (i.isEven ? _rotGreen : _corruptPurple)
            .withValues(alpha: 0.22);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(math.cos(angle) * 22, math.sin(angle) * 14 - 26),
          width: 14 + i * 2.0,
          height: 10 + i * 1.5,
        ),
        puff,
      );
    }

    // Main egg body — asymmetrical cracked shell
    final bodyPath = Path()
      ..moveTo(-22, -8)
      ..lineTo(-18, -22)
      ..lineTo(-8, -28)
      ..lineTo(4, -30)
      ..lineTo(16, -26)
      ..lineTo(22, -16)
      ..lineTo(24, -2)
      ..lineTo(22, 14)
      ..lineTo(14, 24)
      ..lineTo(0, 28)
      ..lineTo(-14, 24)
      ..lineTo(-22, 12)
      ..lineTo(-24, -2)
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.15),
          colors: [_shellLight, _shellMid, _shellDark],
        ).createShader(Rect.fromLTWH(-26, -32, 52, 62)),
    );

    // Interior corruption glow through cracks
    final coreGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _yolkGlow.withValues(alpha: 0.85),
          _rotGreen.withValues(alpha: 0.7),
          _corruptPurple.withValues(alpha: 0.55),
          _yolkDark.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 16));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: 28, height: 26),
      coreGlow,
    );

    // Top shell split / crack
    final crackPaint = Paint()
      ..color = _yolkDark
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-6, -28), const Offset(2, -8), crackPaint);
    canvas.drawLine(const Offset(8, -26), const Offset(4, -6), crackPaint);
    canvas.drawLine(const Offset(-14, -18), const Offset(-4, -2), crackPaint);
    canvas.drawLine(const Offset(14, -14), const Offset(8, 2), crackPaint);

    // Jagged shell shard spikes
    final shardPaint = Paint()..color = _shellMid;
    final shardOutline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final shard in [
      (Offset(-20, -20), Offset(-26, -28)),
      (Offset(-10, -28), Offset(-12, -36)),
      (Offset(6, -30), Offset(8, -38)),
      (Offset(18, -22), Offset(26, -26)),
      (Offset(22, -6), Offset(30, -4)),
      (Offset(-22, 4), Offset(-30, 6)),
    ]) {
      final path = Path()
        ..moveTo(shard.$1.dx, shard.$1.dy)
        ..lineTo(shard.$2.dx, shard.$2.dy)
        ..lineTo(shard.$1.dx + 3, shard.$1.dy + 2);
      canvas.drawPath(path, shardPaint);
      canvas.drawPath(path, shardOutline);
    }

    // Shell outline
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Angry glowing eyes
    for (final eyeX in [-9.0, 7.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(eyeX, -6), width: 9, height: 7),
        Paint()..color = _outline,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(eyeX, -6), width: 7, height: 5),
        Paint()..color = _eyeRed,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeX + 1.5, -7),
          width: 2.5,
          height: 2.5,
        ),
        Paint()..color = const Color(0xFFFFCDD2),
      );
      // Angry brow
      canvas.drawLine(
        Offset(eyeX - 5, -11),
        Offset(eyeX + 2, -9),
        Paint()
          ..color = _outline
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Jagged mouth crack
    final mouth = Path()
      ..moveTo(-6, 4)
      ..lineTo(-2, 8)
      ..lineTo(2, 5)
      ..lineTo(6, 9)
      ..lineTo(4, 12)
      ..lineTo(-4, 11)
      ..close();
    canvas.drawPath(mouth, Paint()..color = _yolkDark);
    canvas.drawPath(
      mouth,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Toxic slime drips
    final dripPaint = Paint()..color = _toxic;
    for (final drip in [
      (Offset(-16, 20), 4.0, 8.0),
      (Offset(-4, 24), 3.5, 10.0),
      (Offset(10, 22), 4.0, 9.0),
      (Offset(18, 16), 3.0, 7.0),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: drip.$1,
            width: drip.$2,
            height: drip.$3,
          ),
          const Radius.circular(2),
        ),
        dripPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(drip.$1.dx, drip.$1.dy + drip.$3 * 0.45),
          width: drip.$2 + 1,
          height: drip.$2 + 1,
        ),
        Paint()..color = _corruptGlow.withValues(alpha: 0.5),
      );
    }

    // Purple rot stains on shell
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-10, 8), width: 10, height: 7),
      Paint()..color = _corruptPurple.withValues(alpha: 0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, 10), width: 8, height: 6),
      Paint()..color = _rotDark.withValues(alpha: 0.4),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
