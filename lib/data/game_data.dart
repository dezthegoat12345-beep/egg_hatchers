import 'dart:math';

import '../models/animal.dart';
import '../models/egg.dart';
import '../models/mutation.dart';
import '../models/player_state.dart';
import '../utils/luck_logic.dart';

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
      spritePath: 'assets/images/animals/chicken.png',
    ),
    Animal(
      id: 'mouse',
      name: 'Mouse',
      rarity: Rarity.common,
      coinsPerSecond: 2,
      emoji: '🐭',
      spritePath: 'assets/images/animals/mouse.png',
    ),
    Animal(
      id: 'rabbit',
      name: 'Rabbit',
      rarity: Rarity.common,
      coinsPerSecond: 3,
      emoji: '🐰',
      spritePath: 'assets/images/animals/rabbit.png',
    ),
    // Forest Egg
    Animal(
      id: 'fox',
      name: 'Fox',
      rarity: Rarity.uncommon,
      coinsPerSecond: 8,
      emoji: '🦊',
      spritePath: 'assets/images/animals/fox.png',
    ),
    Animal(
      id: 'deer',
      name: 'Deer',
      rarity: Rarity.uncommon,
      coinsPerSecond: 10,
      emoji: '🦌',
      spritePath: 'assets/images/animals/deer.png',
    ),
    Animal(
      id: 'bear',
      name: 'Bear',
      rarity: Rarity.rare,
      coinsPerSecond: 20,
      emoji: '🐻',
      spritePath: 'assets/images/animals/bear.png',
    ),
    // Magic Egg
    Animal(
      id: 'tiger',
      name: 'Tiger',
      rarity: Rarity.epic,
      coinsPerSecond: 50,
      emoji: '🐯',
      spritePath: 'assets/images/animals/tiger.png',
    ),
    Animal(
      id: 'dragon',
      name: 'Dragon',
      rarity: Rarity.legendary,
      coinsPerSecond: 100,
      emoji: '🐉',
      spritePath: 'assets/images/animals/dragon.png',
    ),
    Animal(
      id: 'unicorn',
      name: 'Unicorn',
      rarity: Rarity.legendary,
      coinsPerSecond: 120,
      emoji: '🦄',
      spritePath: 'assets/images/animals/unicorn.png',
    ),
    // Farm Egg
    Animal(
      id: 'cow',
      name: 'Cow',
      rarity: Rarity.uncommon,
      coinsPerSecond: 15,
      emoji: '🐮',
      spritePath: 'assets/images/animals/cow.png',
    ),
    Animal(
      id: 'pig',
      name: 'Pig',
      rarity: Rarity.uncommon,
      coinsPerSecond: 18,
      emoji: '🐷',
      spritePath: 'assets/images/animals/pig.png',
    ),
    Animal(
      id: 'sheep',
      name: 'Sheep',
      rarity: Rarity.rare,
      coinsPerSecond: 25,
      emoji: '🐑',
      spritePath: 'assets/images/animals/sheep.png',
    ),
    Animal(
      id: 'horse',
      name: 'Horse',
      rarity: Rarity.rare,
      coinsPerSecond: 35,
      emoji: '🐴',
      spritePath: 'assets/images/animals/horse.png',
    ),
    // Jungle Egg
    Animal(
      id: 'monkey',
      name: 'Monkey',
      rarity: Rarity.rare,
      coinsPerSecond: 75,
      emoji: '🐵',
      spritePath: 'assets/images/animals/monkey.png',
    ),
    Animal(
      id: 'parrot',
      name: 'Parrot',
      rarity: Rarity.rare,
      coinsPerSecond: 90,
      emoji: '🦜',
      spritePath: 'assets/images/animals/parrot.png',
    ),
    Animal(
      id: 'snake',
      name: 'Snake',
      rarity: Rarity.epic,
      coinsPerSecond: 140,
      emoji: '🐍',
      spritePath: 'assets/images/animals/snake.png',
    ),
    Animal(
      id: 'gorilla',
      name: 'Gorilla',
      rarity: Rarity.epic,
      coinsPerSecond: 200,
      emoji: '🦍',
      spritePath: 'assets/images/animals/gorilla.png',
    ),
    // Ocean Egg
    Animal(
      id: 'fish',
      name: 'Fish',
      rarity: Rarity.rare,
      coinsPerSecond: 250,
      emoji: '🐟',
      spritePath: 'assets/images/animals/fish.png',
    ),
    Animal(
      id: 'turtle',
      name: 'Turtle',
      rarity: Rarity.epic,
      coinsPerSecond: 400,
      emoji: '🐢',
      spritePath: 'assets/images/animals/turtle.png',
    ),
    Animal(
      id: 'dolphin',
      name: 'Dolphin',
      rarity: Rarity.epic,
      coinsPerSecond: 650,
      emoji: '🐬',
      spritePath: 'assets/images/animals/dolphin.png',
    ),
    Animal(
      id: 'shark',
      name: 'Shark',
      rarity: Rarity.legendary,
      coinsPerSecond: 1000,
      emoji: '🦈',
      spritePath: 'assets/images/animals/shark.png',
    ),
    // Arctic Egg
    Animal(
      id: 'penguin',
      name: 'Penguin',
      rarity: Rarity.epic,
      coinsPerSecond: 1500,
      emoji: '🐧',
      spritePath: 'assets/images/animals/penguin.png',
    ),
    Animal(
      id: 'seal',
      name: 'Seal',
      rarity: Rarity.epic,
      coinsPerSecond: 2000,
      emoji: '🦭',
      spritePath: 'assets/images/animals/seal.png',
    ),
    Animal(
      id: 'polar_bear',
      name: 'Polar Bear',
      rarity: Rarity.legendary,
      coinsPerSecond: 3000,
      emoji: '🐻‍❄️',
      spritePath: 'assets/images/animals/polar_bear.png',
    ),
    Animal(
      id: 'snow_owl',
      name: 'Snow Owl',
      rarity: Rarity.legendary,
      coinsPerSecond: 4000,
      emoji: '🦉',
      spritePath: 'assets/images/animals/snow_owl.png',
    ),
    // Dino Egg
    Animal(
      id: 'raptor',
      name: 'Raptor',
      rarity: Rarity.epic,
      coinsPerSecond: 6000,
      emoji: '🦖',
      spritePath: 'assets/images/animals/raptor.png',
    ),
    Animal(
      id: 'triceratops',
      name: 'Triceratops',
      rarity: Rarity.legendary,
      coinsPerSecond: 10000,
      emoji: '🦕',
      spritePath: 'assets/images/animals/triceratops.png',
    ),
    Animal(
      id: 't_rex',
      name: 'T-Rex',
      rarity: Rarity.legendary,
      coinsPerSecond: 15000,
      emoji: '🦖',
      spritePath: 'assets/images/animals/t_rex.png',
    ),
    Animal(
      id: 'fossil_dragon',
      name: 'Fossil Dragon',
      rarity: Rarity.mythic,
      coinsPerSecond: 25000,
      emoji: '🐉',
      spritePath: 'assets/images/animals/fossil_dragon.png',
    ),
    // Space Egg
    Animal(
      id: 'moon_cat',
      name: 'Moon Cat',
      rarity: Rarity.legendary,
      coinsPerSecond: 50000,
      emoji: '🐱🌙',
      spritePath: 'assets/images/animals/moon_cat.png',
    ),
    Animal(
      id: 'star_fox',
      name: 'Star Fox',
      rarity: Rarity.legendary,
      coinsPerSecond: 75000,
      emoji: '🦊⭐',
      spritePath: 'assets/images/animals/star_fox.png',
    ),
    Animal(
      id: 'alien_slime',
      name: 'Alien Slime',
      rarity: Rarity.mythic,
      coinsPerSecond: 125000,
      emoji: '👽',
      spritePath: 'assets/images/animals/alien_slime.png',
    ),
    Animal(
      id: 'galaxy_dragon',
      name: 'Galaxy Dragon',
      rarity: Rarity.mythic,
      coinsPerSecond: 250000,
      emoji: '🐉🌌',
      spritePath: 'assets/images/animals/galaxy_dragon.png',
    ),
  ];

  static const mutations = <Mutation>[
    Mutation(
      id: 'none',
      displayName: 'Normal',
      chance: 70,
      incomeMultiplier: 1,
    ),
    Mutation(
      id: 'golden',
      displayName: 'Golden',
      chance: 20,
      incomeMultiplier: 2,
      icon: '✨',
      prefix: 'Golden',
    ),
    Mutation(
      id: 'rainbow',
      displayName: 'Rainbow',
      chance: 8,
      incomeMultiplier: 5,
      icon: '🌈',
      prefix: 'Rainbow',
    ),
    Mutation(
      id: 'shadow',
      displayName: 'Shadow',
      chance: 2,
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
      spritePath: 'assets/images/eggs/basic_egg.png',
    ),
    Egg(
      id: 'forest',
      name: 'Forest Egg',
      cost: 400,
      possibleAnimalIds: ['fox', 'deer', 'bear'],
      emoji: '🌲🥚',
      description: 'Woodland creatures',
      unlockLifetimeCoins: 300,
      spritePath: 'assets/images/eggs/forest_egg.png',
    ),
    Egg(
      id: 'farm',
      name: 'Farm Egg',
      cost: 800,
      possibleAnimalIds: ['cow', 'pig', 'sheep', 'horse'],
      emoji: '🚜🥚',
      description: 'Barnyard beasts',
      unlockLifetimeCoins: 750,
      spritePath: 'assets/images/eggs/farm_egg.png',
    ),
    Egg(
      id: 'magic',
      name: 'Magic Egg',
      cost: 1500,
      possibleAnimalIds: ['tiger', 'dragon', 'unicorn'],
      emoji: '✨🥚',
      description: 'Legendary wonders',
      unlockLifetimeCoins: 2500,
      spritePath: 'assets/images/eggs/magic_egg.png',
    ),
    Egg(
      id: 'jungle',
      name: 'Jungle Egg',
      cost: 3500,
      possibleAnimalIds: ['monkey', 'parrot', 'snake', 'gorilla'],
      emoji: '🌴🥚',
      description: 'Wild jungle hunters',
      unlockLifetimeCoins: 5000,
      spritePath: 'assets/images/eggs/jungle_egg.png',
    ),
    Egg(
      id: 'ocean',
      name: 'Ocean Egg',
      cost: 12000,
      possibleAnimalIds: ['fish', 'turtle', 'dolphin', 'shark'],
      emoji: '🌊🥚',
      description: 'Deep sea legends',
      unlockLifetimeCoins: 20000,
      spritePath: 'assets/images/eggs/ocean_egg.png',
    ),
    Egg(
      id: 'arctic',
      name: 'Arctic Egg',
      cost: 40000,
      possibleAnimalIds: ['penguin', 'seal', 'polar_bear', 'snow_owl'],
      emoji: '❄️🥚',
      description: 'Frozen frontier friends',
      unlockLifetimeCoins: 75000,
      spritePath: 'assets/images/eggs/arctic_egg.png',
    ),
    Egg(
      id: 'dino',
      name: 'Dino Egg',
      cost: 125000,
      possibleAnimalIds: ['raptor', 'triceratops', 't_rex', 'fossil_dragon'],
      emoji: '🦖🥚',
      description: 'Prehistoric power',
      unlockLifetimeCoins: 200000,
      spritePath: 'assets/images/eggs/dino_egg.png',
    ),
    Egg(
      id: 'space',
      name: 'Space Egg',
      cost: 500000,
      possibleAnimalIds: ['moon_cat', 'star_fox', 'alien_slime', 'galaxy_dragon'],
      emoji: '🚀🥚',
      description: 'Cosmic creatures',
      unlockLifetimeCoins: 750000,
      spritePath: 'assets/images/eggs/space_egg.png',
    ),
  ];

  static PlayerState startingPlayerState() => PlayerState.initial();

  /// First built-in egg in progression order that can hatch [animalId].
  static Egg? progressionEggForAnimal(String animalId) {
    for (final egg in eggs) {
      if (egg.possibleAnimalIds.contains(animalId)) return egg;
    }
    return null;
  }

  /// Lower values sort earlier (basic → endgame). Unknown animals sort last.
  static int progressionIndexForAnimal(String animalId) {
    for (var eggIndex = 0; eggIndex < eggs.length; eggIndex++) {
      final slot = eggs[eggIndex].possibleAnimalIds.indexOf(animalId);
      if (slot >= 0) return eggIndex * 100 + slot;
    }
    return 99999;
  }

  /// All animals ordered by built-in egg progression.
  static final List<Animal> animalsInProgressionOrder =
      _buildAnimalsInProgressionOrder();

  static List<Animal> _buildAnimalsInProgressionOrder() {
    final seen = <String>{};
    final ordered = <Animal>[];

    for (final egg in eggs) {
      for (final animalId in egg.possibleAnimalIds) {
        if (!seen.add(animalId)) continue;
        final animal = animalById(animalId);
        if (animal != null) ordered.add(animal);
      }
    }

    for (final animal in animals) {
      if (seen.add(animal.id)) ordered.add(animal);
    }

    return ordered;
  }

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

  /// Roll a mutation using base chances (Luck Level 1).
  static Mutation rollMutation(Random random) {
    return LuckLogic.rollMutation(random, LuckLogic.minLevel);
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
