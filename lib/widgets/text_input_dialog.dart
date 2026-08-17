import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Single-text-field `AlertDialog` for a name entry/rename, returning the
/// trimmed input, or null if cancelled - shared by every "New X"/"Rename X"
/// flow (playlists, practice sets, the inline "new playlist" prompt from the
/// add-to-playlist sheet).
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String label = 'Name',
  String confirmLabel = 'Create',
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: kDialogContentWidth,
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
