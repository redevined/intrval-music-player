import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../widgets/song_tile.dart';

final _hiddenSongsProvider = StreamProvider.autoDispose<List<Song>>((ref) {
  return ref.watch(songRepositoryProvider).watchAll(onlyHidden: true);
});

/// Lets the user unhide songs previously hidden from the Library tab.
/// Reached from Settings > Library > Manage hidden songs.
class HiddenSongsScreen extends ConsumerWidget {
  const HiddenSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(_hiddenSongsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hidden songs')),
      body: songsAsync.when(
        data: (songs) => songs.isEmpty
            ? const Center(child: Text('No hidden songs.'))
            : ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, i) {
                  final song = songs[i];
                  return SongTile(
                    song: song,
                    leading: const SizedBox.shrink(),
                    trailing: TextButton(
                      onPressed: () =>
                          ref.read(songRepositoryProvider).setHidden(song.id, false),
                      child: const Text('Unhide'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
