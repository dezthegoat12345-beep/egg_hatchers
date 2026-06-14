import '../models/quest.dart';

/// All quests available in the first version of the goals system.
class QuestData {
  QuestData._();

  static const List<Quest> all = [
    // Beginner Quests
    Quest(
      id: 'beginner_hatch_1',
      category: QuestCategory.beginner,
      title: 'Hatch Your First Egg',
      description: 'Buy and hatch any egg from the shop.',
      rewardCoins: 100,
      metric: QuestMetric.totalEggsHatched,
      target: 1,
    ),
    Quest(
      id: 'beginner_hatch_3',
      category: QuestCategory.beginner,
      title: 'Hatch 3 Eggs',
      description: 'Keep hatching — three eggs is a great start.',
      rewardCoins: 250,
      metric: QuestMetric.totalEggsHatched,
      target: 3,
    ),
    Quest(
      id: 'beginner_upgrade_1',
      category: QuestCategory.beginner,
      title: 'Upgrade Any Animal',
      description: 'Spend coins to level up one of your animals.',
      rewardCoins: 300,
      metric: QuestMetric.totalAnimalUpgrades,
      target: 1,
    ),
    Quest(
      id: 'beginner_luck_2',
      category: QuestCategory.beginner,
      title: 'Reach Luck Level 2',
      description: 'Upgrade your Luck on the Hatchery screen.',
      rewardCoins: 500,
      metric: QuestMetric.luckLevel,
      target: 2,
    ),

    // Regular Quests
    Quest(
      id: 'regular_hatch_25',
      category: QuestCategory.regular,
      title: 'Hatch 25 Eggs',
      description: 'Build your collection with steady hatching.',
      rewardCoins: 2000,
      metric: QuestMetric.totalEggsHatched,
      target: 25,
    ),
    Quest(
      id: 'regular_triple_1',
      category: QuestCategory.regular,
      title: 'Triple Hatch Once',
      description: 'Use Triple Hatch on any egg from the shop.',
      rewardCoins: 1000,
      metric: QuestMetric.totalTripleHatches,
      target: 1,
    ),
    Quest(
      id: 'regular_mutations_5',
      category: QuestCategory.regular,
      title: 'Hatch 5 Mutations',
      description: 'Golden, Rainbow, or Shadow — any mutation counts.',
      rewardCoins: 3000,
      metric: QuestMetric.totalMutationsHatched,
      target: 5,
    ),
    Quest(
      id: 'regular_luck_4',
      category: QuestCategory.regular,
      title: 'Reach Luck Level 4',
      description: 'Keep investing in Luck for better odds.',
      rewardCoins: 5000,
      metric: QuestMetric.luckLevel,
      target: 4,
    ),

    // Advanced Quests
    Quest(
      id: 'advanced_hatch_100',
      category: QuestCategory.advanced,
      title: 'Hatch 100 Eggs',
      description: 'You are becoming a true hatch master.',
      rewardCoins: 20000,
      metric: QuestMetric.totalEggsHatched,
      target: 100,
    ),
    Quest(
      id: 'advanced_rainbow_1',
      category: QuestCategory.advanced,
      title: 'Hatch a Rainbow Mutation',
      description: 'Find a rare Rainbow animal in any egg.',
      rewardCoins: 15000,
      metric: QuestMetric.totalRainbowHatched,
      target: 1,
    ),
    Quest(
      id: 'advanced_upgrades_25',
      category: QuestCategory.advanced,
      title: 'Upgrade Animals 25 Times',
      description: 'Level up your flock again and again.',
      rewardCoins: 30000,
      metric: QuestMetric.totalAnimalUpgrades,
      target: 25,
    ),
    Quest(
      id: 'advanced_lifetime_100k',
      category: QuestCategory.advanced,
      title: 'Earn 100,000 Lifetime Coins',
      description: 'Reach 100K total coins earned from animal income.',
      rewardCoins: 50000,
      metric: QuestMetric.lifetimeCoinsEarned,
      target: 100000,
    ),

    // Late Game Quests
    Quest(
      id: 'late_hatch_500',
      category: QuestCategory.lateGame,
      title: 'Hatch 500 Eggs',
      description: 'A legendary hatch count for dedicated players.',
      rewardCoins: 250000,
      metric: QuestMetric.totalEggsHatched,
      target: 500,
    ),
    Quest(
      id: 'late_shadow_1',
      category: QuestCategory.lateGame,
      title: 'Hatch a Shadow Mutation',
      description: 'Discover the ultra-rare Shadow mutation.',
      rewardCoins: 150000,
      metric: QuestMetric.totalShadowHatched,
      target: 1,
    ),
    Quest(
      id: 'late_luck_10',
      category: QuestCategory.lateGame,
      title: 'Reach Luck Level 10',
      description: 'Max out your Luck for the best mutation odds.',
      rewardCoins: 500000,
      metric: QuestMetric.luckLevel,
      target: 10,
    ),
    Quest(
      id: 'late_lifetime_1m',
      category: QuestCategory.lateGame,
      title: 'Earn 1,000,000 Lifetime Coins',
      description: 'Join the million-coin club from idle income.',
      rewardCoins: 1000000,
      metric: QuestMetric.lifetimeCoinsEarned,
      target: 1000000,
    ),

    // Custom Egg Quests
    Quest(
      id: 'custom_create_1',
      category: QuestCategory.customEgg,
      title: 'Create a Custom Egg',
      description: 'Design your own egg in the shop.',
      rewardCoins: 2500,
      metric: QuestMetric.totalCustomEggsCreated,
      target: 1,
    ),
    Quest(
      id: 'custom_hatch_10',
      category: QuestCategory.customEgg,
      title: 'Hatch 10 Eggs Total',
      description: 'Create a custom egg, then hatch 10 eggs in total.',
      rewardCoins: 5000,
      metric: QuestMetric.totalEggsHatched,
      target: 10,
      requiresCustomEggCreated: true,
    ),
    Quest(
      id: 'custom_triple_1',
      category: QuestCategory.customEgg,
      title: 'Triple Hatch a Custom Egg',
      description: 'Use Triple Hatch on one of your custom eggs.',
      rewardCoins: 10000,
      metric: QuestMetric.totalCustomTripleHatches,
      target: 1,
    ),
  ];

  static List<Quest> forCategory(QuestCategory category) =>
      all.where((quest) => quest.category == category).toList();

  static const categoryOrder = [
    QuestCategory.beginner,
    QuestCategory.regular,
    QuestCategory.advanced,
    QuestCategory.lateGame,
    QuestCategory.customEgg,
  ];
}
