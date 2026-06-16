import 'owned_animal.dart';

/// Why a background auto battle assignment ended.
enum AutoBattleCompletionReason {
  defeated,
  capReached,
}

/// Ongoing background auto battle assignment for one owned animal stack.
class ActiveAutoBattle {
  const ActiveAutoBattle({
    required this.id,
    required this.animalId,
    required this.mutationId,
    required this.isProtected,
    required this.bossId,
    required this.fighterDisplayName,
    required this.startedAt,
    required this.lastResolvedAt,
    required this.currentHp,
    required this.maxHp,
    required this.battlePower,
    this.battlesWon = 0,
    this.totalCoinsEarned = 0,
    this.totalBattleTokensEarned = 0,
  });

  final String id;
  final String animalId;
  final String mutationId;
  final bool isProtected;
  final String bossId;
  final String fighterDisplayName;
  final DateTime startedAt;
  final DateTime lastResolvedAt;
  final int currentHp;
  final int maxHp;
  final int battlePower;
  final int battlesWon;
  final int totalCoinsEarned;
  final int totalBattleTokensEarned;

  bool matchesStack(OwnedAnimal owned) {
    return owned.animalId == animalId &&
        owned.mutationId == mutationId &&
        owned.isProtected == isProtected;
  }

  ActiveAutoBattle copyWith({
    DateTime? lastResolvedAt,
    int? currentHp,
    int? battlesWon,
    int? totalCoinsEarned,
    int? totalBattleTokensEarned,
  }) {
    return ActiveAutoBattle(
      id: id,
      animalId: animalId,
      mutationId: mutationId,
      isProtected: isProtected,
      bossId: bossId,
      fighterDisplayName: fighterDisplayName,
      startedAt: startedAt,
      lastResolvedAt: lastResolvedAt ?? this.lastResolvedAt,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp,
      battlePower: battlePower,
      battlesWon: battlesWon ?? this.battlesWon,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalBattleTokensEarned:
          totalBattleTokensEarned ?? this.totalBattleTokensEarned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'mutationId': mutationId,
        'isProtected': isProtected,
        'bossId': bossId,
        'fighterDisplayName': fighterDisplayName,
        'startedAt': startedAt.toIso8601String(),
        'lastResolvedAt': lastResolvedAt.toIso8601String(),
        'currentHp': currentHp,
        'maxHp': maxHp,
        'battlePower': battlePower,
        'battlesWon': battlesWon,
        'totalCoinsEarned': totalCoinsEarned,
        'totalBattleTokensEarned': totalBattleTokensEarned,
      };

  factory ActiveAutoBattle.fromJson(Map<String, dynamic> json) {
    return ActiveAutoBattle(
      id: json['id'] as String,
      animalId: json['animalId'] as String,
      mutationId: json['mutationId'] as String? ?? 'none',
      isProtected: json['isProtected'] as bool? ?? false,
      bossId: json['bossId'] as String,
      fighterDisplayName: json['fighterDisplayName'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      lastResolvedAt: DateTime.parse(json['lastResolvedAt'] as String),
      currentHp: json['currentHp'] as int,
      maxHp: json['maxHp'] as int,
      battlePower: json['battlePower'] as int? ?? 1,
      battlesWon: json['battlesWon'] as int? ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] as int? ?? 0,
      totalBattleTokensEarned: json['totalBattleTokensEarned'] as int? ?? 0,
    );
  }
}

/// Summary shown when a background auto battle completes.
class AutoBattleCompletionSummary {
  const AutoBattleCompletionSummary({
    required this.fighterDisplayName,
    required this.bossName,
    required this.battlesWon,
    required this.totalCoinsEarned,
    required this.totalBattleTokensEarned,
    required this.finalHp,
    required this.reason,
  });

  final String fighterDisplayName;
  final String bossName;
  final int battlesWon;
  final int totalCoinsEarned;
  final int totalBattleTokensEarned;
  final int finalHp;
  final AutoBattleCompletionReason reason;

  String get notificationMessage {
    if (reason == AutoBattleCompletionReason.capReached) {
      return 'Auto battle finished! $battlesWon wins. (Limit reached)';
    }
    return 'Auto battle finished! $battlesWon wins.';
  }
}
