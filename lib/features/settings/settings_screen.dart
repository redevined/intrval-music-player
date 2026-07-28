import 'package:flutter/material.dart';

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
              '${AppDefaults.playDurationSeconds ~/ 60}:${(AppDefaults.playDurationSeconds % 60).toString().padLeft(2, '0')} play \u2022 '
              '${AppDefaults.breakSeconds}s break',
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
