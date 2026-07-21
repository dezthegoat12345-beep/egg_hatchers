import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:egg_hatchers/data/audio_assets.dart';

void main() {
  test('every registered audio asset exists', () {
    final assetPaths = {
      ...MusicTrack.values.map((track) => track.assetPath),
      ...Sfx.values.map((sound) => sound.assetPath),
    };

    for (final assetPath in assetPaths) {
      expect(
        File('assets/$assetPath').existsSync(),
        isTrue,
        reason: 'Missing audio asset: $assetPath',
      );
    }
  });
}
