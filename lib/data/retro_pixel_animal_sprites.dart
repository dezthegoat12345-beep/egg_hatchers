import '../models/retro_pixel_sprite_definition.dart';
import 'retro_pixel_chicken.dart';
import 'retro_pixel_hand_authored_sprites.dart';

/// Retro Pixel animal sprites — explicit hand-authored grids only.
///
/// These sprites are separate from [SpriteReferenceData] and the 16×16 custom
/// sprite editor. Animals without an entry fall back to Classic PNG rendering.
class RetroPixelAnimalSprites {
  RetroPixelAnimalSprites._();

  /// Animals with dedicated Retro Pixel art.
  static const supportedAnimalIds = <String>{
    'chicken',
    'mouse',
    'rabbit',
    'turtle',
    'pig',
    'cow',
    'sheep',
    'penguin',
    'alien_slime',
    'moon_cat',
    'fish',
    'horse',
    'monkey',
    'parrot',
    'deer',
    'fox',
    'slime_pet',
  };

  static final Map<String, RetroPixelSpriteDefinition> _sprites = _buildSprites();

  static Map<String, RetroPixelSpriteDefinition> _buildSprites() {
    return {
      'chicken': RetroPixelChickenReference.definition,
      ...RetroPixelHandAuthoredSprites.all,
    };
  }

  static bool hasSprite(String animalId) => _sprites.containsKey(animalId);

  static RetroPixelSpriteDefinition? spriteFor(String animalId) =>
      _sprites[animalId];
}
