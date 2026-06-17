import '../navigation/app_page_route.dart';

/// Tutorial v2 guided spotlight step definitions.
class TutorialData {
  TutorialData._();

  static const currentVersion = 2;

  static const welcomeTitle = 'Welcome to Egg Hatchers!';

  static const finishText =
      "You're ready! Keep hatching, upgrading, battling, and discovering secrets.";

  static const finishButtonLabel = 'Start Hatching!';

  static const steps = <GuidedTutorialStep>[
    GuidedTutorialStep(
      id: 'shop',
      text: 'Click the shop button!',
      targetId: TutorialTargetIds.shopButton,
      requiresTargetTap: true,
      advanceOnRoute: kShopRouteName,
    ),
    GuidedTutorialStep(
      id: 'buyEgg',
      text: 'Buy your first egg!',
      targetId: TutorialTargetIds.basicEggBuyButton,
      fallbackText: 'This is where you buy eggs.',
      requiresTargetTap: true,
      advanceOnAction: TutorialAction.eggPurchased,
      requiredRoute: kShopRouteName,
    ),
    GuidedTutorialStep(
      id: 'hatch',
      text: 'Now hatch your egg!',
      fallbackText: 'Eggs hatch into animals that earn coins.',
      manualNext: true,
    ),
    GuidedTutorialStep(
      id: 'animalIncome',
      text: 'Animals earn coins over time!',
      targetId: TutorialTargetIds.animalsSection,
      manualNext: true,
      requiredRoute: kHatcheryRouteName,
    ),
    GuidedTutorialStep(
      id: 'upgrade',
      text: 'Upgrade animals to make more coins!',
      targetId: TutorialTargetIds.upgradeButton,
      fallbackText: 'This button upgrades animals when you have enough coins.',
      requiresTargetTap: true,
      advanceOnAction: TutorialAction.animalUpgraded,
      requiredRoute: kHatcheryRouteName,
    ),
    GuidedTutorialStep(
      id: 'collection',
      text: "Open your Collection to see what you've found!",
      targetId: TutorialTargetIds.collectionButton,
      requiresTargetTap: true,
      advanceOnRoute: kCollectionRouteName,
      requiredRoute: kHatcheryRouteName,
    ),
    GuidedTutorialStep(
      id: 'quests',
      text: 'Quests give extra rewards!',
      targetId: TutorialTargetIds.questsButton,
      requiresTargetTap: true,
      advanceOnRoute: kQuestsRouteName,
      requiredRoute: kHatcheryRouteName,
    ),
    GuidedTutorialStep(
      id: 'battles',
      text: 'Battle bosses for special rewards!',
      targetId: TutorialTargetIds.battlesButton,
      requiresTargetTap: true,
      advanceOnRoute: kBattlesRouteName,
      requiredRoute: kHatcheryRouteName,
    ),
    GuidedTutorialStep(
      id: 'rebirth',
      text: 'Later, Rebirth gives a permanent income boost!',
      targetId: TutorialTargetIds.rebirthPanel,
      fallbackText: 'Rebirth unlocks after earning enough lifetime coins.',
      manualNext: true,
      requiredRoute: kHatcheryRouteName,
    ),
    GuidedTutorialStep(
      id: 'finish',
      text: finishText,
      manualNext: true,
      isFinish: true,
    ),
  ];
}

/// Global tutorial target identifiers.
class TutorialTargetIds {
  TutorialTargetIds._();

  static const shopButton = 'shopButton';
  static const basicEggBuyButton = 'basicEggBuyButton';
  static const animalsSection = 'animalsSection';
  static const upgradeButton = 'upgradeButton';
  static const collectionButton = 'collectionButton';
  static const questsButton = 'questsButton';
  static const battlesButton = 'battlesButton';
  static const rebirthPanel = 'rebirthPanel';
}

enum TutorialAction { eggPurchased, animalUpgraded }

class GuidedTutorialStep {
  const GuidedTutorialStep({
    required this.id,
    required this.text,
    this.targetId,
    this.fallbackText,
    this.manualNext = false,
    this.requiresTargetTap = false,
    this.advanceOnRoute,
    this.advanceOnAction,
    this.requiredRoute,
    this.isFinish = false,
  });

  final String id;
  final String text;
  final String? targetId;
  final String? fallbackText;
  final bool manualNext;
  final bool requiresTargetTap;
  final String? advanceOnRoute;
  final TutorialAction? advanceOnAction;
  final String? requiredRoute;
  final bool isFinish;

  bool get allowsManualNext =>
      manualNext || fallbackText != null || targetId == null;
}
