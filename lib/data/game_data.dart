import 'dart:math';

import '../models/animal.dart';
import '../models/egg.dart';
import '../models/mutation.dart';
import '../models/player_state.dart';

/// Static game content: all animals, eggs, and helpers to look them up.
class GameData {
  GameData._();

  static const animals = <Animal>[
    // Basic Egg
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
    // Forest Egg
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
    // Magic Egg
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
    // Farm Egg
    Animal(
      id: 'cow',
      name: 'Cow',
      rarity: Rarity.uncommon,
      coinsPerSecond: 15,
      emoji: '🐮',
    ),
    Animal(
      id: 'pig',
      name: 'Pig',
      rarity: Rarity.uncommon,
      coinsPerSecond: 18,
      emoji: '🐷',
    ),
    Animal(
      id: 'sheep',
      name: 'Sheep',
      rarity: Rarity.rare,
      coinsPerSecond: 25,
      emoji: '🐑',
    ),
    Animal(
      id: 'horse',
      name: 'Horse',
      rarity: Rarity.rare,
      coinsPerSecond: 35,
      emoji: '🐴',
    ),
    // Jungle Egg
    Animal(
      id: 'monkey',
      name: 'Monkey',
      rarity: Rarity.rare,
      coinsPerSecond: 75,
      emoji: '🐵',
    ),
    Animal(
      id: 'parrot',
      name: 'Parrot',
      rarity: Rarity.rare,
      coinsPerSecond: 90,
      emoji: '🦜',
    ),
    Animal(
      id: 'snake',
      name: 'Snake',
      rarity: Rarity.epic,
      coinsPerSecond: 140,
      emoji: '🐍',
    ),
    Animal(
      id: 'gorilla',
      name: 'Gorilla',
      rarity: Rarity.epic,
      coinsPerSecond: 200,
      emoji: '🦍',
    ),
    // Ocean Egg
    Animal(
      id: 'fish',
      name: 'Fish',
      rarity: Rarity.rare,
      coinsPerSecond: 250,
      emoji: '🐟',
    ),
    Animal(
      id: 'turtle',
      name: 'Turtle',
      rarity: Rarity.epic,
      coinsPerSecond: 400,
      emoji: '🐢',
    ),
    Animal(
      id: 'dolphin',
      name: 'Dolphin',
      rarity: Rarity.epic,
      coinsPerSecond: 650,
      emoji: '🐬',
    ),
    Animal(
      id: 'shark',
      name: 'Shark',
      rarity: Rarity.legendary,
      coinsPerSecond: 1000,
      emoji: '🦈',
    ),
    // Arctic Egg
    Animal(
      id: 'penguin',
      name: 'Penguin',
      rarity: Rarity.epic,
      coinsPerSecond: 1500,
      emoji: '🐧',
    ),
    Animal(
      id: 'seal',
      name: 'Seal',
      rarity: Rarity.epic,
      coinsPerSecond: 2000,
      emoji: '🦭',
    ),
    Animal(
      id: 'polar_bear',
      name: 'Polar Bear',
      rarity: Rarity.legendary,
      coinsPerSecond: 3000,
      emoji: '🐻‍❄️',
    ),
    Animal(
      id: 'snow_owl',
      name: 'Snow Owl',
      rarity: Rarity.legendary,
      coinsPerSecond: 4000,
      emoji: '🦉',
    ),
    // Dino Egg
    Animal(
      id: 'raptor',
      name: 'Raptor',
      rarity: Rarity.epic,
      coinsPerSecond: 6000,
      emoji: '🦖',
    ),
    Animal(
      id: 'triceratops',
      name: 'Triceratops',
      rarity: Rarity.legendary,
      coinsPerSecond: 10000,
      emoji: '🦕',
    ),
    Animal(
      id: 't_rex',
      name: 'T-Rex',
      rarity: Rarity.legendary,
      coinsPerSecond: 15000,
      emoji: '🦖',
    ),
    Animal(
      id: 'fossil_dragon',
      name: 'Fossil Dragon',
      rarity: Rarity.mythic,
      coinsPerSecond: 25000,
      emoji: '🐉',
    ),
    // Space Egg
    Animal(
      id: 'moon_cat',
      name: 'Moon Cat',
      rarity: Rarity.legendary,
      coinsPerSecond: 50000,
      emoji: '🐱🌙',
    ),
    Animal(
      id: 'star_fox',
      name: 'Star Fox',
      rarity: Rarity.legendary,
      coinsPerSecond: 75000,
      emoji: '🦊⭐',
    ),
    Animal(
      id: 'alien_slime',
      name: 'Alien Slime',
      rarity: Rarity.mythic,
      coinsPerSecond: 125000,
      emoji: '👽',
    ),
    Animal(
      id: 'galaxy_dragon',
      name: 'Galaxy Dragon',
      rarity: Rarity.mythic,
      coinsPerSecond: 250000,
      emoji: '🐉🌌',
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

  /// Eggs in progression order (basic → endgame).
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
      unlockLifetimeCoins: 500,
    ),
    Egg(
      id: 'magic',
      name: 'Magic Egg',
      cost: 2000,
      possibleAnimalIds: ['tiger', 'dragon', 'unicorn'],
      emoji: '✨🥚',
      description: 'Legendary wonders',
      unlockLifetimeCoins: 5000,
    ),
    Egg(
      id: 'farm',
      name: 'Farm Egg',
      cost: 1000,
      possibleAnimalIds: ['cow', 'pig', 'sheep', 'horse'],
      emoji: '🚜🥚',
      description: 'Barnyard beasts',
      unlockLifetimeCoins: 1000,
    ),
    Egg(
      id: 'jungle',
      name: 'Jungle Egg',
      cost: 5000,
      possibleAnimalIds: ['monkey', 'parrot', 'snake', 'gorilla'],
      emoji: '🌴🥚',
      description: 'Wild jungle hunters',
      unlockLifetimeCoins: 10000,
    ),
    Egg(
      id: 'ocean',
      name: 'Ocean Egg',
      cost: 20000,
      possibleAnimalIds: ['fish', 'turtle', 'dolphin', 'shark'],
      emoji: '🌊🥚',
      description: 'Deep sea legends',
      unlockLifetimeCoins: 50000,
    ),
    Egg(
      id: 'arctic',
      name: 'Arctic Egg',
      cost: 75000,
      possibleAnimalIds: ['penguin', 'seal', 'polar_bear', 'snow_owl'],
      emoji: '❄️🥚',
      description: 'Frozen frontier friends',
      unlockLifetimeCoins: 150000,
    ),
    Egg(
      id: 'dino',
      name: 'Dino Egg',
      cost: 250000,
      possibleAnimalIds: ['raptor', 'triceratops', 't_rex', 'fossil_dragon'],
      emoji: '🦖🥚',
      description: 'Prehistoric power',
      unlockLifetimeCoins: 500000,
    ),
    Egg(
      id: 'space',
      name: 'Space Egg',
      cost: 1000000,
      possibleAnimalIds: ['moon_cat', 'star_fox', 'alien_slime', 'galaxy_dragon'],
      emoji: '🚀🥚',
      description: 'Cosmic creatures',
      unlockLifetimeCoins: 2000000,
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

  /// Sort owned animals by rarity, then base income, then name.
  static int compareOwnedAnimals(String animalIdA, String animalIdB) {
    final animalA = animalById(animalIdA);
    final animalB = animalById(animalIdB);
    if (animalA == null || animalB == null) {
      return animalIdA.compareTo(animalIdB);
    }

    final rarityCompare =
        animalB.rarity.sortOrder.compareTo(animalA.rarity.sortOrder);
    if (rarityCompare != 0) return rarityCompare;

    final incomeCompare =
        animalB.coinsPerSecond.compareTo(animalA.coinsPerSecond);
    if (incomeCompare != 0) return incomeCompare;

    return animalA.name.compareTo(animalB.name);
  }
}
