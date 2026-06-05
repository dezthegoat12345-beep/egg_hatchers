import 'package:flutter/material.dart';

import '../models/background_theme.dart';

/// Soft gradient background using the player's selected theme.
class GameBackground extends StatelessWidget {
  const GameBackground({
    super.key,
    required this.theme,
    required this.child,
  });

  final BackgroundTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: theme.gradient),
      child: child,
    );
  }
}
