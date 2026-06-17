import 'package:flutter/material.dart';

import '../data/tutorial_data.dart';
import '../models/background_theme.dart';
import '../services/game_service.dart';
import '../services/tutorial_service.dart';
import '../theme/game_theme.dart';
import 'phone_width_layout.dart';
import 'tutorial_targets.dart';

/// Dim overlay with circular spotlight, callout bubble, and tap blocking.
class TutorialSpotlightOverlay extends StatelessWidget {
  const TutorialSpotlightOverlay({
    super.key,
    required this.service,
    required this.theme,
    required this.topRouteName,
  });

  final TutorialService service;
  final BackgroundTheme theme;
  final String? topRouteName;

  @override
  Widget build(BuildContext context) {
    if (service.phase == TutorialPhase.welcome) {
      return _WelcomeOverlay(service: service, theme: theme);
    }
    if (service.phase != TutorialPhase.guided || service.pausedForDialog) {
      return const SizedBox.shrink();
    }

    final step = service.currentStep;
    if (step == null) return const SizedBox.shrink();

    if (!service.isStepVisibleOnCurrentRoute(topRouteName)) {
      return const SizedBox.shrink();
    }

    final useFallback = service.shouldUseFallback(step);
    final targetRect = useFallback ? null : TutorialTargets.measure(step.targetId);
    final text = service.displayText(step);
    final showNext = service.showNextButton(step);

    if (targetRect == null) {
      return _FallbackCardOverlay(
        service: service,
        theme: theme,
        text: text,
        showNext: showNext,
        isFinish: step.isFinish,
      );
    }

    return _SpotlightLayer(
      service: service,
      theme: theme,
      targetRect: targetRect,
      text: text,
      showNext: showNext,
      isFinish: step.isFinish,
    );
  }
}

class _WelcomeOverlay extends StatelessWidget {
  const _WelcomeOverlay({
    required this.service,
    required this.theme,
  });

  final TutorialService service;
  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: PhoneWidthLayout(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: GameTheme.panelDecoration(theme),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      TutorialData.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: GameTheme.sectionTitle(theme, size: 22),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: service.startGuided,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Tutorial',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: service.skipTutorial,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.cardTextPrimaryColor,
                        side: BorderSide(
                          color: theme.panelAccentColor.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackCardOverlay extends StatelessWidget {
  const _FallbackCardOverlay({
    required this.service,
    required this.theme,
    required this.text,
    required this.showNext,
    required this.isFinish,
  });

  final TutorialService service;
  final BackgroundTheme theme;
  final String text;
  final bool showNext;
  final bool isFinish;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(
          color: Colors.black.withValues(alpha: 0.55),
          dismissible: false,
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: PhoneWidthLayout(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _CalloutCard(
                  theme: theme,
                  text: text,
                  showNext: showNext,
                  isFinish: isFinish,
                  onNext: () => service.advanceNext(force: true),
                  onSkip: service.skipTutorial,
                  nextLabel: isFinish
                      ? TutorialData.finishButtonLabel
                      : 'Next',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightLayer extends StatelessWidget {
  const _SpotlightLayer({
    required this.service,
    required this.theme,
    required this.targetRect,
    required this.text,
    required this.showNext,
    required this.isFinish,
  });

  final TutorialService service;
  final BackgroundTheme theme;
  final Rect targetRect;
  final String text;
  final bool showNext;
  final bool isFinish;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final hole = _circleHole(targetRect);
    final calloutPlacement = _CalloutPlacement.forTarget(
      hole,
      screenSize,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          size: screenSize,
          painter: _DimSpotlightPainter(
            hole: hole,
            dimColor: Colors.black.withValues(alpha: 0.58),
          ),
        ),
        ..._TapBlockers.build(hole: hole, screenSize: screenSize),
        Positioned(
          left: calloutPlacement.left,
          top: calloutPlacement.top,
          width: calloutPlacement.width,
          child: _CalloutCard(
            theme: theme,
            text: text,
            showNext: showNext,
            isFinish: isFinish,
            onNext: () => service.advanceNext(force: true),
            onSkip: service.skipTutorial,
            nextLabel:
                isFinish ? TutorialData.finishButtonLabel : 'Next',
            arrowDirection: calloutPlacement.arrowDirection,
          ),
        ),
      ],
    );
  }

  Rect _circleHole(Rect target) {
    final center = target.center;
    final diameter = target.width > target.height
        ? target.width
        : target.height;
    final radius = (diameter / 2).clamp(28.0, 72.0);
    return Rect.fromCircle(center: center, radius: radius);
  }
}

class _TapBlockers {
  static List<Widget> build({
    required Rect hole,
    required Size screenSize,
  }) {
    return [
      Positioned(
        left: 0,
        top: 0,
        right: 0,
        height: hole.top.clamp(0, screenSize.height),
        child: const _TapBlocker(),
      ),
      Positioned(
        left: 0,
        top: hole.bottom.clamp(0, screenSize.height),
        right: 0,
        bottom: 0,
        child: const _TapBlocker(),
      ),
      Positioned(
        left: 0,
        top: hole.top,
        width: hole.left.clamp(0, screenSize.width),
        height: hole.height,
        child: const _TapBlocker(),
      ),
      Positioned(
        left: hole.right.clamp(0, screenSize.width),
        top: hole.top,
        right: 0,
        height: hole.height,
        child: const _TapBlocker(),
      ),
    ];
  }
}

class _TapBlocker extends StatelessWidget {
  const _TapBlocker();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Container(color: Colors.transparent),
    );
  }
}

class _DimSpotlightPainter extends CustomPainter {
  _DimSpotlightPainter({
    required this.hole,
    required this.dimColor,
  });

  final Rect hole;
  final Color dimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final cutout = Path()..addOval(hole);
    final dimPath = Path.combine(PathOperation.difference, overlay, cutout);
    canvas.drawPath(dimPath, Paint()..color = dimColor);
  }

  @override
  bool shouldRepaint(covariant _DimSpotlightPainter oldDelegate) {
    return oldDelegate.hole != hole || oldDelegate.dimColor != dimColor;
  }
}

enum _ArrowDirection { up, down, left, right }

class _CalloutPlacement {
  const _CalloutPlacement({
    required this.left,
    required this.top,
    required this.width,
    required this.arrowDirection,
  });

