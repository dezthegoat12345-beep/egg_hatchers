import '../data/game_data.dart';
import '../models/player_state.dart';
import '../models/quest.dart';

/// Collection quest helpers based on owned base animals.
class CollectionQuestLogic {
  CollectionQuestLogic._();

  static int collectedBaseAnimalCount(PlayerState state) {
    final ownedIds = state.ownedAnimals.map((owned) => owned.animalId).toSet();
    var count = 0;
    for (final animal in GameData.animals) {
      if (ownedIds.contains(animal.id)) count++;
    }
    return count;
  }

  static int get totalBaseAnimalCount => GameData.animals.length;

  static bool hasCollectedAllBaseAnimals(PlayerState state) {
    return collectedBaseAnimalCount(state) >= totalBaseAnimalCount;
  }

  static String progressText(Quest quest, PlayerState state) {
    final collected = collectedBaseAnimalCount(state);
    return 'Collected $collected / ${quest.target} animals';
  }
}
