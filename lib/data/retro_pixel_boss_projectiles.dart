import '../models/retro_pixel_sprite_definition.dart';
import '../utils/boss_visual_config.dart';
import 'retro_pixel_palette.dart';

/// Crisp pixel-grid boss projectile art for Retro Pixel Animal Style.
class RetroPixelBossProjectiles {
  RetroPixelBossProjectiles._();

  static const _k = RetroPixelPalette.black;
  static const _y = RetroPixelPalette.yellow;
  static const _l = RetroPixelPalette.blue;
  static const _p = RetroPixelPalette.purple;

  static RetroPixelSpriteDefinition? forType(BossProjectileVisualType type) {
    return switch (type) {
      BossProjectileVisualType.slimeGlob => _slimeGlob,
      BossProjectileVisualType.rockEgg => _rockEgg,
      BossProjectileVisualType.shadowFeather => _shadowFeather,
      BossProjectileVisualType.royalSlime => _royalSlime,
      BossProjectileVisualType.guardianShard => _guardianShard,
      BossProjectileVisualType.phoenixFlame => _phoenixFlame,
      BossProjectileVisualType.rottenShell => _rottenShell,
      BossProjectileVisualType.rottenEgg => null,
    };
  }

  static final _slimeGlob = _projectile10([
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

  static final _rockEgg = _projectile10([
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

  static final _shadowFeather = _projectile10([
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

  static final _royalSlime =
      _projectile10([
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
        (8, 0): _y,
        (9, 0): _y,
        (10, 0): _y,
        (8, 1): _k,
        (9, 1): _k,
        (10, 1): _k,
      });

  static final _guardianShard = _projectile10([
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
  ]).withPatches({(8, 6): _l, (10, 8): _l, (8, 10): _l});

  static final _phoenixFlame = _projectile10([
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

  static final _rottenShell = _projectile10([
    '..........',
    '..KKKKKK..',
    '.KGGPPGGK.',
    'KGGGPPGGGK',
    'KGGwPPwGGK',
    'KGGGPPGGGK',
    '.KGGPPGGK.',
    '..KGGGGK..',
    '...KKKK...',
    '..........',
  ]).withPatches({(8, 2): _y, (10, 4): _p, (6, 6): _p});

  /// 10×10 base patterns upscaled to 20×20 for sharper pixel projectiles.
  static RetroPixelSpriteDefinition _projectile10(List<String> rows) =>
      RetroPixelPalette.fromPattern(rows).scale2x();
}
