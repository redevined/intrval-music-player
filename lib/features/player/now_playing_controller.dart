import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../services/notification_permission.dart';
import 'practice_session_controller.dart';

enum QueueRepeatMode { off, all, one }

/// The currently-playing ad-hoc queue (Library/Playlist playback), shared
/// across the whole app so a persistent mini-player can show/control it
/// regardless of which tab is active.
class NowPlayingState {
  NowPlayingState({
    required this.songs,
    required this.order,
    required this.index,
    required this.tempoPercent,
    this.queueTitle,
    this.sourcePlaylistId,
    this.shuffleEnabled = false,
    this.repeatMode = QueueRepeatMode.off,
  });

  final List<Song> songs;

  /// Playback order: a permutation of `songs`' indices. Sequential
  /// (`[0, 1, 2, ...]`) with shuffle off; randomized with it on. [index]
  /// points into this list, not directly into [songs].
  final List<int> order;
  final int index;
  final int tempoPercent;
  final bool shuffleEnabled;
  final QueueRepeatMode repeatMode;

  /// Name of the playlist/source this queue was started from, e.g. shown as
  /// the player's app bar title. Null for a plain library queue.
  final String? queueTitle;

  /// Id of the playlist this queue was started from, if any - lets the
  /// player's song menu offer "Remove from playlist" (see
  /// [NowPlayingController.removeCurrentFromPlaylist]). Null for library
  /// playback or a bookmarked folder's contents.
  final String? sourcePlaylistId;

  Song get currentSong => songs[order[index]];

  /// True whenever pressing "next" does something - either there's a later
  /// track, repeat-all means it wraps back around to the first one, or
  /// repeat-one means it restarts the current track.
  bool get hasNext => repeatMode != QueueRepeatMode.off || index < order.length - 1;
  bool get hasPrevious => index > 0;

