import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils/tutorial_scroll_bridge.dart';

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
    this.contentKey,
  });

  final TutorialHighlightMetrics metrics;
  final Size layerSize;
  final Color dimColor;
  final bool blockOutsideTouches;
  final GlobalKey? contentKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _DimPanelRects.build(
        hole: metrics.bounds,
        layerSize: layerSize,
        dimColor: dimColor,
        blockTouches: blockOutsideTouches,
        contentKey: contentKey,
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
    GlobalKey? contentKey,
  }) {
    Widget panel() {
      final child = ColoredBox(color: dimColor);
      if (!blockTouches) {
        return IgnorePointer(child: child);
      }
      if (contentKey == null) {
        return AbsorbPointer(child: child);
      }
      return _TutorialDimScrollPanel(
        contentKey: contentKey,
        child: child,
      );
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

/// Blocks errant taps on dimmed tutorial regions while forwarding vertical
/// scroll gestures to the underlying scrollable content layer.
class _TutorialDimScrollPanel extends StatefulWidget {
  const _TutorialDimScrollPanel({
    required this.contentKey,
    required this.child,
  });

  final GlobalKey contentKey;
  final Widget child;

  @override
  State<_TutorialDimScrollPanel> createState() =>
      _TutorialDimScrollPanelState();
}

class _TutorialDimScrollPanelState extends State<_TutorialDimScrollPanel> {
  static const _scrollSlop = 8.0;

  int? _activePointer;
  Offset? _downPosition;
  var _isScrolling = false;

  void _resetPointer() {
    _activePointer = null;
    _downPosition = null;
    _isScrolling = false;
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointer = event.pointer;
    _downPosition = event.position;
    _isScrolling = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_activePointer != event.pointer || _downPosition == null) return;

    final totalDelta = event.position - _downPosition!;
    if (!_isScrolling) {
      if (totalDelta.dy.abs() > _scrollSlop &&
          totalDelta.dy.abs() > totalDelta.dx.abs()) {
        _isScrolling = true;
      }
    }

    if (_isScrolling) {
      TutorialScrollBridge.applyDrag(
        contentKey: widget.contentKey,
        globalPosition: event.position,
        delta: event.delta.dy,
      );
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_activePointer != event.pointer) return;
    _resetPointer();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_activePointer != event.pointer) return;
    _resetPointer();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    TutorialScrollBridge.applyScrollSignal(
      contentKey: widget.contentKey,
      globalPosition: event.position,
      delta: event.scrollDelta.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      onPointerSignal: _onPointerSignal,
      child: widget.child,
    );
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
