import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saf/saf.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/theme.dart' show ThemeSeedOption;
import '../../services/file_import_service.dart';
import '../database/database.dart' show BreakCueMode;

/// Global defaults applied when creating a new practice set. Each set (and
/// each entry within it) can still override any of these individually -
/// see [PracticeSets]/[SetEntries] - this only seeds the initial values.
class SetDefaults {
  const SetDefaults({
    required this.tempoPercent,
    required this.playDurationSeconds,
    required this.breakSeconds,
  });

  final int tempoPercent;
  final int playDurationSeconds;
  final int breakSeconds;

  SetDefaults copyWith({
    int? tempoPercent,
    int? playDurationSeconds,
    int? breakSeconds,
  }) {
    return SetDefaults(
      tempoPercent: tempoPercent ?? this.tempoPercent,
      playDurationSeconds: playDurationSeconds ?? this.playDurationSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
    );
  }
}

/// Persists app-wide settings (new-set defaults, music root folder) to
/// [SharedPreferences] so they survive app restarts.
class AppSettingsRepository {
  AppSettingsRepository(this._prefs);
  final SharedPreferences _prefs;
  final _saf = Saf();

  static const _kTempo = 'default_tempo_percent';
  static const _kPlay = 'default_play_duration_seconds';
  static const _kBreak = 'default_break_seconds';
  static const _kFade = 'fade_out_seconds';
  static const _kBreakCueMode = 'break_cue_mode';
  static const _kBreakCueVolume = 'break_cue_volume_percent';
  static const _kVolumeBoost = 'volume_boost_db';
  static const _kAudioNormalization = 'audio_normalization_enabled';
  static const _kMusicRootFolder = 'music_root_folder';
  static const _kThemeSeedOption = 'theme_seed_option';
  static const _kTempoAlgorithm = 'tempo_algorithm';

  String get musicRootFolder =>
      _prefs.getString(_kMusicRootFolder) ?? AppDefaults.musicRootFolder;

  Future<void> saveMusicRootFolder(String path) =>
      _prefs.setString(_kMusicRootFolder, path);

  /// Opens the system directory picker and resolves the result to a plain
  /// filesystem path so [MusicLibraryScanner] can scan it directly. Returns
  /// null if the user cancelled, or if the picked folder isn't on the
  /// device's primary storage volume (no direct path available there).
  Future<String?> pickMusicRootFolder() async {
    final dir = await _saf.pickDirectory();
    if (dir == null) return null;
    return resolvePrimaryStoragePath(dir.uri);
  }

  SetDefaults get setDefaults => SetDefaults(
    tempoPercent: _prefs.getInt(_kTempo) ?? AppDefaults.tempoPercent,
    playDurationSeconds:
        _prefs.getInt(_kPlay) ?? AppDefaults.playDurationSeconds,
    breakSeconds: _prefs.getInt(_kBreak) ?? AppDefaults.breakSeconds,
  );

  Future<void> saveSetDefaults(SetDefaults d) async {
    await _prefs.setInt(_kTempo, d.tempoPercent);
    await _prefs.setInt(_kPlay, d.playDurationSeconds);
    await _prefs.setInt(_kBreak, d.breakSeconds);
  }

  /// The break cue is a single global behavior (not per-set) - how rarely
  /// it's changed doesn't warrant re-deciding it for every practice set.
  String get breakCueMode =>
      _prefs.getString(_kBreakCueMode) ?? BreakCueMode.silence;

  Future<void> saveBreakCueMode(String mode) =>
      _prefs.setString(_kBreakCueMode, mode);

  /// Volume for whichever break cue is currently selected (ambient track or
  /// beep), as a percentage - a single global setting for the same reason
  /// as [breakCueMode].
  int get breakCueVolumePercent =>
      _prefs.getInt(_kBreakCueVolume) ?? AppDefaults.breakCueVolumePercent;

  Future<void> saveBreakCueVolumePercent(int percent) =>
      _prefs.setInt(_kBreakCueVolume, percent);

  /// Overall volume boost (see [VolumeBoostLimits]) applied to all
  /// playback - songs, break cue, and beep alike - via Android's
  /// LoudnessEnhancer. A single global setting: the device's max volume
  /// not being loud enough is a property of the room/speakers, not of
  /// whatever happens to be playing.
  double get volumeBoostDb =>
      _prefs.getDouble(_kVolumeBoost) ?? AppDefaults.volumeBoostDb;

  Future<void> saveVolumeBoostDb(double db) =>
      _prefs.setDouble(_kVolumeBoost, db);

  /// Whether songs are normalized to a consistent target loudness (see
  /// `AudioPlayerHandler.setAudioNormalization`) - a single global setting,
  /// same reasoning as [volumeBoostDb].
  bool get audioNormalizationEnabled =>
      _prefs.getBool(_kAudioNormalization) ??
      AppDefaults.audioNormalizationEnabled;

