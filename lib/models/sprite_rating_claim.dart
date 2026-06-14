/// Record of a one-time sprite rating reward for a specific sprite version.
class SpriteRatingClaim {
  const SpriteRatingClaim({
    required this.score,
    required this.rewardCoins,
    required this.claimedAt,
  });

  final int score;
  final int rewardCoins;
  final DateTime claimedAt;

  factory SpriteRatingClaim.fromJson(Map<String, dynamic> json) {
    return SpriteRatingClaim(
      score: (json['score'] as num?)?.toInt() ?? 0,
      rewardCoins: (json['reward'] as num?)?.toInt() ?? 0,
      claimedAt: DateTime.tryParse(json['claimedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'reward': rewardCoins,
        'claimedAt': claimedAt.toIso8601String(),
      };
}
