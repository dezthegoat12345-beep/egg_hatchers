import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../navigation/app_page_route.dart';
import '../services/game_service.dart';
import '../services/tutorial_service.dart';
import '../utils/snackbar_utils.dart';
import 'tutorial_overlay.dart';

/// Wraps the app and renders the tutorial spotlight above the navigator.
class TutorialHost extends StatefulWidget {
  const TutorialHost({
    super.key,
    required this.game,
    required this.theme,
    required this.child,
  });

  final GameService game;
  final BackgroundTheme theme;
  final Widget child;

  @override
  State<TutorialHost> createState() => _TutorialHostState();
}

class _TutorialHostState extends State<TutorialHost> {
  final TutorialService _tutorial = TutorialService.instance;
  late final VoidCallback _routeListener;

  @override
  void initState() {
    super.initState();
    _tutorial.attach(game: widget.game, theme: widget.theme);
    _tutorial.addListener(_onTutorialChanged);
    _routeListener = _onRouteChanged;
    AppNavigationTracker.instance.addRouteListener(_routeListener);
  }

  @override
  void didUpdateWidget(covariant TutorialHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tutorial.attach(game: widget.game, theme: widget.theme);
  }

  void _onRouteChanged() {
    _tutorial.onRouteChanged(AppNavigationTracker.instance.topRouteName);
  }

  void _onTutorialChanged() {
    if (!mounted) return;
    if (_tutorial.isActive) {
      clearGameSnackBars(context);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tutorial.removeListener(_onTutorialChanged);
    AppNavigationTracker.instance.removeRouteListener(_routeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_tutorial.isActive && !_tutorial.pausedForDialog)
          TutorialSpotlightOverlay(
            service: _tutorial,
            theme: widget.theme,
            topRouteName: AppNavigationTracker.instance.topRouteName,
          ),
      ],
    );
  }
}
