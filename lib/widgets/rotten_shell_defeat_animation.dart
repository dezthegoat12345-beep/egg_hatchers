import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import 'boss_cinematic_ui.dart';
import 'boss_sprite.dart';
import 'rotten_shell_cinematic_background.dart';

/// Cinematic Rotten Shell defeat celebration (~10s).
class RottenShellDefeatAnimation extends StatefulWidget {
  const RottenShellDefeatAnimation({
    super.key,
    required this.theme,
    required this.boss,
    required this.coinReward,
    required this.tokenReward,
    required this.eggShardReward,
    required this.onComplete,
  });

  static const duration = Duration(milliseconds: 10200);

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int coinReward;
  final int tokenReward;
  final int eggShardReward;
  final VoidCallback onComplete;

  @override
  State<RottenShellDefeatAnimation> createState() =>
      _RottenShellDefeatAnimationState();
}

class _RottenShellDefeatAnimationState extends State<RottenShellDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 10200.0;
  static const _skipAfterMs = 1000.0;
  static const _burstStartMs = 7200.0;
  static const _baseSpriteSize = 168.0;

  late final AnimationController _controller;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: RottenShellDefeatAnimation.duration,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finishOnce();
      })
      ..forward();
  }

  void _finishOnce() {
    if (_completed || !mounted) return;
    _completed = true;
    _controller.stop();
    widget.onComplete();
  }

  void _trySkip() {
    if (_controller.value * _totalMs < _skipAfterMs || _completed) return;
    _finishOnce();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(double startMs, double endMs) {
    final t = _controller.value * _totalMs;
    if (t <= startMs) return 0;
    if (t >= endMs) return 1;
    return (t - startMs) / (endMs - startMs);
  }

  double _timeMs() => _controller.value * _totalMs;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _timeMs();
        final zoomPhase = Curves.easeOutCubic.transform(_phase(0, 900));
        final zoomScale = 0.88 + zoomPhase * 0.5;
        final darken = (0.3 + zoomPhase * 0.28).clamp(0.0, 0.65);

        final crackPhase = _phase(1200, 6800);
        final shakeAmp = crackPhase * 14 + _phase(6800, _burstStartMs) * 22;
        final shakeX = t >= 1200 && t < _burstStartMs + 800
            ? math.sin(t / 38 * math.pi) * shakeAmp
            : 0.0;
        final shakeY = t >= 1200 && t < _burstStartMs + 800
            ? math.cos(t / 44 * math.pi) * shakeAmp * 0.5
            : 0.0;

        final showBoss = t < _burstStartMs;
        final burst = Curves.easeOutCubic.transform(
          _phase(_burstStartMs, _burstStartMs + 900),
        );
        final fumeExpand = Curves.easeOut.transform(_phase(2000, 7000));
        final popFlash = t >= _burstStartMs
            ? (1 - _phase(_burstStartMs, _burstStartMs + 400)).clamp(0.0, 1.0)
            : 0.0;

        final titleProgress = Curves.elasticOut.transform(_phase(8600, 9400));
        final titleOpacity = Curves.easeOut.transform(_phase(8600, 9200));
        final rewardsOpacity = Curves.easeOut.transform(_phase(9200, 10000));
        final rewardsSlide = (1 - rewardsOpacity) * 28;

        return Material(
          color: Colors.black.withValues(alpha: 0.84),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: t >= _skipAfterMs && !_completed ? _trySkip : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const RottenShellCinematicBackground(),
                ColoredBox(color: Colors.black.withValues(alpha: darken)),
                CustomPaint(
                  painter: _ToxicFumePainter(
                    expand: fumeExpand,
                    burst: burst,
                  ),
                ),
                if (showBoss)
                  Transform.translate(
                    offset: Offset(shakeX, shakeY),
                    child: Transform.scale(
                      scale: zoomScale,
                      child: BossSprite(
                        spritePath: widget.boss.spritePath,
                        fallbackEmoji: widget.boss.emoji,
                        bossId: widget.boss.id,
                        size: _baseSpriteSize,
                        semanticLabel: widget.boss.name,
                      ),
                    ),
                  ),
                if (burst > 0)
                  CustomPaint(
                    painter: _ShardBurstPainter(progress: burst),
                  ),
                if (popFlash > 0)
                  ColoredBox(
                    color: const Color(0xFFCE93D8)
                        .withValues(alpha: popFlash * 0.55),
                  ),
                BossCinematicVictoryOverlay(
                  theme: widget.theme,
                  bossName: widget.boss.name,
                  defeatTitle: 'ROTTEN BURST!',
                  coinReward: widget.coinReward,
                  tokenReward: widget.tokenReward,
                  eggShardReward: widget.eggShardReward,
                  titleProgress: titleProgress,
                  titleOpacity: titleOpacity,
                  rewardsOpacity: rewardsOpacity,
                  rewardsSlide: rewardsSlide,
                  canSkip: t >= _skipAfterMs && !_completed,
                  onSkip: _trySkip,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToxicFumePainter extends CustomPainter {
  _ToxicFumePainter({required this.expand, required this.burst});

  final double expand;
  final double burst;

  @override
  void paint(Canvas canvas, Size size) {
    if (expand <= 0 && burst <= 0) return;
    final cx = size.width * 0.5;
    final cy = size.height * 0.55;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final radius = (40 + expand * 120 + burst * 80) * (0.8 + i * 0.05);
      final color = i.isEven
          ? const Color(0xFF66BB6A)
          : const Color(0xFF8E24AA);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            cx + math.cos(angle) * radius * 0.35,
            cy + math.sin(angle) * radius * 0.25,
          ),
          width: 24 + expand * 20,
          height: 18 + expand * 16,
        ),
        Paint()..color = color.withValues(alpha: 0.25 + expand * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ToxicFumePainter oldDelegate) =>
      oldDelegate.expand != expand || oldDelegate.burst != burst;
}

class _ShardBurstPainter extends CustomPainter {
  _ShardBurstPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi * 2 / 12;
      final dist = progress * (80 + i * 8);
      final paint = Paint()
        ..color = i.isEven
            ? const Color(0xFFFFF59D)
            : const Color(0xFF81C784);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            cx + math.cos(angle) * dist,
            cy + math.sin(angle) * dist - progress * 40,
          ),
          width: 10,
          height: 10,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShardBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
