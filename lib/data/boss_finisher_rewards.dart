import 'dart:math';

import 'package:flutter/material.dart';

import '../models/boss_battle.dart';
import '../models/finisher_reward.dart';

class _FinisherTableEntry {
  const _FinisherTableEntry({
    required this.weight,
    this.coins = 0,
    this.tokens = 0,
    required this.message,
  });

  final double weight;
  final int coins;
  final int tokens;
  final String message;
}

/// Boss-specific finisher slash bonus rolls and visual styling.
class BossFinisherRewards {
  BossFinisherRewards._();

  static const slashMinDistance = 55.0;
  static const slashRewardCooldownMs = 280;
  static const slashWindowSeconds = 5.0;
  static const rewardGateChance = 0.50;
  static const maxBonusRollsNormal = 6;
  static const maxBonusRollsElite = 8;

  static int maxBonusRolls(BossBattleDefinition boss) =>
      boss.isEliteBoss ? maxBonusRollsElite : maxBonusRollsNormal;

  /// True when a valid slash passes the 50/50 bonus gate.
  static bool passesRewardGate(Random random) =>
      random.nextDouble() < rewardGateChance;

  /// Lightweight flavor text when the bonus gate fails.
  static String noRewardMessageFor(String bossId) {
    if (isBirdBoss(bossId)) return 'Feathers!';
    switch (bossId) {
      case 'slime_boss':
        return 'Splat!';
      case 'egg_golem':
        return 'Clank!';
      case 'slime_king':
        return 'Royal Splat!';
      case 'egg_guardian':
        return 'Spark!';
      case 'shadow_phoenix':
        return 'Smoke!';
      default:
        return 'Slash!';
    }
  }

  static bool isBirdBoss(String bossId) =>
      bossId == 'shadow_rooster' ||
      bossId == 'night_rooster' ||
      bossId == 'night_crow';

  static FinisherSlashRoll rollBonus(String bossId, Random random) {
    final table = _tableFor(bossId);
    final roll = random.nextDouble();
    var cumulative = 0.0;
    for (final entry in table) {
      cumulative += entry.weight;
      if (roll <= cumulative) {
        return FinisherSlashRoll(
          coins: entry.coins,
          tokens: entry.tokens,
          message: entry.message,
        );
      }
    }
    final last = table.last;
    return FinisherSlashRoll(
      coins: last.coins,
      tokens: last.tokens,
      message: last.message,
    );
  }

  static List<_FinisherTableEntry> _tableFor(String bossId) {
    if (isBirdBoss(bossId)) return _birdTable;
    switch (bossId) {
      case 'slime_boss':
        return _slimeTable;
      case 'egg_golem':
        return _golemTable;
      case 'slime_king':
        return _slimeKingTable;
      case 'egg_guardian':
        return _guardianTable;
      case 'shadow_phoenix':
        return _phoenixTable;
      default:
        return _birdTable;
    }
  }

  static const _slimeTable = [
    _FinisherTableEntry(weight: 0.55, coins: 30, message: '+30 coins'),
    _FinisherTableEntry(weight: 0.25, coins: 80, message: '+80 coins'),
    _FinisherTableEntry(weight: 0.10, tokens: 1, message: '+1 Battle Token'),
    _FinisherTableEntry(weight: 0.10, message: 'Splat!'),
  ];

  static const _golemTable = [
    _FinisherTableEntry(weight: 0.45, coins: 120, message: '+120 coins'),
    _FinisherTableEntry(weight: 0.30, tokens: 1, message: '+1 Battle Token'),
    _FinisherTableEntry(weight: 0.15, tokens: 2, message: '+2 Battle Tokens'),
    _FinisherTableEntry(weight: 0.10, message: 'Rubble!'),
  ];

  static const _birdTable = [
    _FinisherTableEntry(weight: 0.45, coins: 150, message: '+150 coins'),
    _FinisherTableEntry(weight: 0.25, tokens: 1, message: '+1 Battle Token'),
    _FinisherTableEntry(weight: 0.15, tokens: 2, message: '+2 Battle Tokens'),
    _FinisherTableEntry(weight: 0.15, message: 'Feathers!'),
  ];

  static const _slimeKingTable = [
    _FinisherTableEntry(weight: 0.35, coins: 200, message: '+200 coins'),
    _FinisherTableEntry(weight: 0.35, tokens: 2, message: '+2 Battle Tokens'),
    _FinisherTableEntry(weight: 0.15, tokens: 4, message: '+4 Battle Tokens'),
    _FinisherTableEntry(weight: 0.15, message: 'Royal Goo!'),
  ];

  static const _guardianTable = [
    _FinisherTableEntry(weight: 0.30, coins: 250, message: '+250 coins'),
    _FinisherTableEntry(weight: 0.35, tokens: 2, message: '+2 Battle Tokens'),
    _FinisherTableEntry(weight: 0.20, tokens: 4, message: '+4 Battle Tokens'),
    _FinisherTableEntry(weight: 0.15, message: 'Ancient Shard!'),
  ];

  static const _phoenixTable = [
    _FinisherTableEntry(weight: 0.25, coins: 350, message: '+350 coins'),
    _FinisherTableEntry(weight: 0.35, tokens: 2, message: '+2 Battle Tokens'),
    _FinisherTableEntry(weight: 0.25, tokens: 5, message: '+5 Battle Tokens'),
    _FinisherTableEntry(weight: 0.15, message: 'Shadow Feather!'),
  ];

  static FinisherSlashStyle styleFor(String bossId) {
    if (bossId == 'slime_boss' || bossId == 'slime_king') {
      return const FinisherSlashStyle(
        slashColor: Color(0xFF66BB6A),
        sparkColor: Color(0xFF43A047),
        particleColor: Color(0xFF81C784),
      );
    }
    if (bossId == 'egg_golem') {
      return const FinisherSlashStyle(
        slashColor: Color(0xFFFFD54F),
        sparkColor: Color(0xFF42A5F5),
        particleColor: Color(0xFF90CAF9),
      );
    }
    if (isBirdBoss(bossId)) {
      return const FinisherSlashStyle(
        slashColor: Color(0xFFCE93D8),
        sparkColor: Color(0xFFAB47BC),
        particleColor: Color(0xFFBA68C8),
      );
    }
    if (bossId == 'egg_guardian') {
      return const FinisherSlashStyle(
        slashColor: Color(0xFF64B5F6),
        sparkColor: Color(0xFFFFD54F),
        particleColor: Color(0xFF4FC3F7),
      );
    }
    if (bossId == 'shadow_phoenix') {
      return const FinisherSlashStyle(
        slashColor: Color(0xFFEF5350),
        sparkColor: Color(0xFF7E57C2),
        particleColor: Color(0xFF9575CD),
      );
    }
    return const FinisherSlashStyle(
      slashColor: Color(0xFFFFF176),
      sparkColor: Color(0xFFFFEE58),
      particleColor: Colors.white,
    );
  }
}

class FinisherSlashStyle {
  const FinisherSlashStyle({
    required this.slashColor,
    required this.sparkColor,
    required this.particleColor,
  });

  final Color slashColor;
  final Color sparkColor;
  final Color particleColor;
}
