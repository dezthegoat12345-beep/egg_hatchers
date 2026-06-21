import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/boss_data.dart';
import 'package:egg_hatchers/data/boss_finisher_rewards.dart';

void main() {
  test('reward gate passes roughly half the time', () {
    final random = Random(99);
    var passes = 0;
    for (var i = 0; i < 1000; i++) {
      if (BossFinisherRewards.passesRewardGate(random)) passes++;
    }
    expect(passes, inInclusiveRange(400, 600));
  });

  test('no-reward messages are boss-specific', () {
    expect(BossFinisherRewards.noRewardMessageFor('slime_boss'), 'Splat!');
    expect(BossFinisherRewards.noRewardMessageFor('egg_golem'), 'Clank!');
    expect(BossFinisherRewards.noRewardMessageFor('shadow_phoenix'), 'Smoke!');
  });

  test('finisher bonus roll produces mixed outcomes', () {
    final random = Random(42);
    var withReward = 0;
    for (var i = 0; i < 200; i++) {
      final roll = BossFinisherRewards.rollBonus('slime_boss', random);
      if (roll.grantsReward) withReward++;
    }
    expect(withReward, greaterThan(50));
    expect(withReward, lessThanOrEqualTo(190));
  });

  test('normal and elite bosses have different finisher roll caps', () {
    final slime = BossData.bossById('slime_boss')!;
    final slimeKing = BossData.bossById('slime_king')!;
    expect(BossFinisherRewards.maxBonusRolls(slime), 6);
    expect(BossFinisherRewards.maxBonusRolls(slimeKing), 8);
  });

  test('bird boss table used for shadow rooster', () {
    final roll = BossFinisherRewards.rollBonus(
      'shadow_rooster',
      Random(1),
    );
    expect(roll.message, isNotEmpty);
  });
}
