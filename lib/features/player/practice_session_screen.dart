import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import 'now_playing_controller.dart';

enum _SessionPhase { loading, playing, breaking, complete }

class _ResolvedEntry {
  _ResolvedEntry({
    required this.entry,
    required this.tempoPercent,
    required this.playDurationSeconds,
    required this.breakSeconds,
    required this.fadeOutSeconds,
    required this.breakCueMode,
    required this.beepLeadSeconds,
    required this.ambientSongId,
  });

  final SetEntry entry;
  final int tempoPercent;
  final int playDurationSeconds;
  final int breakSeconds;
  final int fadeOutSeconds;
  final String breakCueMode;
  final int beepLeadSeconds;
  final String? ambientSongId;
}

/// Runs a [PracticeSet] top to bottom: for each entry, picks a random
/// (non-immediately-repeating) song from its source, plays it with the
/// entry's effective tempo until it ends naturally or hits its play-time
/// cutoff (fading out), then a break with the configured audio cue, then
/// advances - looping the whole set until the user stops.
class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key, required this.practiceSet});

  final PracticeSet practiceSet;

  @override
  ConsumerState<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  _SessionPhase _phase = _SessionPhase.loading;
  List<_ResolvedEntry> _resolved = [];
  int _entryIndex = 0;
  Song? _currentSong;
  Timer? _cutoffTimer;
  Timer? _breakTicker;
  int _breakSecondsRemaining = 0;
  bool _paused = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    // Deferred: mutating nowPlayingProvider synchronously here would trigger
    // a MiniPlayer rebuild while this screen is still being mounted by the
    // Navigator, tripping a "setState()/markNeedsBuild() called during
    // build" assertion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(nowPlayingProvider.notifier).clearSilently();
    });
    ref.read(audioHandlerProvider).onTrackComplete = _onTrackNaturalEnd;
    _prepareSession();
  }

  @override
  void dispose() {
    ref.read(nowPlayingProvider.notifier).attachTrackCompleteHandler();
    _cutoffTimer?.cancel();
    _breakTicker?.cancel();
    super.dispose();
  }

  Future<void> _prepareSession() async {
    final entries = await ref
        .read(practiceSetRepositoryProvider)
        .watchEntries(widget.practiceSet.id)
        .first;
    _resolved = entries.map((e) => _resolveEntry(e)).toList();
    if (_resolved.isEmpty) {
      setState(() => _phase = _SessionPhase.complete);
      return;
    }
    _entryIndex = 0;
    await _playEntry(_entryIndex);
  }

  _ResolvedEntry _resolveEntry(SetEntry e) {
    final set = widget.practiceSet;
    return _ResolvedEntry(
      entry: e,
      tempoPercent: e.tempoPercent ?? set.defaultTempoPercent,
      playDurationSeconds: e.playDurationSeconds ?? set.defaultPlayDurationSeconds,
      breakSeconds: e.breakSeconds ?? set.defaultBreakSeconds,
      fadeOutSeconds: e.fadeOutSeconds ?? set.defaultFadeOutSeconds,
      breakCueMode: e.breakCueMode ?? set.defaultBreakCueMode,
      beepLeadSeconds: e.beepLeadSeconds ?? set.defaultBeepLeadSeconds,
      ambientSongId: e.ambientSongId ?? set.defaultAmbientSongId,
    );
  }

  Future<List<Song>> _candidateSongs(SetEntry entry) async {
    if (entry.playlistId != null) {
      return ref.read(playlistRepositoryProvider).watchSongs(entry.playlistId!).first;
    }
    if (entry.folderId != null) {
      return ref.read(songRepositoryProvider).songsForFolder(entry.folderId!);
    }
    return [];
  }

  Future<void> _playEntry(int index) async {
    setState(() => _phase = _SessionPhase.loading);
    final resolved = _resolved[index];
    final candidates = await _candidateSongs(resolved.entry);
    if (candidates.isEmpty) {
      // Nothing to play for this entry - skip to the next one.
      _advance();
      return;
    }

    Song song;
    if (candidates.length == 1) {
      song = candidates.first;
    } else {
      final pool = candidates.where((s) => s.id != resolved.entry.lastPlayedSongId).toList();
      song = pool.isEmpty
          ? candidates[_random.nextInt(candidates.length)]
          : pool[_random.nextInt(pool.length)];
    }
    await ref
        .read(practiceSetRepositoryProvider)
        .setLastPlayedSong(resolved.entry.id, song.id);

    _currentSong = song;
    final handler = ref.read(audioHandlerProvider);
    try {
      await handler
          .loadTrack(
            uriOrPath: song.uri,
            item: MediaItem(
              id: song.id,
              title: song.title,
              artist: song.artist,
              album: song.album,
              duration:
                  song.durationMs != null ? Duration(milliseconds: song.durationMs!) : null,
            ),
            tempoPercent: resolved.tempoPercent.toDouble(),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Failed/stuck load (e.g. missing file, revoked permission, decode
      // error) - don't leave the UI stuck on the loading spinner forever.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play "${song.title}" - skipping.')),
      );
      _advance();
      return;
    }
    // Note: just_audio's play() future does not resolve until playback
    // stops/pauses/completes - awaiting it here would block the phase
    // transition and cutoff-timer setup below for the entire song.
    unawaited(handler.play());

    setState(() => _phase = _SessionPhase.playing);

    _cutoffTimer?.cancel();
    _cutoffTimer = Timer(Duration(seconds: resolved.playDurationSeconds), () async {
      if (!mounted || _phase != _SessionPhase.playing) return;
      await ref.read(audioHandlerProvider).fadeOutAndStop(
            Duration(seconds: resolved.fadeOutSeconds),
          );
      if (mounted) _startBreak();
    });
  }

  void _onTrackNaturalEnd() {
    if (_phase != _SessionPhase.playing) return;
    _cutoffTimer?.cancel();
    _startBreak();
  }

  Future<void> _startBreak() async {
    if (!mounted) return;
    final resolved = _resolved[_entryIndex];
    setState(() {
      _phase = _SessionPhase.breaking;
      _breakSecondsRemaining = resolved.breakSeconds;
    });

    if (resolved.breakCueMode == BreakCueMode.ambientSong &&
        resolved.ambientSongId != null) {
      final ambient = await ref
          .read(songRepositoryProvider)
          .getById(resolved.ambientSongId!);
      if (ambient != null) {
        final handler = ref.read(audioHandlerProvider);
        await handler.loadTrack(
          uriOrPath: ambient.uri,
          item: MediaItem(id: ambient.id, title: ambient.title),
        );
        unawaited(handler.play());
      }
    }

    _breakTicker?.cancel();
    _breakTicker = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      if (_paused) return;
      setState(() => _breakSecondsRemaining--);

      if (resolved.breakCueMode == BreakCueMode.beepBeforeEnd &&
          _breakSecondsRemaining == resolved.beepLeadSeconds) {
        SystemSound.play(SystemSoundType.click);
      }

      if (_breakSecondsRemaining <= 0) {
        timer.cancel();
        if (resolved.breakCueMode == BreakCueMode.ambientSong) {
          await ref.read(audioHandlerProvider).stop();
        }
        _advance();
      }
    });
  }

  void _advance() {
    if (_entryIndex < _resolved.length - 1) {
      _entryIndex++;
      _playEntry(_entryIndex);
    } else {
      setState(() => _phase = _SessionPhase.complete);
    }
  }

  void _togglePause() {
    final handler = ref.read(audioHandlerProvider);
    setState(() => _paused = !_paused);
    if (_phase == _SessionPhase.playing) {
      _paused ? handler.pause() : handler.play();
    }
  }

  void _skip() {
    _cutoffTimer?.cancel();
    _breakTicker?.cancel();
    ref.read(audioHandlerProvider).stop();
    _advance();
  }

  void _restart() {
    setState(() {
      _phase = _SessionPhase.loading;
      _entryIndex = 0;
    });
    _prepareSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.practiceSet.name)),
      body: Center(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_phase == _SessionPhase.loading) {
      return const CircularProgressIndicator();
    }
    if (_phase == _SessionPhase.complete) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 64),
          const SizedBox(height: 16),
          const Text('Session complete!'),
          const SizedBox(height: 24),
          FilledButton(onPressed: _restart, child: const Text('Restart')),
        ],
      );
    }

    final resolved = _resolved[_entryIndex];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            resolved.entry.label,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text('${_entryIndex + 1} / ${_resolved.length}'),
          const SizedBox(height: 24),
          if (_phase == _SessionPhase.playing && _currentSong != null) ...[
            Text(_currentSong!.title, style: Theme.of(context).textTheme.titleLarge),
            if (_currentSong!.artist != null) Text(_currentSong!.artist!),
            Text('${resolved.tempoPercent}% tempo'),
          ] else if (_phase == _SessionPhase.breaking) ...[
            const Text('Break'),
            Text(
              '$_breakSecondsRemaining s',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 48,
                icon: Icon(_paused ? Icons.play_circle : Icons.pause_circle),
                onPressed: _togglePause,
              ),
              const SizedBox(width: 24),
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.skip_next),
                onPressed: _skip,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
