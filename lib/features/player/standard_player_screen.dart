import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/tempo_slider.dart';
import 'now_playing_controller.dart';

/// Displays and controls the shared [nowPlayingProvider] queue. If [songs]
/// is provided, starts (or replaces) that queue at [initialIndex] on open -
/// used for ad-hoc playback of a single song, a whole playlist, or a
/// bookmarked folder's contents. Opened with no arguments (e.g. by tapping
/// the persistent mini-player), it just displays whatever is already
/// playing. This is distinct from [PracticeSessionScreen]'s structured,
/// timed dance-set sequencing, which owns the audio handler exclusively
/// while active.
class StandardPlayerScreen extends ConsumerStatefulWidget {
  const StandardPlayerScreen({super.key, this.songs, this.initialIndex = 0});

  final List<Song>? songs;
  final int initialIndex;

  @override
  ConsumerState<StandardPlayerScreen> createState() => _StandardPlayerScreenState();
}

class _StandardPlayerScreenState extends ConsumerState<StandardPlayerScreen> {
  @override
  void initState() {
    super.initState();
    final songs = widget.songs;
    if (songs != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(nowPlayingProvider.notifier).playQueue(songs, widget.initialIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);

    if (nowPlaying == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Now Playing')),
        body: const Center(child: Text('Nothing playing')),
      );
    }

    final song = nowPlaying.currentSong;

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
              percent: nowPlaying.tempoPercent,
              onChanged: (p) => ref.read(nowPlayingProvider.notifier).setTempo(p),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => ref.read(nowPlayingProvider.notifier).previous(),
                ),
                StreamBuilder<PlaybackState>(
                  stream: handler.playbackState,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      iconSize: 64,
                      icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                      onPressed: () =>
                          ref.read(nowPlayingProvider.notifier).togglePlayPause(),
                    );
                  },
                ),
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_next),
                  onPressed: nowPlaying.hasNext
                      ? () => ref.read(nowPlayingProvider.notifier).next()
                      : null,
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
