import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import '../models/custom_sprite_data.dart';
import '../theme/game_theme.dart';
import '../utils/boss_battle_logic.dart';
import '../utils/format_utils.dart';
import 'boss_sprite.dart';
import 'game_sprite.dart';

/// Animated phone-width boss battle scene before the result dialog.
class BattleAnimationDialog extends StatefulWidget {
  const BattleAnimationDialog({
    super.key,
    required this.theme,
    required this.boss,
    required this.result,
    required this.fighterName,
    required this.fighterSpritePath,
    required this.fighterEmoji,
    this.fighterCustomSprite,
  });

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final BossBattleResult result;
  final String fighterName;
  final String? fighterSpritePath;
  final String fighterEmoji;
  final CustomSpriteData? fighterCustomSprite;

  static Future<void> show(
    BuildContext context, {
    required BackgroundTheme theme,
    required BossBattleDefinition boss,
    required BossBattleResult result,
    required String fighterName,
    required String? fighterSpritePath,
    required String fighterEmoji,
    CustomSpriteData? fighterCustomSprite,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: theme.scaffoldColor.withValues(alpha: 0.92),
      builder: (_) => BattleAnimationDialog(
        theme: theme,
        boss: boss,
        result: result,
        fighterName: fighterName,
        fighterSpritePath: fighterSpritePath,
        fighterEmoji: fighterEmoji,
        fighterCustomSprite: fighterCustomSprite,
      ),
    );
  }

  @override
  State<BattleAnimationDialog> createState() => _BattleAnimationDialogState();
}

class _BattleAnimationDialogState extends State<BattleAnimationDialog> {
  late final List<BattleRoundSnapshot> _steps;
  var _stepIndex = -1;
  var _playerHp = 0;
  var _bossHp = 0;
  var _playerOffset = 0.0;
  var _bossOffset = 0.0;
  var _playerFlash = false;
  var _bossFlash = false;
  var _finished = false;
  var _skipped = false;

  BackgroundTheme get theme => widget.theme;
  BossBattleResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    _steps = BossBattleLogic.visibleSnapshots(result);
    _playerHp = result.initialPlayerHp;
    _bossHp = result.initialBossHp;
    WidgetsBinding.instance.addPostFrameCallback((_) => _runBattle());
  }

  Future<void> _runBattle() async {
    if (_steps.isEmpty) {
      _finish();
      return;
    }

    for (var i = 0; i < _steps.length; i++) {
      if (!mounted || _skipped) break;
      await _playStep(_steps[i]);
    }

    if (mounted) _finish();
  }

  Future<void> _playStep(BattleRoundSnapshot step) async {
    setState(() {
      _stepIndex++;
      if (step.isPlayerAttack) {
        _playerOffset = 24;
      } else {
        _bossOffset = -24;
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 175));
    if (!mounted || _skipped) return;

    setState(() {
      _playerHp = step.playerHpAfter;
      _bossHp = step.bossHpAfter;
      if (step.isPlayerAttack) {
        _bossFlash = true;
      } else {
        _playerFlash = true;
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 175));
    if (!mounted || _skipped) return;

    setState(() {
      _playerOffset = 0;
      _bossOffset = 0;
      _playerFlash = false;
      _bossFlash = false;
    });
  }

  void _skip() {
    if (_finished) return;
    setState(() {
      _skipped = true;
      _playerHp = result.finalPlayerHp;
      _bossHp = result.finalBossHp;
      _playerOffset = 0;
      _bossOffset = 0;
      _playerFlash = false;
      _bossFlash = false;
    });
    _finish();
  }

  void _finish() {
    if (_finished) return;
    setState(() {
      _finished = true;
      _playerHp = result.finalPlayerHp;
      _bossHp = result.finalBossHp;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final playerSize = width >= 360 ? 96.0 : 84.0;
    final bossSize = width >= 360 ? 150.0 : 132.0;

    return Dialog(
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Battle!',
                      style: GameTheme.sectionTitle(theme),
                    ),
                  ),
                  if (!_finished)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: theme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _HpBar(
                theme: theme,
                label: widget.fighterName,
                current: _playerHp,
                max: result.initialPlayerHp,
                accent: theme.primaryColor,
              ),
              const SizedBox(height: 8),
              _HpBar(
                theme: theme,
                label: widget.boss.name,
                current: _bossHp,
                max: result.initialBossHp,
                accent: theme.secondaryColor,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: bossSize + 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: Offset(_playerOffset, 0),
                          child: _FlashWrap(
                            flash: _playerFlash,
                            child: GameSprite(
                              customSprite: widget.fighterCustomSprite,
                              spritePath: widget.fighterSpritePath,
                              fallbackEmoji: widget.fighterEmoji,
                              size: playerSize,
                              emojiFontSize: playerSize * 0.55,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: Offset(_bossOffset, 0),
                          child: _FlashWrap(
                            flash: _bossFlash,
                            child: BossSprite(
                              spritePath: widget.boss.spritePath,
                              fallbackEmoji: widget.boss.emoji,
                              size: bossSize,
                              semanticLabel: widget.boss.name,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (_stepIndex >= 0 && _stepIndex < _steps.length)
                Text(
                  _steps[_stepIndex.clamp(0, _steps.length - 1)].logText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.cardTextSecondaryColor,
                    height: 1.3,
                  ),
                )
              else
                Text(
                  'Get ready…',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.cardTextSecondaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HpBar extends StatelessWidget {
  const _HpBar({
    required this.theme,
    required this.label,
    required this.current,
    required this.max,
    required this.accent,
  });

  final BackgroundTheme theme;
  final String label;
  final int current;
  final int max;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (current / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.cardTextPrimaryColor,
                ),
              ),
            ),
            Text(
              '${formatCoins(current)} / ${formatCoins(max)}',
              style: TextStyle(
                fontSize: 11,
                color: theme.cardTextSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: theme.disabledColor.withValues(alpha: 0.2),
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _FlashWrap extends StatelessWidget {
  const _FlashWrap({
    required this.flash,
    required this.child,
  });

  final bool flash;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: flash ? 0.45 : 1,
      child: child,
    );
  }
}
