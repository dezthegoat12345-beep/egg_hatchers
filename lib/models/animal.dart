import 'package:flutter/material.dart';

/// Rarity tiers for animals, from most to least common.
enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic;

  String get label {
    switch (this) {
      case Rarity.common:
        return 'Common';
      case Rarity.uncommon:
        return 'Uncommon';
      case Rarity.rare:
        return 'Rare';
      case Rarity.epic:
        return 'Epic';
      case Rarity.legendary:
        return 'Legendary';
      case Rarity.mythic:
        return 'Mythic';
    }
  }

  /// Display color for rarity badges and text.
  Color get color {
    switch (this) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.uncommon:
        return Colors.green;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.epic:
        return Colors.purple;
      case Rarity.legendary:
        return Colors.orange;
      case Rarity.mythic:
        return Colors.cyan;
    }
  }

  /// Higher sort values appear first in collection lists.
  int get sortOrder {
    switch (this) {
      case Rarity.mythic:
        return 6;
      case Rarity.legendary:
        return 5;
      case Rarity.epic:
        return 4;
      case Rarity.rare:
        return 3;
      case Rarity.uncommon:
        return 2;
      case Rarity.common:
        return 1;
    }
  }
}

/// A hatchable creature that generates coins over time.
class Animal {
  const Animal({
    required this.id,
    required this.name,
    required this.rarity,
    required this.coinsPerSecond,
    required this.emoji,
    this.spritePath,
  });

  final String id;
  final String name;
  final Rarity rarity;
  final int coinsPerSecond;
  final String emoji;

  /// Optional sprite asset path. Emoji is used when null or if load fails.
  final String? spritePath;
}