  final double left;
  final double top;
  final double width;
  final _ArrowDirection arrowDirection;

  static _CalloutPlacement forTarget(Rect hole, Size screenSize) {
    const margin = 16.0;
    const calloutWidth = 280.0;
    const estimatedHeight = 140.0;

    final centerX = hole.center.dx;
    final left = (centerX - calloutWidth / 2)
        .clamp(margin, screenSize.width - calloutWidth - margin);

    final spaceBelow = screenSize.height - hole.bottom;
    final spaceAbove = hole.top;

    if (spaceBelow >= estimatedHeight + margin) {
      return _CalloutPlacement(
        left: left,
        top: hole.bottom + margin,
        width: calloutWidth,
        arrowDirection: _ArrowDirection.up,
      );
    }
    if (spaceAbove >= estimatedHeight + margin) {
      return _CalloutPlacement(
        left: left,
        top: hole.top - estimatedHeight - margin,
        width: calloutWidth,
        arrowDirection: _ArrowDirection.down,
      );
    }
    if (hole.center.dx > screenSize.width / 2) {
      return _CalloutPlacement(
        left: margin,
        top: hole.center.dy - estimatedHeight / 2,
        width: calloutWidth,
        arrowDirection: _ArrowDirection.right,
      );
    }
    return _CalloutPlacement(
      left: screenSize.width - calloutWidth - margin,
      top: hole.center.dy - estimatedHeight / 2,
      width: calloutWidth,
      arrowDirection: _ArrowDirection.left,
    );
  }
}

class _CalloutCard extends StatelessWidget {
  const _CalloutCard({
    required this.theme,
    required this.text,
    required this.showNext,
    required this.isFinish,
    required this.onNext,
    required this.onSkip,
    required this.nextLabel,
    this.arrowDirection,
  });

  final BackgroundTheme theme;
  final String text;
  final bool showNext;
  final bool isFinish;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;
  final _ArrowDirection? arrowDirection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (arrowDirection == _ArrowDirection.up)
          _ArrowPointer(direction: arrowDirection!, theme: theme),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: GameTheme.panelDecoration(theme).copyWith(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: theme.cardTextPrimaryColor,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: theme.cardTextSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (showNext) ...[
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    nextLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (arrowDirection == _ArrowDirection.down)
          _ArrowPointer(direction: arrowDirection!, theme: theme),
      ],
    );
  }
}

class _ArrowPointer extends StatelessWidget {
  const _ArrowPointer({
    required this.direction,
    required this.theme,
  });

  final _ArrowDirection direction;
  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (direction) {
      case _ArrowDirection.up:
        icon = Icons.arrow_drop_up;
      case _ArrowDirection.down:
        icon = Icons.arrow_drop_down;
      case _ArrowDirection.left:
        icon = Icons.arrow_left;
      case _ArrowDirection.right:
        icon = Icons.arrow_right;
    }

    return Icon(
      icon,
      size: 32,
      color: theme.cardColor,
    );
  }
}

/// Back-compat entry point for replay and external callers.
class TutorialOverlay {
  TutorialOverlay._();

  static void show(
    BuildContext context, {
    required GameService game,
    required BackgroundTheme theme,
    bool isReplay = false,
  }) {
    TutorialService.instance.attach(game: game, theme: theme);
    TutorialService.instance.showWelcome(isReplay: isReplay);
  }
}
