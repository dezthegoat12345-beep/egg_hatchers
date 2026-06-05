import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// Soft pastel gradient background for game screens.
class GameBackground extends StatelessWidget {
  const GameBackground({
    super.key,
    required this.style,
    required this.child,
  });

  final GameBackgroundStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: GameTheme.gradientFor(style),
      ),
      child: child,
    );
  }
}
