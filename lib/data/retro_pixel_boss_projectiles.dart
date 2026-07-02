import '../models/retro_pixel_sprite_definition.dart';
import '../utils/boss_visual_config.dart';
import 'retro_pixel_palette.dart';

/// Crisp pixel-grid boss projectile art for Retro Pixel Animal Style.
class RetroPixelBossProjectiles {
  RetroPixelBossProjectiles._();

  static const _k = RetroPixelPalette.black;
  static const _g = RetroPixelPalette.slimeGreen;
  static const _y = RetroPixelPalette.yellow;
  static const _l = RetroPixelPalette.blue;

  static RetroPixelSpriteDefinition? forType(BossProjectileVisualType type) {
    return switch (type) {
      BossProjectileVisualType.slimeGlob => _slimeGlob,
      BossProjectileVisualType.rockEgg => _rockEgg,
      BossProjectileVisualType.shadowFeather => _shadowFeather,
      BossProjectileVisualType.royalSlime => _royalSlime,
      BossProjectileVisualType.guardianShard => _guardianShard,
      BossProjectileVisualType.phoenixFlame => _phoenixFlame,
      BossProjectileVisualType.rottenEgg => null,
    };
  }

  static final _slimeGlob = RetroPixelPalette.fromPattern([
    '..........',
    '..KKKKKK..',
    '.KGGGGGGK.',
    'KGGGGGGGGK',
    'KGGwGGGGGK',
    'KGGGGGGGGK',
    '.KGGGGGGK.',
    '..KGGGGK..',
    '...KKKK...',
    '..........',
  ]);

  static final _rockEgg = RetroPixelPalette.fromPattern([
    '..........',
    '....KK....',
    '..KBBBBK..',
    '.KBBBBBBK.',
    'KBBBBBBBBK',
    'KBBKBBBBBK',
    'KBBBBBBBBK',
    '.KBBBBBBK.',
    '..KBBBBK..',
    '....KK....',
  ]);

  static final _shadowFeather = RetroPixelPalette.fromPattern([
    '..........',
    '....KK....',
    '..KPPPPK..',
    '.KPPPPPPK.',
    'KPPKPPPPPK',
    'KPPPPPPPPK',
    '.KPPPPPPK.',
    '..KPPPPK..',
    '...KPPK...',
    '....KK....',
  ]);

  static final _royalSlime = RetroPixelPalette.fromPattern([
    '..........',
    '..KKYYKK..',
    '.KGGGGGGK.',
    'KGGGGGGGGK',
    'KGGwGGGGGK',
    'KGGGGGGGGK',
    '.KGGGGGGK.',
    '..KGGGGK..',
    '...KKKK...',
    '..........',
  ]).withPatches({
    (4, 0): _y,
    (5, 0): _y,
    (4, 1): _k,
    (5, 1): _k,
  });

  static final _guardianShard = RetroPixelPalette.fromPattern([
    '..........',
    '....KK....',
    '..KYYBBK..',
    '.KYBBBBBK.',
    'KYBBBBBBBK',
    '.KYBBBBBK.',
    '..KYYBBK..',
    '...KBBK...',
    '....KK....',
    '..........',
  ]).withPatches({
    (4, 3): _l,
    (5, 4): _l,
    (4, 5): _l,
  });

  static final _phoenixFlame = RetroPixelPalette.fromPattern([
    '..........',
    '....KK....',
    '..KLLPPK..',
    '.KLLPPPPK.',
    'KLLPKPPPPK',
    'KLLPPPPPPK',
    '.KLLPPPPK.',
    '..KLLPPK..',
    '...KPPK...',
    '....KK....',
  ]);
}
