import 'package:flutter/material.dart';

/// Moonlit roost backdrop for the base bird boss defeat cinematic.
class BirdRoostBackground extends StatelessWidget {
  const BirdRoostBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _BirdRoostPainter());
  }
}

class _BirdRoostPainter extends CustomPainter {
  const _BirdRoostPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1A237E),
            Color(0xFF311B92),
            Color(0xFF1A1A2E),
          ],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.11),
      22,
      Paint()..color = const Color(0xFFE8EAF6).withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.11),
      28,
      Paint()..color = const Color(0xFF7986CB).withValues(alpha: 0.15),
    );

    final hill = Paint()..color = const Color(0xFF0D0D1A).withValues(alpha: 0.55);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.68, size.width, size.height * 0.32),
      hill,
    );

    final barn = Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: 0.75);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.48, size.width * 0.28, size.height * 0.22),
      barn,
    );
    final roof = Path()
      ..moveTo(size.width * 0.6, size.height * 0.48)
      ..lineTo(size.width * 0.76, size.height * 0.38)
      ..lineTo(size.width * 0.92, size.height * 0.48);
    canvas.drawPath(
      roof,
      Paint()
        ..color = const Color(0xFF283593)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final fence = Paint()..color = const Color(0xFF0D0D1A).withValues(alpha: 0.7);
    for (var i = 0; i < 9; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (0.04 + i * 0.105),
          size.height * 0.74,
          7,
          size.height * 0.12,
        ),
        fence,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.02, size.height * 0.74, size.width * 0.96, 4),
      fence,
    );

    final perch = Paint()..color = const Color(0xFF4A148C).withValues(alpha: 0.45);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.62, size.width * 0.22, 5),
      perch,
    );

    final tree = Paint()..color = const Color(0xFF1A237E).withValues(alpha: 0.6);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.42, 12, size.height * 0.28),
      tree,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.11, size.height * 0.4),
        width: 52,
        height: 38,
      ),
      tree,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
