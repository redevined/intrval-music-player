import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../services/notification_permission.dart';
import 'now_playing_controller.dart';

enum SessionPhase { loading, playing, breaking, complete }

/// A set entry with every "inherit from the set" value already resolved to a
/// concrete number, so playback logic never has to re-check for nulls.
class ResolvedSetEntry {
  ResolvedSetEntry({
    required this.entry,
    required this.tempoPercent,
    required this.playDurationSeconds,
    required this.breakSeconds,
  });

  final SetEntry entry;
  final int tempoPercent;
  final int playDurationSeconds;
  final int breakSeconds;

  String get label => entry.label;
}

/// Everything the player UI needs to render a running practice set.
class PracticeSessionState {
  PracticeSessionState({
    required this.practiceSet,
    required this.entries,
    required this.entryIndex,
    required this.phase,
    this.currentSong,
    this.tempoPercent = 100,
    this.breakSecondsRemaining = 0,
    this.breakTotalSeconds = 0,
    this.paused = false,
    this.cutoffRemainingSeconds,
    this.activeBreakCueMode,
  });

  final PracticeSet practiceSet;
  final List<ResolvedSetEntry> entries;
  final int entryIndex;
  final SessionPhase phase;
  final Song? currentSong;

  /// Tempo actually applied to playback right now. Starts from the current
  /// entry's configured tempo and can be nudged live from the player.
  final int tempoPercent;

  final int breakSecondsRemaining;
  final int breakTotalSeconds;
  final bool paused;

  /// Seconds left before the current song is faded out and cut off, ticking
  /// down only while actually playing (frozen while paused). Null outside
  /// [SessionPhase.playing].
  final int? cutoffRemainingSeconds;

  /// The break-cue mode snapshotted from the global setting when the current
  /// break started, so it can't change mid-break if the setting is edited
  /// while a break is already running. Null outside [SessionPhase.breaking].
  final String? activeBreakCueMode;

  ResolvedSetEntry? get currentEntry =>
      entryIndex >= 0 && entryIndex < entries.length ? entries[entryIndex] : null;

  ResolvedSetEntry? get nextEntry =>
      entryIndex + 1 < entries.length ? entries[entryIndex + 1] : null;

  bool get isActive => phase != SessionPhase.complete;

  /// 1-based position for display, e.g. "2 / 5".
  String get positionLabel => '${entryIndex + 1} / ${entries.length}';

  PracticeSessionState copyWith({
    PracticeSet? practiceSet,
    List<ResolvedSetEntry>? entries,
    int? entryIndex,
    SessionPhase? phase,
    Song? currentSong,
    bool clearCurrentSong = false,
    int? tempoPercent,
    int? breakSecondsRemaining,
    int? breakTotalSeconds,
    bool? paused,
    int? cutoffRemainingSeconds,
    bool clearCutoffRemaining = false,
    String? activeBreakCueMode,
    bool clearActiveBreakCueMode = false,
  }) {
    return PracticeSessionState(
      practiceSet: practiceSet ?? this.practiceSet,
      entries: entries ?? this.entries,
      entryIndex: entryIndex ?? this.entryIndex,
      phase: phase ?? this.phase,
      currentSong: clearCurrentSong ? null : (currentSong ?? this.currentSong),
      tempoPercent: tempoPercent ?? this.tempoPercent,
      breakSecondsRemaining: breakSecondsRemaining ?? this.breakSecondsRemaining,
      breakTotalSeconds: breakTotalSeconds ?? this.breakTotalSeconds,
      paused: paused ?? this.paused,
      cutoffRemainingSeconds: clearCutoffRemaining
          ? null
          : (cutoffRemainingSeconds ?? this.cutoffRemainingSeconds),
      activeBreakCueMode: clearActiveBreakCueMode
          ? null
          : (activeBreakCueMode ?? this.activeBreakCueMode),
    );
  }
}

/// Runs a [PracticeSet] top to bottom: for each entry, picks a random
/// (non-immediately-repeating) song from its source, plays it with the
/// entry's effective tempo until it ends naturally or hits its play-time
/// cutoff (fading out), then a break with the configured audio cue, then
/// advances.
///
/// This lives in a controller rather than in the session screen's State so a
/// session keeps running when the user navigates away - the screen is just a
/// view onto it, and the mini-player offers the same controls from anywhere.
class PracticeSessionController extends StateNotifier<PracticeSessionState?> {
  PracticeSessionController(this._ref) : super(null);

  final Ref _ref;
  final _random = Random();

  Timer? _playTicker;
  Timer? _breakTicker;

  /// Per-source (playlist/folder id) draw-without-replacement pools: songs
  /// already played from that source since it was last exhausted, so
  /// picking never repeats one until every song from it has come up. Purely
  /// in-memory and scoped to the running session - cleared in [start], so a
  /// stopped-and-restarted session forgets what it already played, same as
  /// a shuffled queue starting over. See [_pickSong].
  final Map<String, Set<String>> _usedSongIds = {};

