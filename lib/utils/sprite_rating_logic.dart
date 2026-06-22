import 'dart:math';

import '../data/game_data.dart';
import '../models/custom_sprite_data.dart';
import '../utils/custom_egg_logic.dart';

/// Local deterministic sprite similarity scoring and reward calculation.
class SpriteRatingLogic {
  SpriteRatingLogic._();

  /// Bump when scoring weights or heuristics change (v2: polished sprite baseline).
  static const int algorithmVersion = 2;

  static const double _silhouetteWeight = 0.35;
  static const double _featureWeight = 0.25;
  static const double _colorWeight = 0.20;
  static const double _readabilityWeight = 0.10;
  static const double _coverageWeight = 0.10;

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

  /// Stable quest key for a rated sprite version (`animalId:spriteHash`).
  static String questRatingKey(String animalId, String spriteHash) =>
      '$animalId:$spriteHash';

  /// Raw similarity in [0, 1] against the polished built-in reference grid.
  static double rawSimilarity(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    if (!custom.hasVisiblePixels) return 0.0;

    final silhouette = _silhouetteScore(custom, reference);
    final features = _featureRegionScore(custom, reference);
    final color = _colorPaletteScore(custom, reference);
    final readability = _readabilityScore(custom, reference);
    final coverage = _coverageScore(custom, reference);

    return (_silhouetteWeight * silhouette +
            _featureWeight * features +
            _colorWeight * color +
            _readabilityWeight * readability +
            _coverageWeight * coverage)
        .clamp(0.0, 1.0);
  }

  /// Display score 0–10.
  static int displayScore(CustomSpriteData custom, CustomSpriteData reference) {
    return (rawSimilarity(custom, reference) * 10).round().clamp(0, 10);
  }

  static String ratingMessage(int score) {
    if (score <= 1) return 'Barely recognizable — add animal features!';
    if (score <= 3) return 'A start — try clearer legs, ears, or colors.';
    if (score <= 5) return 'Getting the general animal shape.';
    if (score <= 7) return 'Nice resemblance — good animal features!';
    if (score <= 9) return 'Very close to the built-in sprite!';
    return 'Almost a perfect match!';
  }

  /// Contextual tip based on the weakest scoring area.
  static String ratingFeedback(
    CustomSpriteData custom,
    CustomSpriteData reference,
    int score,
  ) {
    if (!custom.hasVisiblePixels) {
      return 'Draw your animal before rating.';
    }
    if (score >= 9) return 'Almost a perfect match!';

    if (score <= 3 && _isBlobLike(custom, reference)) {
      return 'This looks too much like a blob. Add defining animal features.';
    }

    final features = _featureRegionScore(custom, reference);
    final color = _colorPaletteScore(custom, reference);
    final silhouette = _silhouetteScore(custom, reference);

    if (features < 0.45 && _regionHasFeatures(reference, _Region.legs)) {
      return 'Try adding clearer legs or feet.';
    }
    if (features < 0.5 &&
        (_regionHasFeatures(reference, _Region.head) ||
            _regionHasFeatures(reference, _Region.sides))) {
      return 'Try adding the animal\'s tail, ears, wings, or horns.';
    }
    if (silhouette < 0.45) {
      return 'Great animal shape — match the built-in silhouette more closely.';
    }
    if (color < 0.45) {
      return 'Nice colors are close — use the built-in palette for a higher score.';
    }
    if (_readabilityScore(custom, reference) < 0.5) {
      return 'Make the face and key details easier to see at small size.';
    }

    return ratingMessage(score);
  }

  /// Tier base used for rating rewards and overlay unlock pricing.
  static int tierBaseForAnimal(String animalId) {
    final animal = GameData.animalById(animalId);
    if (animal == null) return 0;

    final sourceEgg = CustomEggLogic.findSourceEggForAnimal(animalId);
    return max(
      100,
      sourceEgg != null
          ? (sourceEgg.cost / 4).round()
          : animal.coinsPerSecond * 30,
    );
  }

  /// Maximum possible rating reward for an animal (tierBase × 8).
  static int maxRatingRewardForAnimal(String animalId) {
    final tierBase = tierBaseForAnimal(animalId);
    if (tierBase <= 0) return 0;
    return tierBase * 8;
  }

