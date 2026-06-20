import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Finds and drives scrollables under the tutorial content layer while the
/// spotlight overlay sits above it in a sibling [Stack].
class TutorialScrollBridge {
  TutorialScrollBridge._();

  static void applyDrag({
    required GlobalKey contentKey,
    required Offset globalPosition,
    required double delta,
  }) {
    final offset = _viewportOffsetAtPoint(
      contentKey: contentKey,
      globalPosition: globalPosition,
    );
    if (offset == null) return;
    offset.jumpTo(offset.pixels - delta);
  }

  static void applyScrollSignal({
    required GlobalKey contentKey,
    required Offset globalPosition,
    required double delta,
  }) {
    applyDrag(
      contentKey: contentKey,
      globalPosition: globalPosition,
      delta: delta,
    );
  }

  static ViewportOffset? _viewportOffsetAtPoint({
    required GlobalKey contentKey,
    required Offset globalPosition,
  }) {
    final contentContext = contentKey.currentContext;
    if (contentContext == null) return null;

    final renderObject = contentContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;

    final local = renderObject.globalToLocal(globalPosition);
    if (!(Offset.zero & renderObject.size).contains(local)) return null;

    final result = BoxHitTestResult();
    renderObject.hitTest(result, position: local);

    for (final entry in result.path) {
      final offset = _viewportOffsetForTarget(entry.target);
      if (offset != null) return offset;
    }
    return null;
  }

  static ViewportOffset? _viewportOffsetForTarget(HitTestTarget target) {
    if (target is! RenderObject) return null;

    RenderObject? node = target;
    while (node != null) {
      if (node is RenderViewportBase) {
        return node.offset;
      }
      node = node.parent;
    }
    return null;
  }
}