  /// The last song actually played per source, kept alongside
  /// [_usedSongIds] so that the moment a pool is exhausted and reshuffled,
  /// the immediately-following pick still doesn't repeat it back-to-back.
  final Map<String, String> _lastPlayedBySource = {};

  /// Guards against a stale timer/callback from a previous entry (or a
  /// previous session entirely) mutating state after we've moved on.
  int _generation = 0;

  @override
  void dispose() {
    _playTicker?.cancel();
    _breakTicker?.cancel();
    super.dispose();
  }

  /// Starts [practiceSet] from the top, replacing any session or ad-hoc queue
  /// already using the shared audio handler.
  Future<void> start(PracticeSet practiceSet) async {
    _generation++;
    unawaited(ensureNotificationPermission());
    _playTicker?.cancel();
    _breakTicker?.cancel();
    _usedSongIds.clear();
    _lastPlayedBySource.clear();

    // The mini-player would otherwise show a stale ad-hoc queue and fight
    // over the same handler.
    _ref.read(nowPlayingProvider.notifier).clearSilently();
    final handler = _ref.read(audioHandlerProvider);
    handler.onTrackComplete = _onTrackNaturalEnd;
    // A set runs forwards only (see PracticeSessionScreen) - lock-screen
    // "previous" has nothing sensible to do here.
    handler.onSkipNext = skip;
    handler.onSkipPrevious = null;

    final rawEntries =
        await _ref.read(practiceSetRepositoryProvider).watchEntries(practiceSet.id).first;
    final entries = rawEntries.map((e) => _resolve(e, practiceSet)).toList();

    state = PracticeSessionState(
      practiceSet: practiceSet,
      entries: entries,
      entryIndex: 0,
      phase: entries.isEmpty ? SessionPhase.complete : SessionPhase.loading,
    );
    if (entries.isEmpty) return;
    await _playEntry(0);
  }

  ResolvedSetEntry _resolve(SetEntry e, PracticeSet set) {
    return ResolvedSetEntry(
      entry: e,
      tempoPercent: e.tempoPercent ?? set.defaultTempoPercent,
      playDurationSeconds: e.playDurationSeconds ?? set.defaultPlayDurationSeconds,
      breakSeconds: e.breakSeconds ?? set.defaultBreakSeconds,
    );
  }

  Future<List<Song>> _candidateSongs(SetEntry entry) async {
    if (entry.playlistId != null) {
      return _ref.read(playlistRepositoryProvider).watchSongs(entry.playlistId!).first;
    }
    if (entry.folderId != null) {
      return _ref.read(songRepositoryProvider).songsForFolder(entry.folderId!);
    }
    return [];
  }

