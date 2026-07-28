import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('New set defaults'),
            subtitle: Text(
              '${AppDefaults.newSetEntryCount} entries \u2022 '
              '${AppDefaults.playDurationSeconds ~/ 60}:${(AppDefaults.playDurationSeconds % 60).toString().padLeft(2, '0')} play \u2022 '
              '${AppDefaults.breakSeconds}s break',
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Storage permission'),
            subtitle: const Text('Required to read audio files and folders'),
            trailing: FilledButton(
              onPressed: () async {
                await Permission.audio.request();
                await Permission.manageExternalStorage.request();
              },
              child: const Text('Grant'),
            ),
          ),
          const Divider(),
          const AboutListTile(
            applicationName: 'intrval',
            applicationVersion: '1.0.0',
            aboutBoxChildren: [
              Text('A tempo-controlled practice-set music player for dancers.'),
            ],
          ),
        ],
      ),
    );
  }
}
