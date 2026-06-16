import 'package:flutter/material.dart';

/// Small rotten egg used as a manual-battle boss projectile.
class RottenEggProjectile extends StatelessWidget {
  const RottenEggProjectile({
    super.key,
    this.size = 22,
  });

  static const assetPath = 'assets/images/ui/rotten_egg.png';

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
        errorBuilder: (_, _, _) => _RottenEggFallback(size: size),
      ),
    );
  }
}

class _RottenEggFallback extends StatelessWidget {
  const _RottenEggFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.12),
      painter: _RottenEggPainter(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: size * 0.08),
          child: Text(
            '🥚',
            style: TextStyle(
              fontSize: size * 0.78,
              height: 1,
            ),
          ),
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
        colors: [
          const Color(0xFFD4E157),
          const Color(0xFF8D6E63),
          const Color(0xFF5D4037),
        ],
        stops: const [0.2, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.52));

    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.88, height: h * 0.92),
      shell,
    );

    final spotPaint = Paint()..color = const Color(0xFF33691E).withValues(alpha: 0.75);
    canvas.drawCircle(Offset(w * 0.34, h * 0.42), w * 0.07, spotPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.58), w * 0.05, spotPaint);
    canvas.drawCircle(Offset(w * 0.48, h * 0.72), w * 0.04, spotPaint);

    final crack = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final crackPath = Path()
      ..moveTo(w * 0.44, h * 0.28)
      ..lineTo(w * 0.5, h * 0.4)
      ..lineTo(w * 0.46, h * 0.52);
    canvas.drawPath(crackPath, crack);

    final glow = Paint()
      ..color = const Color(0xFF689F38).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.95, height: h * 0.98),
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
