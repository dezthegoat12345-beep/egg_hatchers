import 'dart:math';

import '../data/game_data.dart';
import '../models/custom_sprite_data.dart';
import '../utils/custom_egg_logic.dart';

/// Local deterministic sprite similarity scoring and reward calculation.
class SpriteRatingLogic {
  SpriteRatingLogic._();

  static const double _maskWeight = 0.40;
  static const double _colorWeight = 0.40;
  static const double _shapeWeight = 0.20;

  /// Stable FNV-1a hash for a 16×16 sprite grid (hex string key).
  static String computeSpriteHash(CustomSpriteData data) {
    var hash = 2166136261;
    for (final pixel in data.pixels) {
      final value = pixel ?? -1;
      hash ^= value & 0xFFFFFFFF;
      hash = (hash * 16777619) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// Whether two sprites are identical for claim deduplication.
  static bool spritesEqual(CustomSpriteData a, CustomSpriteData b) {
    return computeSpriteHash(a) == computeSpriteHash(b);
  }

  /// Raw similarity in [0, 1].
  static double rawSimilarity(CustomSpriteData custom, CustomSpriteData reference) {
    if (!custom.hasVisiblePixels) return 0.0;

    var maskMatches = 0;
    var colorTotal = 0.0;
    var colorCount = 0;

    for (var y = 0; y < CustomSpriteData.gridSize; y++) {
      for (var x = 0; x < CustomSpriteData.gridSize; x++) {
        final customPixel = custom.pixelAt(x, y);
        final referencePixel = reference.pixelAt(x, y);
        final customOpaque = customPixel != null;
        final referenceOpaque = referencePixel != null;

        if (customOpaque == referenceOpaque) {
          maskMatches++;
        }

        if (customOpaque && referenceOpaque) {
          colorCount++;
          colorTotal += _colorSimilarity(customPixel, referencePixel);
        }
      }
    }

    final maskScore = maskMatches / CustomSpriteData.cellCount;
    final colorScore = colorCount > 0 ? colorTotal / colorCount : 0.0;
    final shapeScore = _shapePlacementScore(custom, reference);

    return (_maskWeight * maskScore) +
        (_colorWeight * colorScore) +
        (_shapeWeight * shapeScore);
  }

  /// Display score 0–10.
  static int displayScore(CustomSpriteData custom, CustomSpriteData reference) {
    return (rawSimilarity(custom, reference) * 10).round().clamp(0, 10);
  }

  static String ratingMessage(int score) {
    if (score <= 1) return 'Barely recognizable — keep trying!';
    if (score <= 3) return 'A start — refine the shape and colors.';
    if (score <= 5) return 'Getting the general idea.';
    if (score <= 7) return 'Nice resemblance!';
    if (score <= 9) return 'Very close to the original!';
    return 'Almost a perfect match!';
  }

  /// Reward coins for a score; returns 0 when score < 1.
  static int calculateReward({
    required String animalId,
    required int score,
    required int currentCoins,
  }) {
    if (score < 1) return 0;

    final animal = GameData.animalById(animalId);
    if (animal == null) return 0;

    final sourceEgg = CustomEggLogic.findSourceEggForAnimal(animalId);
    final tierBase = max(
      100,
      sourceEgg != null ? (sourceEgg.cost / 4).round() : animal.coinsPerSecond * 30,
    );

    final scoreFactor = score / 10.0;
    final progressFactor =
        sqrt(max(currentCoins, 250) / 250.0).clamp(1.0, 25.0);

    var reward = (tierBase * scoreFactor * progressFactor * 0.20).round();
    reward = max(25, reward);
    reward = min(reward, tierBase * 8);

    return reward;
  }

  static double _colorSimilarity(int a, int b) {
    if (a == b) return 1.0;

    final ar = (a >> 16) & 0xFF;
    final ag = (a >> 8) & 0xFF;
    final ab = a & 0xFF;
    final br = (b >> 16) & 0xFF;
    final bg = (b >> 8) & 0xFF;
    final bb = b & 0xFF;

    final dr = ar - br;
    final dg = ag - bg;
    final db = ab - bb;
    final distance = sqrt(dr * dr + dg * dg + db * db);
    const maxDistance = 441.6729559; // sqrt(3 * 255^2)

    return max(0.0, 1.0 - distance / maxDistance);
  }

  static double _shapePlacementScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    final customBounds = _opaqueBounds(custom);
    final referenceBounds = _opaqueBounds(reference);

    if (customBounds == null || referenceBounds == null) return 0.0;

    final iou = _boundsIoU(customBounds, referenceBounds);
    final centerScore = 1.0 -
        (_centerDistance(custom, reference) / CustomSpriteData.gridSize)
            .clamp(0.0, 1.0);

    return (iou * 0.6 + centerScore * 0.4).clamp(0.0, 1.0);
  }

  static _SpriteBounds? _opaqueBounds(CustomSpriteData data) {
    int? minX;
    int? minY;
    int? maxX;
    int? maxY;

    for (var y = 0; y < CustomSpriteData.gridSize; y++) {
      for (var x = 0; x < CustomSpriteData.gridSize; x++) {
        if (data.pixelAt(x, y) == null) continue;
        minX = minX == null ? x : min(minX, x);
        minY = minY == null ? y : min(minY, y);
        maxX = maxX == null ? x : max(maxX, x);
        maxY = maxY == null ? y : max(maxY, y);
      }
    }

    if (minX == null || minY == null || maxX == null || maxY == null) {
      return null;
    }

    return _SpriteBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }

  static double _boundsIoU(_SpriteBounds a, _SpriteBounds b) {
    final interMinX = max(a.minX, b.minX);
    final interMinY = max(a.minY, b.minY);
    final interMaxX = min(a.maxX, b.maxX);
    final interMaxY = min(a.maxY, b.maxY);

    if (interMaxX < interMinX || interMaxY < interMinY) return 0.0;

    final interArea =
        (interMaxX - interMinX + 1) * (interMaxY - interMinY + 1);
    final areaA = a.area;
    final areaB = b.area;
    final union = areaA + areaB - interArea;
    if (union <= 0) return 0.0;
    return interArea / union;
  }

  static double _centerDistance(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    final customCenter = _centerOfMass(custom);
    final referenceCenter = _centerOfMass(reference);
    if (customCenter == null || referenceCenter == null) return 16.0;

    final dx = customCenter.$1 - referenceCenter.$1;
    final dy = customCenter.$2 - referenceCenter.$2;
    return sqrt(dx * dx + dy * dy);
  }

  static (double, double)? _centerOfMass(CustomSpriteData data) {
    var sumX = 0.0;
    var sumY = 0.0;
    var count = 0;

    for (var y = 0; y < CustomSpriteData.gridSize; y++) {
      for (var x = 0; x < CustomSpriteData.gridSize; x++) {
        if (data.pixelAt(x, y) == null) continue;
        sumX += x;
        sumY += y;
        count++;
      }
    }

    if (count == 0) return null;
    return (sumX / count, sumY / count);
  }
}

class _SpriteBounds {
  const _SpriteBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final int minX;
  final int minY;
  final int maxX;
  final int maxY;

  int get area => (maxX - minX + 1) * (maxY - minY + 1);
}
