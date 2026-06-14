/// Developer-only forced hatch override for a single result slot.
class ForcedHatchResult {
  const ForcedHatchResult({
    required this.animalId,
    required this.mutationId,
  });

  final String animalId;
  final String mutationId;

  ForcedHatchResult copyWith({String? animalId, String? mutationId}) {
    return ForcedHatchResult(
      animalId: animalId ?? this.animalId,
      mutationId: mutationId ?? this.mutationId,
    );
  }
}

/// Whether the active dev override applies to one or three hatches.
enum ForcedHatchMode {
  none,
  single,
  triple,
}
