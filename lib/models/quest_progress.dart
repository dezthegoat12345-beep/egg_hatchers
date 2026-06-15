/// Tracks quest-related stats and which quests have been claimed.
class QuestProgress {
  const QuestProgress({
    this.totalEggsHatched = 0,
    this.totalSingleHatches = 0,
    this.totalTripleHatches = 0,
    this.totalMutationsHatched = 0,
    this.totalGoldenHatched = 0,
    this.totalRainbowHatched = 0,
    this.totalShadowHatched = 0,
    this.totalAnimalUpgrades = 0,
    this.totalLuckUpgrades = 0,
    this.totalCustomEggsCreated = 0,
    this.totalCustomEggHatches = 0,
    this.totalCustomTripleHatches = 0,
    this.totalSpritesRated = 0,
    this.totalSpriteRatingRewardsClaimed = 0,
    this.bestSpriteRatingScore = 0,
    this.totalPerfectSpriteRatings = 0,
    this.totalReferenceOverlaysUnlocked = 0,
    this.perfectRatedSpriteKeys = const [],
    this.claimedQuestIds = const [],
    this.notifiedCompletedQuestIds = const [],
  });

  final int totalEggsHatched;
  final int totalSingleHatches;
  final int totalTripleHatches;
  final int totalMutationsHatched;
  final int totalGoldenHatched;
  final int totalRainbowHatched;
  final int totalShadowHatched;
  final int totalAnimalUpgrades;
  final int totalLuckUpgrades;
  final int totalCustomEggsCreated;
  final int totalCustomEggHatches;
  final int totalCustomTripleHatches;
  final int totalSpritesRated;
  final int totalSpriteRatingRewardsClaimed;
  final int bestSpriteRatingScore;
  final int totalPerfectSpriteRatings;
  final int totalReferenceOverlaysUnlocked;

  /// Tracks sprite versions already counted toward perfect rating quests.
  final List<String> perfectRatedSpriteKeys;
  final List<String> claimedQuestIds;
  final List<String> notifiedCompletedQuestIds;

  static QuestProgress initial() => const QuestProgress();

  bool isQuestClaimed(String questId) => claimedQuestIds.contains(questId);

  bool wasCompletionNotified(String questId) =>
      notifiedCompletedQuestIds.contains(questId);

