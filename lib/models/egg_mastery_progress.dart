import '../utils/egg_mastery_logic.dart';

/// Persisted hatch mastery progress for one built-in egg type.
class EggMasteryProgress {
  const EggMasteryProgress({
    required this.eggId,
    this.hatchCount = 0,
    this.masteryLevel = 0,
  });

  final String eggId;
  final int hatchCount;
  final int masteryLevel;

  EggMasteryProgress copyWith({
    int? hatchCount,
    int? masteryLevel,
  }) {
    return EggMasteryProgress(
      eggId: eggId,
      hatchCount: hatchCount ?? this.hatchCount,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }

  /// Recomputes [masteryLevel] from [hatchCount] and clamps to valid range.
  EggMasteryProgress normalized() {
    return copyWith(
      hatchCount: hatchCount < 0 ? 0 : hatchCount,
      masteryLevel: EggMasteryLogic.masteryLevelForHatchCount(hatchCount),
    );
  }

  Map<String, dynamic> toJson() => {
        'eggId': eggId,
        'hatchCount': hatchCount,
        'masteryLevel': masteryLevel,
      };

  factory EggMasteryProgress.fromJson(Map<String, dynamic> json) {
    final eggId = json['eggId'] as String;
    final hatchCount = (json['hatchCount'] as num?)?.toInt() ?? 0;
    return EggMasteryProgress(
      eggId: eggId,
      hatchCount: hatchCount,
      masteryLevel: json['masteryLevel'] as int? ??
          EggMasteryLogic.masteryLevelForHatchCount(hatchCount),
    ).normalized();
  }
}
