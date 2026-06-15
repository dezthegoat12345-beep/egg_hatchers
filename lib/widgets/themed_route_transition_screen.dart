import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import 'phone_width_layout.dart';
import 'route_transition_cue.dart';

/// Duration for Hatchery -> Shop pre-navigation transition screen.
const Duration kShopPreNavTransitionDuration = Duration(milliseconds: 680);

/// Short full-screen cue shown before navigating to a destination route.
class ThemedRouteTransitionScreen extends StatefulWidget {
  const ThemedRouteTransitionScreen({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.duration,
    required this.onComplete,
    this.opacityForProgress = shopRouteCueOpacity,
  });

  final BackgroundTheme theme;
  final String icon;
  final String label;
  final Duration duration;
  final VoidCallback onComplete;
  final double Function(double progress) opacityForProgress;

  @override
  State<ThemedRouteTransitionScreen> createState() =>
      _ThemedRouteTransitionScreenState();
}

class _ThemedRouteTransitionScreenState extends State<ThemedRouteTransitionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconBounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _iconBounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (!mounted) return;
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PhoneWidthLayout(
        useSafeArea: true,
        padding: EdgeInsets.zero,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconBounce.value,
                child: child,
              );
            },
            child: RouteTransitionCue(
              theme: widget.theme,
              animation: _controller,
              icon: widget.icon,
              label: widget.label,
              opacityForProgress: widget.opacityForProgress,
            ),
          ),
        ),
      ),
    );
  }
}
