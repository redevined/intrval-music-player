import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import 'playlist_detail_screen.dart';

final playlistsProvider = StreamProvider.autoDispose<List<Playlist>>((ref) {
  return ref.watch(playlistRepositoryProvider).watchAll();
});

class PlaylistListScreen extends ConsumerWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: playlistsAsync.when(
        data: (playlists) => playlists.isEmpty
            ? const Center(child: Text('No playlists yet.'))
            : ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, i) {
                  final playlist = playlists[i];
                  return ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(playlist.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(playlistRepositoryProvider)
                          .delete(playlist.id),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlist: playlist),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
}
