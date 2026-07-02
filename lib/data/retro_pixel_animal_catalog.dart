import '../models/retro_pixel_sprite_definition.dart';
import 'retro_pixel_chicken.dart';
import 'retro_pixel_extra_templates.dart';
import 'retro_pixel_hand_authored_sprites.dart';
import 'retro_pixel_palette.dart';

/// Generates Retro Pixel sprites for every built-in animal not in the core batch.
class RetroPixelAnimalCatalog {
  RetroPixelAnimalCatalog._();

  static const _k = RetroPixelPalette.black;
  static const _w = RetroPixelPalette.offWhite;
  static const _y = RetroPixelPalette.yellow;

  static final Map<String, RetroPixelSpriteDefinition> generated = {
    for (final entry in _builders.entries) entry.key: entry.value(),
  };

  static final Map<String, RetroPixelSpriteDefinition Function()> _builders = {
    'bear': () => RetroPixelExtraTemplates.bear,
    'tiger': () => RetroPixelHandAuthoredSprites.fox.recolor({
          RetroPixelPalette.orange: RetroPixelPalette.orange,
          RetroPixelPalette.offWhite: RetroPixelPalette.yellow,
        }).withPatches({
          (10, 14): _k,
          (12, 14): RetroPixelPalette.black,
          (14, 14): RetroPixelPalette.black,
          (18, 14): RetroPixelPalette.black,
          (20, 14): _k,
        }),
    'dragon': () => RetroPixelExtraTemplates.dragon,
    'unicorn': () => RetroPixelHandAuthoredSprites.horse.withPatches({
          (16, 4): _k,
          (17, 2): _y,
          (18, 0): _y,
          (19, 2): _y,
          (20, 4): _k,
        }),
    'snake': () => RetroPixelExtraTemplates.snake,
    'gorilla': () => RetroPixelHandAuthoredSprites.monkey.recolor({
          RetroPixelPalette.brown: RetroPixelPalette.darkBrown,
          RetroPixelPalette.tan: RetroPixelPalette.brown,
        }),
    'dolphin': () => RetroPixelHandAuthoredSprites.fish.recolor({
          RetroPixelPalette.blue: RetroPixelPalette.lightGray,
          RetroPixelPalette.darkBlue: RetroPixelPalette.blue,
        }).withPatches({
          (16, 14): _k,
          (17, 14): _w,
          (18, 16): RetroPixelPalette.blue,
        }),
    'shark': () => RetroPixelHandAuthoredSprites.fish.recolor({
          RetroPixelPalette.blue: RetroPixelPalette.gray,
          RetroPixelPalette.darkBlue: RetroPixelPalette.darkGray,
        }).withPatches({
          (16, 14): _k,
          (14, 16): _w,
          (15, 17): _k,
          (16, 17): _k,
          (17, 17): _k,
        }),
    'seal': () => RetroPixelExtraTemplates.seal,
    'polar_bear': () => RetroPixelExtraTemplates.bear.recolor({
          RetroPixelPalette.brown: RetroPixelPalette.offWhite,
          RetroPixelPalette.darkBrown: RetroPixelPalette.lightGray,
        }),
    'snow_owl': () => RetroPixelExtraTemplates.owl,
    'raptor': () => RetroPixelExtraTemplates.dino.recolor({
          RetroPixelPalette.green: RetroPixelPalette.darkGreen,
          RetroPixelPalette.darkGreen: RetroPixelPalette.brown,
        }),
    'triceratops': () => RetroPixelExtraTemplates.dino.withPatches({
          (8, 4): _k,
          (10, 2): RetroPixelPalette.lightGray,
          (16, 2): RetroPixelPalette.lightGray,
          (22, 2): RetroPixelPalette.lightGray,
          (24, 4): _k,
        }),
    't_rex': () => RetroPixelExtraTemplates.dino.recolor({
          RetroPixelPalette.green: RetroPixelPalette.darkGreen,
        }).withPatches({
          (12, 12): _k,
          (20, 12): _k,
          (14, 14): _w,
          (15, 15): _k,
          (16, 15): _k,
          (17, 15): _k,
        }),
    'fossil_dragon': () => RetroPixelExtraTemplates.dragon.recolor({
          RetroPixelPalette.red: RetroPixelPalette.tan,
          RetroPixelPalette.darkGreen: RetroPixelPalette.brown,
        }),
    'star_fox': () => RetroPixelHandAuthoredSprites.fox.withPatches({
          (4, 6): RetroPixelPalette.blue,
          (6, 4): _w,
          (26, 6): RetroPixelPalette.blue,
          (28, 4): _w,
        }),
    'galaxy_dragon': () => RetroPixelExtraTemplates.dragon.recolor({
          RetroPixelPalette.red: RetroPixelPalette.purple,
        }).withPatches({
          (6, 8): _w,
          (24, 10): _w,
          (20, 6): RetroPixelPalette.blue,
        }),
    'scarab_beetle': () => RetroPixelExtraTemplates.beetle,
    'saber_cub': () => RetroPixelExtraTemplates.bear.recolor({
          RetroPixelPalette.brown: RetroPixelPalette.orange,
          RetroPixelPalette.darkBrown: RetroPixelPalette.brown,
        }).withPatches({
          (8, 18): RetroPixelPalette.lightGray,
          (9, 18): RetroPixelPalette.offWhite,
          (10, 18): RetroPixelPalette.lightGray,
        }),
    'stone_golem': () => RetroPixelExtraTemplates.golem,
    'royal_chicken': () => RetroPixelChickenReference.definition.withPatches({
          (14, 2): _y,
          (16, 0): _y,
          (18, 0): _y,
          (20, 2): _y,
          (12, 4): _k,
          (22, 4): _k,
        }),
    'crown_fox': () => RetroPixelHandAuthoredSprites.fox.withPatches({
          (14, 2): _y,
          (16, 0): _y,
          (18, 0): _y,
          (20, 2): _y,
        }),
    'gem_dragon': () => RetroPixelExtraTemplates.dragon.recolor({
          RetroPixelPalette.red: RetroPixelPalette.blue,
        }).withPatches({
          (14, 10): RetroPixelPalette.pink,
          (18, 12): RetroPixelPalette.green,
        }),
    'cloud_bunny': () => RetroPixelHandAuthoredSprites.rabbit.withPatches({
          (4, 8): _w,
          (6, 6): _w,
          (26, 8): _w,
          (28, 6): _w,
          (8, 4): _w,
          (24, 4): _w,
        }),
    'sun_lion': () => RetroPixelExtraTemplates.lion,
    'cosmic_phoenix': () => RetroPixelExtraTemplates.phoenix,
    'void_mouse': () => RetroPixelHandAuthoredSprites.mouse.recolor({
          RetroPixelPalette.lightGray: RetroPixelPalette.darkGray,
          RetroPixelPalette.gray: RetroPixelPalette.purple,
          RetroPixelPalette.earPink: RetroPixelPalette.purple,
        }).withPatches({
          (6, 6): RetroPixelPalette.blue,
          (26, 6): RetroPixelPalette.blue,
        }),
    'eclipse_wolf': () => RetroPixelHandAuthoredSprites.fox.recolor({
          RetroPixelPalette.orange: RetroPixelPalette.darkGray,
          RetroPixelPalette.offWhite: RetroPixelPalette.gray,
        }).withPatches({
          (28, 14): RetroPixelPalette.darkGray,
          (29, 14): _w,
          (30, 15): RetroPixelPalette.darkGray,
        }),
    'nebula_hydra': () => RetroPixelExtraTemplates.snake.withPatches({
          (4, 4): RetroPixelPalette.purple,
          (6, 6): _k,
          (7, 7): RetroPixelPalette.pink,
          (22, 4): RetroPixelPalette.purple,
          (24, 6): _k,
          (25, 7): RetroPixelPalette.pink,
        }),
    'egg_golem_pet': () => RetroPixelExtraTemplates.golem.recolor({
          RetroPixelPalette.green: RetroPixelPalette.lightGray,
          RetroPixelPalette.darkGreen: RetroPixelPalette.gray,
        }).withPatches({
          (14, 2): RetroPixelPalette.yellow,
          (16, 2): RetroPixelPalette.yellow,
          (18, 2): RetroPixelPalette.yellow,
        }),
    'night_rooster': () => RetroPixelChickenReference.definition.recolor({
          RetroPixelPalette.offWhite: RetroPixelPalette.darkGray,
          RetroPixelPalette.red: RetroPixelPalette.purple,
        }).withPatches({
          (14, 6): RetroPixelPalette.purple,
          (16, 6): RetroPixelPalette.purple,
        }),
    'slime_king': () => RetroPixelHandAuthoredSprites.slimePet.recolor({
          RetroPixelPalette.slimeGreen: RetroPixelPalette.green,
        }).withPatches({
          (12, 2): _y,
          (14, 0): _y,
          (16, 0): _y,
          (18, 0): _y,
          (20, 2): _y,
          (24, 8): _y,
        }),
    'egg_guardian': () => RetroPixelExtraTemplates.golem.recolor({
          RetroPixelPalette.green: RetroPixelPalette.cream,
          RetroPixelPalette.darkGreen: RetroPixelPalette.yellow,
        }).withPatches({
          (10, 6): RetroPixelPalette.blue,
          (22, 6): RetroPixelPalette.blue,
          (14, 4): _y,
          (18, 4): _y,
        }),
    'shadow_phoenix': () => RetroPixelExtraTemplates.phoenix.recolor({
          RetroPixelPalette.red: RetroPixelPalette.darkBlue,
          RetroPixelPalette.orange: RetroPixelPalette.purple,
          RetroPixelPalette.yellow: RetroPixelPalette.blue,
        }),
  };
}
