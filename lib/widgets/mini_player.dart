import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../features/player/now_playing_controller.dart';
import '../features/player/standard_player_screen.dart';

/// Persistent playback bar shown above the bottom navigation whenever a
/// [nowPlayingProvider] queue is active, regardless of which tab is open.
/// Tapping it opens the full Now Playing screen.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    if (nowPlaying == null) return const SizedBox.shrink();

    final handler = ref.watch(audioHandlerProvider);
    final song = nowPlaying.currentSong;

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StandardPlayerScreen()),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<Duration>(
                  stream: handler.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = handler.duration ?? Duration.zero;
                    final ratio = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;
                    return LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      minHeight: 2,
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        const Icon(Icons.music_note),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (song.artist != null)
                                Text(
                                  song.artist!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () =>
                              ref.read(nowPlayingProvider.notifier).previous(),
                        ),
                        StreamBuilder<PlaybackState>(
                          stream: handler.playbackState,
                          builder: (context, snapshot) {
                            final playing = snapshot.data?.playing ?? false;
                            return IconButton(
                              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                              onPressed: () => ref
                                  .read(nowPlayingProvider.notifier)
                                  .togglePlayPause(),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: nowPlaying.hasNext
                              ? () => ref.read(nowPlayingProvider.notifier).next()
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
