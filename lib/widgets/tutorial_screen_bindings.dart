import 'package:flutter/material.dart';

import '../data/tutorial_data.dart';
import '../services/tutorial_target_registry.dart';

/// Registers per-screen tutorial proxy handlers while the screen is mounted.
class TutorialScreenBindings extends StatefulWidget {
  const TutorialScreenBindings({
    super.key,
    required this.onReturnToHatchery,
    required this.child,
    this.handlers = const {},
  });

  final VoidCallback onReturnToHatchery;
  final Map<String, VoidCallback> handlers;
  final Widget child;

  @override
  State<TutorialScreenBindings> createState() => _TutorialScreenBindingsState();
}

class _TutorialScreenBindingsState extends State<TutorialScreenBindings> {
  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(covariant TutorialScreenBindings oldWidget) {
    super.didUpdateWidget(oldWidget);
    _register();
  }

  void _register() {
    TutorialTargetRegistry.register(
      TutorialTargetIds.screenBackButton,
      widget.onReturnToHatchery,
    );
    for (final entry in widget.handlers.entries) {
      TutorialTargetRegistry.register(entry.key, entry.value);
    }
  }

  @override
  void dispose() {
    TutorialTargetRegistry.unregister(TutorialTargetIds.screenBackButton);
    for (final id in widget.handlers.keys) {
      TutorialTargetRegistry.unregister(id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
