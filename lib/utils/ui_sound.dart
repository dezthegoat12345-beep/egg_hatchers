import 'package:flutter/widgets.dart';

import '../data/audio_assets.dart';
import '../widgets/audio_scope.dart';

/// Shared UI/reward SFX helpers (respect SFX toggle + volume via [AudioService]).
abstract final class UiSound {
  UiSound._();

  /// Routine navigation taps are intentionally silent.
  static void click(BuildContext context) {}

  static void confirm(BuildContext context) {
    AudioScope.maybeOf(context)?.playSfx(Sfx.purchase);
  }

  static void locked(BuildContext context) {
    AudioScope.maybeOf(context)?.playSfx(Sfx.errorLocked);
  }

  static void rewardTriumph(BuildContext context) {
    AudioScope.maybeOf(context)?.playRewardTriumph();
  }

  static void rewardBigTriumph(BuildContext context) {
    AudioScope.maybeOf(context)?.playBigRewardTriumph();
  }
}
