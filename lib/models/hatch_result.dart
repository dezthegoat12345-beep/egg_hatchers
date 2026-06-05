import 'animal.dart';
import 'mutation.dart';

/// The animal and mutation produced when an egg hatches.
class HatchResult {
  const HatchResult({
    required this.animal,
    required this.mutation,
  });

  final Animal animal;
  final Mutation mutation;
}
