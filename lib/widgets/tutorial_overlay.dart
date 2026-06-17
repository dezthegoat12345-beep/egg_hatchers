import 'package:flutter/material.dart';

import '../data/tutorial_data.dart';
import '../models/background_theme.dart';
import '../services/game_service.dart';
import '../theme/game_theme.dart';
import 'phone_width_layout.dart';

/// Full-screen themed tutorial overlay for new players and replay.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({
    super.key,
    required this.game,
    required this.theme,
    this.isReplay = false,
  });

  final GameService game;
  final BackgroundTheme theme;
  final bool isReplay;

  static Future<void> show(
    BuildContext context, {
    required GameService game,
    required BackgroundTheme theme,
    bool isReplay = false,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return TutorialOverlay(
            game: game,
            theme: theme,
            isReplay: isReplay,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  var _stepIndex = 0;

  TutorialStep get _step => TutorialData.steps[_stepIndex];
  bool get _isFirst => _stepIndex == 0;
  bool get _isLast => _step.isLast;

  void _goNext() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() => _stepIndex++);
  }

  void _goBack() {
    if (_isFirst) return;
    setState(() => _stepIndex--);
  }

  void _finish() {
    if (!widget.isReplay) {
      widget.game.completeTutorial();
    }
    Navigator.of(context).pop();
  }

  Future<void> _onSkipPressed() async {
    if (widget.isReplay) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: widget.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameTheme.cardRadius),
          ),
          title: Text(
            'Skip tutorial?',
            style: TextStyle(
              color: widget.theme.cardTextPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You can replay it later from Secret Hatchery → Help.',
            style: TextStyle(
              color: widget.theme.cardTextSecondaryColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Keep Learning',
                style: TextStyle(color: widget.theme.cardTextSecondaryColor),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: widget.theme.secondaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      widget.game.skipTutorial();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final step = _step;
    final total = TutorialData.steps.length;

    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: PhoneWidthLayout(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.72,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: GameTheme.panelDecoration(theme),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tutorial ${_stepIndex + 1}/$total',
                                style: TextStyle(
                                  color: theme.cardTextSecondaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _onSkipPressed,
                              child: Text(
                                widget.isReplay ? 'Close' : 'Skip',
                                style: TextStyle(
                                  color: theme.cardTextSecondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (step.icon != null) ...[
                          Text(
                            step.icon!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: GameTheme.sectionTitle(theme, size: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          step.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.cardTextSecondaryColor,
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            if (!_isFirst)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _goBack,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.cardTextPrimaryColor,
                                    side: BorderSide(
                                      color: theme.panelAccentColor
                                          .withValues(alpha: 0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                              ),
                            if (!_isFirst) const SizedBox(width: 10),
                            Expanded(
                              flex: _isFirst ? 1 : 1,
                              child: FilledButton(
                                onPressed: _goNext,
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.secondaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  _isLast ? 'Start Hatching!' : 'Next',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
