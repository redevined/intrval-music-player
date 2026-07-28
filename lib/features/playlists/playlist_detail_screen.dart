import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/song_tile.dart';
import '../library/library_screen.dart';
import '../player/standard_player_screen.dart';

final _playlistSongsProvider =
    StreamProvider.autoDispose.family<List<Song>, String>((ref, playlistId) {
  return ref.watch(playlistRepositoryProvider).watchSongs(playlistId);
});

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(_playlistSongsProvider(playlist.id));

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: songsAsync.when(
        data: (songs) => songs.isEmpty
            ? const Center(child: Text('No songs yet. Tap + to add some.'))
            : ReorderableListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, i) => Dismissible(
                  key: ValueKey(songs[i].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => ref
                      .read(playlistRepositoryProvider)
                      .removeSong(playlist.id, songs[i].id),
                  background: Container(color: Colors.red),
                  child: SongTile(
                    song: songs[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StandardPlayerScreen(
                          songs: songs,
                          initialIndex: i,
                        ),
                      ),
                    ),
                  ),
                ),
                onReorderItem: (oldIndex, newIndex) {
                  final ids = songs.map((s) => s.id).toList();
                  final id = ids.removeAt(oldIndex);
                  ids.insert(newIndex, id);
                  ref.read(playlistRepositoryProvider).reorder(playlist.id, ids);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSongs(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addSongs(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddSongsSheet(playlistId: playlist.id),
    );
  }
}

class _AddSongsSheet extends ConsumerWidget {
  const _AddSongsSheet({required this.playlistId});
  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(librarySongsProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, scrollController) => songsAsync.when(
        data: (songs) => ListView.builder(
          controller: scrollController,
          itemCount: songs.length,
          itemBuilder: (context, i) => SongTile(
            song: songs[i],
            trailing: const Icon(Icons.add_circle_outline),
            onTap: () =>
                ref.read(playlistRepositoryProvider).addSong(playlistId, songs[i].id),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
