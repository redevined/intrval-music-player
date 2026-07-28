import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/song_repository.dart';
import '../../widgets/bpm_edit_dialog.dart';
import '../../widgets/song_tile.dart';
import '../player/standard_player_screen.dart';

final librarySearchProvider = StateProvider<String>((ref) => '');
final librarySortProvider = StateProvider<SongSortField>((ref) => SongSortField.title);

final librarySongsProvider = StreamProvider.autoDispose<List<Song>>((ref) {
  final query = ref.watch(librarySearchProvider);
  final sortField = ref.watch(librarySortProvider);
  return ref.watch(songRepositoryProvider).watchAll(
        query: query,
        sortField: sortField,
      );
});

final bookmarkedFoldersProvider =
    StreamProvider.autoDispose<List<BookmarkedFolder>>((ref) {
  return ref.watch(folderRepositoryProvider).watchAll();
});

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(librarySongsProvider);
    final foldersAsync = ref.watch(bookmarkedFoldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          PopupMenuButton<SongSortField>(
            icon: const Icon(Icons.sort),
            initialValue: ref.watch(librarySortProvider),
            onSelected: (v) => ref.read(librarySortProvider.notifier).state = v,
            itemBuilder: (context) => SongSortField.values
                .map((f) => PopupMenuItem(value: f, child: Text(_sortLabel(f))))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search title, artist, album',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => ref.read(librarySearchProvider.notifier).state = v,
            ),
          ),
          foldersAsync.when(
            data: (folders) => folders.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: folders
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InputChip(
                                  avatar: const Icon(Icons.folder, size: 18),
                                  label: Text(f.displayName),
                                  onPressed: () =>
                                      ref.read(folderRepositoryProvider).syncFolder(f.id),
                                  onDeleted: () =>
                                      ref.read(folderRepositoryProvider).delete(f.id),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const Divider(height: 1),
          Expanded(
            child: songsAsync.when(
              data: (songs) => songs.isEmpty
                  ? const Center(child: Text('No songs yet. Add a folder below.'))
                  : ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, i) => SongTile(
                        song: songs[i],
                        onEditBpm: (song) => showBpmEditDialog(context, ref, song),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final id = await ref.read(folderRepositoryProvider).pickAndBookmarkFolder();
          if (id == null) return;
          ref.invalidate(bookmarkedFoldersProvider);
          ref.invalidate(librarySongsProvider);
        },
        icon: const Icon(Icons.create_new_folder),
        label: const Text('Add folder'),
      ),
    );
  }

  String _sortLabel(SongSortField f) => switch (f) {
        SongSortField.title => 'Title',
        SongSortField.artist => 'Artist',
        SongSortField.album => 'Album',
        SongSortField.dateAdded => 'Date added',
        SongSortField.duration => 'Duration',
        SongSortField.bpm => 'BPM',
      };
}
