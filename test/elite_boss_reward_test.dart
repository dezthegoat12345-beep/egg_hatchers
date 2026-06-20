import 'dart:math';

import 'package:egg_hatchers/utils/luck_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rollNormalMutation never returns boss mutation when unlocked', () {
    for (var seed = 0; seed < 50; seed++) {
      final mutation = LuckLogic.rollNormalMutation(
        _SeededRandom(seed),
        10,
      );
      expect(mutation.id, isNot('boss'));
    }
  });
}

class _SeededRandom implements Random {
  _SeededRandom(this._seed);

  int _seed;

  @override
  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }

  @override
  double nextDouble() => nextInt(1 << 30) / (1 << 30);

  @override
  bool nextBool() => nextInt(2) == 0;
}
