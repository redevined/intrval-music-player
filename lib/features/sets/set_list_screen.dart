import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../player/practice_session_screen.dart';
import 'set_builder_screen.dart';

enum SetSortField { name, dateCreated }

final practiceSetsProvider = StreamProvider.autoDispose<List<PracticeSet>>((ref) {
  return ref.watch(practiceSetRepositoryProvider).watchAll();
});

final setSortProvider = StateProvider.autoDispose<SetSortField>((ref) => SetSortField.name);
final setSortAscendingProvider = StateProvider.autoDispose<bool>((ref) => true);

final visiblePracticeSetsProvider = Provider.autoDispose<AsyncValue<List<PracticeSet>>>((ref) {
  final setsAsync = ref.watch(practiceSetsProvider);
  final sortField = ref.watch(setSortProvider);
  final ascending = ref.watch(setSortAscendingProvider);

  return setsAsync.whenData((sets) {
    var result = [...sets];
    switch (sortField) {
      case SetSortField.name:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SetSortField.dateCreated:
        result.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    }
    if (!ascending) result = result.reversed.toList();
    return result;
  });
});

final _setEntryCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, setId) {
  return ref
      .watch(practiceSetRepositoryProvider)
      .watchEntries(setId)
      .map((entries) => entries.length);
});

class SetListScreen extends ConsumerWidget {
  const SetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(visiblePracticeSetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Sets'),
        actions: [
          IconButton(
            tooltip: ref.watch(setSortAscendingProvider) ? 'Ascending' : 'Descending',
            icon: Icon(
              ref.watch(setSortAscendingProvider)
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: () => ref.read(setSortAscendingProvider.notifier).state =
                !ref.read(setSortAscendingProvider),
          ),
          PopupMenuButton<SetSortField>(
            icon: const Icon(Icons.sort),
            initialValue: ref.watch(setSortProvider),
            onSelected: (v) => ref.read(setSortProvider.notifier).state = v,
            itemBuilder: (context) => const [
              PopupMenuItem(value: SetSortField.name, child: Text('Name')),
              PopupMenuItem(
                value: SetSortField.dateCreated,
                child: Text('Date created'),
              ),
            ],
          ),
        ],
      ),
      body: setsAsync.when(
        data: (sets) => sets.isEmpty
            ? const Center(child: Text('No practice sets yet.'))
            : ListView.builder(
                itemCount: sets.length,
                itemBuilder: (context, i) {
                  final set = sets[i];
                  return ListTile(
                    leading: const Icon(Icons.timelapse),
                    title: Text(set.name),
                    subtitle: Consumer(
                      builder: (context, ref, _) {
                        final count = ref.watch(_setEntryCountProvider(set.id)).valueOrNull;
                        return Text(count == null
                            ? ''
                            : '$count ${count == 1 ? 'entry' : 'entries'}');
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PracticeSessionScreen(practiceSet: set),
                            ),
                          ),
                        ),
                        PopupMenuButton<_SetAction>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (action) async {
                            switch (action) {
                              case _SetAction.rename:
                                await _renameSet(context, ref, set);
                              case _SetAction.delete:
                                await ref
                                    .read(practiceSetRepositoryProvider)
                                    .delete(set.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _SetAction.rename,
                              child: Text('Rename'),
                            ),
                            PopupMenuItem(
                              value: _SetAction.delete,
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SetBuilderScreen(practiceSet: set),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createSet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createSet(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New practice set'),
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
      final defaults = ref.read(setDefaultsProvider);
      final id = await ref
          .read(practiceSetRepositoryProvider)
          .create(name, defaults: defaults);
      if (context.mounted) {
        final set = await ref.read(practiceSetRepositoryProvider).getById(id);
        if (set != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SetBuilderScreen(practiceSet: set)),
          );
        }
      }
    }
  }

  Future<void> _renameSet(
    BuildContext context,
    WidgetRef ref,
    PracticeSet set,
  ) async {
    final controller = TextEditingController(text: set.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename set'),
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
      await ref.read(practiceSetRepositoryProvider).rename(set.id, name);
    }
  }
}

enum _SetAction { rename, delete }
