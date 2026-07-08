/// Guards cinematic phase sounds so each key plays at most once.
class CinematicSoundGuard {
  final Set<String> _played = {};

  bool playOnce(String key, void Function() play) {
    if (_played.contains(key)) return false;
    _played.add(key);
    play();
    return true;
  }

  void maybeAt(double timeMs, String key, double startMs, void Function() play) {
    if (timeMs >= startMs) playOnce(key, play);
  }
}
