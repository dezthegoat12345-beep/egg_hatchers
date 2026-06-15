import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/owned_animal.dart';

/// Sell value calculations for owned animal stacks.
class AnimalSellLogic {
  AnimalSellLogic._();

  static const int baseSellMultiplier = 20;
  static const int minimumSellValue = 10;

  static int mutationSellMultiplier(String mutationId) {
    final mutation = GameData.mutationById(mutationId);
    return mutation?.incomeMultiplier ?? 1;
  }

  /// Coins received for selling one animal from this stack.
  static int sellValueFor(Animal animal, OwnedAnimal owned) {
    final baseSellValue = animal.coinsPerSecond * baseSellMultiplier;
    final mutationMultiplier = mutationSellMultiplier(owned.mutationId);
    final levelMultiplier = owned.level < 1 ? 1 : owned.level;
    final raw = baseSellValue * mutationMultiplier * levelMultiplier;
    return raw < minimumSellValue ? minimumSellValue : raw.round();
  }

  static int totalSellValueFor(Animal animal, OwnedAnimal owned, int quantity) {
    if (quantity <= 0) return 0;
    return sellValueFor(animal, owned) * quantity;
  }
}
