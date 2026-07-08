import 'package:flutter/material.dart';

import '../services/audio_service.dart';

/// Provides [AudioService] to the widget tree.
class AudioScope extends InheritedNotifier<AudioService> {
  const AudioScope({
    super.key,
    required AudioService audio,
    required super.child,
  }) : super(notifier: audio);

  static AudioService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AudioScope>();
    assert(scope != null, 'AudioScope not found in widget tree');
    return scope!.notifier!;
  }

  static AudioService? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AudioScope>()
        ?.notifier;
  }
}

/// Unlocks web audio and optionally plays a tap SFX on first interaction.
class AudioUnlockListener extends StatelessWidget {
  const AudioUnlockListener({
    super.key,
    required this.audio,
    required this.child,
  });

  final AudioService audio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (!audio.userUnlocked) {
          audio.unlockFromUserGesture();
        }
      },
      child: child,
    );
  }
}
