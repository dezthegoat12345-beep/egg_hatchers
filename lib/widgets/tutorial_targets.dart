import 'package:flutter/material.dart';

import '../data/tutorial_data.dart';

/// Registry of [GlobalKey] targets for the guided tutorial spotlight.
class TutorialTargets {
  TutorialTargets._();

  static final GlobalKey shopButton = GlobalKey(debugLabel: 'tutorialShop');
  static final GlobalKey basicEggBuyButton =
      GlobalKey(debugLabel: 'tutorialBasicEggBuy');
  static final GlobalKey animalsSection =
      GlobalKey(debugLabel: 'tutorialAnimals');
  static final GlobalKey upgradeButton =
      GlobalKey(debugLabel: 'tutorialUpgrade');
  static final GlobalKey collectionButton =
      GlobalKey(debugLabel: 'tutorialCollection');
  static final GlobalKey questsButton = GlobalKey(debugLabel: 'tutorialQuests');
  static final GlobalKey battlesButton =
      GlobalKey(debugLabel: 'tutorialBattles');
  static final GlobalKey rebirthPanel =
      GlobalKey(debugLabel: 'tutorialRebirth');

  static GlobalKey? keyFor(String? targetId) {
    switch (targetId) {
      case TutorialTargetIds.shopButton:
        return shopButton;
      case TutorialTargetIds.basicEggBuyButton:
        return basicEggBuyButton;
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
      case TutorialTargetIds.rebirthPanel:
        return rebirthPanel;
      default:
        return null;
    }
  }

  static Rect? measure(String? targetId, {double padding = 10}) {
    final key = keyFor(targetId);
    if (key == null) return null;
    return measureKey(key, padding: padding);
  }

  static Rect? measureKey(GlobalKey key, {double padding = 10}) {
    final context = key.currentContext;
    if (context == null) return null;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final offset = renderObject.localToGlobal(Offset.zero);
    final rect = offset & renderObject.size;
    return rect.inflate(padding);
  }
}
