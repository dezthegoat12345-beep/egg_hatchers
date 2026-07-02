import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/retro_pixel_animal_sprites.dart';
import 'package:egg_hatchers/data/retro_pixel_chicken.dart';
import 'package:egg_hatchers/data/retro_pixel_hand_authored_sprites.dart';
import 'package:egg_hatchers/data/sprite_reference_data.dart';
import 'package:egg_hatchers/models/animal_sprite_theme.dart';
import 'package:egg_hatchers/models/custom_sprite_data.dart';

void main() {
  test('AnimalSpriteThemes defaults invalid ids to classic', () {
    expect(AnimalSpriteThemes.byId(null).id, 'classic');
    expect(AnimalSpriteThemes.byId('unknown').id, 'classic');
    expect(AnimalSpriteThemes.byId('retroPixel').id, 'retroPixel');
  });

  test('Retro Pixel library includes expanded hand-authored batch', () {
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
      expect(RetroPixelAnimalSprites.hasSprite(id), isTrue,
          reason: 'missing retro pixel sprite for $id');
      final sprite = RetroPixelAnimalSprites.spriteFor(id)!;
      expect(sprite.hasVisiblePixels, isTrue);
      expect(sprite.pixels.length, CustomSpriteData.cellCount);
      expect(sprite.pixels, contains(0xFF000000),
          reason: '$id should have black outline pixels');
    }
  });

  test('Retro Pixel chicken uses user reference grid, not rating reference', () {
    final chicken = RetroPixelAnimalSprites.spriteFor('chicken')!;
    final ratingReference = SpriteReferenceData.referenceFor('chicken')!;

    expect(chicken.pixels, RetroPixelChickenReference.data.pixels);
    expect(chicken.pixels, isNot(equals(ratingReference.pixels)));
  });

  test('Retro Pixel mouse and rabbit are not rating reference copies', () {
    for (final id in ['mouse', 'rabbit']) {
      final retro = RetroPixelAnimalSprites.spriteFor(id)!;
      final rating = SpriteReferenceData.referenceFor(id)!;

      expect(retro.pixels, isNot(equals(rating.pixels)),
          reason: '$id retro pixel must not copy rating reference');
      expect(retro.pixels, RetroPixelHandAuthoredSprites.all[id]!.pixels);
    }
  });

  test('unimplemented animals return null for retro pixel lookup', () {
    expect(RetroPixelAnimalSprites.hasSprite('dragon'), isFalse);
    expect(RetroPixelAnimalSprites.spriteFor('dragon'), isNull);
    expect(RetroPixelAnimalSprites.hasSprite('cloud_bunny'), isFalse);
  });
}
