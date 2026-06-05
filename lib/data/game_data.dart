import '../models/animal.dart';
import '../models/egg.dart';
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
}
