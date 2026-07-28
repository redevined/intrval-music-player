import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../player/practice_session_screen.dart';
import 'set_builder_screen.dart';

final practiceSetsProvider = StreamProvider.autoDispose<List<PracticeSet>>((ref) {
  return ref.watch(practiceSetRepositoryProvider).watchAll();
});

class SetListScreen extends ConsumerWidget {
  const SetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(practiceSetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice Sets')),
      body: setsAsync.when(
        data: (sets) => sets.isEmpty
            ? const Center(child: Text('No practice sets yet.'))
            : ListView.builder(
                itemCount: sets.length,
                itemBuilder: (context, i) {
                  final set = sets[i];
                  return ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(set.name),
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
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              ref.read(practiceSetRepositoryProvider).delete(set.id),
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
      final id = await ref
          .read(practiceSetRepositoryProvider)
          .createWithDefaultEntries(name);
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
}
