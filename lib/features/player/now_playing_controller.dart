import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';

/// The currently-playing ad-hoc queue (Library/Playlist playback), shared
/// across the whole app so a persistent mini-player can show/control it
/// regardless of which tab is active.
class NowPlayingState {
  NowPlayingState({
    required this.songs,
    required this.index,
    required this.tempoPercent,
  });

  final List<Song> songs;
  final int index;
  final int tempoPercent;

  Song get currentSong => songs[index];
  bool get hasNext => index < songs.length - 1;
  bool get hasPrevious => index > 0;

  NowPlayingState copyWith({int? index, int? tempoPercent}) {
    return NowPlayingState(
      songs: songs,
      index: index ?? this.index,
      tempoPercent: tempoPercent ?? this.tempoPercent,
    );
  }
}

class NowPlayingController extends StateNotifier<NowPlayingState?> {
  NowPlayingController(this._ref) : super(null) {
    _attachTrackCompleteHandler();
  }

  final Ref _ref;

  /// Re-wires the audio handler's completion callback to this controller.
  /// [PracticeSessionScreen] takes exclusive ownership of that callback
  /// while a practice session is active and should call this on dispose so
  /// mini-player auto-advance resumes afterwards.
  void attachTrackCompleteHandler() => _attachTrackCompleteHandler();

  void _attachTrackCompleteHandler() {
    _ref.read(audioHandlerProvider).onTrackComplete = _onTrackComplete;
  }

  Future<void> playQueue(List<Song> songs, int initialIndex) async {
    if (songs.isEmpty) return;
    state = NowPlayingState(
      songs: songs,
      index: initialIndex,
      tempoPercent: AppDefaults.tempoPercent,
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
      item: MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration:
            song.durationMs != null ? Duration(milliseconds: song.durationMs!) : null,
      ),
      tempoPercent: s.tempoPercent.toDouble(),
    );
    await handler.play();
  }

  void _onTrackComplete() {
    if (state == null) return;
    next();
  }

  Future<void> next() async {
    final s = state;
    if (s == null || !s.hasNext) return;
    state = s.copyWith(index: s.index + 1);
    await _loadCurrent();
  }

  /// Standard player UX: restart the current track if it's more than a few
  /// seconds in; only skip to the actual previous track otherwise.
  Future<void> previous() async {
    final s = state;
    if (s == null) return;
    final handler = _ref.read(audioHandlerProvider);
    if (handler.position > const Duration(seconds: 3) || !s.hasPrevious) {
      await handler.seek(Duration.zero);
      return;
    }
    state = s.copyWith(index: s.index - 1);
    await _loadCurrent();
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
      await handler.play();
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
