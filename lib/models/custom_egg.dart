import 'dart:convert';

import '../data/game_data.dart';
import 'egg.dart';

/// A player-created egg stored locally; not part of built-in game data.
class CustomEgg {
  const CustomEgg({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.selectedAnimalIds,
    this.isEnabled = true,
  });

  static const int maxNameLength = 20;
  static const String idPrefix = 'custom_';

  final String id;
  final String name;
  final String emoji;
  final int cost;
  final List<String> selectedAnimalIds;
  final bool isEnabled;

  /// Animal ids that still exist in game data.
  List<String> get validAnimalIds => selectedAnimalIds
      .where((id) => GameData.animalById(id) != null)
      .toList();

  bool get isValid => validAnimalIds.isNotEmpty;

  Egg toEgg() {
    final count = validAnimalIds.length;
    return Egg(
      id: id,
      name: name,
      cost: cost,
      possibleAnimalIds: List<String>.from(validAnimalIds),
      emoji: emoji.isNotEmpty ? emoji : '🥚',
      description: 'Custom egg · $count animal${count == 1 ? '' : 's'}',
      unlockLifetimeCoins: 0,
    );
  }

  CustomEgg copyWith({
    String? name,
    String? emoji,
    int? cost,
    List<String>? selectedAnimalIds,
    bool? isEnabled,
  }) {
    return CustomEgg(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      cost: cost ?? this.cost,
      selectedAnimalIds: selectedAnimalIds ?? List.from(this.selectedAnimalIds),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'cost': cost,
        'selectedAnimalIds': selectedAnimalIds,
        'isEnabled': isEnabled,
      };

  factory CustomEgg.fromJson(Map<String, dynamic> json) {
    return CustomEgg(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'My Custom Egg',
      emoji: json['emoji'] as String? ?? '🥚',
      cost: (json['cost'] as num?)?.toInt() ?? 1000,
      selectedAnimalIds: (json['selectedAnimalIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  static CustomEgg newDraft() {
    return CustomEgg(
      id: '$idPrefix${DateTime.now().millisecondsSinceEpoch}',
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
