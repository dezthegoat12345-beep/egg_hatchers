import 'dart:math';

import '../models/animal.dart';
import '../models/egg.dart';
import '../models/mutation.dart';
import '../models/player_state.dart';

/// Static game content: all animals, eggs, and helpers to look them up.
class GameData {
  GameData._();

  static const animals = <Animal>[
    Animal(
      id: 'chicken',
      name: 'Chicken',
      rarity: Rarity.common,
      coinsPerSecond: 1,
      emoji: '🐔',
    ),
    Animal(
      id: 'mouse',
      name: 'Mouse',
      rarity: Rarity.common,
      coinsPerSecond: 2,
      emoji: '🐭',
    ),
    Animal(
      id: 'rabbit',
      name: 'Rabbit',
      rarity: Rarity.common,
      coinsPerSecond: 3,
      emoji: '🐰',
    ),
    Animal(
      id: 'fox',
      name: 'Fox',
      rarity: Rarity.uncommon,
      coinsPerSecond: 8,
      emoji: '🦊',
    ),
    Animal(
      id: 'deer',
      name: 'Deer',
      rarity: Rarity.uncommon,
      coinsPerSecond: 10,
      emoji: '🦌',
    ),
    Animal(
      id: 'bear',
      name: 'Bear',
      rarity: Rarity.rare,
      coinsPerSecond: 20,
      emoji: '🐻',
    ),
    Animal(
      id: 'tiger',
      name: 'Tiger',
      rarity: Rarity.epic,
      coinsPerSecond: 50,
      emoji: '🐯',
    ),
    Animal(
      id: 'dragon',
      name: 'Dragon',
      rarity: Rarity.legendary,
      coinsPerSecond: 100,
      emoji: '🐉',
    ),
    Animal(
      id: 'unicorn',
      name: 'Unicorn',
      rarity: Rarity.legendary,
      coinsPerSecond: 120,
      emoji: '🦄',
    ),
  ];

  static const mutations = <Mutation>[
    Mutation(
      id: 'none',
      displayName: 'Normal',
      chance: 85,
      incomeMultiplier: 1,
    ),
    Mutation(
      id: 'golden',
      displayName: 'Golden',
      chance: 10,
      incomeMultiplier: 2,
      icon: '✨',
      prefix: 'Golden',
    ),
    Mutation(
      id: 'rainbow',
      displayName: 'Rainbow',
      chance: 4,
      incomeMultiplier: 5,
      icon: '🌈',
      prefix: 'Rainbow',
    ),
    Mutation(
      id: 'shadow',
      displayName: 'Shadow',
      chance: 1,
      incomeMultiplier: 10,
      icon: '🌑',
      prefix: 'Shadow',
    ),
  ];

  static const eggs = <Egg>[
    Egg(
      id: 'basic',
      name: 'Basic Egg',
      cost: 100,
      possibleAnimalIds: ['chicken', 'mouse', 'rabbit'],
      emoji: '🥚',
      description: 'Common farm friends',
    ),
    Egg(
      id: 'forest',
      name: 'Forest Egg',
      cost: 500,
      possibleAnimalIds: ['fox', 'deer', 'bear'],
      emoji: '🌲🥚',
      description: 'Woodland creatures',
    ),
    Egg(
      id: 'magic',
      name: 'Magic Egg',
      cost: 2000,
      possibleAnimalIds: ['tiger', 'dragon', 'unicorn'],
      emoji: '✨🥚',
      description: 'Legendary wonders',
    ),
  ];

  static PlayerState startingPlayerState() => PlayerState.initial();

  static Animal? animalById(String id) {
    for (final animal in animals) {
      if (animal.id == id) return animal;
    }
    return null;
  }

  static Egg? eggById(String id) {
    for (final egg in eggs) {
      if (egg.id == id) return egg;
    }
    return null;
  }

  static Mutation? mutationById(String id) {
    for (final mutation in mutations) {
      if (mutation.id == id) return mutation;
    }
    return null;
  }

  /// Roll a mutation using weighted chances (85/10/4/1).
  static Mutation rollMutation(Random random) {
    final roll = random.nextInt(100);
    var cumulative = 0;
    for (final mutation in mutations) {
      cumulative += mutation.chance;
      if (roll < cumulative) return mutation;
    }
    return mutations.first;
  }
}

/// Type alias helper to avoid importing owned_animal in game_data callers.
typedef OwnedAnimalRef = String;

