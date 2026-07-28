import 'package:flutter/material.dart';

import '../data/database/database.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.trailing,
    this.leading,
  });

  final Song song;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bpm = song.bpmManual ?? song.bpmDetected;
    final isManualBpm = song.bpmManual != null;
    final durationLabel = song.durationMs != null
        ? _formatDuration(Duration(milliseconds: song.durationMs!))
        : null;

    return ListTile(
      onTap: onTap,
      leading: leading ?? const CircleAvatar(child: Icon(Icons.music_note)),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (song.artist?.isNotEmpty ?? false) song.artist,
          ?durationLabel,
        ].join(' \u2022 '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bpm != null ? '${bpm.round()} BPM' : '-- BPM',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (isManualBpm) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 14),
                ],
              ],
            ),
          ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
