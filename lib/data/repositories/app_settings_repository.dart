import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../database/database.dart' show BreakCueMode;

/// Global defaults applied when creating a new practice set. Each set (and
/// each entry within it) can still override any of these individually -
/// see [PracticeSets]/[SetEntries] - this only seeds the initial values.
class SetDefaults {
  const SetDefaults({
    required this.tempoPercent,
    required this.playDurationSeconds,
    required this.breakSeconds,
    required this.fadeOutSeconds,
    required this.breakCueMode,
    required this.beepLeadSeconds,
    this.ambientSongId,
  });

  final int tempoPercent;
  final int playDurationSeconds;
  final int breakSeconds;
  final int fadeOutSeconds;
  final String breakCueMode;
  final int beepLeadSeconds;
  final String? ambientSongId;

  SetDefaults copyWith({
    int? tempoPercent,
    int? playDurationSeconds,
    int? breakSeconds,
    int? fadeOutSeconds,
    String? breakCueMode,
    int? beepLeadSeconds,
    String? ambientSongId,
  }) {
    return SetDefaults(
      tempoPercent: tempoPercent ?? this.tempoPercent,
      playDurationSeconds: playDurationSeconds ?? this.playDurationSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      fadeOutSeconds: fadeOutSeconds ?? this.fadeOutSeconds,
      breakCueMode: breakCueMode ?? this.breakCueMode,
      beepLeadSeconds: beepLeadSeconds ?? this.beepLeadSeconds,
      ambientSongId: ambientSongId ?? this.ambientSongId,
    );
  }
}

/// Persists app-wide settings (currently just the new-set defaults) to
/// [SharedPreferences] so they survive app restarts.
class AppSettingsRepository {
  AppSettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _kTempo = 'default_tempo_percent';
  static const _kPlay = 'default_play_duration_seconds';
  static const _kBreak = 'default_break_seconds';
  static const _kFade = 'default_fade_out_seconds';
  static const _kBreakCueMode = 'default_break_cue_mode';
  static const _kBeepLead = 'default_beep_lead_seconds';
  static const _kAmbientSongId = 'default_ambient_song_id';

  SetDefaults get setDefaults => SetDefaults(
        tempoPercent: _prefs.getInt(_kTempo) ?? AppDefaults.tempoPercent,
        playDurationSeconds:
            _prefs.getInt(_kPlay) ?? AppDefaults.playDurationSeconds,
        breakSeconds: _prefs.getInt(_kBreak) ?? AppDefaults.breakSeconds,
        fadeOutSeconds: _prefs.getInt(_kFade) ?? AppDefaults.fadeOutSeconds,
        breakCueMode: _prefs.getString(_kBreakCueMode) ?? BreakCueMode.silence,
        beepLeadSeconds:
            _prefs.getInt(_kBeepLead) ?? AppDefaults.beepLeadSeconds,
        ambientSongId: _prefs.getString(_kAmbientSongId),
      );

  Future<void> saveSetDefaults(SetDefaults d) async {
    await _prefs.setInt(_kTempo, d.tempoPercent);
    await _prefs.setInt(_kPlay, d.playDurationSeconds);
    await _prefs.setInt(_kBreak, d.breakSeconds);
    await _prefs.setInt(_kFade, d.fadeOutSeconds);
    await _prefs.setString(_kBreakCueMode, d.breakCueMode);
    await _prefs.setInt(_kBeepLead, d.beepLeadSeconds);
    if (d.ambientSongId != null) {
      await _prefs.setString(_kAmbientSongId, d.ambientSongId!);
    } else {
      await _prefs.remove(_kAmbientSongId);
    }
  }
}

class SetDefaultsController extends StateNotifier<SetDefaults> {
  SetDefaultsController(this._repo) : super(_repo.setDefaults);
  final AppSettingsRepository _repo;

  Future<void> update(SetDefaults defaults) async {
    state = defaults;
    await _repo.saveSetDefaults(defaults);
  }
}
