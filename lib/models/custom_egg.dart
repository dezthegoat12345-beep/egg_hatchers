import 'dart:convert';
import 'dart:math';

import '../data/game_data.dart';
import '../utils/custom_egg_logic.dart';
import 'egg.dart';

/// A player-created egg stored locally; not part of built-in game data.
class CustomEgg {
  const CustomEgg({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.selectedAnimalIds,
    this.animalWeights = const {},
    this.isEnabled = true,
  });

  static const int maxNameLength = 20;
  static const int maxSelectedAnimals = CustomEggLogic.maxSelectedAnimals;
  static const String idPrefix = 'custom_';

  final String id;
  final String name;
  final String emoji;
  final int cost;
  final List<String> selectedAnimalIds;
  final Map<String, int> animalWeights;
  final bool isEnabled;

  /// Animal ids that still exist in game data.
  List<String> get validAnimalIds => selectedAnimalIds
      .where((id) => GameData.animalById(id) != null)
      .toList();

  /// Valid animals the player has unlocked for custom eggs.
  List<String> hatchableAnimalIds(int lifetimeCoinsEarned) =>
      CustomEggLogic.hatchableAnimalIds(this, lifetimeCoinsEarned);

  bool get isValid => validAnimalIds.isNotEmpty;

  bool isShopValid(int lifetimeCoinsEarned) =>
      isEnabled && hatchableAnimalIds(lifetimeCoinsEarned).isNotEmpty;

  int minimumCostFor(int lifetimeCoinsEarned) =>
      CustomEggLogic.minimumCostForCustomEgg(
        this,
        lifetimeCoinsEarned: lifetimeCoinsEarned,
      );

  Egg toEgg({required int lifetimeCoinsEarned}) {
    final ids = hatchableAnimalIds(lifetimeCoinsEarned);
    final activeIds = ids.isNotEmpty ? ids : validAnimalIds;
    final count = activeIds.length;
    final summary = CustomEggLogic.formatChanceSummary(
      this,
      lifetimeCoinsEarned: lifetimeCoinsEarned,
    );
    final chanceText = summary.isNotEmpty ? ' · $summary' : '';
    return Egg(
      id: id,
      name: name,
      cost: cost,
      possibleAnimalIds: List<String>.from(activeIds),
      emoji: emoji.isNotEmpty ? emoji : '🥚',
      description: 'Custom egg · $count animal${count == 1 ? '' : 's'}$chanceText',
      unlockLifetimeCoins: 0,
    );
  }

  CustomEgg copyWith({
    String? name,
    String? emoji,
    int? cost,
    List<String>? selectedAnimalIds,
    Map<String, int>? animalWeights,
    bool? isEnabled,
    String? id,
  }) {
    return CustomEgg(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      cost: cost ?? this.cost,
      selectedAnimalIds: selectedAnimalIds ?? List.from(this.selectedAnimalIds),
      animalWeights: animalWeights ?? Map.from(this.animalWeights),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    final weights = <String, int>{};
    for (final id in selectedAnimalIds) {
      if (animalWeights.containsKey(id)) {
        weights[id] = animalWeights[id]!.clamp(
          CustomEggLogic.minWeight,
          CustomEggLogic.maxWeight,
        );
      }
    }

    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'cost': cost,
      'selectedAnimalIds': selectedAnimalIds,
      if (weights.isNotEmpty) 'animalWeights': weights,
      'isEnabled': isEnabled,
    };
  }

  factory CustomEgg.fromJson(Map<String, dynamic> json) {
    final selected = (json['selectedAnimalIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final weights = <String, int>{};
    final rawWeights = json['animalWeights'];
    if (rawWeights is Map) {
      for (final entry in rawWeights.entries) {
        final id = entry.key.toString();
        final w = (entry.value as num?)?.toInt() ?? 1;
        weights[id] = w.clamp(
          CustomEggLogic.minWeight,
          CustomEggLogic.maxWeight,
        );
      }
    }

    return CustomEgg(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'My Custom Egg',
      emoji: json['emoji'] as String? ?? '🥚',
      cost: (json['cost'] as num?)?.toInt() ?? 1000,
      selectedAnimalIds: selected,
      animalWeights: weights,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  static String generateUniqueId() {
    final random = Random().nextInt(900000) + 100000;
    return '$idPrefix${DateTime.now().millisecondsSinceEpoch}_$random';
  }

  static CustomEgg newDraft() {
    return CustomEgg(
      id: generateUniqueId(),
      name: 'My Custom Egg',
      emoji: '🥚',
      cost: 1000,
      selectedAnimalIds: const [],
      isEnabled: true,
    );
  }

  static List<CustomEgg> listFromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List<dynamic>) return [];

      final eggs = <CustomEgg>[];
      for (final item in decoded) {
        if (item is! Map) continue;

        try {
          final map = Map<String, dynamic>.from(item);
          final egg = CustomEgg.fromJson(map);
          if (egg.id.isNotEmpty) {
            eggs.add(egg);
          }
        } catch (_) {
          // Skip malformed entries; keep loading valid eggs.
        }
      }
      return eggs;
    } catch (_) {
      return [];
    }
  }

  static String listToJsonString(List<CustomEgg> eggs) {
    return jsonEncode(eggs.map((e) => e.toJson()).toList());
  }
}
