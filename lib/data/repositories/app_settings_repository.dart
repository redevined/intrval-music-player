import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saf/saf.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
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
  static const _kMusicRootFolder = 'music_root_folder';

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

  /// Also a single global behavior, for the same reason as [breakCueMode].
  int get fadeOutSeconds => _prefs.getInt(_kFade) ?? AppDefaults.fadeOutSeconds;

  Future<void> saveFadeOutSeconds(int seconds) =>
      _prefs.setInt(_kFade, seconds);
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

class FadeOutSecondsController extends StateNotifier<int> {
  FadeOutSecondsController(this._repo) : super(_repo.fadeOutSeconds);
  final AppSettingsRepository _repo;

  Future<void> update(int seconds) async {
    state = seconds;
    await _repo.saveFadeOutSeconds(seconds);
  }
}
