import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../data/game_data.dart';
import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import '../models/custom_sprite_data.dart';
import '../models/owned_animal.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/battle_power_logic.dart';
import '../utils/boss_battle_logic.dart';
import '../utils/format_utils.dart';
import '../widgets/boss_sprite.dart';
import '../widgets/game_background.dart';
import '../widgets/game_sprite.dart';
import '../widgets/phone_width_layout.dart';
import '../widgets/rotten_egg_projectile.dart';

/// Top-view dodge boss fight: move side-to-side, break shield, shoot eggs.
class ManualBossBattleScreen extends StatefulWidget {
  const ManualBossBattleScreen({
    super.key,
    required this.game,
    required this.preferences,
    required this.customSprites,
    required this.boss,
    required this.fighter,
  });

  final GameService game;
  final PreferencesService preferences;
  final CustomSpriteService customSprites;
  final BossBattleDefinition boss;
  final OwnedAnimal fighter;

  @override
  State<ManualBossBattleScreen> createState() => _ManualBossBattleScreenState();
}

class _ManualBossBattleScreenState extends State<ManualBossBattleScreen>
    with SingleTickerProviderStateMixin {
  static const _playerSpeed = 280.0;
  static const _eggSpeed = 420.0;
  static const _playerSize = 48.0;
  static const _bossSize = 80.0;
  static const _bossTop = 8.0;
  static const _projectileRadius = 10.0;
  static const _playerHitRadius = 22.0;
  static const _bossHitHalfWidth = 36.0;

  late final Ticker _ticker;
  late final Random _random;
  late int _battlePower;
  late int _eggDamage;
  late String _fighterName;
  late String? _fighterSpritePath;
  late String _fighterEmoji;
  late CustomSpriteData? _fighterCustomSprite;

  var _lives = BossBattleLogic.manualBattleLives;
  var _bossHp = 0;
  var _playerX = 0.0;
  var _bossX = 0.0;
  var _bossDirection = 1.0;
  var _arenaWidth = 320.0;
  var _arenaHeight = 280.0;
  var _shieldActive = true;
  var _missCount = 0;
  var _totalDodges = 0;
  var _successfulEggHits = 0;
  var _elapsedSeconds = 0.0;
  var _totalDamageDealt = 0;
  var _pointerActive = false;
  double? _targetX;
  var _moveLeft = false;
  var _moveRight = false;
  var _eggCooldownRemaining = 0.0;
  var _spawnAccumulator = 0.0;
  var _shieldFlash = 0.0;
  var _bossSpeedBannerRemaining = 0.0;
  var _gameOver = false;
  var _won = false;
  var _rewardsApplied = false;
  var _resultDialogShown = false;

  Duration? _lastTickElapsed;

  final List<_FallingProjectile> _bossProjectiles = [];
  _EggProjectile? _activeEgg;
  final List<_FloatingDamage> _floatingDamages = [];

  BackgroundTheme get theme => widget.preferences.selectedTheme;
  BossBattleDefinition get boss => widget.boss;

  int get _requiredMisses =>
      BossBattleLogic.manualRequiredMisses(_successfulEggHits);

  double get _projectileSpeedMultiplier =>
      BossBattleLogic.manualProjectileSpeedMultiplier(
        elapsedSeconds: _elapsedSeconds,
        bossHitCount: _successfulEggHits,
      );

  int get _currentProjectileIntervalMs =>
      BossBattleLogic.manualProjectileIntervalMs(boss, _successfulEggHits);

  double get _currentBossMoveSpeed =>
      BossBattleLogic.manualBossMoveSpeed(boss, _successfulEggHits);

  double get _bossCenterY => _bossTop + _bossSize / 2;

  double get _bossSpawnY => _bossTop + _bossSize - 4;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _initFighterInfo();
    _resetBattleState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _initFighterInfo() {
    final animal = GameData.animalById(widget.fighter.animalId)!;
    final mutation =
        GameData.mutationById(widget.fighter.mutationId) ?? GameData.mutations.first;
    _fighterName = mutation.fullName(animal);
    _fighterSpritePath = animal.spritePath;
    _fighterEmoji = mutation.displayEmoji(animal);
    _fighterCustomSprite =
        widget.customSprites.getDisplaySprite(animal.id);
    _battlePower = BattlePowerLogic.battlePowerForOwnedAnimal(widget.fighter);
    _eggDamage = BossBattleLogic.manualEggDamage(_battlePower);
  }

  void _resetBattleState() {
    _lives = BossBattleLogic.manualBattleLives;
    _bossHp = boss.maxHp;
    _shieldActive = true;
    _missCount = 0;
    _totalDodges = 0;
    _successfulEggHits = 0;
    _elapsedSeconds = 0;
    _totalDamageDealt = 0;
    _pointerActive = false;
    _targetX = null;
    _moveLeft = false;
    _moveRight = false;
    _eggCooldownRemaining = 0;
    _spawnAccumulator = 0;
    _shieldFlash = 0;
    _bossSpeedBannerRemaining = 0;
    _gameOver = false;
    _won = false;
    _rewardsApplied = false;
    _resultDialogShown = false;
    _lastTickElapsed = null;
    _bossProjectiles.clear();
    _activeEgg = null;
    _floatingDamages.clear();
    _playerX = _arenaWidth / 2;
    _bossX = _arenaWidth / 2;
    _bossDirection = _random.nextBool() ? 1.0 : -1.0;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted || _gameOver) return;

    final last = _lastTickElapsed ?? Duration.zero;
    var dt = (elapsed - last).inMicroseconds / 1000000.0;
    _lastTickElapsed = elapsed;
    if (dt <= 0) return;
    if (dt > 0.05) dt = 0.05;

    _updateGame(dt);
    setState(() {});
  }

  void _updateGame(double dt) {
    if (_arenaWidth <= 0) return;

    _elapsedSeconds += dt;

    final minX = _playerSize / 2 + 8;
    final maxX = _arenaWidth - _playerSize / 2 - 8;

    if (_pointerActive && _targetX != null) {
      final target = _targetX!.clamp(minX, maxX);
      final diff = target - _playerX;
      final step = _playerSpeed * dt;
      if (diff.abs() <= step) {
        _playerX = target;
      } else {
        _playerX += step * diff.sign;
      }
    } else {
      var dx = 0.0;
      if (_moveLeft) dx -= _playerSpeed * dt;
      if (_moveRight) dx += _playerSpeed * dt;
      if (dx != 0) {
        _playerX = (_playerX + dx).clamp(minX, maxX);
      }
    }

    if (_eggCooldownRemaining > 0) {
      _eggCooldownRemaining = max(0, _eggCooldownRemaining - dt);
    }

    if (_shieldFlash > 0) {
      _shieldFlash = max(0, _shieldFlash - dt);
    }

    if (_bossSpeedBannerRemaining > 0) {
      _bossSpeedBannerRemaining = max(0, _bossSpeedBannerRemaining - dt);
    }

    _updateBossMovement(dt);

    _spawnAccumulator += dt * 1000;
    final interval = _currentProjectileIntervalMs;
    while (_spawnAccumulator >= interval &&
        _bossProjectiles.length <
            BossBattleLogic.manualMaxBossProjectiles) {
      _spawnAccumulator -= interval;
      _spawnBossProjectile();
    }

    _updateBossProjectiles(dt);
    _updateEgg(dt);

    for (var i = _floatingDamages.length - 1; i >= 0; i--) {
      _floatingDamages[i].age += dt;
      if (_floatingDamages[i].age > 0.9) {
        _floatingDamages.removeAt(i);
      }
    }
  }

  void _updateBossMovement(double dt) {
    final half = _bossSize / 2 + 8;
    final minBx = half;
    final maxBx = max(half, _arenaWidth - half);

    _bossX += _bossDirection * _currentBossMoveSpeed * dt;
    if (_bossX <= minBx) {
      _bossX = minBx;
      _bossDirection = 1;
    } else if (_bossX >= maxBx) {
      _bossX = maxBx;
      _bossDirection = -1;
    }
  }

  void _spawnBossProjectile() {
    final spread = 24.0 * (_random.nextDouble() * 2 - 1);
    final x = (_bossX + spread).clamp(16.0, _arenaWidth - 16.0).toDouble();
    _bossProjectiles.add(
      _FallingProjectile(x: x, y: _bossSpawnY),
    );
  }

  void _updateBossProjectiles(double dt) {
    final playerY = _arenaHeight - _playerSize - 12;
    final missY = _arenaHeight + 4;

    for (var i = _bossProjectiles.length - 1; i >= 0; i--) {
      final p = _bossProjectiles[i];
      p.y += boss.projectileSpeed * _projectileSpeedMultiplier * dt;

      final hitPlayer = (p.x - _playerX).abs() < _playerHitRadius + _projectileRadius &&
          (p.y - playerY).abs() < _playerHitRadius + _projectileRadius;

      if (hitPlayer) {
        _bossProjectiles.removeAt(i);
        _loseLife();
        continue;
      }

      if (p.y >= missY) {
        _bossProjectiles.removeAt(i);
        _registerMiss();
      }
    }
  }

  void _updateEgg(double dt) {
    final egg = _activeEgg;
    if (egg == null) return;

    egg.y -= _eggSpeed * dt;

    final hitBoss = egg.y <= _bossCenterY + _bossSize / 2 &&
        (egg.x - _bossX).abs() < _bossHitHalfWidth + _projectileRadius;

    if (hitBoss) {
      _activeEgg = null;
      if (!_shieldActive) {
        _damageBoss(_eggDamage);
      }
      return;
    }

    if (egg.y < -20) {
      _activeEgg = null;
    }
  }

  void _registerMiss() {
    _totalDodges++;
    if (!_shieldActive) return;
    _missCount++;
    if (_missCount >= _requiredMisses) {
      _shieldActive = false;
      _shieldFlash = 0.35;
    }
  }

  void _regenerateShieldAfterHit() {
    _successfulEggHits++;
    _shieldActive = true;
    _missCount = 0;
    _shieldFlash = 0.35;
  }

  void _loseLife() {
    if (_gameOver) return;
    _lives = max(0, _lives - 1);
    _floatingDamages.add(
      _FloatingDamage(
        x: _playerX,
        y: _arenaHeight - _playerSize - 28,
        label: '-1 life',
      ),
    );
    if (_lives <= 0) {
      _endBattle(won: false);
    }
  }

  void _damageBoss(int amount) {
    if (_gameOver) return;
    _bossHp = max(0, _bossHp - amount);
    _totalDamageDealt += amount;
    _floatingDamages.add(
      _FloatingDamage(
        x: _bossX,
        y: _bossTop + 8,
        amount: amount,
      ),
    );
    if (_bossHp <= 0) {
      _endBattle(won: true);
      return;
    }
    _regenerateShieldAfterHit();
    _bossSpeedBannerRemaining = 1.8;
  }

  void _shootEgg() {
    if (_gameOver || _shieldActive || _activeEgg != null) return;
    if (_eggCooldownRemaining > 0) return;

    _activeEgg = _EggProjectile(
      x: _playerX,
      y: _arenaHeight - _playerSize - 20,
    );
    _eggCooldownRemaining =
        BossBattleLogic.manualEggCooldown.inMilliseconds / 1000;
  }

  void _endBattle({required bool won}) {
    if (_gameOver) return;
    _gameOver = true;
    _won = won;
    _ticker.stop();
    _applyRewardsOnce();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showResultDialog();
    });
  }

  void _applyRewardsOnce() {
    if (_rewardsApplied) return;
    _rewardsApplied = true;

    final result = BossBattleResult(
      won: _won,
      rounds: 0,
      initialPlayerHp: BossBattleLogic.manualBattleLives,
      initialBossHp: boss.maxHp,
      finalPlayerHp: _won ? _lives : 0,
      finalBossHp: _bossHp,
      damageLog: const [],
      roundSnapshots: const [],
      battlePower: _battlePower,
      coinReward: _won ? boss.coinReward : 0,
      battleTokenReward: _won ? boss.battleTokenReward : 0,
    );
    widget.game.applyBossBattleRewards(boss.id, result);
  }

  Future<void> _showResultDialog() async {
    if (_resultDialogShown || !mounted) return;
    _resultDialogShown = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: theme.scaffoldColor.withValues(alpha: 0.92),
      builder: (dialogContext) => _ManualBattleResultDialog(
        theme: theme,
        boss: boss,
        fighterName: _fighterName,
        won: _won,
        livesRemaining: _lives,
        missCount: _totalDodges,
        damageDealt: _totalDamageDealt,
        coinReward: _won ? boss.coinReward : 0,
        tokenReward: _won ? boss.battleTokenReward : 0,
        onBackToBattles: () {
          Navigator.pop(dialogContext);
          if (mounted) Navigator.pop(context);
        },
        onBattleAgain: () {
          Navigator.pop(dialogContext);
          if (!mounted) return;
          widget.game.recordBossBattleStarted();
          setState(() {
            _resetBattleState();
            _resultDialogShown = false;
            _ticker.start();
          });
        },
      ),
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (_gameOver) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      if (event is KeyUpEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
            event.logicalKey == LogicalKeyboardKey.keyA) {
          _moveLeft = false;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.keyD) {
          _moveRight = false;
        }
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      _moveLeft = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _moveRight = true;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      _shootEgg();
    }
    return KeyEventResult.handled;
  }

  void _onArenaPointerDown(double localX) {
    if (_gameOver) return;
    _pointerActive = true;
    _updateTargetX(localX);
  }

  void _onArenaPointerMove(double localX) {
    if (_gameOver || !_pointerActive) return;
    _updateTargetX(localX);
  }

  void _onArenaPointerRelease() {
    _pointerActive = false;
    _targetX = null;
  }

  void _updateTargetX(double localX) {
    final minX = _playerSize / 2 + 8;
    final maxX = _arenaWidth - _playerSize / 2 - 8;
    _targetX = localX.clamp(minX, maxX);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.preferences,
      builder: (context, _) {
        final currentTheme = widget.preferences.selectedTheme;

        return Focus(
          autofocus: true,
          onKeyEvent: _handleKey,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PhoneWidthAppBar(
              title: boss.name,
              titleStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              backgroundColor: currentTheme.appBarColor,
              foregroundColor: Colors.white,
            ),
            body: GameBackground(
              theme: currentTheme,
              child: PhoneWidthLayout(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BattleHeader(
                        theme: currentTheme,
                        boss: boss,
                        bossHp: _bossHp,
                        bossMaxHp: boss.maxHp,
                        lives: _lives,
                        shieldActive: _shieldActive,
                        shieldFlash: _shieldFlash,
                        missCount: _missCount,
                        requiredMisses: _requiredMisses,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            _arenaWidth = constraints.maxWidth;
                            _arenaHeight = constraints.maxHeight;
                            if (_playerX == 0 ||
                                _playerX > _arenaWidth) {
                              _playerX = _arenaWidth / 2;
                            }
                            if (_bossX == 0 || _bossX > _arenaWidth) {
                              _bossX = _arenaWidth / 2;
                            }
                            return _Arena(
                              theme: currentTheme,
                              boss: boss,
                              arenaWidth: _arenaWidth,
                              arenaHeight: _arenaHeight,
                              playerX: _playerX,
                              bossX: _bossX,
                              bossTop: _bossTop,
                              bossSpeedBannerRemaining:
                                  _bossSpeedBannerRemaining,
                              playerSize: _playerSize,
                              bossSize: _bossSize,
                              fighterCustomSprite: _fighterCustomSprite,
                              fighterSpritePath: _fighterSpritePath,
                              fighterEmoji: _fighterEmoji,
                              fighterName: _fighterName,
                              bossProjectiles: _bossProjectiles,
                              activeEgg: _activeEgg,
                              floatingDamages: _floatingDamages,
                              shieldActive: _shieldActive,
                              shieldFlash: _shieldFlash,
                              onPointerDown: _onArenaPointerDown,
                              onPointerMove: _onArenaPointerMove,
                              onPointerRelease: _onArenaPointerRelease,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hold and drag to dodge.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: currentTheme.cardTextSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ShootRow(
                        theme: currentTheme,
                        shieldActive: _shieldActive,
                        canShoot: !_gameOver &&
                            !_shieldActive &&
                            _activeEgg == null &&
                            _eggCooldownRemaining <= 0,
                        eggOnCooldown: _eggCooldownRemaining > 0,
                        onShootEgg: _shootEgg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BattleHeader extends StatelessWidget {
  const _BattleHeader({
    required this.theme,
    required this.boss,
    required this.bossHp,
    required this.bossMaxHp,
    required this.lives,
    required this.shieldActive,
    required this.shieldFlash,
    required this.missCount,
    required this.requiredMisses,
  });

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int bossHp;
  final int bossMaxHp;
  final int lives;
  final bool shieldActive;
  final double shieldFlash;
  final int missCount;
  final int requiredMisses;

  @override
  Widget build(BuildContext context) {
    final bossRatio = bossMaxHp > 0 ? bossHp / bossMaxHp : 0.0;
    final maxLives = BossBattleLogic.manualBattleLives;
    final hearts = List.generate(maxLives, (index) {
      return index < lives ? '❤️' : '🖤';
    }).join();
    final shieldLabel = shieldActive ? 'Shielded' : 'Shield down!';
    final shieldColor = shieldActive
        ? theme.secondaryColor
        : Colors.orange.shade400;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: GameTheme.cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            boss.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.cardTextPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _HpBar(
            theme: theme,
            label: 'Boss HP',
            ratio: bossRatio,
            valueText:
                '${formatCoins(bossHp)} / ${formatCoins(bossMaxHp)}',
            color: Colors.red.shade400,
            trackColor: theme.panelColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Lives: $hearts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.cardTextPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: shieldColor.withValues(
                alpha: shieldFlash > 0 ? 0.45 : 0.18,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: shieldColor),
            ),
            child: Text(
              shieldLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.cardTextPrimaryColor,
              ),
            ),
          ),
          if (shieldActive) ...[
            const SizedBox(height: 6),
            Text(
              'Break shield: $missCount / $requiredMisses',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.cardTextSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HpBar extends StatelessWidget {
  const _HpBar({
    required this.theme,
    required this.label,
    required this.ratio,
    required this.valueText,
    required this.color,
    required this.trackColor,
  });

  final BackgroundTheme theme;
  final String label;
  final double ratio;
  final String valueText;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.cardTextSecondaryColor,
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.cardTextSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: trackColor.withValues(alpha: 0.35),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Arena extends StatelessWidget {
  const _Arena({
    required this.theme,
    required this.boss,
    required this.arenaWidth,
    required this.arenaHeight,
    required this.playerX,
    required this.bossX,
    required this.bossTop,
    required this.bossSpeedBannerRemaining,
    required this.playerSize,
    required this.bossSize,
    required this.fighterCustomSprite,
    required this.fighterSpritePath,
    required this.fighterEmoji,
    required this.fighterName,
    required this.bossProjectiles,
    required this.activeEgg,
    required this.floatingDamages,
    required this.shieldActive,
    required this.shieldFlash,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerRelease,
  });

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final double arenaWidth;
  final double arenaHeight;
  final double playerX;
  final double bossX;
  final double bossTop;
  final double bossSpeedBannerRemaining;
  final double playerSize;
  final double bossSize;
  final CustomSpriteData? fighterCustomSprite;
  final String? fighterSpritePath;
  final String fighterEmoji;
  final String fighterName;
  final List<_FallingProjectile> bossProjectiles;
  final _EggProjectile? activeEgg;
  final List<_FloatingDamage> floatingDamages;
  final bool shieldActive;
  final double shieldFlash;
  final ValueChanged<double> onPointerDown;
  final ValueChanged<double> onPointerMove;
  final VoidCallback onPointerRelease;

  @override
  Widget build(BuildContext context) {
    final playerY = arenaHeight - playerSize - 12;
    final bossLeft = bossX - bossSize / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (details) => onPointerDown(details.localPosition.dx),
      onPanUpdate: (details) => onPointerMove(details.localPosition.dx),
      onPanEnd: (_) => onPointerRelease(),
      onPanCancel: () => onPointerRelease(),
      child: Container(
      decoration: BoxDecoration(
        color: theme.panelColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.cardBorderColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if (shieldActive && shieldFlash <= 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.secondaryColor.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          if (shieldFlash > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.12 * shieldFlash / 0.35),
                ),
              ),
            ),
          Positioned(
            left: bossLeft,
            top: bossTop,
            child: Stack(
              alignment: Alignment.center,
              children: [
                BossSprite(
                  spritePath: boss.spritePath,
                  fallbackEmoji: boss.emoji,
                  size: bossSize,
                  semanticLabel: boss.name,
                ),
                if (shieldActive)
                  Container(
                    width: bossSize + 12,
                    height: bossSize + 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.secondaryColor.withValues(alpha: 0.7),
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (bossSpeedBannerRemaining > 0)
            Positioned(
              left: 0,
              right: 0,
              top: bossTop + bossSize + 4,
              child: IgnorePointer(
                child: Text(
                  'Boss speed increased!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          for (final p in bossProjectiles)
            Positioned(
              left: p.x - 11,
              top: p.y - 12,
              child: const RottenEggProjectile(size: 22),
            ),
          if (activeEgg != null)
            Positioned(
              left: activeEgg!.x - 12,
              top: activeEgg!.y - 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.brown.shade400, width: 2),
                ),
                child: const Center(
                  child: Text('🥚', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          Positioned(
            left: playerX - playerSize / 2,
            top: playerY,
            child: GameSprite(
              customSprite: fighterCustomSprite,
              spritePath: fighterSpritePath,
              fallbackEmoji: fighterEmoji,
              size: playerSize,
              semanticLabel: fighterName,
            ),
          ),
          for (final d in floatingDamages)
            Positioned(
              left: d.x - 24,
              top: d.y - d.age * 28,
              child: Opacity(
                opacity: (1 - d.age / 0.9).clamp(0.0, 1.0),
                child: Text(
                  d.displayText,
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: d.label != null ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _ShootRow extends StatelessWidget {
  const _ShootRow({
    required this.theme,
    required this.shieldActive,
    required this.canShoot,
    required this.eggOnCooldown,
    required this.onShootEgg,
  });

  final BackgroundTheme theme;
  final bool shieldActive;
  final bool canShoot;
  final bool eggOnCooldown;
  final VoidCallback onShootEgg;

  @override
  Widget build(BuildContext context) {
    if (shieldActive) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: canShoot ? onShootEgg : null,
        style: GameTheme.filledButton(
          theme,
          color: canShoot ? theme.secondaryColor : theme.disabledColor,
          height: 48,
        ),
        child: Text(
          eggOnCooldown ? 'Egg...' : 'Shoot Egg 🥚',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ManualBattleResultDialog extends StatelessWidget {
  const _ManualBattleResultDialog({
    required this.theme,
    required this.boss,
    required this.fighterName,
    required this.won,
    required this.livesRemaining,
    required this.missCount,
    required this.damageDealt,
    required this.coinReward,
    required this.tokenReward,
    required this.onBackToBattles,
    required this.onBattleAgain,
  });

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final String fighterName;
  final bool won;
  final int livesRemaining;
  final int missCount;
  final int damageDealt;
  final int coinReward;
  final int tokenReward;
  final VoidCallback onBackToBattles;
  final VoidCallback onBattleAgain;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.cardBorderColor),
      ),
      title: Text(
        won ? '🏆 Victory!' : '💀 Defeat',
        style: TextStyle(
          color: theme.cardTextPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!won)
              Text(
                'You ran out of lives!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
            if (!won) const SizedBox(height: 8),
            Text(
              boss.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.cardTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fighter: $fighterName',
              style: TextStyle(color: theme.cardTextSecondaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Dodges: $missCount · Damage dealt: ${formatCoins(damageDealt)}',
              style: TextStyle(
                fontSize: 13,
                color: theme.cardTextSecondaryColor,
              ),
            ),
            if (won) ...[
              const SizedBox(height: 6),
              Text(
                'Lives left: $livesRemaining',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryColor,
                ),
              ),
            ],
            if (won) ...[
              const SizedBox(height: 12),
              Text(
                'Rewards:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.secondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '🪙 ${formatCoins(coinReward)} · ⚔️ +$tokenReward',
                style: TextStyle(color: theme.cardTextPrimaryColor),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onBackToBattles,
          child: const Text('Back to Battles'),
        ),
        FilledButton(
          onPressed: onBattleAgain,
          style: GameTheme.filledButton(theme),
          child: const Text('Battle Again'),
        ),
      ],
    );
  }
}

class _FallingProjectile {
  _FallingProjectile({required this.x, required this.y});

  double x;
  double y;
}

class _EggProjectile {
  _EggProjectile({required this.x, required this.y});

  double x;
  double y;
}

class _FloatingDamage {
  _FloatingDamage({
    required this.x,
    required this.y,
    this.amount,
    this.label,
  }) : assert(amount != null || label != null);

  final double x;
  final double y;
  final int? amount;
  final String? label;
  double age = 0;

  String get displayText =>
      label ?? '-${formatCoins(amount!)}';
}
