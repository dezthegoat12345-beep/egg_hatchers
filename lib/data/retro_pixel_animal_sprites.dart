import '../data/game_data.dart';
import '../models/retro_pixel_sprite_definition.dart';
import 'retro_pixel_animal_catalog.dart';
import 'retro_pixel_chicken.dart';
import 'retro_pixel_hand_authored_sprites.dart';

/// Retro Pixel animal sprites — explicit hand-authored grids only.
///
/// These sprites are separate from [SpriteReferenceData] and the 16×16 custom
/// sprite editor. Full coverage of [GameData.animals]; missing entries fall
/// back to Classic PNG rendering only if generation fails.
class RetroPixelAnimalSprites {
  RetroPixelAnimalSprites._();

  static final Map<String, RetroPixelSpriteDefinition> _sprites = _buildSprites();

  static Map<String, RetroPixelSpriteDefinition> _buildSprites() {
    return {
      'chicken': RetroPixelChickenReference.definition,
      ...RetroPixelHandAuthoredSprites.all,
      ...RetroPixelAnimalCatalog.generated,
    };
  }

  /// Every built-in animal id from game data.
  static Set<String> get supportedAnimalIds =>
      GameData.animals.map((animal) => animal.id).toSet();

  static bool hasSprite(String animalId) => _sprites.containsKey(animalId);

  static RetroPixelSpriteDefinition? spriteFor(String animalId) =>
      _sprites[animalId];
}
