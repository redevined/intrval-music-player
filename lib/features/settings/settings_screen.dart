import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/app_settings_repository.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/tab_heading.dart';
import '../library/library_screen.dart' show librarySongsProvider;
import 'hidden_songs_screen.dart';

final _ambientSongProvider =
    FutureProvider.autoDispose.family<Song?, String>((ref, id) {
  return ref.watch(songRepositoryProvider).getById(id);
});

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

  void _updateDefaults(SetDefaults updated) {
    unawaited(ref.read(setDefaultsProvider.notifier).update(updated));
  }

  Future<void> _pickAmbientSong(SetDefaults defaults) async {
    final song = await showModalBottomSheet<Song>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, _) {
            final songsAsync = ref.watch(librarySongsProvider);
            return songsAsync.when(
              data: (songs) => songs.isEmpty
                  ? const Center(child: Text('No songs in your library yet.'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: songs.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(songs[i].title),
                        subtitle: songs[i].artist != null ? Text(songs[i].artist!) : null,
                        onTap: () => Navigator.of(context).pop(songs[i]),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
        ),
      ),
    );
    if (song != null) {
      _updateDefaults(defaults.copyWith(ambientSongId: song.id));
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
    final hiddenCount = ref.watch(_hiddenSongCountProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const TabHeading('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('New set defaults'),
          LabeledSlider(
            label: 'Tempo',
            valueLabel: '${defaults.tempoPercent}%',
            value: defaults.tempoPercent.toDouble(),
            min: TempoLimits.minPercent.toDouble(),
            max: TempoLimits.maxPercent.toDouble(),
            divisions: TempoLimits.maxPercent - TempoLimits.minPercent,
            onChanged: (v) => _updateDefaults(defaults.copyWith(tempoPercent: v.round())),
          ),
          LabeledSlider(
            label: 'Play duration',
            valueLabel: '${defaults.playDurationSeconds}s',
            value: defaults.playDurationSeconds.toDouble(),
            min: 15,
            max: 300,
            divisions: 57,
            onChanged: (v) =>
                _updateDefaults(defaults.copyWith(playDurationSeconds: v.round())),
          ),
          LabeledSlider(
            label: 'Break',
            valueLabel: '${defaults.breakSeconds}s',
            value: defaults.breakSeconds.toDouble(),
            min: 0,
            max: 120,
            divisions: 24,
            onChanged: (v) => _updateDefaults(defaults.copyWith(breakSeconds: v.round())),
          ),
          LabeledSlider(
            label: 'Fade-out at cutoff',
            valueLabel: '${defaults.fadeOutSeconds}s',
            value: defaults.fadeOutSeconds.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) => _updateDefaults(defaults.copyWith(fadeOutSeconds: v.round())),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text('Break cue', style: Theme.of(context).textTheme.bodyLarge),
          ),
          RadioGroup<String>(
            groupValue: defaults.breakCueMode,
            onChanged: (v) => _updateDefaults(defaults.copyWith(breakCueMode: v)),
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('Silence'),
                  value: BreakCueMode.silence,
                ),
                RadioListTile<String>(
                  title: Text('Silence + beeps before next song'),
                  value: BreakCueMode.beepBeforeEnd,
                ),
                RadioListTile<String>(
                  title: Text('Break audio track'),
                  value: BreakCueMode.ambientSong,
                ),
              ],
            ),
          ),
          if (defaults.breakCueMode == BreakCueMode.beepBeforeEnd)
            LabeledSlider(
              label: 'Beep lead time',
              valueLabel: '${defaults.beepLeadSeconds}s before next song',
              value: defaults.beepLeadSeconds.toDouble().clamp(0, defaults.breakSeconds.toDouble()),
              min: 0,
              max: defaults.breakSeconds.toDouble().clamp(1, double.infinity),
              divisions: defaults.breakSeconds.clamp(1, 999),
              onChanged: (v) =>
                  _updateDefaults(defaults.copyWith(beepLeadSeconds: v.round())),
            ),
          if (defaults.breakCueMode == BreakCueMode.ambientSong)
            Builder(
              builder: (context) {
                final ambientId = defaults.ambientSongId;
                final ambientSong = ambientId == null
                    ? null
                    : ref.watch(_ambientSongProvider(ambientId)).valueOrNull;
                return ListTile(
                  title: Text(ambientSong?.title ?? 'Choose a track'),
                  subtitle: const Text('Break audio track'),
                  onTap: () => _pickAmbientSong(defaults),
                );
              },
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

