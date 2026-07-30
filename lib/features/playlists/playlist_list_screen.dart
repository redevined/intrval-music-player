import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../player/standard_player_screen.dart';
import 'playlist_detail_screen.dart';

enum PlaylistSortField { name, dateCreated }

final playlistsProvider = StreamProvider.autoDispose<List<Playlist>>((ref) {
  return ref.watch(playlistRepositoryProvider).watchAll();
});

final playlistSearchProvider = StateProvider.autoDispose<String>((ref) => '');
final playlistSortProvider =
    StateProvider.autoDispose<PlaylistSortField>((ref) => PlaylistSortField.name);
final playlistSortAscendingProvider = StateProvider.autoDispose<bool>((ref) => true);

final _playlistSongsProvider =
    StreamProvider.autoDispose.family<List<Song>, String>((ref, playlistId) {
  return ref.watch(playlistRepositoryProvider).watchSongs(playlistId);
});

/// Applies the search/sort UI state on top of the raw playlist stream.
/// Filtering/sorting happens client-side since the playlist count is small
/// and this keeps [PlaylistRepository] focused on plain CRUD.
final visiblePlaylistsProvider = Provider.autoDispose<AsyncValue<List<Playlist>>>((ref) {
  final playlistsAsync = ref.watch(playlistsProvider);
  final query = ref.watch(playlistSearchProvider).trim().toLowerCase();
  final sortField = ref.watch(playlistSortProvider);
  final ascending = ref.watch(playlistSortAscendingProvider);

  return playlistsAsync.whenData((playlists) {
    var result = playlists;
    if (query.isNotEmpty) {
      result = result.where((p) => p.name.toLowerCase().contains(query)).toList();
    }
    result = [...result];
    switch (sortField) {
      case PlaylistSortField.name:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case PlaylistSortField.dateCreated:
        result.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    }
    if (!ascending) result = result.reversed.toList();
    return result;
  });
});

enum _PlaylistAction { rename, delete }

class PlaylistListScreen extends ConsumerWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(visiblePlaylistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            tooltip: ref.watch(playlistSortAscendingProvider) ? 'Ascending' : 'Descending',
            icon: Icon(
              ref.watch(playlistSortAscendingProvider)
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: () => ref.read(playlistSortAscendingProvider.notifier).state =
                !ref.read(playlistSortAscendingProvider),
          ),
          PopupMenuButton<PlaylistSortField>(
            icon: const Icon(Icons.sort),
            initialValue: ref.watch(playlistSortProvider),
            onSelected: (v) => ref.read(playlistSortProvider.notifier).state = v,
            itemBuilder: (context) => const [
              PopupMenuItem(value: PlaylistSortField.name, child: Text('Name')),
              PopupMenuItem(
                value: PlaylistSortField.dateCreated,
                child: Text('Date created'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search playlists',
              ),
              onChanged: (v) => ref.read(playlistSearchProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: playlistsAsync.when(
              data: (playlists) => playlists.isEmpty
                  ? const Center(child: Text('No playlists yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: playlists.length,
                      itemBuilder: (context, i) {
                        final playlist = playlists[i];
                        return Consumer(
                          builder: (context, ref, _) {
                            final songs = ref
                                .watch(_playlistSongsProvider(playlist.id))
                                .valueOrNull;
                            return ListTile(
                              leading: const Icon(Icons.queue_music),
                              title: Text(playlist.name),
                              subtitle: Text(songs == null
                                  ? ''
                                  : '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Play playlist',
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: (songs ?? const []).isEmpty
                                        ? null
                                        : () => Navigator.of(context, rootNavigator: true)
                                                .push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    StandardPlayerScreen(songs: songs!),
                                              ),
                                            ),
                                  ),
                                  PopupMenuButton<_PlaylistAction>(
                                    icon: const Icon(Icons.more_vert),
                                    padding: EdgeInsets.zero,
                                    onSelected: (action) async {
                                      switch (action) {
                                        case _PlaylistAction.rename:
                                          await _renamePlaylist(context, ref, playlist);
                                        case _PlaylistAction.delete:
                                          await ref
                                              .read(playlistRepositoryProvider)
                                              .delete(playlist.id);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: _PlaylistAction.rename,
                                        child: Text('Rename'),
                                      ),
                                      PopupMenuItem(
                                        value: _PlaylistAction.delete,
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlaylistDetailScreen(playlist: playlist),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPlaylist(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
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
    if (name != null && name.isNotEmpty) {
      await ref.read(playlistRepositoryProvider).create(name);
    }
  }

  Future<void> _renamePlaylist(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final controller = TextEditingController(text: playlist.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(playlistRepositoryProvider).rename(playlist.id, name);
    }
  }
}
