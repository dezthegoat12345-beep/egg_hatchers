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
  static const _projectileRadius = 10.0;
  static const _playerHitRadius = 22.0;
  static const _bossHitHalfWidth = 36.0;
  static const _bossHitTop = 72.0;

  late final Ticker _ticker;
  late final Random _random;
  late int _battlePower;
  late int _playerMaxHp;
  late int _bossProjectileDamage;
  late int _eggDamage;
  late String _fighterName;
  late String? _fighterSpritePath;
  late String _fighterEmoji;
  late CustomSpriteData? _fighterCustomSprite;

  var _playerHp = 0;
  var _bossHp = 0;
  var _playerX = 0.0;
  var _arenaWidth = 320.0;
  var _arenaHeight = 280.0;
  var _shieldActive = true;
  var _missCount = 0;
  var _totalDamageDealt = 0;
  var _moveLeft = false;
  var _moveRight = false;
  var _eggCooldownRemaining = 0.0;
  var _spawnAccumulator = 0.0;
  var _shieldFlash = 0.0;
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
    _playerMaxHp = BossBattleLogic.maxAnimalHpFor(_battlePower);
    _bossProjectileDamage = BossBattleLogic.manualBossProjectileDamage(boss);
    _eggDamage = BossBattleLogic.manualEggDamage(_battlePower);
  }

  void _resetBattleState() {
    _playerHp = _playerMaxHp;
    _bossHp = boss.maxHp;
    _shieldActive = true;
    _missCount = 0;
    _totalDamageDealt = 0;
    _moveLeft = false;
    _moveRight = false;
    _eggCooldownRemaining = 0;
    _spawnAccumulator = 0;
    _shieldFlash = 0;
    _gameOver = false;
    _won = false;
    _rewardsApplied = false;
    _resultDialogShown = false;
    _lastTickElapsed = null;
    _bossProjectiles.clear();
    _activeEgg = null;
    _floatingDamages.clear();
    _playerX = _arenaWidth / 2;
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

    final minX = _playerSize / 2 + 8;
    final maxX = _arenaWidth - _playerSize / 2 - 8;
    var dx = 0.0;
    if (_moveLeft) dx -= _playerSpeed * dt;
    if (_moveRight) dx += _playerSpeed * dt;
    _playerX = (_playerX + dx).clamp(minX, maxX);

    if (_eggCooldownRemaining > 0) {
      _eggCooldownRemaining = max(0, _eggCooldownRemaining - dt);
    }

    if (_shieldFlash > 0) {
      _shieldFlash = max(0, _shieldFlash - dt);
    }

    _spawnAccumulator += dt * 1000;
    while (_spawnAccumulator >= boss.projectileIntervalMs &&
        _bossProjectiles.length <
            BossBattleLogic.manualMaxBossProjectiles) {
      _spawnAccumulator -= boss.projectileIntervalMs;
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

  void _spawnBossProjectile() {
    final spread = _arenaWidth * 0.35;
    final center = _arenaWidth / 2;
    final x = center + (_random.nextDouble() * 2 - 1) * spread;
    _bossProjectiles.add(
      _FallingProjectile(x: x.clamp(16, _arenaWidth - 16), y: _bossHitTop),
    );
  }

  void _updateBossProjectiles(double dt) {
    final playerY = _arenaHeight - _playerSize - 12;
    final missY = _arenaHeight + 4;

    for (var i = _bossProjectiles.length - 1; i >= 0; i--) {
      final p = _bossProjectiles[i];
      p.y += boss.projectileSpeed * dt;

      final hitPlayer = (p.x - _playerX).abs() < _playerHitRadius + _projectileRadius &&
          (p.y - playerY).abs() < _playerHitRadius + _projectileRadius;

      if (hitPlayer) {
        _bossProjectiles.removeAt(i);
        _damagePlayer(_bossProjectileDamage);
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

    final bossCenterX = _arenaWidth / 2;
    final hitBoss = egg.y <= _bossHitTop + _bossSize / 2 &&
        (egg.x - bossCenterX).abs() < _bossHitHalfWidth + _projectileRadius;

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
    _missCount++;
    if (_shieldActive &&
        _missCount >= BossBattleLogic.manualShieldMissThreshold) {
      _shieldActive = false;
      _shieldFlash = 0.35;
    }
  }

  void _damagePlayer(int amount) {
    if (_gameOver) return;
    _playerHp = max(0, _playerHp - amount);
    _floatingDamages.add(
      _FloatingDamage(
        x: _playerX,
        y: _arenaHeight - _playerSize - 28,
        amount: amount,
        onPlayer: true,
      ),
    );
    if (_playerHp <= 0) {
      _endBattle(won: false);
    }
  }

  void _damageBoss(int amount) {
    if (_gameOver) return;
    _bossHp = max(0, _bossHp - amount);
    _totalDamageDealt += amount;
    _floatingDamages.add(
      _FloatingDamage(
        x: _arenaWidth / 2,
        y: _bossHitTop + 8,
        amount: amount,
        onPlayer: false,
      ),
    );
    if (_bossHp <= 0) {
      _endBattle(won: true);
    }
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
      initialPlayerHp: _playerMaxHp,
      initialBossHp: boss.maxHp,
      finalPlayerHp: _playerHp,
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
        missCount: _missCount,
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
                        playerHp: _playerHp,
                        playerMaxHp: _playerMaxHp,
                        shieldActive: _shieldActive,
                        shieldFlash: _shieldFlash,
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
                            return _Arena(
                              theme: currentTheme,
                              boss: boss,
                              arenaWidth: _arenaWidth,
                              arenaHeight: _arenaHeight,
                              playerX: _playerX,
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
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ControlRow(
                        theme: currentTheme,
                        shieldActive: _shieldActive,
                        canShoot: !_gameOver &&
                            !_shieldActive &&
                            _activeEgg == null &&
                            _eggCooldownRemaining <= 0,
                        eggOnCooldown: _eggCooldownRemaining > 0,
                        onMoveLeftDown: () => _moveLeft = true,
                        onMoveLeftUp: () => _moveLeft = false,
                        onMoveRightDown: () => _moveRight = true,
                        onMoveRightUp: () => _moveRight = false,
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
    required this.playerHp,
    required this.playerMaxHp,
    required this.shieldActive,
    required this.shieldFlash,
  });

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int bossHp;
  final int bossMaxHp;
  final int playerHp;
  final int playerMaxHp;
  final bool shieldActive;
  final double shieldFlash;

  @override
  Widget build(BuildContext context) {
    final bossRatio = bossMaxHp > 0 ? bossHp / bossMaxHp : 0.0;
    final playerRatio = playerMaxHp > 0 ? playerHp / playerMaxHp : 0.0;
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
          _HpBar(
            theme: theme,
            label: 'Your HP',
            ratio: playerRatio,
            valueText:
                '${formatCoins(playerHp)} / ${formatCoins(playerMaxHp)}',
            color: theme.primaryColor,
            trackColor: theme.panelColor,
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
  });

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final double arenaWidth;
  final double arenaHeight;
  final double playerX;
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

  @override
  Widget build(BuildContext context) {
    final playerY = arenaHeight - playerSize - 12;
    final bossX = arenaWidth / 2 - bossSize / 2;

    return Container(
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
            left: bossX,
            top: 8,
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
          for (final p in bossProjectiles)
            Positioned(
              left: p.x - 10,
              top: p.y - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
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
                  '-${formatCoins(d.amount)}',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.theme,
    required this.shieldActive,
    required this.canShoot,
    required this.eggOnCooldown,
    required this.onMoveLeftDown,
    required this.onMoveLeftUp,
    required this.onMoveRightDown,
    required this.onMoveRightUp,
    required this.onShootEgg,
  });

  final BackgroundTheme theme;
  final bool shieldActive;
  final bool canShoot;
  final bool eggOnCooldown;
  final VoidCallback onMoveLeftDown;
  final VoidCallback onMoveLeftUp;
  final VoidCallback onMoveRightDown;
  final VoidCallback onMoveRightUp;
  final VoidCallback onShootEgg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HoldButton(
            theme: theme,
            label: '◀ Left',
            onDown: onMoveLeftDown,
            onUp: onMoveLeftUp,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HoldButton(
            theme: theme,
            label: 'Right ▶',
            onDown: onMoveRightDown,
            onUp: onMoveRightUp,
          ),
        ),
        if (!shieldActive) ...[
          const SizedBox(width: 8),
          Expanded(
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
          ),
        ],
      ],
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.theme,
    required this.label,
    required this.onDown,
    required this.onUp,
  });

  final BackgroundTheme theme;
  final String label;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: FilledButton(
        onPressed: () {},
        style: GameTheme.filledButton(theme, height: 48).copyWith(
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    required this.amount,
    required this.onPlayer,
  });

  final double x;
  final double y;
  final int amount;
  final bool onPlayer;
  double age = 0;
}
