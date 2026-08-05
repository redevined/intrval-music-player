import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data/database/database.dart';
import '../data/providers.dart';
import '../features/playlists/playlist_list_screen.dart' show playlistsProvider;

final _songPlaylistIdsProvider =
    StreamProvider.autoDispose.family<Set<String>, String>((ref, songId) {
  return ref.watch(playlistRepositoryProvider).watchPlaylistIdsForSong(songId);
});

/// Shows a bottom sheet listing every playlist, indicating with a
/// check/add circle whether [song] is already in each one. Tapping a
/// playlist toggles membership - mirrors the "+" add-songs sheet in
/// playlist view, just with playlists and songs swapped.
Future<void> showAddToPlaylistSheet(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddToPlaylistSheet(song: song),
  );
}

class _AddToPlaylistSheet extends ConsumerWidget {
  const _AddToPlaylistSheet({required this.song});
  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists =
        ref.watch(playlistsProvider).valueOrNull ?? const <Playlist>[];
    final memberIds =
        ref.watch(_songPlaylistIdsProvider(song.id)).valueOrNull ??
            const <String>{};

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Add to playlist',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New playlist'),
            onTap: () => _createAndAdd(context, ref),
          ),
          const Divider(height: 1),
          if (playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('No playlists yet.'),
            )
          else
            for (final p in playlists)
              ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(p.name),
                trailing: memberIds.contains(p.id)
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const Icon(Icons.add_circle_outline),
                onTap: () => memberIds.contains(p.id)
                    ? ref
                        .read(playlistRepositoryProvider)
                        .removeSong(p.id, song.id)
                    : ref
                        .read(playlistRepositoryProvider)
                        .addSong(p.id, song.id),
              ),
        ],
      ),
    );
  }

  Future<void> _createAndAdd(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New playlist'),
        content: SizedBox(
          width: kDialogContentWidth,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final id = await ref.read(playlistRepositoryProvider).create(name);
    await ref.read(playlistRepositoryProvider).addSong(id, song.id);
  }
}
