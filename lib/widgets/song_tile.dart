import 'package:flutter/material.dart';

import '../core/format.dart';
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
    final durationLabel = song.durationMs != null
        ? formatDuration(Duration(milliseconds: song.durationMs!))
        : null;
    final hasArtist = song.artist?.isNotEmpty ?? false;
    final metaLabel = [
      ?durationLabel,
      bpm != null ? '${bpm.round()} BPM' : '-- BPM',
    ].join(' \u2022 ');

    return ListTile(
      onTap: onTap,
      leading: leading ?? const CircleAvatar(child: Icon(Icons.music_note)),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      // The artist name is the part that gives way here: Flexible (loose
      // fit, unlike Expanded) only takes as much width as it actually
      // needs, so duration/BPM sits right after it instead of being
      // pushed flush right by leftover space - but it still shrinks
      // (with an ellipsis) rather than push duration/BPM off screen when
      // the row is too narrow for both.
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasArtist)
            Flexible(
              child: Text(
                song.artist!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (hasArtist) const Text(' \u2022 '),
          Text(metaLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: trailing,
    );
  }
}
