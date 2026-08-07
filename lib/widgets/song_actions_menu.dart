import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../data/providers.dart';
import 'add_to_playlist_sheet.dart';
import 'song_edit_dialog.dart';

enum _SongAction { edit, favorite, addToPlaylist, hide, removeFromPlaylist }

/// Three-dot song menu shared by the Library, Playlist, and player screens:
/// edit metadata, toggle favorite, and add to a playlist are always
/// available; "Hide" ([showHide]) and "Remove from playlist"
/// ([onRemoveFromPlaylist]) are opt-in since not every context has a
/// sensible meaning for them (e.g. a practice session has no fixed list to
/// remove a song from).
class SongActionsMenu extends ConsumerWidget {
  const SongActionsMenu({
    super.key,
    required this.song,
    this.showHide = false,
    this.onRemoveFromPlaylist,
  });

  final Song song;

  /// Shows a "Hide" action that sets [Song.isHidden] - used by the Library
  /// list, where a song has no other place to disappear to.
  final bool showHide;

  /// Shows a "Remove from playlist" action, called on selection - used by
  /// the Playlist detail list and the player screens (when the current
  /// queue is known to have come from a specific playlist).
  final VoidCallback? onRemoveFromPlaylist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_SongAction>(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      onSelected: (action) async {
        switch (action) {
          case _SongAction.edit:
            await showSongEditDialog(context, ref, song);
          case _SongAction.favorite:
            await ref
                .read(songRepositoryProvider)
                .setFavorite(song.id, !song.isFavorite);
          case _SongAction.addToPlaylist:
            await showAddToPlaylistSheet(context, ref, song);
          case _SongAction.hide:
            await ref.read(songRepositoryProvider).setHidden(song.id, true);
          case _SongAction.removeFromPlaylist:
            onRemoveFromPlaylist?.call();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: _SongAction.edit, child: Text('Edit')),
        PopupMenuItem(
          value: _SongAction.favorite,
          child: Text(song.isFavorite ? 'Unfavorite' : 'Favorite'),
        ),
        const PopupMenuItem(
          value: _SongAction.addToPlaylist,
          child: Text('Add to playlist'),
        ),
        if (showHide)
          const PopupMenuItem(value: _SongAction.hide, child: Text('Hide')),
        if (onRemoveFromPlaylist != null)
          const PopupMenuItem(
            value: _SongAction.removeFromPlaylist,
            child: Text('Remove from playlist'),
          ),
      ],
    );
  }
}
