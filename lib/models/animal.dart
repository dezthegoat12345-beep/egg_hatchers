import 'package:flutter/material.dart';

/// Rarity tiers for animals, from most to least common.
enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

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
  });

  final String id;
  final String name;
  final Rarity rarity;
  final int coinsPerSecond;
  final String emoji;
}
