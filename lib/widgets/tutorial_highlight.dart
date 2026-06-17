import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shape used to outline a tutorial spotlight target.
enum TutorialHighlightShape {
  roundedRectangle,
  circle,
}

/// Layout metrics for a tutorial target highlight and dim cutout.
class TutorialHighlightMetrics {
  TutorialHighlightMetrics._({
    required this.shape,
    required this.bounds,
    required this.roundedRect,
    required this.ovalRect,
  });

  final TutorialHighlightShape shape;
  final Rect bounds;
  final RRect roundedRect;
  final Rect ovalRect;

  static TutorialHighlightMetrics forTarget(
    Rect targetRect, {
    double padding = 10,
  }) {
    final inflated = targetRect.inflate(padding);
    final aspect = inflated.width / math.max(inflated.height, 1);

    if (aspect > 1.35) {
      final radius = (inflated.height * 0.24).clamp(12.0, 18.0);
      final rrect = RRect.fromRectAndRadius(
        inflated,
        Radius.circular(radius),
      );
      return TutorialHighlightMetrics._(
        shape: TutorialHighlightShape.roundedRectangle,
        bounds: inflated,
        roundedRect: rrect,
        ovalRect: inflated,
      );
    }

    final diameter = math.max(inflated.width, inflated.height);
    final oval = Rect.fromCenter(
      center: inflated.center,
      width: diameter,
      height: diameter,
    );
    return TutorialHighlightMetrics._(
      shape: TutorialHighlightShape.circle,
      bounds: oval,
      roundedRect: RRect.fromRectAndRadius(
        inflated,
        Radius.circular(inflated.shortestSide * 0.2),
      ),
      ovalRect: oval,
    );
  }

  Path cutoutPath() {
    switch (shape) {
      case TutorialHighlightShape.roundedRectangle:
        return Path()..addRRect(roundedRect);
      case TutorialHighlightShape.circle:
        return Path()..addOval(ovalRect);
    }
  }
}

/// Four-panel dim mask leaving the target hole fully transparent.
///
/// More reliable than [Path.combine] cutouts on Flutter Web, where difference
/// paths may still composite dim color over the target.
class TutorialSpotlightDimMask extends StatelessWidget {
  const TutorialSpotlightDimMask({
    super.key,
    required this.metrics,
    required this.layerSize,
    required this.dimColor,
    this.blockOutsideTouches = true,
  });

  final TutorialHighlightMetrics metrics;
  final Size layerSize;
  final Color dimColor;
  final bool blockOutsideTouches;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _DimPanelRects.build(
        hole: metrics.bounds,
        layerSize: layerSize,
        dimColor: dimColor,
        blockTouches: blockOutsideTouches,
      ),
    );
  }
}

class _DimPanelRects {
  static List<Widget> build({
    required Rect hole,
    required Size layerSize,
    required Color dimColor,
    required bool blockTouches,
  }) {
    Widget panel() {
      final child = ColoredBox(color: dimColor);
      if (!blockTouches) {
        return IgnorePointer(child: child);
      }
      return AbsorbPointer(child: child);
    }

    return [
      Positioned(
        left: 0,
        top: 0,
        right: 0,
        height: hole.top.clamp(0, layerSize.height),
        child: panel(),
      ),
      Positioned(
        left: 0,
        top: hole.bottom.clamp(0, layerSize.height),
        right: 0,
        bottom: 0,
        child: panel(),
      ),
      Positioned(
        left: 0,
        top: hole.top,
        width: hole.left.clamp(0, layerSize.width),
        height: hole.height,
        child: panel(),
      ),
      Positioned(
        left: hole.right.clamp(0, layerSize.width),
        top: hole.top,
        right: 0,
        height: hole.height,
        child: panel(),
      ),
    ];
  }
}

/// Dims the screen with a cutout over the active tutorial target.
///
/// Prefer [TutorialSpotlightDimMask] for runtime spotlight UI.
class TutorialDimSpotlightPainter extends CustomPainter {
  TutorialDimSpotlightPainter({
    required this.metrics,
    required this.dimColor,
  });

  final TutorialHighlightMetrics metrics;
  final Color dimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final cutout = metrics.cutoutPath();
    final dimPath = Path.combine(
      PathOperation.difference,
      overlay,
      cutout,
    );
    canvas.drawPath(
      dimPath,
      Paint()..color = dimColor,
    );
  }

  @override
  bool shouldRepaint(covariant TutorialDimSpotlightPainter oldDelegate) {
    return oldDelegate.metrics.bounds != metrics.bounds ||
        oldDelegate.metrics.shape != metrics.shape ||
        oldDelegate.dimColor != dimColor;
  }
}

/// Bright gold outline and glow drawn above the dim layer.
class TutorialTargetHighlightPainter extends CustomPainter {
  TutorialTargetHighlightPainter({
    required this.metrics,
    required this.pulse,
  });

  final TutorialHighlightMetrics metrics;
  final double pulse;

  static const _gold = Color(0xFFFFD54F);
  static const _goldBright = Color(0xFFFFEB3B);

  @override
  void paint(Canvas canvas, Size size) {
    final glowSpread = 2 + pulse * 3;
    final outerAlpha = 0.14 + pulse * 0.1;
    final midAlpha = 0.28 + pulse * 0.18;
    final borderAlpha = 0.88 + pulse * 0.12;

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12 + pulse * 4
      ..color = Colors.white.withValues(alpha: outerAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = _gold.withValues(alpha: midAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = _goldBright.withValues(alpha: borderAlpha);

    switch (metrics.shape) {
      case TutorialHighlightShape.roundedRectangle:
        final outer = _inflateRRect(metrics.roundedRect, glowSpread + 4);
        final mid = _inflateRRect(metrics.roundedRect, glowSpread);
        canvas.drawRRect(outer, outerGlow);
        canvas.drawRRect(mid, glowPaint);
        canvas.drawRRect(metrics.roundedRect, borderPaint);
      case TutorialHighlightShape.circle:
        canvas.drawOval(metrics.ovalRect.inflate(glowSpread + 4), outerGlow);
        canvas.drawOval(metrics.ovalRect.inflate(glowSpread), glowPaint);
        canvas.drawOval(metrics.ovalRect, borderPaint);
    }
  }

  RRect _inflateRRect(RRect rrect, double delta) {
    final rect = rrect.outerRect.inflate(delta);
    final radius = Radius.circular(
      (rrect.outerRect.shortestSide * 0.22 + delta).clamp(8.0, 24.0),
    );
    return RRect.fromRectAndRadius(rect, radius);
  }

  @override
  bool shouldRepaint(covariant TutorialTargetHighlightPainter oldDelegate) {
    return oldDelegate.metrics.bounds != metrics.bounds ||
        oldDelegate.pulse != pulse;
  }
}

/// Pulsing highlight border rendered above the dim overlay.
class TutorialTargetHighlight extends StatefulWidget {
  const TutorialTargetHighlight({
    super.key,
    required this.metrics,
    required this.layerSize,
  });

  final TutorialHighlightMetrics metrics;
  final Size layerSize;

  @override
  State<TutorialTargetHighlight> createState() =>
      _TutorialTargetHighlightState();
}

class _TutorialTargetHighlightState extends State<TutorialTargetHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: widget.layerSize,
          painter: TutorialTargetHighlightPainter(
            metrics: widget.metrics,
            pulse: _controller.value,
          ),
        );
      },
    );
  }
}