  /// One-time reference overlay unlock cost (25% of perfect-score reward).
  static int referenceOverlayCostForAnimal({
    required String animalId,
    required int currentCoins,
    int? displayedReward,
  }) {
    final perfectReward = calculateReward(
      animalId: animalId,
      score: 10,
      currentCoins: currentCoins,
    );
    if (perfectReward <= 0) return 0;

    var cost = (perfectReward * 0.25).round();
    cost = max(25, cost);
    cost = min(cost, perfectReward);

    if (displayedReward != null && displayedReward > 0) {
      cost = min(cost, (displayedReward * 0.5).round());
      cost = min(cost, displayedReward);
    }

    return max(25, cost);
  }

  /// Reward coins for a score; returns 0 when score < 1.
  static int calculateReward({
    required String animalId,
    required int score,
    required int currentCoins,
  }) {
    if (score < 1) return 0;

    final tierBase = tierBaseForAnimal(animalId);
    if (tierBase <= 0) return 0;

    final scoreFactor = score / 10.0;
    final progressFactor =
        sqrt(max(currentCoins, 250) / 250.0).clamp(1.0, 25.0);

    var reward = (tierBase * scoreFactor * progressFactor * 0.20).round();
    reward = max(25, reward);
    reward = min(reward, tierBase * 8);

    return reward;
  }

