import 'dart:typed_data';

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
      appBarActions: [
        IconButton(
          tooltip: song.isFavorite ? 'Unfavorite' : 'Favorite',
          icon: Icon(song.isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: controller.toggleFavoriteCurrent,
        ),
      ],
      artwork: StreamBuilder<Uint8List?>(
        stream: handler.coverArtStream,
        builder: (context, snapshot) {
          return PlayerArtwork(artworkBytes: snapshot.data);
        },
      ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (nowPlaying.songs.length > 1)
            _ShuffleButton(
              enabled: nowPlaying.shuffleEnabled,
              onPressed: controller.toggleShuffle,
            )
          else
            const SizedBox(width: 48),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TransportButton(
                icon: Icons.skip_previous_rounded,
                tooltip: 'Previous',
                onPressed: controller.previous,
              ),
              const SizedBox(width: 20),
              StreamBuilder<bool>(
                stream: handler.playingStream,
                builder: (context, snapshot) {
                  return PlayPauseButton(
                    playing: snapshot.data ?? false,
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
          if (nowPlaying.songs.length > 1)
            _RepeatButton(
              mode: nowPlaying.repeatMode,
              onPressed: controller.cycleRepeatMode,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

Color _queueIconColor(BuildContext context, bool active) {
  final colors = Theme.of(context).colorScheme;
  return active ? colors.primary : colors.onSurfaceVariant;
}

class _ShuffleButton extends StatelessWidget {
  const _ShuffleButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: enabled ? 'Shuffle on' : 'Shuffle off',
      icon: Icon(Icons.shuffle_rounded, color: _queueIconColor(context, enabled)),
      onPressed: onPressed,
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.mode, required this.onPressed});

  final QueueRepeatMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: switch (mode) {
        QueueRepeatMode.off => 'Repeat off',
        QueueRepeatMode.all => 'Repeat all',
        QueueRepeatMode.one => 'Repeat one',
      },
      icon: Icon(
        mode == QueueRepeatMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
        color: _queueIconColor(context, mode != QueueRepeatMode.off),
      ),
      onPressed: onPressed,
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
