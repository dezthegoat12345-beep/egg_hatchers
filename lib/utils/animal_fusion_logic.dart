import 'dart:math';

import '../data/game_data.dart';
import '../models/mutation.dart';
import '../models/owned_animal.dart';

/// Rules for Animal Fusion v1 — combine 3 same animal/mutation stacks.
abstract final class AnimalFusionLogic {
  AnimalFusionLogic._();

  static const inputQuantity = 3;
  static const luckyJumpChance = 0.10;

  /// Fusion ladder excluding Boss Mutation.
  static const fusionLadder = ['none', 'golden', 'rainbow', 'shadow'];

  static bool isFusionInputMutation(String mutationId) =>
      fusionLadder.contains(mutationId) &&
      mutationId != fusionLadder.last;

  static Mutation? mutationFor(String mutationId) =>
      GameData.mutationById(mutationId);

  static String? nextMutationId(String mutationId, {int jump = 1}) {
    final index = fusionLadder.indexOf(mutationId);
    if (index < 0) return null;
    final target = index + jump;
    if (target >= fusionLadder.length) return null;
    return fusionLadder[target];
  }

  static String resolveResultMutation(String inputMutationId, Random random) {
    final index = fusionLadder.indexOf(inputMutationId);
    if (index < 0 || index >= fusionLadder.length - 1) {
      return inputMutationId;
    }

    final jump = random.nextDouble() < luckyJumpChance ? 2 : 1;
    final targetIndex = min(index + jump, fusionLadder.length - 1);
    return fusionLadder[targetIndex];
  }

  static bool wasLuckyFusion(String inputMutationId, String resultMutationId) {
    final inputIndex = fusionLadder.indexOf(inputMutationId);
    final resultIndex = fusionLadder.indexOf(resultMutationId);
    return resultIndex - inputIndex >= 2;
  }

  static String primaryResultMutationId(String inputMutationId) =>
      nextMutationId(inputMutationId) ?? inputMutationId;

  static String? luckyResultMutationId(String inputMutationId) {
    if (fusionLadder.indexOf(inputMutationId) + 2 >= fusionLadder.length) {
      return null;
    }
    return nextMutationId(inputMutationId, jump: 2);
  }

  static String chanceDescription(String mutationId) {
    final primaryId = primaryResultMutationId(mutationId);
    final primary = mutationFor(primaryId);
    if (primary == null) return '';

    final luckyId = luckyResultMutationId(mutationId);
    if (luckyId == null || luckyId == primaryId) {
      return '100% ${primary.displayName}';
    }

    final lucky = mutationFor(luckyId);
    if (lucky == null) return '100% ${primary.displayName}';

    final luckyPct = (luckyJumpChance * 100).round();
    final normalPct = 100 - luckyPct;
    return '$normalPct% ${primary.displayName}, $luckyPct% ${lucky.displayName}';
  }

  static String? blockReasonText(OwnedAnimal owned, {required bool inBattle}) {
    if (owned.mutationId == 'boss') return 'Boss Mutation cannot fuse';
    if (owned.isEliteReward || owned.isSecretReward || owned.isProtected) {
      return 'Protected';
    }
    if (inBattle) return 'In battle';
    if (!fusionLadder.contains(owned.mutationId)) return 'Cannot fuse';
    if (owned.mutationId == fusionLadder.last) return 'Max mutation';
    if (owned.quantity < inputQuantity) return 'Need 3';
    return null;
  }

  static bool canFuseStack(OwnedAnimal owned, {required bool inBattle}) =>
      blockReasonText(owned, inBattle: inBattle) == null;

  static bool shouldShowInFusionList(OwnedAnimal owned) {
    if (owned.mutationId == 'boss') return true;
    if (owned.isEliteReward || owned.isSecretReward || owned.isProtected) {
      return true;
    }
    return fusionLadder.contains(owned.mutationId);
  }
}

/// Outcome of a successful fusion.
class AnimalFusionOutcome {
  const AnimalFusionOutcome({
    required this.animalId,
    required this.inputMutationId,
    required this.resultMutationId,
    required this.wasLucky,
    required this.displayName,
  });

  final String animalId;
  final String inputMutationId;
  final String resultMutationId;
  final bool wasLucky;
  final String displayName;
}
