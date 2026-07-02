import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/data/retro_pixel_animal_sprites.dart';
import 'package:egg_hatchers/data/retro_pixel_boss_projectiles.dart';
import 'package:egg_hatchers/data/retro_pixel_massive_sprites.dart';
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
      expect(sprite.width, greaterThanOrEqualTo(48));
      expect(sprite.height, greaterThanOrEqualTo(48));
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

    expect(chicken.width, 64);
    expect(chicken.height, 64);
    expect(chicken.pixels, RetroPixelMassiveSprites.chicken.pixels);
    expect(chicken.pixels.length, isNot(ratingReference.pixels.length));
  });

  test('Retro Pixel mouse and rabbit use massive-grid art', () {
    for (final id in ['mouse', 'rabbit']) {
      final retro = RetroPixelAnimalSprites.spriteFor(id)!;
      final rating = SpriteReferenceData.referenceFor(id)!;

      expect(retro.width, 64);
      expect(retro.height, 64);
      expect(retro.pixels.length, isNot(rating.pixels.length));
      expect(retro.pixels, RetroPixelMassiveSprites.priority[id]!.pixels);
    }
  });

  test('Retro Pixel priority animals use 64x64 grids', () {
    for (final id in RetroPixelMassiveSprites.priority.keys) {
      final sprite = RetroPixelAnimalSprites.spriteFor(id)!;
      expect(sprite.width, 64, reason: id);
      expect(sprite.height, 64, reason: id);
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
      expect(art.width, greaterThanOrEqualTo(20));
    }
  });

  test('RetroPixelSpriteDefinition supports per-sprite dimensions and scale', () {
    final wide = RetroPixelSpriteDefinition(
      width: 24,
      height: 32,
      pixels: List<int?>.filled(24 * 32, null),
    );
    expect(wide.cellCount, 768);
    expect(wide.scale2x().width, 48);
    expect(wide.scale(4).width, 96);
    expect(wide.scaleToMinDimension(64).width, 96);
    expect(wide.scaleToMinDimension(64).height, 128);
  });

  test('unimplemented ids outside game data return null', () {
    expect(RetroPixelAnimalSprites.hasSprite('not_an_animal'), isFalse);
    expect(RetroPixelAnimalSprites.spriteFor('not_an_animal'), isNull);
  });
}
