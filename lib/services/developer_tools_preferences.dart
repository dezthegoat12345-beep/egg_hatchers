import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_data.dart';
import '../models/forced_hatch_result.dart';

/// Persists last-used Developer Tools forced hatch slot selections.
class DeveloperToolsPreferences {
  DeveloperToolsPreferences._();

  static const _slot1AnimalKey = 'devForceSlot1AnimalId';
  static const _slot1MutationKey = 'devForceSlot1MutationId';
  static const _slot2AnimalKey = 'devForceSlot2AnimalId';
  static const _slot2MutationKey = 'devForceSlot2MutationId';
  static const _slot3AnimalKey = 'devForceSlot3AnimalId';
  static const _slot3MutationKey = 'devForceSlot3MutationId';

  static String get defaultAnimalId => GameData.animals.first.id;
  static String get defaultMutationId => 'none';

  static Future<DevForceSlotSelections> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DevForceSlotSelections(
      slot1: _readSlot(
        prefs.getString(_slot1AnimalKey),
        prefs.getString(_slot1MutationKey),
      ),
      slot2: _readSlot(
        prefs.getString(_slot2AnimalKey),
        prefs.getString(_slot2MutationKey),
      ),
      slot3: _readSlot(
        prefs.getString(_slot3AnimalKey),
        prefs.getString(_slot3MutationKey),
      ),
    );
  }

  static DevForceSlotSelection _readSlot(
    String? animalId,
    String? mutationId,
  ) {
    return DevForceSlotSelection(
      animalId: _validAnimalId(animalId),
      mutationId: _validMutationId(mutationId),
    );
  }

  static String _validAnimalId(String? id) {
    if (id != null && GameData.animalById(id) != null) return id;
    return defaultAnimalId;
  }

  static String _validMutationId(String? id) {
    if (id != null && GameData.mutationById(id) != null) return id;
    return defaultMutationId;
  }

  static Future<void> saveSlots(DevForceSlotSelections selections) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_slot1AnimalKey, selections.slot1.animalId);
    await prefs.setString(_slot1MutationKey, selections.slot1.mutationId);
    await prefs.setString(_slot2AnimalKey, selections.slot2.animalId);
    await prefs.setString(_slot2MutationKey, selections.slot2.mutationId);
    await prefs.setString(_slot3AnimalKey, selections.slot3.animalId);
    await prefs.setString(_slot3MutationKey, selections.slot3.mutationId);
  }
}

/// Remembered dropdown values for the three force slots.
class DevForceSlotSelections {
  const DevForceSlotSelections({
    required this.slot1,
    required this.slot2,
    required this.slot3,
  });

  final DevForceSlotSelection slot1;
  final DevForceSlotSelection slot2;
  final DevForceSlotSelection slot3;

  DevForceSlotSelection slotAt(int index) {
    switch (index) {
      case 0:
        return slot1;
      case 1:
        return slot2;
      case 2:
      default:
        return slot3;
    }
  }

  DevForceSlotSelections updateSlot(
    int index,
    DevForceSlotSelection value,
  ) {
    switch (index) {
      case 0:
        return DevForceSlotSelections(
          slot1: value,
          slot2: slot2,
          slot3: slot3,
        );
      case 1:
        return DevForceSlotSelections(
          slot1: slot1,
          slot2: value,
          slot3: slot3,
        );
      case 2:
      default:
        return DevForceSlotSelections(
          slot1: slot1,
          slot2: slot2,
          slot3: value,
        );
    }
  }
}

class DevForceSlotSelection {
  const DevForceSlotSelection({
    required this.animalId,
    required this.mutationId,
  });

  final String animalId;
  final String mutationId;

  DevForceSlotSelection copyWith({String? animalId, String? mutationId}) {
    return DevForceSlotSelection(
      animalId: animalId ?? this.animalId,
      mutationId: mutationId ?? this.mutationId,
    );
  }

  ForcedHatchResult toForcedResult() {
    return ForcedHatchResult(
      animalId: animalId,
      mutationId: mutationId,
    );
  }
}
