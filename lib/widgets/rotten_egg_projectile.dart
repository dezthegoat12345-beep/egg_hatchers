import 'package:flutter/material.dart';

/// Small green rotten egg used as a manual-battle boss projectile.
class RottenEggProjectile extends StatelessWidget {
  const RottenEggProjectile({
    super.key,
    this.size = 22,
  });

  static const assetPath = 'assets/images/projectiles/rotten_egg.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: Image.asset(
        assetPath,
        width: size,
        height: size * 1.12,
        fit: BoxFit.contain,
        semanticLabel: 'Rotten egg',
        errorBuilder: (_, _, _) => CustomPaint(
          size: Size(size, size * 1.12),
          painter: _RottenEggPainter(),
        ),
      ),
    );
  }
}

class _RottenEggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.54);

    final shell = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFFDCEDC8),
          Color(0xFF8BC34A),
          Color(0xFF558B2F),
          Color(0xFF33691E),
        ],
        stops: const [0.15, 0.45, 0.78, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.52));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.88, height: h * 0.92),
      shell,
    );

    final spotPaint = Paint()..color = const Color(0xFF1B5E20).withValues(alpha: 0.82);
    canvas.drawCircle(Offset(w * 0.32, h * 0.4), w * 0.075, spotPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.55), w * 0.055, spotPaint);
    canvas.drawCircle(Offset(w * 0.46, h * 0.7), w * 0.045, spotPaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.36), w * 0.035, spotPaint);

    final slime = Paint()..color = const Color(0xFF689F38).withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.58, h * 0.62),
        width: w * 0.22,
        height: h * 0.12,
      ),
      slime,
    );

    final crack = Paint()
      ..color = const Color(0xFF2E4F1C)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    final crackPath = Path()
      ..moveTo(w * 0.42, h * 0.26)
      ..lineTo(w * 0.5, h * 0.38)
      ..lineTo(w * 0.44, h * 0.5)
      ..lineTo(w * 0.52, h * 0.58);
    canvas.drawPath(crackPath, crack);

    final glow = Paint()
      ..color = const Color(0xFF76FF03).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.98, height: h * 1.0),
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
