import '../models/custom_sprite_data.dart';
import 'retro_pixel_chicken.dart';
import 'retro_pixel_hand_authored_sprites.dart';

/// Retro Pixel animal sprites — explicit hand-authored 16×16 grids only.
///
/// These sprites are separate from [SpriteReferenceData] used by Rate Sprite Beta.
/// Animals without an entry here fall back to Classic PNG rendering.
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

  static final Map<String, CustomSpriteData> _sprites = _buildSprites();

  static Map<String, CustomSpriteData> _buildSprites() {
    return {
      'chicken': RetroPixelChickenReference.data,
      ...RetroPixelHandAuthoredSprites.all,
    };
  }

  static bool hasSprite(String animalId) => _sprites.containsKey(animalId);

  static CustomSpriteData? spriteFor(String animalId) => _sprites[animalId];
}
