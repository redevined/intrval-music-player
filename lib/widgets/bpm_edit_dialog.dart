import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../data/providers.dart';

Future<void> showBpmEditDialog(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final controller = TextEditingController(
    text: (song.bpmManual ?? song.bpmDetected)?.round().toString() ?? '',
  );
  var isDetecting = false;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'BPM (manual)'),
              ),
              const SizedBox(height: 12),
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
          actions: [
            if (song.bpmManual != null)
              TextButton(
                onPressed: () async {
                  await ref
                      .read(songRepositoryProvider)
                      .setManualBpm(song.id, null);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Clear override'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final parsed = double.tryParse(controller.text.trim());
                await ref
                    .read(songRepositoryProvider)
                    .setManualBpm(song.id, parsed);
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