  QuestProgress copyWith({
    int? totalEggsHatched,
    int? totalSingleHatches,
    int? totalTripleHatches,
    int? totalMutationsHatched,
    int? totalGoldenHatched,
    int? totalRainbowHatched,
    int? totalShadowHatched,
    int? totalAnimalUpgrades,
    int? totalLuckUpgrades,
    int? totalCustomEggsCreated,
    int? totalCustomEggHatches,
    int? totalCustomTripleHatches,
    int? totalSpritesRated,
    int? totalSpriteRatingRewardsClaimed,
    int? bestSpriteRatingScore,
    int? totalPerfectSpriteRatings,
    int? totalReferenceOverlaysUnlocked,
    List<String>? perfectRatedSpriteKeys,
    List<String>? claimedQuestIds,
    List<String>? notifiedCompletedQuestIds,
  }) {
    return QuestProgress(
      totalEggsHatched: totalEggsHatched ?? this.totalEggsHatched,
      totalSingleHatches: totalSingleHatches ?? this.totalSingleHatches,
      totalTripleHatches: totalTripleHatches ?? this.totalTripleHatches,
      totalMutationsHatched:
          totalMutationsHatched ?? this.totalMutationsHatched,
      totalGoldenHatched: totalGoldenHatched ?? this.totalGoldenHatched,
      totalRainbowHatched: totalRainbowHatched ?? this.totalRainbowHatched,
      totalShadowHatched: totalShadowHatched ?? this.totalShadowHatched,
      totalAnimalUpgrades: totalAnimalUpgrades ?? this.totalAnimalUpgrades,
      totalLuckUpgrades: totalLuckUpgrades ?? this.totalLuckUpgrades,
      totalCustomEggsCreated:
          totalCustomEggsCreated ?? this.totalCustomEggsCreated,
      totalCustomEggHatches:
          totalCustomEggHatches ?? this.totalCustomEggHatches,
      totalCustomTripleHatches:
          totalCustomTripleHatches ?? this.totalCustomTripleHatches,
      totalSpritesRated: totalSpritesRated ?? this.totalSpritesRated,
      totalSpriteRatingRewardsClaimed: totalSpriteRatingRewardsClaimed ??
          this.totalSpriteRatingRewardsClaimed,
      bestSpriteRatingScore:
          bestSpriteRatingScore ?? this.bestSpriteRatingScore,
      totalPerfectSpriteRatings:
          totalPerfectSpriteRatings ?? this.totalPerfectSpriteRatings,
      totalReferenceOverlaysUnlocked: totalReferenceOverlaysUnlocked ??
          this.totalReferenceOverlaysUnlocked,
      perfectRatedSpriteKeys:
          perfectRatedSpriteKeys ?? this.perfectRatedSpriteKeys,
      claimedQuestIds: claimedQuestIds ?? this.claimedQuestIds,
      notifiedCompletedQuestIds:
          notifiedCompletedQuestIds ?? this.notifiedCompletedQuestIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalEggsHatched': totalEggsHatched,
        'totalSingleHatches': totalSingleHatches,
        'totalTripleHatches': totalTripleHatches,
        'totalMutationsHatched': totalMutationsHatched,
        'totalGoldenHatched': totalGoldenHatched,
        'totalRainbowHatched': totalRainbowHatched,
        'totalShadowHatched': totalShadowHatched,
        'totalAnimalUpgrades': totalAnimalUpgrades,
        'totalLuckUpgrades': totalLuckUpgrades,
        'totalCustomEggsCreated': totalCustomEggsCreated,
        'totalCustomEggHatches': totalCustomEggHatches,
        'totalCustomTripleHatches': totalCustomTripleHatches,
        'totalSpritesRated': totalSpritesRated,
        'totalSpriteRatingRewardsClaimed': totalSpriteRatingRewardsClaimed,
        'bestSpriteRatingScore': bestSpriteRatingScore,
        'totalPerfectSpriteRatings': totalPerfectSpriteRatings,
        'totalReferenceOverlaysUnlocked': totalReferenceOverlaysUnlocked,
        'perfectRatedSpriteKeys': perfectRatedSpriteKeys,
        'claimedQuestIds': claimedQuestIds,
        'notifiedCompletedQuestIds': notifiedCompletedQuestIds,
      };

  factory QuestProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return QuestProgress.initial();

    return QuestProgress(
      totalEggsHatched: json['totalEggsHatched'] as int? ?? 0,
      totalSingleHatches: json['totalSingleHatches'] as int? ?? 0,
      totalTripleHatches: json['totalTripleHatches'] as int? ?? 0,
      totalMutationsHatched: json['totalMutationsHatched'] as int? ?? 0,
      totalGoldenHatched: json['totalGoldenHatched'] as int? ?? 0,
      totalRainbowHatched: json['totalRainbowHatched'] as int? ?? 0,
      totalShadowHatched: json['totalShadowHatched'] as int? ?? 0,
      totalAnimalUpgrades: json['totalAnimalUpgrades'] as int? ?? 0,
      totalLuckUpgrades: json['totalLuckUpgrades'] as int? ?? 0,
      totalCustomEggsCreated: json['totalCustomEggsCreated'] as int? ?? 0,
      totalCustomEggHatches: json['totalCustomEggHatches'] as int? ?? 0,
      totalCustomTripleHatches: json['totalCustomTripleHatches'] as int? ?? 0,
      totalSpritesRated: json['totalSpritesRated'] as int? ?? 0,
      totalSpriteRatingRewardsClaimed:
          json['totalSpriteRatingRewardsClaimed'] as int? ?? 0,
      bestSpriteRatingScore: json['bestSpriteRatingScore'] as int? ?? 0,
      totalPerfectSpriteRatings:
          json['totalPerfectSpriteRatings'] as int? ?? 0,
      totalReferenceOverlaysUnlocked:
          json['totalReferenceOverlaysUnlocked'] as int? ?? 0,
      perfectRatedSpriteKeys:
          (json['perfectRatedSpriteKeys'] as List<dynamic>?)
                  ?.map((key) => key as String)
                  .toList() ??
              const [],
      claimedQuestIds: (json['claimedQuestIds'] as List<dynamic>?)
              ?.map((id) => id as String)
              .toList() ??
          const [],
      notifiedCompletedQuestIds:
          (json['notifiedCompletedQuestIds'] as List<dynamic>?)
                  ?.map((id) => id as String)
                  .toList() ??
              const [],
    );
  }
}
