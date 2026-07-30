import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/player_artwork.dart';
import '../../widgets/seek_bar.dart';
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

    return PlayerShell(
      appBarTitle: session.practiceSet.name,
      appBarActions: [
        IconButton(
          tooltip: 'End session',
          icon: const Icon(Icons.stop_circle_outlined),
          onPressed: () async {
            await controller.stop();
            if (context.mounted) Navigator.of(context).maybePop();
          },
        ),
      ],
      artwork: PlayerArtwork(
        icon: breaking ? Icons.self_improvement : Icons.music_note,
        dimmed: breaking,
        badge: Text(
          breaking ? 'Break' : '${session.tempoPercent}% tempo',
        ),
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
                return SeekBar(
                  position: snapshot.data ?? Duration.zero,
                  duration: handler.duration ?? Duration.zero,
                  onSeek: handler.seek,
                );
              },
            ),
      // Tempo applies to the song currently sounding; the next entry starts
      // from its own configured tempo again.
      tempo: breaking
          ? null
          : TempoSlider(
              percent: session.tempoPercent,
              onChanged: controller.setTempo,
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
      footer: _NextUp(next: session.nextEntry),
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
        Container(
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