  NowPlayingState copyWith({
    List<Song>? songs,
    List<int>? order,
    int? index,
    int? tempoPercent,
    bool? shuffleEnabled,
    QueueRepeatMode? repeatMode,
  }) {
    return NowPlayingState(
      songs: songs ?? this.songs,
      order: order ?? this.order,
      index: index ?? this.index,
      tempoPercent: tempoPercent ?? this.tempoPercent,
      queueTitle: queueTitle,
      sourcePlaylistId: sourcePlaylistId,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}

class NowPlayingController extends StateNotifier<NowPlayingState?> {
  NowPlayingController(this._ref) : super(null) {
    _attachTrackCompleteHandler();
  }

  final Ref _ref;

  /// Re-wires the audio handler's completion/skip callbacks to this
  /// controller. [PracticeSessionController] takes exclusive ownership of
  /// those callbacks while a practice session is active and calls this when
  /// the session ends so mini-player auto-advance (and lock-screen
  /// next/previous) resume afterwards.
  void attachTrackCompleteHandler() => _attachTrackCompleteHandler();

  void _attachTrackCompleteHandler() {
    final handler = _ref.read(audioHandlerProvider);
    handler.onTrackComplete = _onTrackComplete;
    handler.onSkipNext = () => unawaited(next());
    handler.onSkipPrevious = () => unawaited(previous());
  }

  Future<void> playQueue(
    List<Song> songs,
    int initialIndex, {
    String? queueTitle,
    String? sourcePlaylistId,
  }) async {
    if (songs.isEmpty) return;
    unawaited(ensureNotificationPermission());
    // Ad-hoc playback and a timed practice set can't share the one audio
    // handler, so starting a queue ends any running session.
    await _ref.read(practiceSessionProvider.notifier).stop();
    state = NowPlayingState(
      songs: songs,
      order: List.generate(songs.length, (i) => i),
      index: initialIndex,
      tempoPercent: AppDefaults.tempoPercent,
      queueTitle: queueTitle,
      sourcePlaylistId: sourcePlaylistId,
    );
    _attachTrackCompleteHandler();
    await _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final s = state;
    if (s == null) return;
    final handler = _ref.read(audioHandlerProvider);
    final song = s.currentSong;
    await handler.loadTrack(
      uriOrPath: song.uri,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration:
          song.durationMs != null ? Duration(milliseconds: song.durationMs!) : null,
      tempoPercent: s.tempoPercent.toDouble(),
    );
    unawaited(handler.play());
  }

  /// Auto-advance when a track finishes on its own (as opposed to the user
  /// tapping "next") - repeat-one replays the same track instead of
  /// advancing, same as a user-pressed [next] in that mode.
  Future<void> _onTrackComplete() async {
    final s = state;
    if (s == null) return;
    if (s.repeatMode == QueueRepeatMode.one) {
      await _loadCurrent();
      return;
    }
    await next();
  }

  /// Repeat-one locks playback to the current track, so a user-pressed
  /// "next" restarts it instead of advancing - same as [previous] in that
  /// mode.
  Future<void> next() async {
    final s = state;
    if (s == null || !s.hasNext) return;
    if (s.repeatMode == QueueRepeatMode.one) {
      await _ref.read(audioHandlerProvider).seek(Duration.zero);
      return;
    }
    final nextIndex = s.index + 1 >= s.order.length ? 0 : s.index + 1;
    state = s.copyWith(index: nextIndex);
    await _loadCurrent();
  }

  /// Standard player UX: restart the current track if it's more than a few
  /// seconds in; only skip to the actual previous track otherwise. Under
  /// repeat-one, always restarts - the queue shouldn't move at all.
  Future<void> previous() async {
    final s = state;
    if (s == null) return;
    final handler = _ref.read(audioHandlerProvider);
    if (s.repeatMode == QueueRepeatMode.one ||
        handler.position > const Duration(seconds: 3) ||
        !s.hasPrevious) {
      await handler.seek(Duration.zero);
      return;
    }
    state = s.copyWith(index: s.index - 1);
    await _loadCurrent();
  }

  /// Toggles shuffle, re-randomizing (or restoring the sequential) play
  /// order for every track except the one currently playing, which stays
  /// exactly where it is so toggling shuffle never interrupts playback.
  void toggleShuffle() {
    final s = state;
    if (s == null) return;
    final currentSongIndex = s.order[s.index];
    if (s.shuffleEnabled) {
      final sequential = List.generate(s.songs.length, (i) => i);
      state = s.copyWith(
        order: sequential,
        index: currentSongIndex,
        shuffleEnabled: false,
      );
      return;
    }
    final rest = [
      for (var i = 0; i < s.songs.length; i++)
        if (i != currentSongIndex) i,
    ]..shuffle(Random());
    final anchor = s.index.clamp(0, rest.length);
    final shuffled = [...rest]..insert(anchor, currentSongIndex);
    state = s.copyWith(order: shuffled, shuffleEnabled: true);
  }

  /// Toggles the current track's favorite flag. `NowPlayingState.songs` is a
  /// snapshot taken when the queue started (unlike the Library/Playlist
  /// screens, which rebuild straight from a DB stream), so the DB write
  /// alone wouldn't make the player's heart icon flip - patch the local
  /// copy too so it updates immediately.
  Future<void> toggleFavoriteCurrent() async {
    final s = state;
    if (s == null) return;
    final songIndex = s.order[s.index];
    final song = s.songs[songIndex];
    final favorite = !song.isFavorite;
    await _ref.read(songRepositoryProvider).setFavorite(song.id, favorite);
    final updatedSongs = [...s.songs];
    updatedSongs[songIndex] = song.copyWith(isFavorite: favorite);
    state = s.copyWith(songs: updatedSongs);
  }

  /// Removes the current track from the playlist it was started from (see
  /// [NowPlayingState.sourcePlaylistId]) - a DB-only detach, deliberately
  /// leaving playback and the in-memory queue untouched, same as unchecking
  /// a song from the "Add to playlist" sheet. An earlier version also
  /// dropped it from this queue (reloading, or stopping if it was the only
  /// song left), which meant the currently-playing song audibly cut out
  /// the moment you removed it - jarring, and inconsistent with the other
  /// way to do the same removal (the "Add to playlist" sheet), which never
  /// touched playback at all.
  Future<void> removeCurrentFromPlaylist() async {
    final s = state;
    if (s == null) return;
    final playlistId = s.sourcePlaylistId;
    if (playlistId == null) return;
    final song = s.currentSong;
    await _ref.read(playlistRepositoryProvider).removeSong(playlistId, song.id);
  }

  /// Patches the current track's local snapshot with freshly-edited
  /// metadata (see [SongActionsMenu.onSongUpdated]) - same reasoning as
  /// [toggleFavoriteCurrent]: `NowPlayingState.songs` won't pick up a bare
  /// DB write on its own.
  void updateCurrentSongLocally(Song updated) {
    final s = state;
    if (s == null) return;
    final songIndex = s.order[s.index];
    final updatedSongs = [...s.songs];
    updatedSongs[songIndex] = updated;
    state = s.copyWith(songs: updatedSongs);
  }

  void cycleRepeatMode() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(
      repeatMode: switch (s.repeatMode) {
        QueueRepeatMode.off => QueueRepeatMode.all,
        QueueRepeatMode.all => QueueRepeatMode.one,
        QueueRepeatMode.one => QueueRepeatMode.off,
      },
    );
  }

  Future<void> setTempo(int percent) async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(tempoPercent: percent);
    await _ref.read(audioHandlerProvider).setTempoPercent(percent.toDouble());
  }

  Future<void> togglePlayPause() async {
    final handler = _ref.read(audioHandlerProvider);
    if (handler.isPlaying) {
      await handler.pause();
    } else {
      unawaited(handler.play());
    }
  }

  Future<void> stop() async {
    await _ref.read(audioHandlerProvider).stop();
    state = null;
  }

  /// Clears this queue without touching playback - used when
  /// [PracticeSessionScreen] takes over the shared audio handler, so the
  /// mini-player (which would otherwise show stale info and fight over
  /// playback controls) hides itself for the duration of the session.
  void clearSilently() => state = null;
}

final nowPlayingProvider =
    StateNotifierProvider<NowPlayingController, NowPlayingState?>((ref) {
  return NowPlayingController(ref);
});
