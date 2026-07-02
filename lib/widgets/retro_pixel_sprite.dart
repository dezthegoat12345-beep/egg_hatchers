import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/retro_pixel_sprite_definition.dart';

/// Renders a variable-size Retro Pixel grid with crisp block scaling.
class RetroPixelSprite extends StatelessWidget {
  const RetroPixelSprite({
    super.key,
    required this.definition,
    required this.size,
    this.backgroundColor,
  });

  final RetroPixelSpriteDefinition definition;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RetroPixelSpritePainter(
          definition: definition,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

class _RetroPixelSpritePainter extends CustomPainter {
  _RetroPixelSpritePainter({
    required this.definition,
    this.backgroundColor,
  });

  final RetroPixelSpriteDefinition definition;
  final Color? backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor!);
    }

    if (!definition.hasVisiblePixels) return;

    final fitCell = math.min(
      size.width / definition.width,
      size.height / definition.height,
    );
    final cell = fitCell * definition.displayScale;
    final drawnW = cell * definition.width;
    final drawnH = cell * definition.height;
    final offsetX =
        (size.width - drawnW) / 2 + definition.horizontalOffset * cell;
    final offsetY =
        (size.height - drawnH) / 2 + definition.verticalOffset * cell;

    final paint = Paint()..isAntiAlias = false;

    for (var y = 0; y < definition.height; y++) {
      for (var x = 0; x < definition.width; x++) {
        final argb = definition.pixelAt(x, y);
        if (argb == null) continue;

        paint.color = Color(argb);
        canvas.drawRect(
          Rect.fromLTWH(
            offsetX + x * cell,
            offsetY + y * cell,
            cell,
            cell,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RetroPixelSpritePainter oldDelegate) {
    return oldDelegate.definition != definition ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
