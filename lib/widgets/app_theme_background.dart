import 'package:flutter/material.dart';

import '../models/background_theme.dart';

/// Full-screen gradient backdrop that stays painted behind routes.
class AppThemeBackground extends StatelessWidget {
  const AppThemeBackground({
    super.key,
    required this.theme,
    this.child = const SizedBox.shrink(),
  });

  final BackgroundTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: theme.gradient),
          child: const SizedBox.expand(),
        ),
        child,
      ],
    );
  }
}
