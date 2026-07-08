import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/audio_assets.dart';

/// Central music/SFX controller with persisted settings and web-safe playback.
class AudioService extends ChangeNotifier {
  AudioService();

  static const _musicEnabledKey = 'audioMusicEnabled';
  static const _sfxEnabledKey = 'audioSfxEnabled';
  static const _musicVolumeKey = 'audioMusicVolume';
  static const _sfxVolumeKey = 'audioSfxVolume';

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music');
  final List<AudioPlayer> _sfxPlayers = List.generate(
    4,
    (i) => AudioPlayer(playerId: 'sfx_$i'),
  );

  var _musicEnabled = true;
  var _sfxEnabled = true;
  var _musicVolume = 0.6;
  var _sfxVolume = 0.8;
  var _isInitialized = false;
  var _userUnlocked = false;
  MusicTrack? _currentTrack;
  MusicTrack? _pendingTrack;
  var _sfxRoundRobin = 0;
  final Map<Sfx, DateTime> _lastSfxPlayed = {};

  bool get isInitialized => _isInitialized;
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get userUnlocked => _userUnlocked;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicEnabled = prefs.getBool(_musicEnabledKey) ?? true;
      _sfxEnabled = prefs.getBool(_sfxEnabledKey) ?? true;
      _musicVolume = prefs.getDouble(_musicVolumeKey) ?? 0.6;
      _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 0.8;
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('AudioService initialize failed: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Call after the first user gesture (required on Flutter web).
  Future<void> unlockFromUserGesture() async {
    if (_userUnlocked) return;
    _userUnlocked = true;
    final pending = _pendingTrack ?? MusicTrack.hatchery;
    _pendingTrack = null;
    await playMusic(pending);
  }

  Future<void> setMusicEnabled(bool value) async {
    if (_musicEnabled == value) return;
    _musicEnabled = value;
    notifyListeners();
    await _persistBool(_musicEnabledKey, value);
    if (!value) {
      await _stopMusic();
    } else if (_userUnlocked && _currentTrack != null) {
      await playMusic(_currentTrack!);
    } else if (_userUnlocked) {
      await playMusic(MusicTrack.hatchery);
    }
  }

  Future<void> setSfxEnabled(bool value) async {
    if (_sfxEnabled == value) return;
    _sfxEnabled = value;
    notifyListeners();
    await _persistBool(_sfxEnabledKey, value);
  }

  Future<void> setMusicVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    if ((_musicVolume - clamped).abs() < 0.001) return;
    _musicVolume = clamped;
    notifyListeners();
    await _persistDouble(_musicVolumeKey, clamped);
    try {
      await _musicPlayer.setVolume(clamped);
    } catch (_) {}
  }

  Future<void> setSfxVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    if ((_sfxVolume - clamped).abs() < 0.001) return;
    _sfxVolume = clamped;
    notifyListeners();
    await _persistDouble(_sfxVolumeKey, clamped);
  }

  Future<void> playMusic(MusicTrack track) async {
    _pendingTrack = track;
    if (!_musicEnabled) return;
    if (!_userUnlocked) return;

    if (_currentTrack == track) {
      try {
        if (_musicPlayer.state == PlayerState.playing) return;
      } catch (_) {}
    }

    _currentTrack = track;
    _pendingTrack = null;
    await _stopMusic();

    final played = await _tryPlayMusicAsset(track.assetPath);
    if (!played && track == MusicTrack.finalBoss) {
      await _tryPlayMusicAsset(MusicTrack.bossBattle.assetPath);
      _currentTrack = MusicTrack.bossBattle;
    }
  }

  Future<void> stopMusic() => _stopMusic();

  Future<void> playSfx(Sfx sfx, {double volumeScale = 1.0}) async {
    if (!_sfxEnabled || !_userUnlocked) return;
    if (!_canPlaySfx(sfx)) return;

    final player = _sfxPlayers[_sfxRoundRobin++ % _sfxPlayers.length];
    try {
      await player.stop();
      await player.setVolume((_sfxVolume * volumeScale).clamp(0.0, 1.0));
      await player.play(AssetSource(sfx.assetPath));
      _lastSfxPlayed[sfx] = DateTime.now();
    } catch (e) {
      debugPrint('SFX play failed (${sfx.name}): $e');
    }
  }

  /// Short shell-crack SFX for hatches and boss shell breaks.
  Future<void> playEggCrack() => playSfx(Sfx.eggCrack, volumeScale: 0.78);

  bool _canPlaySfx(Sfx sfx) {
    if (sfx.cooldownMs <= 0) return true;
    final last = _lastSfxPlayed[sfx];
    if (last == null) return true;
    return DateTime.now().difference(last).inMilliseconds >= sfx.cooldownMs;
  }

  Future<bool> _tryPlayMusicAsset(String assetPath) async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(AssetSource(assetPath));
      return true;
    } catch (e) {
      debugPrint('Music play failed ($assetPath): $e');
      return false;
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> _persistBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  Future<void> _persistDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (_) {}
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    for (final player in _sfxPlayers) {
      player.dispose();
    }
    super.dispose();
  }
}
