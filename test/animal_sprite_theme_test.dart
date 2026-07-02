import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/retro_pixel_animal_sprites.dart';
import 'package:egg_hatchers/data/retro_pixel_chicken.dart';
import 'package:egg_hatchers/data/sprite_reference_data.dart';
import 'package:egg_hatchers/models/animal_sprite_theme.dart';
import 'package:egg_hatchers/models/custom_sprite_data.dart';

void main() {
  test('AnimalSpriteThemes defaults invalid ids to classic', () {
    expect(AnimalSpriteThemes.byId(null).id, 'classic');
    expect(AnimalSpriteThemes.byId('unknown').id, 'classic');
    expect(AnimalSpriteThemes.byId('retroPixel').id, 'retroPixel');
  });

  test('Retro Pixel v1 batch includes chicken and common animals', () {
    const expected = [
      'chicken',
      'mouse',
      'rabbit',
      'turtle',
      'pig',
      'cow',
      'sheep',
      'fox',
      'penguin',
      'moon_cat',
    ];

    for (final id in expected) {
      expect(RetroPixelAnimalSprites.hasSprite(id), isTrue,
          reason: 'missing retro pixel sprite for $id');
      final sprite = RetroPixelAnimalSprites.spriteFor(id)!;
      expect(sprite.hasVisiblePixels, isTrue);
      expect(sprite.pixels.length, CustomSpriteData.cellCount);
    }
  });

  test('Retro Pixel chicken uses user reference grid, not rating reference', () {
    final chicken = RetroPixelAnimalSprites.spriteFor('chicken')!;
    final ratingReference = SpriteReferenceData.referenceFor('chicken')!;

    expect(chicken.pixels, RetroPixelChickenReference.data.pixels);
    expect(chicken.pixels, isNot(equals(ratingReference.pixels)));
    expect(chicken.pixels, contains(RetroPixelChickenReference.red));
    expect(chicken.pixels, contains(RetroPixelChickenReference.orange));
    expect(chicken.pixels, contains(RetroPixelChickenReference.black));
    expect(chicken.pixels, contains(RetroPixelChickenReference.offWhite));
  });

  test('Retro Pixel adds black outline to non-chicken sprites', () {
    final mouse = RetroPixelAnimalSprites.spriteFor('mouse')!;
    final hasOutline = mouse.pixels.contains(0xFF000000);

    expect(hasOutline, isTrue);
  });

  test('unimplemented animals return null for retro pixel lookup', () {
    expect(RetroPixelAnimalSprites.hasSprite('dragon'), isFalse);
    expect(RetroPixelAnimalSprites.spriteFor('dragon'), isNull);
  });
}
