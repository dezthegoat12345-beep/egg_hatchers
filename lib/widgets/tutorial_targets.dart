import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/tutorial_data.dart';

/// Registry of [GlobalKey] targets for the guided tutorial spotlight.
class TutorialTargets {
  TutorialTargets._();

  static final GlobalKey shopButton = GlobalKey(debugLabel: 'tutorialShop');
  static final GlobalKey basicEggBuyButton =
      GlobalKey(debugLabel: 'tutorialBasicEggBuy');
  static final GlobalKey screenBackButton =
      GlobalKey(debugLabel: 'tutorialScreenBack');
  static final GlobalKey animalsSection =
      GlobalKey(debugLabel: 'tutorialAnimals');
  static final GlobalKey upgradeButton =
      GlobalKey(debugLabel: 'tutorialUpgrade');
  static final GlobalKey collectionButton =
      GlobalKey(debugLabel: 'tutorialCollection');
  static final GlobalKey questsButton = GlobalKey(debugLabel: 'tutorialQuests');
  static final GlobalKey battlesButton =
      GlobalKey(debugLabel: 'tutorialBattles');
  static final GlobalKey battlesExplainSection =
      GlobalKey(debugLabel: 'tutorialBattlesExplain');
  static final GlobalKey rebirthPanel =
      GlobalKey(debugLabel: 'tutorialRebirth');

  static GlobalKey? keyFor(String? targetId) {
    switch (targetId) {
      case TutorialTargetIds.shopButton:
        return shopButton;
      case TutorialTargetIds.basicEggBuyButton:
        return basicEggBuyButton;
      case TutorialTargetIds.screenBackButton:
        return screenBackButton;
      case TutorialTargetIds.animalsSection:
        return animalsSection;
      case TutorialTargetIds.upgradeButton:
        return upgradeButton;
      case TutorialTargetIds.collectionButton:
        return collectionButton;
      case TutorialTargetIds.questsButton:
        return questsButton;
      case TutorialTargetIds.battlesButton:
        return battlesButton;
      case TutorialTargetIds.battlesExplainSection:
        return battlesExplainSection;
      case TutorialTargetIds.rebirthPanel:
        return rebirthPanel;
      default:
        return null;
    }
  }

  static String? labelFor(String? targetId) => targetId;

  static Rect? measure(
    String? targetId, {
    required BuildContext overlayContext,
    double padding = 8,
  }) {
    final key = keyFor(targetId);
    if (key == null) return null;
    return measureKey(key, overlayContext: overlayContext, padding: padding);
  }

  static Rect? measureKey(
    GlobalKey key, {
    required BuildContext overlayContext,
    double padding = 8,
  }) {
    final targetContext = key.currentContext;
    if (targetContext == null) return null;

    final targetBox = targetContext.findRenderObject();
    if (targetBox is! RenderBox || !targetBox.hasSize) return null;

    final overlayBox = overlayContext.findRenderObject();
    if (overlayBox is! RenderBox || !overlayBox.hasSize) return null;

    final topLeft = targetBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final bottomRight = targetBox.localToGlobal(
      targetBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );

    if (bottomRight.dx <= topLeft.dx || bottomRight.dy <= topLeft.dy) {
      return null;
    }

    return Rect.fromPoints(topLeft, bottomRight).inflate(padding);
  }

  static Future<void> scrollTargetIntoView(
    String? targetId, {
    Duration duration = const Duration(milliseconds: 320),
    double alignment = 0.32,
  }) async {
    final targetContext = keyFor(targetId)?.currentContext;
    if (targetContext == null) return;

    try {
      await Scrollable.ensureVisible(
        targetContext,
        duration: duration,
        curve: Curves.easeInOut,
        alignment: alignment,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    } catch (_) {
      // Target may not live inside a scrollable ancestor.
    }
  }

  static void debugLogMeasure({
    required String stepId,
    required String? targetId,
    required Rect? rect,
  }) {
    if (!kDebugMode) return;
    final label = labelFor(targetId) ?? targetId ?? 'none';
    if (rect == null) {
      debugPrint('[Tutorial] step=$stepId target=$label rect=NOT_FOUND');
    } else {
      debugPrint(
        '[Tutorial] step=$stepId target=$label '
        'rect=${rect.left.toStringAsFixed(1)},'
        '${rect.top.toStringAsFixed(1)} '
        '${rect.width.toStringAsFixed(1)}x${rect.height.toStringAsFixed(1)}',
      );
    }
  }
}
