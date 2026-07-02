import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/retro_pixel_animal_sprites.dart';
import 'package:egg_hatchers/data/retro_pixel_chicken.dart';
import 'package:egg_hatchers/data/retro_pixel_hand_authored_sprites.dart';
import 'package:egg_hatchers/data/sprite_reference_data.dart';
import 'package:egg_hatchers/models/animal_sprite_theme.dart';
import 'package:egg_hatchers/models/custom_sprite_data.dart';
import 'package:egg_hatchers/models/retro_pixel_sprite_definition.dart';

void main() {
  test('AnimalSpriteThemes defaults invalid ids to classic', () {
    expect(AnimalSpriteThemes.byId(null).id, 'classic');
    expect(AnimalSpriteThemes.byId('unknown').id, 'classic');
    expect(AnimalSpriteThemes.byId('retroPixel').id, 'retroPixel');
  });

  test('Retro Pixel library uses higher-detail grids than custom sprites', () {
    const expected = [
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
    ];

    expect(RetroPixelAnimalSprites.supportedAnimalIds, containsAll(expected));

    for (final id in expected) {
      final sprite = RetroPixelAnimalSprites.spriteFor(id)!;
      expect(sprite.hasVisiblePixels, isTrue);
      expect(sprite.width, greaterThan(CustomSpriteData.gridSize));
      expect(sprite.height, greaterThan(CustomSpriteData.gridSize));
      expect(sprite.pixels, contains(0xFF000000),
          reason: '$id should have black outline pixels');
    }
  });

  test('Retro Pixel chicken is upscaled reference, not rating reference', () {
    final chicken = RetroPixelAnimalSprites.spriteFor('chicken')!;
    final ratingReference = SpriteReferenceData.referenceFor('chicken')!;

    expect(chicken.width, 32);
    expect(chicken.height, 32);
    expect(chicken.pixels, RetroPixelChickenReference.definition.pixels);
    expect(chicken.pixels.length, isNot(ratingReference.pixels.length));
  });

  test('Retro Pixel mouse and rabbit are not rating reference copies', () {
    for (final id in ['mouse', 'rabbit']) {
      final retro = RetroPixelAnimalSprites.spriteFor(id)!;
      final rating = SpriteReferenceData.referenceFor(id)!;

      expect(retro.width, 32);
      expect(retro.pixels.length, isNot(rating.pixels.length));
      expect(retro.pixels, RetroPixelHandAuthoredSprites.all[id]!.pixels);
    }
  });

  test('RetroPixelSpriteDefinition supports per-sprite dimensions', () {
    final wide = RetroPixelSpriteDefinition(
      width: 24,
      height: 32,
      pixels: List<int?>.filled(24 * 32, null),
    );
    expect(wide.cellCount, 768);
    expect(wide.scale2x().width, 48);
  });

  test('unimplemented animals return null for retro pixel lookup', () {
    expect(RetroPixelAnimalSprites.hasSprite('dragon'), isFalse);
    expect(RetroPixelAnimalSprites.spriteFor('dragon'), isNull);
    expect(RetroPixelAnimalSprites.hasSprite('cloud_bunny'), isFalse);
  });
}
