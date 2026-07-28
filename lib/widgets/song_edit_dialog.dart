import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../data/providers.dart';

/// Full song metadata editor: title, artist, and BPM (manual override, with
/// a re-detect action). Used from the Library and Playlist three-dot menus.
Future<void> showSongEditDialog(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final titleController = TextEditingController(text: song.title);
  final artistController = TextEditingController(text: song.artist ?? '');
  final bpmController = TextEditingController(
    text: (song.bpmManual ?? song.bpmDetected)?.round().toString() ?? '',
  );
  var isDetecting = false;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Edit song'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: artistController,
                  decoration: const InputDecoration(labelText: 'Artist'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bpmController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'BPM (manual)'),
                ),
                const SizedBox(height: 8),
                if (song.bpmDetected != null)
                  Text(
                    'Auto-detected: ${song.bpmDetected!.round()} BPM',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isDetecting
                      ? null
                      : () async {
                          setState(() => isDetecting = true);
                          final result = await ref
                              .read(bpmDetectionServiceProvider)
                              .detectBpm(song.uri);
                          if (result != null) {
                            await ref
                                .read(songRepositoryProvider)
                                .setDetectedBpm(song.id, result.bpm);
                          }
                          setState(() => isDetecting = false);
                        },
                  icon: isDetecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Re-detect BPM'),
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
                final title = titleController.text.trim();
                final artist = artistController.text.trim();
                final bpm = double.tryParse(bpmController.text.trim());
                await ref.read(songRepositoryProvider).updateMetadata(
                      song.id,
                      title: title.isEmpty ? song.title : title,
                      artist: artist.isEmpty ? null : artist,
                    );
                await ref.read(songRepositoryProvider).setManualBpm(song.id, bpm);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}
