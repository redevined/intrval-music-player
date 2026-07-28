import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../library/library_screen.dart';
import '../playlists/playlist_list_screen.dart';

final _setEntriesProvider =
    StreamProvider.autoDispose.family<List<SetEntry>, String>((ref, setId) {
  return ref.watch(practiceSetRepositoryProvider).watchEntries(setId);
});

class SetBuilderScreen extends ConsumerWidget {
  const SetBuilderScreen({super.key, required this.practiceSet});

  final PracticeSet practiceSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(_setEntriesProvider(practiceSet.id));
    final playlistsAsync = ref.watch(playlistsProvider);
    final foldersAsync = ref.watch(bookmarkedFoldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(practiceSet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set defaults',
            onPressed: () => _editDefaults(context, ref),
          ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) {
          final playlists = playlistsAsync.valueOrNull ?? const <Playlist>[];
          final folders = foldersAsync.valueOrNull ?? const <BookmarkedFolder>[];

          if (entries.isEmpty) {
            return const Center(child: Text('No entries yet. Tap + to add one.'));
          }
          return ReorderableListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final entry = entries[i];
              final sourceName = entry.playlistId != null
                  ? playlists
                      .firstWhere(
                        (p) => p.id == entry.playlistId,
                        orElse: () => Playlist(
                          id: '',
                          name: '(deleted playlist)',
                          dateCreated: DateTime.now(),
                        ),
                      )
                      .name
                  : folders
                      .firstWhere(
                        (f) => f.id == entry.folderId,
                        orElse: () => BookmarkedFolder(
                          id: '',
                          treeUri: '',
                          displayName: '(deleted folder)',
                          dateAdded: DateTime.now(),
                        ),
                      )
                      .displayName;

              return ListTile(
                key: ValueKey(entry.id),
                leading: const Icon(Icons.drag_handle),
                title: Text(entry.label),
                subtitle: Text(sourceName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref
                      .read(practiceSetRepositoryProvider)
                      .removeEntry(entry.id),
                ),
                onTap: () => _editEntry(context, ref, entry, playlists, folders),
              );
            },
            onReorderItem: (oldIndex, newIndex) {
              final ids = entries.map((e) => e.id).toList();
              final id = ids.removeAt(oldIndex);
              ids.insert(newIndex, id);
              ref
                  .read(practiceSetRepositoryProvider)
                  .reorderEntries(practiceSet.id, ids);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEntry(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addEntry(BuildContext context, WidgetRef ref) async {
    final source = await _pickSource(context, ref);
    if (source == null) return;
    await ref.read(practiceSetRepositoryProvider).addEntry(
          practiceSet.id,
          label: source.label,
          playlistId: source.playlistId,
        );
  }

  Future<void> _editEntry(
    BuildContext context,
    WidgetRef ref,
    SetEntry entry,
    List<Playlist> playlists,
    List<BookmarkedFolder> folders,
  ) async {
    final labelController = TextEditingController(text: entry.label);
    var tempoPercent = entry.tempoPercent;
    var playSeconds = entry.playDurationSeconds;
    var breakSeconds = entry.breakSeconds;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                const SizedBox(height: 16),
                Text('Tempo override: ${tempoPercent ?? "inherit"}${tempoPercent != null ? "%" : ""}'),
                Slider(
                  value: (tempoPercent ?? AppDefaults.tempoPercent).toDouble(),
                  min: TempoLimits.minPercent.toDouble(),
                  max: TempoLimits.maxPercent.toDouble(),
                  divisions: TempoLimits.maxPercent - TempoLimits.minPercent,
                  onChanged: (v) => setState(() => tempoPercent = v.round()),
                ),
                Text('Play duration override: ${playSeconds ?? "inherit"}${playSeconds != null ? "s" : ""}'),
                Slider(
                  value: (playSeconds ?? AppDefaults.playDurationSeconds).toDouble(),
                  min: 15,
                  max: 300,
                  divisions: 57,
                  onChanged: (v) => setState(() => playSeconds = v.round()),
                ),
                Text('Break override: ${breakSeconds ?? "inherit"}${breakSeconds != null ? "s" : ""}'),
                Slider(
                  value: (breakSeconds ?? AppDefaults.breakSeconds).toDouble(),
                  min: 0,
                  max: 120,
                  divisions: 24,
                  onChanged: (v) => setState(() => breakSeconds = v.round()),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    tempoPercent = null;
                    playSeconds = null;
                    breakSeconds = null;
                  }),
                  child: const Text('Reset overrides to inherit'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(practiceSetRepositoryProvider).updateEntry(
                      entry.id,
                      SetEntriesCompanion(
                        label: Value(labelController.text.trim()),
                        tempoPercent: Value(tempoPercent),
                        playDurationSeconds: Value(playSeconds),
                        breakSeconds: Value(breakSeconds),
                      ),
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editDefaults(BuildContext context, WidgetRef ref) async {
    var tempo = practiceSet.defaultTempoPercent;
    var play = practiceSet.defaultPlayDurationSeconds;
    var brk = practiceSet.defaultBreakSeconds;
    var fade = practiceSet.defaultFadeOutSeconds;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set defaults'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tempo: $tempo%'),
              Slider(
                value: tempo.toDouble(),
                min: TempoLimits.minPercent.toDouble(),
                max: TempoLimits.maxPercent.toDouble(),
                divisions: TempoLimits.maxPercent - TempoLimits.minPercent,
                onChanged: (v) => setState(() => tempo = v.round()),
              ),
              Text('Play duration: ${play}s'),
              Slider(
                value: play.toDouble(),
                min: 15,
                max: 300,
                divisions: 57,
                onChanged: (v) => setState(() => play = v.round()),
              ),
              Text('Break: ${brk}s'),
              Slider(
                value: brk.toDouble(),
                min: 0,
                max: 120,
                divisions: 24,
                onChanged: (v) => setState(() => brk = v.round()),
              ),
              Text('Fade-out at cutoff: ${fade}s'),
              Slider(
                value: fade.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (v) => setState(() => fade = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(practiceSetRepositoryProvider).update(
                      practiceSet.id,
                      PracticeSetsCompanion(
                        defaultTempoPercent: Value(tempo),
                        defaultPlayDurationSeconds: Value(play),
                        defaultBreakSeconds: Value(brk),
                        defaultFadeOutSeconds: Value(fade),
                      ),
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<_SourcePick?> _pickSource(BuildContext context, WidgetRef ref) async {
    final playlists = ref.read(playlistsProvider).valueOrNull ?? const <Playlist>[];

    return showModalBottomSheet<_SourcePick>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => playlists.isEmpty
            ? const Center(child: Text('No playlists yet. Create one first.'))
            : ListView(
                controller: scrollController,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Playlists', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...playlists.map((p) => ListTile(
                        leading: const Icon(Icons.queue_music),
                        title: Text(p.name),
                        onTap: () => Navigator.of(context).pop(
                          _SourcePick(label: p.name, playlistId: p.id),
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}

class _SourcePick {
  _SourcePick({required this.label, this.playlistId});
  final String label;
  final String? playlistId;
}
