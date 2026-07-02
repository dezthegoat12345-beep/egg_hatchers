import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/data/retro_pixel_animal_sprites.dart';
import 'package:egg_hatchers/data/retro_pixel_boss_projectiles.dart';
import 'package:egg_hatchers/data/retro_pixel_chicken.dart';
import 'package:egg_hatchers/data/retro_pixel_hand_authored_sprites.dart';
import 'package:egg_hatchers/data/sprite_reference_data.dart';
import 'package:egg_hatchers/models/animal_sprite_theme.dart';
import 'package:egg_hatchers/models/custom_sprite_data.dart';
import 'package:egg_hatchers/models/retro_pixel_sprite_definition.dart';
import 'package:egg_hatchers/utils/boss_visual_config.dart';

void main() {
  test('AnimalSpriteThemes defaults invalid ids to classic', () {
    expect(AnimalSpriteThemes.byId(null).id, 'classic');
    expect(AnimalSpriteThemes.byId('unknown').id, 'classic');
    expect(AnimalSpriteThemes.byId('retroPixel').id, 'retroPixel');
  });

  test('Retro Pixel covers every built-in animal', () {
    for (final animal in GameData.animals) {
      expect(
        RetroPixelAnimalSprites.hasSprite(animal.id),
        isTrue,
        reason: 'missing retro pixel sprite for ${animal.id}',
      );
      final sprite = RetroPixelAnimalSprites.spriteFor(animal.id)!;
      expect(sprite.hasVisiblePixels, isTrue);
      expect(sprite.width, greaterThan(CustomSpriteData.gridSize));
      expect(sprite.pixels, contains(0xFF000000));
    }

    expect(
      RetroPixelAnimalSprites.supportedAnimalIds.length,
      GameData.animals.length,
    );
  });

  test('Retro Pixel chicken is upscaled reference, not rating reference', () {
    final chicken = RetroPixelAnimalSprites.spriteFor('chicken')!;
    final ratingReference = SpriteReferenceData.referenceFor('chicken')!;

    expect(chicken.width, 32);
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

  test('Retro Pixel boss projectile art exists for all boss types', () {
    const types = [
      BossProjectileVisualType.slimeGlob,
      BossProjectileVisualType.rockEgg,
      BossProjectileVisualType.shadowFeather,
      BossProjectileVisualType.royalSlime,
      BossProjectileVisualType.guardianShard,
      BossProjectileVisualType.phoenixFlame,
    ];

    for (final type in types) {
      final art = RetroPixelBossProjectiles.forType(type);
      expect(art, isNotNull);
      expect(art!.hasVisiblePixels, isTrue);
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

  test('unimplemented ids outside game data return null', () {
    expect(RetroPixelAnimalSprites.hasSprite('not_an_animal'), isFalse);
    expect(RetroPixelAnimalSprites.spriteFor('not_an_animal'), isNull);
  });
}
