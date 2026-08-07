import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/player_artwork.dart';
import '../../widgets/seek_bar.dart';
import '../../widgets/song_actions_menu.dart';
import '../../widgets/tempo_slider.dart';
import 'player_shell.dart';
import 'practice_session_controller.dart';

/// The running-practice-set player. Deliberately the same view as the ad-hoc
/// Now Playing screen (same [PlayerShell]) with the set context layered on
/// top: which entry is running, where it sits in the set, and what's next.
///
/// The session itself lives in [practiceSessionController], so closing this
/// screen leaves the set playing and the mini-player keeps offering the same
/// controls.
class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key, this.practiceSet});

  /// When given, starts this set on open unless it is already the running
  /// session (which is the case when the screen is reopened from the
  /// mini-player).
  final PracticeSet? practiceSet;

  @override
  ConsumerState<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  // The stop-point marker is derived from position + cutoffRemainingSeconds,
  // but those two values tick down on independent schedules (a continuous
  // position stream vs. a once-a-second timer), so recomputing it on every
  // tick makes it visibly wiggle by about a second. It only actually needs
  // to move when the user seeks, so it's anchored once per playback instead.
  Duration? _stopAt;
  bool _stopAtAnchored = false;

  /// Projects where the cutoff marker sits on the track from [position],
  /// given [cutoffRemainingSeconds] of real wall-clock playback time left at
  /// [tempoPercent]. The countdown itself ticks in real seconds regardless of
  /// tempo, but the track position it corresponds to advances faster or
  /// slower than that depending on tempo, so the two can't be added directly.
  Duration _projectStopAt(Duration position, int cutoffRemainingSeconds, int tempoPercent) {
    final coveredMs = cutoffRemainingSeconds * 1000 * tempoPercent / 100;
    return position + Duration(milliseconds: coveredMs.round());
  }

  @override
  void initState() {
    super.initState();
    final set = widget.practiceSet;
    if (set == null) return;
    // Deferred: starting the session mutates providers, which would rebuild
    // the mini-player while this route is still being mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final running = ref.read(practiceSessionProvider);
      final alreadyRunning = running != null &&
          running.practiceSet.id == set.id &&
          running.phase != SessionPhase.complete;
      if (!alreadyRunning) {
        ref.read(practiceSessionProvider.notifier).start(set);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(practiceSessionProvider);
    final controller = ref.read(practiceSessionProvider.notifier);
    final handler = ref.watch(audioHandlerProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.practiceSet?.name ?? 'Practice set')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (session.phase == SessionPhase.complete) {
      return _SessionCompleteScreen(
        setName: session.practiceSet.name,
        onRestart: controller.restart,
        onClose: () async {
          await controller.stop();
          if (context.mounted) Navigator.of(context).maybePop();
        },
      );
    }

    final entry = session.currentEntry;
    final breaking = session.phase == SessionPhase.breaking;
    final loading = session.phase == SessionPhase.loading;

    if (session.phase != SessionPhase.playing) {
      _stopAtAnchored = false;
      _stopAt = null;
    } else if (!_stopAtAnchored) {
      _stopAtAnchored = true;
      final cutoffRemaining = session.cutoffRemainingSeconds;
      _stopAt = cutoffRemaining == null
          ? null
          : _projectStopAt(handler.position, cutoffRemaining, session.tempoPercent);
    }

    return PlayerShell(
      appBarTitle: session.practiceSet.name,
      appBarActions: [
        IconButton(
          tooltip: 'End session',
          icon: const Icon(Icons.stop_circle_outlined),
          iconSize: 32,
          onPressed: () async {
            await controller.stop();
            if (context.mounted) Navigator.of(context).maybePop();
          },
        ),
        if (session.currentSong != null)
          SongActionsMenu(
            song: session.currentSong!,
            // Only offered when the entry actually pulls from a playlist -
            // a folder-backed entry has nothing sensible to remove it from.
            onRemoveFromPlaylist: entry?.entry.playlistId == null
                ? null
                : controller.removeCurrentSongFromPlaylist,
            onToggleFavorite: controller.toggleFavoriteCurrentSong,
            onSongUpdated: controller.updateCurrentSongLocally,
          ),
      ],
      artwork: StreamBuilder<Uint8List?>(
        stream: handler.coverArtStream,
        builder: (context, snapshot) {
          return PlayerArtwork(
            artworkBytes: snapshot.data,
            icon: breaking ? Icons.self_improvement : Icons.music_note,
            dimmed: breaking,
            badge: breaking ? const Text('Break') : null,
          );
        },
      ),
      contextHeader: entry == null
          ? null
          : _EntryHeader(label: entry.label, position: session.positionLabel),
      title: breaking
          ? 'Break'
          : loading
              ? 'Loading...'
              : session.currentSong?.title ?? '',
      subtitle: breaking
          ? 'Next song starts automatically'
          : session.currentSong?.artist,
      progress: breaking
          ? SeekBar(
              position: Duration(
                seconds: session.breakTotalSeconds - session.breakSecondsRemaining,
              ),
              duration: Duration(seconds: session.breakTotalSeconds),
              remainingAsCountdown: true,
            )
          : StreamBuilder<Duration>(
              stream: handler.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = handler.duration ?? Duration.zero;
                final stopAt = _stopAt;
                return SeekBar(
                  position: position,
                  duration: duration,
                  onSeek: (target) {
                    // The cutoff is time-based, not position-based, so
                    // seeking shifts the marker by the same amount without
                    // otherwise affecting the countdown.
                    final cutoffRemaining = session.cutoffRemainingSeconds;
                    handler.seek(target);
                    setState(() {
                      _stopAt = cutoffRemaining == null
                          ? null
                          : _projectStopAt(target, cutoffRemaining, session.tempoPercent);
                    });
                  },
                  // Only worth showing if the cutoff would actually fire
                  // before the song ends naturally on its own.
                  stopAt: stopAt != null && duration > Duration.zero && stopAt < duration
                      ? stopAt
                      : null,
                );
              },
            ),
      // Tempo applies to the song currently sounding; the next entry starts
      // from its own configured tempo again.
      tempo: breaking
          ? null
          : TempoSlider(
              percent: session.tempoPercent,
              baseBpm: session.currentSong?.bpmManual ?? session.currentSong?.bpmDetected,
              onChanged: (percent) {
                // The marker's remaining distance is covered at the new
                // tempo, not the old one, so it has to be re-projected from
                // the current position rather than left where it was.
                final cutoffRemaining = session.cutoffRemainingSeconds;
                if (cutoffRemaining != null) {
                  setState(() {
                    _stopAt = _projectStopAt(handler.position, cutoffRemaining, percent);
                  });
                }
                controller.setTempo(percent);
              },
            ),
      controls: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A set runs forwards only, so there is no previous button - this
          // reserves its width to keep the play button optically centred.
          const SizedBox(width: 76),
          PlayPauseButton(
            playing: !session.paused,
            onPressed: controller.togglePause,
          ),
          const SizedBox(width: 20),
          TransportButton(
            icon: Icons.skip_next_rounded,
            tooltip: breaking ? 'Skip break' : 'Skip to next entry',
            onPressed: controller.skip,
          ),
        ],
      ),
      footer: breaking ? _NextUp(next: session.nextEntry) : null,
    );
  }
}

/// The current entry's name plus its position in the set - the core piece of
/// information a practice player needs that a normal player doesn't.
class _EntryHeader extends StatelessWidget {
  const _EntryHeader({required this.label, required this.position});

  final String label;
  final String position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          position,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _NextUp extends StatelessWidget {
  const _NextUp({required this.next});

  final ResolvedSetEntry? next;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = next == null ? 'Last entry of the set' : 'Next up: ${next!.label}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          next == null ? Icons.flag_outlined : Icons.arrow_forward_rounded,
          size: 16,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SessionCompleteScreen extends StatelessWidget {
  const _SessionCompleteScreen({
    required this.setName,
    required this.onRestart,
    required this.onClose,
  });

  final String setName;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(setName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text('Session complete', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'You worked through every entry in this set.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay),
                label: const Text('Run it again'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onClose, child: const Text('Done')),
            ],
          ),
        ),
      ),
    );
  }
}
