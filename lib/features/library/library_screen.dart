import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/song_repository.dart';
import '../../widgets/song_edit_dialog.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/sort_app_bar_actions.dart';
import '../../widgets/tab_heading.dart';
import '../player/standard_player_screen.dart';

final librarySearchProvider = StateProvider<String>((ref) => '');
final librarySortProvider = StateProvider<SongSortField>((ref) => SongSortField.title);
final librarySortAscendingProvider = StateProvider<bool>((ref) => true);

final librarySongsProvider = StreamProvider.autoDispose<List<Song>>((ref) {
  final query = ref.watch(librarySearchProvider);
  final sortField = ref.watch(librarySortProvider);
  final ascending = ref.watch(librarySortAscendingProvider);
  return ref.watch(songRepositoryProvider).watchAll(
        query: query,
        sortField: sortField,
        ascending: ascending,
      );
});

final bookmarkedFoldersProvider =
    StreamProvider.autoDispose<List<BookmarkedFolder>>((ref) {
  return ref.watch(folderRepositoryProvider).watchAll();
});

enum _SongAction { edit, hide }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scanDefaultLibrary());
  }

  Future<void> _scanDefaultLibrary() async {
    setState(() => _scanning = true);
    try {
      await ref.read(musicLibraryScannerProvider).scan();
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(librarySongsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TabHeading('Library'),
        actions: [
          SortAppBarActions<SongSortField>(
            ascending: ref.watch(librarySortAscendingProvider),
            onToggleAscending: () => ref.read(librarySortAscendingProvider.notifier).state =
                !ref.read(librarySortAscendingProvider),
            sortValue: ref.watch(librarySortProvider),
            onSortSelected: (v) => ref.read(librarySortProvider.notifier).state = v,
            items: SongSortField.values
                .map((f) => PopupMenuItem(value: f, child: Text(_sortLabel(f))))
                .toList(),
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
                hintText: 'Search title, artist, album',
              ),
              onChanged: (v) => ref.read(librarySearchProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: songsAsync.when(
              data: (songs) => songs.isEmpty
                  ? Center(
                      child: Text(
                        _scanning
                            ? 'Scanning your Music folder...'
                            : 'No songs found in your device\'s Music folder.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: songs.length,
                      itemBuilder: (context, i) => _buildTile(context, songs, i),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, List<Song> songs, int i) {
    final song = songs[i];
    return SongTile(
      song: song,
      trailing: PopupMenuButton<_SongAction>(
        icon: const Icon(Icons.more_vert),
        padding: EdgeInsets.zero,
        onSelected: (action) async {
          switch (action) {
            case _SongAction.edit:
              await showSongEditDialog(context, ref, song);
            case _SongAction.hide:
              await ref.read(songRepositoryProvider).setHidden(song.id, true);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: _SongAction.edit, child: Text('Edit')),
          PopupMenuItem(value: _SongAction.hide, child: Text('Hide')),
        ],
      ),
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => StandardPlayerScreen(songs: songs, initialIndex: i),
        ),
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
