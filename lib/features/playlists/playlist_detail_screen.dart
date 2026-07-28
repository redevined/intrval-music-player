import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/song_edit_dialog.dart';
import '../../widgets/song_tile.dart';
import '../library/library_screen.dart';
import '../player/standard_player_screen.dart';

final _playlistSongsProvider =
    StreamProvider.autoDispose.family<List<Song>, String>((ref, playlistId) {
  return ref.watch(playlistRepositoryProvider).watchSongs(playlistId);
});

/// View-only sort for a playlist's song list. [manual] shows the playlist's
/// stored (drag-reorderable) order; any other value re-sorts the displayed
/// list without touching the persisted order, and disables drag-reordering
/// while active (there'd be nothing sensible for a drag to do).
enum PlaylistViewSort { manual, title, artist, bpm, duration }

enum _SongAction { edit, remove }

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});

  final Playlist playlist;

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  String _query = '';
  PlaylistViewSort _sort = PlaylistViewSort.manual;

  List<Song> _visible(List<Song> songs) {
    var result = songs;
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((s) =>
              s.title.toLowerCase().contains(query) ||
              (s.artist?.toLowerCase().contains(query) ?? false))
          .toList();
    }
    if (_sort == PlaylistViewSort.manual) return result;
    result = [...result];
    switch (_sort) {
      case PlaylistViewSort.manual:
        break;
      case PlaylistViewSort.title:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case PlaylistViewSort.artist:
        result.sort(
            (a, b) => (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase()));
      case PlaylistViewSort.bpm:
        result.sort((a, b) {
          final bpmA = a.bpmManual ?? a.bpmDetected ?? 0;
          final bpmB = b.bpmManual ?? b.bpmDetected ?? 0;
          return bpmA.compareTo(bpmB);
        });
      case PlaylistViewSort.duration:
        result.sort((a, b) => (a.durationMs ?? 0).compareTo(b.durationMs ?? 0));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(_playlistSongsProvider(widget.playlist.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        actions: [
          PopupMenuButton<PlaylistViewSort>(
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: PlaylistViewSort.manual,
                child: Text('Manual (drag to reorder)'),
              ),
              PopupMenuItem(value: PlaylistViewSort.title, child: Text('Title')),
              PopupMenuItem(value: PlaylistViewSort.artist, child: Text('Artist')),
              PopupMenuItem(value: PlaylistViewSort.bpm, child: Text('BPM')),
              PopupMenuItem(value: PlaylistViewSort.duration, child: Text('Duration')),
            ],
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
                hintText: 'Search this playlist',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: songsAsync.when(
              data: (allSongs) {
                final songs = _visible(allSongs);
                if (songs.isEmpty) {
                  return Center(
                    child: Text(
                      allSongs.isEmpty
                          ? 'No songs yet. Tap + to add some.'
                          : 'No songs match your search.',
                    ),
                  );
                }
                if (_sort != PlaylistViewSort.manual) {
                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, i) =>
                        _buildTile(context, songs, i, showDragHandle: false),
                  );
                }
                return ReorderableListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, i) =>
                      _buildTile(context, songs, i, showDragHandle: true),
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = songs.map((s) => s.id).toList();
                    final id = ids.removeAt(oldIndex);
                    ids.insert(newIndex, id);
                    ref
                        .read(playlistRepositoryProvider)
                        .reorder(widget.playlist.id, ids);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSongs(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    List<Song> songs,
    int i, {
    required bool showDragHandle,
  }) {
    final song = songs[i];
    return SongTile(
      key: ValueKey(song.id),
      song: song,
      leading: showDragHandle
          ? ReorderableDragStartListener(
              index: i,
              child: const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.drag_handle),
              ),
            )
          : null,
      trailing: PopupMenuButton<_SongAction>(
        icon: const Icon(Icons.more_vert),
        onSelected: (action) async {
          switch (action) {
            case _SongAction.edit:
              await showSongEditDialog(context, ref, song);
            case _SongAction.remove:
              await ref
                  .read(playlistRepositoryProvider)
                  .removeSong(widget.playlist.id, song.id);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: _SongAction.edit, child: Text('Edit')),
          PopupMenuItem(value: _SongAction.remove, child: Text('Remove from playlist')),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StandardPlayerScreen(songs: songs, initialIndex: i),
        ),
      ),
    );
  }

  Future<void> _addSongs(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddSongsSheet(playlistId: widget.playlist.id),
    );
  }
}

class _AddSongsSheet extends ConsumerStatefulWidget {
  const _AddSongsSheet({required this.playlistId});
  final String playlistId;

  @override
  ConsumerState<_AddSongsSheet> createState() => _AddSongsSheetState();
}

class _AddSongsSheetState extends ConsumerState<_AddSongsSheet> {
  bool _addingFolder = false;

  Future<void> _addFolder() async {
    setState(() => _addingFolder = true);
    try {
      final folderId =
          await ref.read(folderRepositoryProvider).pickAndBookmarkFolder();
      if (folderId == null) return;
      final songs = await ref.read(songRepositoryProvider).songsForFolder(folderId);
      final playlistRepo = ref.read(playlistRepositoryProvider);
      for (final song in songs) {
        await playlistRepo.addSong(widget.playlistId, song.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${songs.length} song(s) from folder')),
        );
      }
    } finally {
      if (mounted) setState(() => _addingFolder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(librarySongsProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, scrollController) => songsAsync.when(
        data: (songs) => ListView(
          controller: scrollController,
          children: [
            ListTile(
              leading: _addingFolder
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.create_new_folder),
              title: const Text('Add an OS folder'),
              subtitle: const Text('Imports and adds every song in the folder'),
              onTap: _addingFolder ? null : _addFolder,
            ),
            const Divider(height: 1),
            for (var i = 0; i < songs.length; i++)
              SongTile(
                song: songs[i],
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () => ref
                    .read(playlistRepositoryProvider)
                    .addSong(widget.playlistId, songs[i].id),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
