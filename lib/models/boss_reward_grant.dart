import 'animal.dart';
import 'mutation.dart';

/// Result of granting a boss victory reward animal.
class BossRewardGrant {
  const BossRewardGrant({
    required this.animal,
    required this.mutation,
  });

  final Animal animal;
  final Mutation mutation;

  String get displayName => mutation.fullName(animal);
}
