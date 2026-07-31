import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/app_settings_repository.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/tab_heading.dart';
import 'hidden_songs_screen.dart';

final _hiddenSongCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(songRepositoryProvider)
      .watchAll(onlyHidden: true)
      .map((songs) => songs.length);
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _scanning = false;
  bool _pickingFolder = false;

  Future<void> _rescanLibrary() async {
    setState(() => _scanning = true);
    try {
      await ref.read(musicLibraryScannerProvider).scan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Music folder rescanned.')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _pickRootFolder() async {
    setState(() => _pickingFolder = true);
    try {
      final path = await ref.read(appSettingsRepositoryProvider).pickMusicRootFolder();
      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Couldn't use that folder - pick one on this device's main storage.",
              ),
            ),
          );
        }
        return;
      }
      await ref.read(musicRootFolderProvider.notifier).update(path);
      await _rescanLibrary();
    } finally {
      if (mounted) setState(() => _pickingFolder = false);
    }
  }

  Future<void> _editSetDefaults(BuildContext context, WidgetRef ref, SetDefaults defaults) async {
    var tempo = defaults.tempoPercent;
    var play = defaults.playDurationSeconds;
    var brk = defaults.breakSeconds;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New set defaults'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledSlider(
                  padding: EdgeInsets.zero,
                  label: 'Tempo',
                  valueLabel: '$tempo%',
                  value: tempo.toDouble(),
                  min: TempoLimits.minPercent.toDouble(),
                  max: TempoLimits.maxPercent.toDouble(),
                  divisions: TempoLimits.maxPercent - TempoLimits.minPercent,
                  onChanged: (v) => setState(() => tempo = v.round()),
                ),
                LabeledSlider(
                  padding: EdgeInsets.zero,
                  label: 'Play duration',
                  valueLabel: '${play}s',
                  value: play.toDouble(),
                  min: 15,
                  max: 300,
                  divisions: 57,
                  onChanged: (v) => setState(() => play = v.round()),
                ),
                LabeledSlider(
                  padding: EdgeInsets.zero,
                  label: 'Break',
                  valueLabel: '${brk}s',
                  value: brk.toDouble(),
                  min: 0,
                  max: 120,
                  divisions: 24,
                  onChanged: (v) => setState(() => brk = v.round()),
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
                await ref.read(setDefaultsProvider.notifier).update(
                      SetDefaults(
                        tempoPercent: tempo,
                        playDurationSeconds: play,
                        breakSeconds: brk,
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

  Future<void> _editFadeOutSeconds(BuildContext context, WidgetRef ref, int current) async {
    var fade = current;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Song fade-out'),
          content: SingleChildScrollView(
            child: LabeledSlider(
              padding: EdgeInsets.zero,
              label: 'Fade-out at cutoff',
              valueLabel: '${fade}s',
              value: fade.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => setState(() => fade = v.round()),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(fadeOutSecondsProvider.notifier).update(fade);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _breakCueModeLabel(String mode) {
    switch (mode) {
      case BreakCueMode.beepBeforeEnd:
        return 'Silence + beeps before next song';
      case BreakCueMode.ambientSong:
        return 'Break audio track';
      case BreakCueMode.silence:
      default:
        return 'Silence';
    }
  }

  Future<void> _pickBreakCueMode(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (v) => Navigator.of(context).pop(v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Silence'),
                value: BreakCueMode.silence,
              ),
              RadioListTile<String>(
                title: const Text('Silence + beeps before next song'),
                value: BreakCueMode.beepBeforeEnd,
              ),
              RadioListTile<String>(
                title: const Text('Break audio track'),
                value: BreakCueMode.ambientSong,
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && selected != current) {
      await ref.read(breakCueModeProvider.notifier).update(selected);
    }
  }

  Future<void> _confirmClearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all app data?'),
        content: const Text(
          'This deletes all imported songs, playlists, and practice sets. '
          'Your music files themselves are not touched - songs are '
          're-imported automatically next time you open the Library tab.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All app data cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaults = ref.watch(setDefaultsProvider);
    final rootFolder = ref.watch(musicRootFolderProvider);
    final breakCueMode = ref.watch(breakCueModeProvider);
    final fadeOutSeconds = ref.watch(fadeOutSecondsProvider);
    final hiddenCount = ref.watch(_hiddenSongCountProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const TabHeading('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Sets'),
          ListTile(
            title: const Text('New set defaults'),
            subtitle: Text(
              'Tempo ${defaults.tempoPercent}% \u00b7 Play ${defaults.playDurationSeconds}s \u00b7 '
              'Break ${defaults.breakSeconds}s',
            ),
            onTap: () => _editSetDefaults(context, ref, defaults),
          ),
          ListTile(
            title: const Text('Song fade-out'),
            subtitle: Text('${fadeOutSeconds}s at cutoff'),
            onTap: () => _editFadeOutSeconds(context, ref, fadeOutSeconds),
          ),
          ListTile(
            title: const Text('Break cue'),
            subtitle: Text(_breakCueModeLabel(breakCueMode)),
            onTap: () => _pickBreakCueMode(context, ref, breakCueMode),
          ),
          const Divider(),
          const _SectionHeader('Library'),
          ListTile(
            title: const Text('Music folder'),
            subtitle: Text(rootFolder),
            trailing: _pickingFolder
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _pickingFolder ? null : _pickRootFolder,
          ),
          ListTile(
            title: const Text('Rescan music folder'),
            subtitle: Text(
              _scanning
                  ? 'Scanning...'
                  : "Imports any new songs added to your device's Music folder",
            ),
            onTap: _scanning ? null : _rescanLibrary,
          ),
          ListTile(
            title: const Text('Manage hidden songs'),
            subtitle: Text(
              hiddenCount == null
                  ? 'Loading...'
                  : hiddenCount == 0
                      ? 'No hidden songs'
                      : '$hiddenCount hidden',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HiddenSongsScreen()),
            ),
          ),
          const Divider(),
          const _SectionHeader('Data'),
          ListTile(
            title: const Text('Clear all app data', style: TextStyle(color: Colors.red)),
            subtitle: const Text(
              'Deletes all imported songs, playlists, and practice sets',
            ),
            onTap: () => _confirmClearData(context, ref),
          ),
          const Divider(),
          const _SectionHeader('About'),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

