import 'package:flutter/material.dart';

import '../models/custom_sprite_data.dart';

/// Active drawing tool in the sprite editor.
enum SpriteEditorTool {
  pencil,
  fill,
  eraser,
}

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

/// Interactive 16×16 editor canvas with brush, fill, and drag painting.
class PixelSpriteEditor extends StatefulWidget {
  const PixelSpriteEditor({
    super.key,
    required this.data,
    required this.selectedColor,
    required this.tool,
    required this.brushSize,
    required this.showGrid,
    required this.onChanged,
    this.onStrokeStart,
    this.onStrokeEnd,
    this.canvasSize = 256,
    this.themeColor,
  });

  final CustomSpriteData data;
  final int? selectedColor;
  final SpriteEditorTool tool;
  final int brushSize;
  final bool showGrid;
  final ValueChanged<CustomSpriteData> onChanged;
  final VoidCallback? onStrokeStart;
  final VoidCallback? onStrokeEnd;
  final double canvasSize;
  final Color? themeColor;

  @override
  State<PixelSpriteEditor> createState() => _PixelSpriteEditorState();
}

class _PixelSpriteEditorState extends State<PixelSpriteEditor> {
  bool _strokeActive = false;

  int? get _activeColor {
    if (widget.tool == SpriteEditorTool.eraser) {
      return SpritePalette.transparent;
    }
    return widget.selectedColor;
  }

  (int x, int y)? _cellAt(Offset localPosition) {
    final cell = widget.canvasSize / CustomSpriteData.gridSize;
    final x = (localPosition.dx / cell).floor();
    final y = (localPosition.dy / cell).floor();
    if (x < 0 ||
        x >= CustomSpriteData.gridSize ||
        y < 0 ||
        y >= CustomSpriteData.gridSize) {
      return null;
    }
    return (x, y);
  }

  void _beginStroke() {
    if (_strokeActive) return;
    _strokeActive = true;
    widget.onStrokeStart?.call();
  }

  void _endStroke() {
    if (!_strokeActive) return;
    _strokeActive = false;
    widget.onStrokeEnd?.call();
  }

  void _applyAt(Offset localPosition) {
    final cell = _cellAt(localPosition);
    if (cell == null) return;

    final color = _activeColor;
    CustomSpriteData next;

    if (widget.tool == SpriteEditorTool.fill) {
      next = widget.data.floodFill(cell.$1, cell.$2, color);
    } else {
      next = widget.data.applyBrush(
        cell.$1,
        cell.$2,
        widget.brushSize,
        color,
      );
    }

    if (next.pixels.toString() == widget.data.pixels.toString()) return;
    widget.onChanged(next);
  }

  void _handleDown(Offset position) {
    _beginStroke();
    _applyAt(position);
    if (widget.tool == SpriteEditorTool.fill) {
      _endStroke();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.themeColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 2),
        color: Colors.white.withValues(alpha: 0.6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Listener(
          onPointerUp: (_) => _endStroke(),
          onPointerCancel: (_) => _endStroke(),
          child: GestureDetector(
            onPanDown: (details) => _handleDown(details.localPosition),
            onPanUpdate: (details) {
              if (widget.tool == SpriteEditorTool.fill) return;
              _applyAt(details.localPosition);
            },
            onPanEnd: (_) => _endStroke(),
            onPanCancel: () => _endStroke(),
            child: PixelSprite(
              data: widget.data,
              size: widget.canvasSize,
              showGrid: widget.showGrid,
              gridColor: borderColor.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }
}
