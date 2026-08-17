import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../data/providers.dart';
import '../features/player/now_playing_controller.dart';
import '../features/player/practice_session_controller.dart';
import '../features/player/practice_session_screen.dart';
import '../features/player/standard_player_screen.dart';

/// Persistent strip above the nav bar summarising whatever is currently
/// playing - an ad-hoc queue *or* a running practice set - and offering the
/// minimum controls for it. Tapping it reopens the matching full player.
///
/// It renders nothing when nothing is playing, so the nav bar sits flush at
/// the bottom as before.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(practiceSessionProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);

    if (session != null && session.phase != SessionPhase.complete) {
      final breaking = session.phase == SessionPhase.breaking;
      final entry = session.currentEntry;
      final controller = ref.read(practiceSessionProvider.notifier);

      return _MiniPlayerBar(
        leadingIcon: breaking ? Icons.self_improvement : Icons.timelapse,
        title: breaking
            ? 'Break - ${formatDuration(Duration(seconds: session.breakSecondsRemaining))}'
            : session.currentSong?.title ?? 'Loading...',
        subtitle: [
          session.practiceSet.name,
          if (entry != null) '${entry.label} (${session.positionLabel})',
        ].join(' - '),
        progress: breaking && session.breakTotalSeconds > 0
            ? 1 - (session.breakSecondsRemaining / session.breakTotalSeconds)
            : null,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PracticeSessionScreen()),
        ),
        actions: [
          _MiniIconButton(
            icon: session.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            tooltip: session.paused ? 'Resume' : 'Pause',
            onPressed: controller.togglePause,
          ),
          _MiniIconButton(
            icon: Icons.skip_next_rounded,
            tooltip: breaking ? 'Skip break' : 'Skip to next entry',
            onPressed: controller.skip,
          ),
        ],
      );
    }

    if (nowPlaying == null) return const SizedBox.shrink();

    final song = nowPlaying.currentSong;
    final handler = ref.watch(audioHandlerProvider);
    final controller = ref.read(nowPlayingProvider.notifier);

    return _MiniPlayerBar(
      leadingIcon: Icons.music_note,
      title: song.title,
      subtitle: song.artist ?? 'Unknown artist',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const StandardPlayerScreen()),
      ),
      actions: [
        StreamBuilder<bool>(
          stream: handler.playingStream,
          builder: (context, snapshot) {
            final playing = snapshot.data ?? false;
            return _MiniIconButton(
              icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              tooltip: playing ? 'Pause' : 'Play',
              onPressed: controller.togglePlayPause,
            );
          },
        ),
        _MiniIconButton(
          icon: Icons.skip_next_rounded,
          tooltip: 'Next',
          onPressed: nowPlaying.hasNext ? controller.next : null,
        ),
      ],
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.actions,
    this.progress,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final List<Widget> actions;

  /// 0-1 for a determinate hairline along the top edge (break countdown).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 2,
              child: progress == null
                  ? null
                  : LinearProgressIndicator(
                      value: progress!.clamp(0.0, 1.0),
                      backgroundColor: colors.surfaceContainerHighest,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      leadingIcon,
                      size: 22,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: 26,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}
