import '../models/boss_battle.dart';

/// Tunable boss battle definitions.
class BossData {
  BossData._();

  static const bosses = <BossBattleDefinition>[
    BossBattleDefinition(
      id: 'slime_boss',
      name: 'Slime Boss',
      description: 'A wobbly starter boss.',
      emoji: '🟢',
      maxHp: 1000,
      recommendedPower: 100,
      coinReward: 2500,
      battleTokenReward: 1,
      unlockRequirementText: 'Hatch at least one animal',
    ),
    BossBattleDefinition(
      id: 'egg_golem',
      name: 'Egg Golem',
      description: 'A cracked guardian of rare eggs.',
      emoji: '🪨🥚',
      maxHp: 15000,
      recommendedPower: 1500,
      coinReward: 25000,
      battleTokenReward: 3,
      unlockRequirementText: 'Collect 10 unique base animals',
    ),
    BossBattleDefinition(
      id: 'shadow_rooster',
      name: 'Shadow Rooster',
      description: 'A dark champion from the secret coop.',
      emoji: '🌑🐓',
      maxHp: 150000,
      recommendedPower: 15000,
      coinReward: 250000,
      battleTokenReward: 8,
      unlockRequirementText:
          'Reach Rebirth Level 1 or collect 25 unique base animals',
    ),
  ];

  static BossBattleDefinition? bossById(String id) {
    for (final boss in bosses) {
      if (boss.id == id) return boss;
    }
    return null;
  }
}