  static double _silhouetteScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    var maskMatches = 0;
    for (var y = 0; y < CustomSpriteData.gridSize; y++) {
      for (var x = 0; x < CustomSpriteData.gridSize; x++) {
        final customOpaque = custom.pixelAt(x, y) != null;
        final referenceOpaque = reference.pixelAt(x, y) != null;
        if (customOpaque == referenceOpaque) maskMatches++;
      }
    }
    final maskScore = maskMatches / CustomSpriteData.cellCount;
    final shapeScore = _shapePlacementScore(custom, reference);
    return (maskScore * 0.55 + shapeScore * 0.45).clamp(0.0, 1.0);
  }

  static double _featureRegionScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    var weightedTotal = 0.0;
    var weightSum = 0.0;

    for (final region in _Region.values) {
      final refCount = _opaqueCountInRegion(reference, region);
      if (refCount == 0) continue;

      final matchScore = _regionMatchScore(custom, reference, region);
      final weight = refCount.toDouble();
      weightedTotal += matchScore * weight;
      weightSum += weight;
    }

    if (weightSum == 0) return 0.0;
    return (weightedTotal / weightSum).clamp(0.0, 1.0);
  }

  static double _regionMatchScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
    _Region region,
  ) {
    var matches = 0;
    var refCells = 0;

    for (final (x, y) in _cellsInRegion(region)) {
      if (reference.pixelAt(x, y) == null) continue;
      refCells++;
      if (_hasOpaqueNear(custom, x, y)) matches++;
    }

    if (refCells == 0) return 1.0;
    return matches / refCells;
  }

  static bool _hasOpaqueNear(CustomSpriteData data, int cx, int cy) {
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        final x = cx + dx;
        final y = cy + dy;
        if (x < 0 ||
            y < 0 ||
            x >= CustomSpriteData.gridSize ||
            y >= CustomSpriteData.gridSize) {
          continue;
        }
        if (data.pixelAt(x, y) != null) return true;
      }
    }
    return false;
  }

  static double _colorPaletteScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    var total = 0.0;
    var count = 0;

    for (var y = 0; y < CustomSpriteData.gridSize; y++) {
      for (var x = 0; x < CustomSpriteData.gridSize; x++) {
        final customPixel = custom.pixelAt(x, y);
        final referencePixel = reference.pixelAt(x, y);
        if (customPixel == null || referencePixel == null) continue;
        count++;
        total += _colorFamilySimilarity(customPixel, referencePixel);
      }
    }

    if (count == 0) return 0.0;

    final overlapScore = total / count;
    final paletteScore = _paletteDistributionScore(custom, reference);
    return (overlapScore * 0.7 + paletteScore * 0.3).clamp(0.0, 1.0);
  }

  static double _paletteDistributionScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    final refFamilies = _colorFamilies(reference);
    if (refFamilies.isEmpty) return 0.0;

    final customFamilies = _colorFamilies(custom);
    if (customFamilies.isEmpty) return 0.0;

    var matched = 0;
    for (final family in refFamilies) {
      if (customFamilies.contains(family)) matched++;
    }
    return matched / refFamilies.length;
  }

  static Set<int> _colorFamilies(CustomSpriteData data) {
    final families = <int>{};
    for (final pixel in data.pixels) {
      if (pixel == null) continue;
      families.add(_colorFamily(pixel));
    }
    return families;
  }

  static double _readabilityScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    final customCount = _opaqueCount(custom);
    if (customCount < 6) return 0.1;

    var score = 1.0;

    if (_isBlobLike(custom, reference)) {
      score *= 0.35;
    }

    final refFamilies = _colorFamilies(reference).length;
    final customFamilies = _colorFamilies(custom).length;
    if (refFamilies >= 3 && customFamilies <= 1) {
      score *= 0.5;
    }

    final customBounds = _opaqueBounds(custom);
    if (customBounds != null) {
      final height = customBounds.maxY - customBounds.minY + 1;
      if (height <= 4 && _regionHasFeatures(reference, _Region.legs)) {
        score *= 0.6;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  static double _coverageScore(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    final customCount = _opaqueCount(custom);
    final refCount = _opaqueCount(reference);
    if (refCount == 0) return customCount > 0 ? 0.5 : 0.0;
    if (customCount == 0) return 0.0;

    final ratio = customCount / refCount;
    if (ratio >= 0.55 && ratio <= 1.35) return 1.0;
    if (ratio >= 0.35 && ratio <= 1.6) return 0.75;
    if (ratio >= 0.2 && ratio <= 2.0) return 0.45;
    return 0.2;
  }

  static bool _isBlobLike(
    CustomSpriteData custom,
    CustomSpriteData reference,
  ) {
    final refFill = _opaqueCount(reference) / CustomSpriteData.cellCount;
    if (refFill > 0.55) return false;

    final customCount = _opaqueCount(custom);
    if (customCount < 12) return false;

    final bounds = _opaqueBounds(custom);
    if (bounds == null) return false;

    final bboxArea = bounds.area;
    final fillRatio = customCount / bboxArea;
    if (fillRatio < 0.72) return false;

    final families = _colorFamilies(custom);
    if (families.length > 2) return false;

    final refFamilies = _colorFamilies(reference).length;
    return refFamilies >= 2 || _regionHasFeatures(reference, _Region.legs);
  }

  static bool _regionHasFeatures(CustomSpriteData reference, _Region region) {
    return _opaqueCountInRegion(reference, region) >= 3;
  }

  static int _opaqueCount(CustomSpriteData data) {
    var count = 0;
    for (final pixel in data.pixels) {
      if (pixel != null) count++;
    }
    return count;
  }

  static int _opaqueCountInRegion(CustomSpriteData data, _Region region) {
    var count = 0;
    for (final (x, y) in _cellsInRegion(region)) {
      if (data.pixelAt(x, y) != null) count++;
    }
    return count;
  }

  static Iterable<(int, int)> _cellsInRegion(_Region region) sync* {
    for (var y = 0; y < CustomSpriteData.gridSize; y++) {
      for (var x = 0; x < CustomSpriteData.gridSize; x++) {
        switch (region) {
          case _Region.head:
            if (y <= 4) yield (x, y);
          case _Region.body:
            if (y >= 4 && y <= 10) yield (x, y);
          case _Region.legs:
            if (y >= 11) yield (x, y);
          case _Region.sides:
            if (x <= 2 || x >= 13) yield (x, y);
        }
      }
    }
  }

  static int _colorFamily(int color) {
    final r = (color >> 16) & 0xFF;
    final g = (color >> 8) & 0xFF;
    final b = color & 0xFF;
    final maxC = max(r, max(g, b));
    final minC = min(r, min(g, b));
    final spread = maxC - minC;

    if (maxC < 60) return 0;
    if (spread < 25 && maxC > 200) return 1;
    if (spread < 30 && maxC > 140) return 2;

    if (r > g + 25 && r > b + 25) {
      if (g > 140) return 3;
      return 4;
    }
    if (g > r + 15 && g > b + 15) return 5;
    if (b > r + 15 && b > g + 15) return 6;
    if (r > 180 && g > 120 && b < 100) return 3;
    if (r > 150 && b > 120) return 7;
    if (r > 120 && g > 80 && b < 90) return 8;
    return 9;
  }

  static double _colorFamilySimilarity(int a, int b) {
    if (a == b) return 1.0;
    if (_colorFamily(a) == _colorFamily(b)) return 0.88;

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
    const maxDistance = 441.6729559;

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

enum _Region { head, body, legs, sides }

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
