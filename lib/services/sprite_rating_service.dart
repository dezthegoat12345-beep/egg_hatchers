import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sprite_rating_claim.dart';

/// Persists one-time sprite rating reward claims in shared_preferences.
class SpriteRatingService extends ChangeNotifier {
  static const _claimsKey = 'spriteRatingClaims';

  final Map<String, Map<String, SpriteRatingClaim>> _claimsByAnimal = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  bool isClaimed(String animalId, String spriteHash) {
    return _claimsByAnimal[animalId]?.containsKey(spriteHash) ?? false;
  }

  SpriteRatingClaim? getClaim(String animalId, String spriteHash) {
    return _claimsByAnimal[animalId]?[spriteHash];
  }

  Future<void> initialize() async {
    _claimsByAnimal.clear();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claimsKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          for (final entry in decoded.entries) {
            final animalId = entry.key;
            final hashMap = entry.value;
            if (hashMap is! Map<String, dynamic>) continue;

            final claims = <String, SpriteRatingClaim>{};
            for (final hashEntry in hashMap.entries) {
              final claimJson = hashEntry.value;
              if (claimJson is Map<String, dynamic>) {
                claims[hashEntry.key] = SpriteRatingClaim.fromJson(claimJson);
              }
            }
            if (claims.isNotEmpty) {
              _claimsByAnimal[animalId] = claims;
            }
          }
        }
      } catch (_) {
        // Ignore corrupt claim data.
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> recordClaim({
    required String animalId,
    required String spriteHash,
    required int score,
    required int rewardCoins,
  }) async {
    if (isClaimed(animalId, spriteHash)) return false;

    final claim = SpriteRatingClaim(
      score: score,
      rewardCoins: rewardCoins,
      claimedAt: DateTime.now(),
    );

    _claimsByAnimal.putIfAbsent(animalId, () => {})[spriteHash] = claim;
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> clearAllClaims() async {
    _claimsByAnimal.clear();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claimsKey);
  }

  Future<void> _persist() async {
    final encoded = <String, dynamic>{};
    for (final animalEntry in _claimsByAnimal.entries) {
      encoded[animalEntry.key] = {
        for (final claimEntry in animalEntry.value.entries)
          claimEntry.key: claimEntry.value.toJson(),
      };
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claimsKey, jsonEncode(encoded));
  }
}