  Future<void> _playEntry(int index) async {
    final s = state;
    if (s == null) return;
    final generation = ++_generation;
    final resolved = s.entries[index];

    state = s.copyWith(
      entryIndex: index,
      phase: SessionPhase.loading,
      tempoPercent: resolved.tempoPercent,
      paused: false,
      clearCurrentSong: true,
      clearActiveBreakCueMode: true,
    );

    final candidates = await _candidateSongs(resolved.entry);
    if (generation != _generation) return;
    if (candidates.isEmpty) {
      // Nothing to play for this entry - skip to the next one.
      _advance();
      return;
    }

    final sourceKey = resolved.entry.playlistId ?? resolved.entry.folderId!;
    final song = _pickSong(candidates, sourceKey);

    final handler = _ref.read(audioHandlerProvider);
    try {
      await handler
          .loadTrack(
            uriOrPath: song.uri,
            title: song.title,
            artist: song.artist,
            album: song.album,
            duration:
                song.durationMs != null ? Duration(milliseconds: song.durationMs!) : null,
            tempoPercent: resolved.tempoPercent.toDouble(),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Failed/stuck load (missing file, revoked permission, decode error) -
      // don't wedge the session on this entry.
      if (generation != _generation) return;
      _advance();
      return;
    }
    if (generation != _generation) return;

    unawaited(handler.play());

    state = state?.copyWith(
      phase: SessionPhase.playing,
      currentSong: song,
      cutoffRemainingSeconds: resolved.playDurationSeconds,
    );

    _startPlayTicker(generation, resolved);
  }

  /// Counts down the current entry's play-time cutoff a second at a time -
  /// mirroring [_startBreak]'s ticker - so it can be frozen while paused
  /// instead of firing on real wall-clock time regardless of playback state.
  void _startPlayTicker(int generation, ResolvedSetEntry resolved) {
    _playTicker?.cancel();
    _playTicker = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (generation != _generation) {
        timer.cancel();
        return;
      }
      final current = state;
      if (current == null || current.phase != SessionPhase.playing) {
        timer.cancel();
        return;
      }
      if (current.paused) return;

      final remaining = (current.cutoffRemainingSeconds ?? 0) - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = current.copyWith(cutoffRemainingSeconds: 0);
        final fadeOutSeconds = _ref.read(fadeOutSecondsProvider);
        await _ref
            .read(audioHandlerProvider)
            .fadeOutAndStop(Duration(seconds: fadeOutSeconds));
        if (generation != _generation) return;
        _startBreak();
      } else {
        state = current.copyWith(cutoffRemainingSeconds: remaining);
      }
    });
  }

  /// Draws a song from [candidates] without replacement, tracked per
  /// [sourceKey] (a playlist/folder id - shared by every entry pulling from
  /// the same source, so e.g. two entries both using playlist "JV" draw
  /// from the same pool rather than each avoiding repeats independently).
  /// Once every candidate has come up, the pool reshuffles - but the song
  /// that had just played from this source is still excluded from that
  /// very next pick, so a reshuffle never immediately repeats it. See
  /// [_usedSongIds]/[_lastPlayedBySource].
  Song _pickSong(List<Song> candidates, String sourceKey) {
    if (candidates.length == 1) return candidates.first;

    final used = _usedSongIds.putIfAbsent(sourceKey, () => <String>{});
    var pool = candidates.where((s) => !used.contains(s.id)).toList();

    if (pool.isEmpty) {
      used.clear();
      final lastPlayed = _lastPlayedBySource[sourceKey];
      pool = candidates.where((s) => s.id != lastPlayed).toList();
    }

    final song = pool[_random.nextInt(pool.length)];
    used.add(song.id);
    _lastPlayedBySource[sourceKey] = song.id;
    return song;
  }

  void _onTrackNaturalEnd() {
    if (state?.phase != SessionPhase.playing) return;
    _playTicker?.cancel();
    _startBreak();
  }

  Future<void> _startBreak() async {
    final s = state;
    final resolved = s?.currentEntry;
    if (s == null || resolved == null) return;

    // Reaching the last entry only skips the break if the set is actually
    // about to end - a break after the last entry would otherwise just be
    // dead air before the completion screen. With repeat on, the last entry
    // is followed by the first one again, exactly like any other
    // entry-to-entry transition, so it still gets its break.
    final isLastEntry = s.entryIndex >= s.entries.length - 1;
    final willLoop = isLastEntry && s.practiceSet.repeatEnabled;
    // A zero-length break is likewise skipped entirely - no cue of any kind
    // should play for a break that isn't actually happening.
    if ((isLastEntry && !willLoop) || resolved.breakSeconds <= 0) {
      _advance();
      return;
    }

    final generation = ++_generation;

    // Snapshotted once per break from the global setting, so an in-flight
    // break isn't disrupted by the user changing the setting mid-break.
    final mode = _ref.read(breakCueModeProvider);
    final cueVolume = _ref.read(breakCueVolumeProvider) / 100.0;

    state = s.copyWith(
      phase: SessionPhase.breaking,
      breakSecondsRemaining: resolved.breakSeconds,
      breakTotalSeconds: resolved.breakSeconds,
      clearCutoffRemaining: true,
      activeBreakCueMode: mode,
    );

    final handler = _ref.read(audioHandlerProvider);

    // Fade duration for the break audio track, clamped so a very short
    // break still leaves room for both a fade-in and a fade-out.
    final trackFadeSeconds =
        min(AppDefaults.breakTrackFadeSeconds, resolved.breakSeconds ~/ 2);
    final trackFade = Duration(seconds: trackFadeSeconds);

    if (mode == BreakCueMode.ambientSong) {
      unawaited(handler.playBreakTrack(fadeDuration: trackFade, targetVolume: cueVolume));
    }

    // The beep is a fixed lead time before the break ends; if the break
    // itself is shorter than that, it just fires right away.
    final beepAtRemaining =
        min(AppDefaults.beepLeadSeconds, resolved.breakSeconds);
    if (mode == BreakCueMode.beepBeforeEnd &&
        beepAtRemaining >= resolved.breakSeconds) {
      unawaited(handler.playBeep(volume: cueVolume));
    }

    _breakTicker?.cancel();
    _breakTicker = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (generation != _generation) {
        timer.cancel();
        return;
      }
      final current = state;
      if (current == null) {
        timer.cancel();
        return;
      }
      if (current.paused) return;

      final remaining = current.breakSecondsRemaining - 1;
      state = current.copyWith(breakSecondsRemaining: remaining);

      if (mode == BreakCueMode.beepBeforeEnd &&
          remaining == beepAtRemaining &&
          beepAtRemaining < resolved.breakSeconds) {
        unawaited(handler.playBeep(volume: cueVolume));
      }

      if (mode == BreakCueMode.ambientSong && remaining == trackFadeSeconds) {
        unawaited(handler.fadeOutAndStopBreakTrack(fadeDuration: trackFade));
      }

      if (remaining <= 0) {
        timer.cancel();
        if (mode == BreakCueMode.ambientSong) {
          await handler.stopBreakTrack();
        }
        _advance();
      }
    });
  }

  void _advance() {
    final s = state;
    if (s == null) return;
    if (s.entryIndex < s.entries.length - 1) {
      _playEntry(s.entryIndex + 1);
    } else if (s.practiceSet.repeatEnabled) {
      _playEntry(0);
    } else {
      _generation++;
      _playTicker?.cancel();
      _breakTicker?.cancel();
      state = s.copyWith(phase: SessionPhase.complete, clearCurrentSong: true);
    }
  }

  void togglePause() {
    final s = state;
    if (s == null) return;
    final paused = !s.paused;
    state = s.copyWith(paused: paused);
    final handler = _ref.read(audioHandlerProvider);
    // During a break the countdown itself is what's "playing"; the ticker
    // checks `paused` on its own, so only real playback needs toggling.
    if (s.phase == SessionPhase.playing) {
      paused ? handler.pause() : unawaited(handler.play());
    } else if (s.phase == SessionPhase.breaking &&
        s.activeBreakCueMode == BreakCueMode.ambientSong) {
      paused ? handler.pauseBreakTrack() : unawaited(handler.resumeBreakTrack());
    }
  }

  /// Skips whatever is happening now and moves to the next entry.
  void skip() {
    final s = state;
    if (s == null) return;
    _playTicker?.cancel();
    _breakTicker?.cancel();
    final handler = _ref.read(audioHandlerProvider);
    handler.stop();
    if (s.phase == SessionPhase.breaking &&
        s.activeBreakCueMode == BreakCueMode.ambientSong) {
      handler.stopBreakTrack();
    }
    _advance();
  }

  Future<void> setTempo(int percent) async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(tempoPercent: percent);
    await _ref.read(audioHandlerProvider).setTempoPercent(percent.toDouble());
  }

  /// Toggles the current song's favorite flag. `PracticeSessionState.
  /// currentSong` is a local snapshot (picked once when the entry started),
  /// so - same as [NowPlayingController.toggleFavoriteCurrent] - a bare DB
  /// write alone wouldn't make the player's heart icon/menu label flip.
  Future<void> toggleFavoriteCurrentSong() async {
    final s = state;
    final song = s?.currentSong;
    if (s == null || song == null) return;
    final favorite = !song.isFavorite;
    await _ref.read(songRepositoryProvider).setFavorite(song.id, favorite);
    state = s.copyWith(currentSong: song.copyWith(isFavorite: favorite));
  }

  /// Patches the current song's local snapshot with freshly-edited
  /// metadata (see [SongActionsMenu.onSongUpdated]) - same reasoning as
  /// [toggleFavoriteCurrentSong].
  void updateCurrentSongLocally(Song updated) {
    final s = state;
    if (s == null || s.currentSong == null) return;
    state = s.copyWith(currentSong: updated);
  }

  /// Removes the current song from the entry's source playlist (see
  /// [SetEntry.playlistId]) - a DB-only detach, same as
  /// [NowPlayingController.removeCurrentFromPlaylist]: playback and the
  /// running session are left untouched. A set entry pulls a fresh
  /// candidate from its source each time it's played, so this only affects
  /// future runs, not the song currently playing.
  Future<void> removeCurrentSongFromPlaylist() async {
    final s = state;
    final song = s?.currentSong;
    final playlistId = s?.currentEntry?.entry.playlistId;
    if (song == null || playlistId == null) return;
    await _ref.read(playlistRepositoryProvider).removeSong(playlistId, song.id);
  }

  Future<void> restart() async {
    final s = state;
    if (s == null) return;
    await start(s.practiceSet);
  }

  /// Ends the session and releases the audio handler back to the ad-hoc
  /// queue's controller.
  Future<void> stop() async {
    if (state == null) return;
    _generation++;
    _playTicker?.cancel();
    _breakTicker?.cancel();
    state = null;
    final handler = _ref.read(audioHandlerProvider);
    await handler.stop();
    await handler.stopBreakTrack();
    _ref.read(nowPlayingProvider.notifier).attachTrackCompleteHandler();
  }
}

/// Deliberately not `autoDispose`: the session has to outlive the screen that
/// started it so playback continues when the user navigates away.
final practiceSessionProvider =
    StateNotifierProvider<PracticeSessionController, PracticeSessionState?>((ref) {
  return PracticeSessionController(ref);
});
