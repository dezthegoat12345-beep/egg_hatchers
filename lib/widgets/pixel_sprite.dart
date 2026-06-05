import 'package:flutter/material.dart';

import '../models/custom_sprite_data.dart';

/// Renders a pixel grid with CustomPaint at any display size.
class PixelSprite extends StatelessWidget {
  const PixelSprite({
    super.key,
    required this.data,
    required this.size,
    this.showGrid = false,
    this.gridColor,
    this.backgroundColor,
  });

  final CustomSpriteData data;
  final double size;
  final bool showGrid;
  final Color? gridColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PixelSpritePainter(
          data: data,
          showGrid: showGrid,
          gridColor: gridColor ?? Colors.black.withValues(alpha: 0.15),
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

class _PixelSpritePainter extends CustomPainter {
  _PixelSpritePainter({
    required this.data,
    required this.showGrid,
    required this.gridColor,
    this.backgroundColor,
  });

  final CustomSpriteData data;
  final bool showGrid;
  final Color gridColor;
  final Color? backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor!);
    }

    final cell = size.width / CustomSpriteData.gridSize;

    for (var y = 0; y < CustomSpriteData.gridSize; y++) {
      for (var x = 0; x < CustomSpriteData.gridSize; x++) {
        final argb = data.pixelAt(x, y);
        if (argb != null) {
          final paint = Paint()..color = Color(argb);
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            paint,
          );
        }
      }
    }

    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1;

      for (var i = 0; i <= CustomSpriteData.gridSize; i++) {
        final offset = i * cell;
        canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), gridPaint);
        canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelSpritePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Interactive 16×16 editor canvas.
class PixelSpriteEditor extends StatelessWidget {
  const PixelSpriteEditor({
    super.key,
    required this.data,
    required this.selectedColor,
    required this.onChanged,
    this.canvasSize = 256,
    this.themeColor,
  });

  final CustomSpriteData data;
  final int? selectedColor;
  final ValueChanged<CustomSpriteData> onChanged;
  final double canvasSize;
  final Color? themeColor;

  void _paintAt(Offset localPosition) {
    final cell = canvasSize / CustomSpriteData.gridSize;
    final x = (localPosition.dx / cell).floor();
    final y = (localPosition.dy / cell).floor();
    if (x < 0 ||
        x >= CustomSpriteData.gridSize ||
        y < 0 ||
        y >= CustomSpriteData.gridSize) {
      return;
    }

    if (data.pixelAt(x, y) == selectedColor) return;
    onChanged(data.setPixel(x, y, selectedColor));
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = themeColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 2),
        color: Colors.white.withValues(alpha: 0.6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onPanDown: (details) => _paintAt(details.localPosition),
          onPanUpdate: (details) => _paintAt(details.localPosition),
          onTapDown: (details) => _paintAt(details.localPosition),
          child: PixelSprite(
            data: data,
            size: canvasSize,
            showGrid: true,
            gridColor: borderColor.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
