import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/player_artwork.dart';
import '../../widgets/seek_bar.dart';
import '../../widgets/tempo_slider.dart';
import 'now_playing_controller.dart';
import 'player_shell.dart';

/// Displays and controls the shared [nowPlayingProvider] queue. If [songs]
/// is provided, starts (or replaces) that queue at [initialIndex] on open -
/// used for ad-hoc playback of a single song, a whole playlist, or a
/// bookmarked folder's contents. Opened with no arguments (e.g. by tapping
/// the persistent mini-player), it just displays whatever is already
/// playing. This is distinct from [PracticeSessionScreen]'s structured,
/// timed dance-set sequencing, which owns the audio handler exclusively
/// while active.
class StandardPlayerScreen extends ConsumerStatefulWidget {
  const StandardPlayerScreen({
    super.key,
    this.songs,
    this.initialIndex = 0,
    this.queueTitle,
  });

  final List<Song>? songs;
  final int initialIndex;

  /// Name of the playlist this queue was started from, shown as the app bar
  /// title instead of the generic "Now Playing". Null for library playback.
  final String? queueTitle;

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
        ref
            .read(nowPlayingProvider.notifier)
            .playQueue(songs, widget.initialIndex, queueTitle: widget.queueTitle);
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
    final controller = ref.read(nowPlayingProvider.notifier);

    return PlayerShell(
      appBarTitle: nowPlaying.queueTitle ?? 'Now Playing',
      artwork: const PlayerArtwork(),
      contextHeader: nowPlaying.songs.length > 1
          ? _QueuePositionLabel(
              index: nowPlaying.index,
              total: nowPlaying.songs.length,
            )
          : null,
      title: song.title,
      subtitle: song.artist,
      progress: StreamBuilder<Duration>(
        stream: handler.positionStream,
        builder: (context, snapshot) {
          return SeekBar(
            position: snapshot.data ?? Duration.zero,
            duration: handler.duration ?? Duration.zero,
            onSeek: handler.seek,
          );
        },
      ),
      tempo: TempoSlider(
        percent: nowPlaying.tempoPercent,
        onChanged: controller.setTempo,
        baseBpm: song.bpmManual ?? song.bpmDetected,
      ),
      controls: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TransportButton(
            icon: Icons.skip_previous_rounded,
            tooltip: 'Previous',
            onPressed: controller.previous,
          ),
          const SizedBox(width: 20),
          StreamBuilder<PlaybackState>(
            stream: handler.playbackState,
            builder: (context, snapshot) {
              return PlayPauseButton(
                playing: snapshot.data?.playing ?? false,
                onPressed: controller.togglePlayPause,
              );
            },
          ),
          const SizedBox(width: 20),
          TransportButton(
            icon: Icons.skip_next_rounded,
            tooltip: 'Next',
            onPressed: nowPlaying.hasNext ? controller.next : null,
          ),
        ],
      ),
    );
  }
}

class _QueuePositionLabel extends StatelessWidget {
  const _QueuePositionLabel({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'Track ${index + 1} of $total',
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.6,
      ),
    );
  }
}