  Future<void> saveAudioNormalizationEnabled(bool enabled) =>
      _prefs.setBool(_kAudioNormalization, enabled);

  /// Also a single global behavior, for the same reason as [breakCueMode].
  int get fadeOutSeconds => _prefs.getInt(_kFade) ?? AppDefaults.fadeOutSeconds;

  Future<void> saveFadeOutSeconds(int seconds) =>
      _prefs.setInt(_kFade, seconds);

  /// The app-icon theme-cycling easter egg's current choice - see
  /// [ThemeSeedOption].
  ThemeSeedOption get themeSeedOption {
    final raw = _prefs.getString(_kThemeSeedOption);
    return ThemeSeedOption.values.firstWhere(
      (o) => o.name == raw,
      orElse: () => ThemeSeedOption.green,
    );
  }

  Future<void> saveThemeSeedOption(ThemeSeedOption option) =>
      _prefs.setString(_kThemeSeedOption, option.name);

  /// The tempo-stretch DSP algorithm (see [TempoAlgorithm]) - a single
  /// global setting, not something worth deciding per practice set.
  TempoAlgorithm get tempoAlgorithm {
    final raw = _prefs.getString(_kTempoAlgorithm);
    return TempoAlgorithm.values.firstWhere(
      (a) => a.name == raw,
      orElse: () => TempoAlgorithm.rubberband,
    );
  }

  Future<void> saveTempoAlgorithm(TempoAlgorithm algorithm) =>
      _prefs.setString(_kTempoAlgorithm, algorithm.name);
}

class SetDefaultsController extends StateNotifier<SetDefaults> {
  SetDefaultsController(this._repo) : super(_repo.setDefaults);
  final AppSettingsRepository _repo;

  Future<void> update(SetDefaults defaults) async {
    state = defaults;
    await _repo.saveSetDefaults(defaults);
  }
}

class MusicRootFolderController extends StateNotifier<String> {
  MusicRootFolderController(this._repo) : super(_repo.musicRootFolder);
  final AppSettingsRepository _repo;

  Future<void> update(String path) async {
    state = path;
    await _repo.saveMusicRootFolder(path);
  }
}

class BreakCueModeController extends StateNotifier<String> {
  BreakCueModeController(this._repo) : super(_repo.breakCueMode);
  final AppSettingsRepository _repo;

  Future<void> update(String mode) async {
    state = mode;
    await _repo.saveBreakCueMode(mode);
  }
}

class BreakCueVolumeController extends StateNotifier<int> {
  BreakCueVolumeController(this._repo) : super(_repo.breakCueVolumePercent);
  final AppSettingsRepository _repo;

  Future<void> update(int percent) async {
    state = percent;
    await _repo.saveBreakCueVolumePercent(percent);
  }
}

class VolumeBoostController extends StateNotifier<double> {
  VolumeBoostController(this._repo) : super(_repo.volumeBoostDb);
  final AppSettingsRepository _repo;

  Future<void> update(double db) async {
    state = db;
    await _repo.saveVolumeBoostDb(db);
  }
}

class AudioNormalizationController extends StateNotifier<bool> {
  AudioNormalizationController(this._repo) : super(_repo.audioNormalizationEnabled);
  final AppSettingsRepository _repo;

  Future<void> update(bool enabled) async {
    state = enabled;
    await _repo.saveAudioNormalizationEnabled(enabled);
  }
}

class FadeOutSecondsController extends StateNotifier<int> {
  FadeOutSecondsController(this._repo) : super(_repo.fadeOutSeconds);
  final AppSettingsRepository _repo;

  Future<void> update(int seconds) async {
    state = seconds;
    await _repo.saveFadeOutSeconds(seconds);
  }
}

class TempoAlgorithmController extends StateNotifier<TempoAlgorithm> {
  TempoAlgorithmController(this._repo) : super(_repo.tempoAlgorithm);
  final AppSettingsRepository _repo;

  Future<void> update(TempoAlgorithm algorithm) async {
    state = algorithm;
    await _repo.saveTempoAlgorithm(algorithm);
  }
}

class ThemeSeedController extends StateNotifier<ThemeSeedOption> {
  ThemeSeedController(this._repo) : super(_repo.themeSeedOption);
  final AppSettingsRepository _repo;

  /// Advances to the next option after [state], skipping [ThemeSeedOption.system]
  /// when [systemAvailable] is false. If the persisted option is no longer
  /// available (e.g. `system` was picked on a device that later doesn't
  /// offer one), this just resets to the first available option instead of
  /// getting stuck.
  Future<void> cycle({required bool systemAvailable}) async {
    final available = ThemeSeedOption.values
        .where((o) => systemAvailable || o != ThemeSeedOption.system)
        .toList();
    final currentIndex = available.indexOf(state);
    final next = available[(currentIndex + 1) % available.length];
    state = next;
    await _repo.saveThemeSeedOption(next);
  }
}
