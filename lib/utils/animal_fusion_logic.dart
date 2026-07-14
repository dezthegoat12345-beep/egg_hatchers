import 'dart:math';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/mutation.dart';
import '../models/owned_animal.dart';

/// Rules for Animal Fusion — combine 2 same animal/mutation stacks at risk.
abstract final class AnimalFusionLogic {
  AnimalFusionLogic._();

  static const inputQuantity = 2;
  static const successChance = 0.80;
  static const failureChance = 0.20;
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

  static FusionRoll rollFusion(String inputMutationId, Random random) {
    if (random.nextDouble() >= successChance) {
      return const FusionRoll(succeeded: false);
    }

    final resultMutationId = resolveResultMutation(inputMutationId, random);
    return FusionRoll(
      succeeded: true,
      resultMutationId: resultMutationId,
      wasLucky: wasLuckyFusion(inputMutationId, resultMutationId),
    );
  }

  static String primaryResultMutationId(String inputMutationId) =>
      nextMutationId(inputMutationId) ?? inputMutationId;

  static String? luckyResultMutationId(String inputMutationId) {
    if (fusionLadder.indexOf(inputMutationId) + 2 >= fusionLadder.length) {
      return null;
    }
    return nextMutationId(inputMutationId, jump: 2);
  }

  static String successResultLabel(String mutationId, Animal animal) {
    final primaryId = primaryResultMutationId(mutationId);
    return mutationFor(primaryId)?.fullName(animal) ?? animal.name;
  }

  static String? luckyResultLabel(String mutationId, Animal animal) {
    final luckyId = luckyResultMutationId(mutationId);
    if (luckyId == null || luckyId == primaryResultMutationId(mutationId)) {
      return null;
    }
    return mutationFor(luckyId)?.fullName(animal);
  }

  static String? blockReasonText(OwnedAnimal owned, {required bool inBattle}) {
    if (owned.mutationId == 'boss') return 'Boss Mutation cannot fuse';
    if (owned.isEliteReward || owned.isSecretReward || owned.isProtected) {
      return 'Protected';
    }
    if (inBattle) return 'In battle';
    if (!fusionLadder.contains(owned.mutationId)) return 'Cannot fuse';
    if (owned.mutationId == fusionLadder.last) return 'Max mutation';
    if (owned.quantity < inputQuantity) return 'Need 2';
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

/// Result of rolling fusion odds after consuming inputs.
class FusionRoll {
  const FusionRoll({
    required this.succeeded,
    this.resultMutationId,
    this.wasLucky = false,
  });

  final bool succeeded;
  final String? resultMutationId;
  final bool wasLucky;
}

/// Outcome of a confirmed fusion attempt.
class AnimalFusionOutcome {
  const AnimalFusionOutcome({
    required this.animalId,
    required this.inputMutationId,
    required this.succeeded,
    required this.inputDisplayName,
    this.resultMutationId,
    this.wasLucky = false,
    this.displayName,
  });

  final String animalId;
  final String inputMutationId;
  final bool succeeded;
  final String inputDisplayName;
  final String? resultMutationId;
  final bool wasLucky;
  final String? displayName;
}
