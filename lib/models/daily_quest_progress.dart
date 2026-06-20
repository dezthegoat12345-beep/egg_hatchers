/// Progress for a single daily quest on the current calendar day.
class DailyQuestProgress {
  const DailyQuestProgress({
    required this.id,
    required this.type,
    required this.title,
    required this.target,
    this.progress = 0,
    this.rewardCoins = 0,
    this.rewardBattleTokens = 0,
    this.claimed = false,
  });

  final String id;
  final String type;
  final String title;
  final int target;
  final int progress;
  final int rewardCoins;
  final int rewardBattleTokens;
  final bool claimed;

  bool get isComplete => progress >= target;

  DailyQuestProgress copyWith({
    String? id,
    String? type,
    String? title,
    int? target,
    int? progress,
    int? rewardCoins,
    int? rewardBattleTokens,
    bool? claimed,
  }) {
    return DailyQuestProgress(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardBattleTokens: rewardBattleTokens ?? this.rewardBattleTokens,
      claimed: claimed ?? this.claimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'target': target,
        'progress': progress,
        'rewardCoins': rewardCoins,
        'rewardBattleTokens': rewardBattleTokens,
        'claimed': claimed,
      };

  factory DailyQuestProgress.fromJson(Map<String, dynamic> json) {
    return DailyQuestProgress(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String? ?? '',
      target: (json['target'] as num).toInt(),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      rewardCoins: (json['rewardCoins'] as num?)?.toInt() ?? 0,
      rewardBattleTokens: (json['rewardBattleTokens'] as num?)?.toInt() ?? 0,
      claimed: json['claimed'] as bool? ?? false,
    );
  }
}
