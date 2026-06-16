import '../data/game_data.dart';
import '../models/owned_animal.dart';

/// Battle power for an owned animal stack (no rebirth income multiplier).
class BattlePowerLogic {
  BattlePowerLogic._();

  /// battlePower = cps × level × mutation multiplier, minimum 1.
  static int battlePowerForOwnedAnimal(OwnedAnimal owned) {
    final animal = GameData.animalById(owned.animalId);
    if (animal == null) return 1;

    final mutation =
        GameData.mutationById(owned.mutationId) ?? GameData.mutations.first;
    final power =
        animal.coinsPerSecond * owned.level * mutation.incomeMultiplier;
    return power < 1 ? 1 : power;
  }
}
