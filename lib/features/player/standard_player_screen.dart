import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/tempo_slider.dart';

/// Plays a fixed queue of [songs] on demand, starting at [initialIndex].
/// Used for ad-hoc playback of a single song, a whole playlist, or a
/// bookmarked folder's contents - as opposed to [PracticeSessionScreen]'s
/// structured, timed dance-set sequencing.
class StandardPlayerScreen extends ConsumerStatefulWidget {
  const StandardPlayerScreen({
    super.key,
    required this.songs,
    this.initialIndex = 0,
  });

  final List<Song> songs;
  final int initialIndex;

  @override
  ConsumerState<StandardPlayerScreen> createState() => _StandardPlayerScreenState();
}

class _StandardPlayerScreenState extends ConsumerState<StandardPlayerScreen> {
  late int _index;
  int _tempoPercent = AppDefaults.tempoPercent;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrent());
    ref.read(audioHandlerProvider).onTrackComplete = _playNext;
  }

  @override
  void dispose() {
    ref.read(audioHandlerProvider).onTrackComplete = null;
    super.dispose();
  }

  Song get _currentSong => widget.songs[_index];

  Future<void> _loadCurrent() async {
    final handler = ref.read(audioHandlerProvider);
    final song = _currentSong;
    await handler.loadTrack(
      uriOrPath: song.uri,
      item: MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.durationMs != null
            ? Duration(milliseconds: song.durationMs!)
            : null,
      ),
      tempoPercent: _tempoPercent.toDouble(),
    );
    await handler.play();
  }

  void _playNext() {
    if (_index < widget.songs.length - 1) {
      setState(() => _index++);
      _loadCurrent();
    }
  }

  void _playPrevious() {
    if (_index > 0) {
      setState(() => _index--);
      _loadCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);
    final song = _currentSong;

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 96),
            const SizedBox(height: 24),
            Text(
              song.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (song.artist != null)
              Text(song.artist!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            StreamBuilder<Duration>(
              stream: handler.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = handler.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: position.inMilliseconds
                          .toDouble()
                          .clamp(0, duration.inMilliseconds.toDouble().clamp(1, double.infinity)),
                      max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                      onChanged: (v) => handler.seek(Duration(milliseconds: v.round())),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_format(position)),
                        Text(_format(duration)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            TempoSlider(
              percent: _tempoPercent,
              onChanged: (p) {
                setState(() => _tempoPercent = p);
                handler.setTempoPercent(p.toDouble());
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _index > 0 ? _playPrevious : null,
                ),
                StreamBuilder<PlaybackState>(
                  stream: handler.playbackState,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      iconSize: 64,
                      icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                      onPressed: () => playing ? handler.pause() : handler.play(),
                    );
                  },
                ),
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _index < widget.songs.length - 1 ? _playNext : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
