import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/app_settings_repository.dart';
import '../library/library_screen.dart' show librarySongsProvider;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _scanning = false;

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

  @override
  Widget build(BuildContext context) {
    final defaults = ref.watch(setDefaultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('New set defaults'),
            subtitle: Text(_summarize(defaults)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editSetDefaults(context, ref, defaults),
          ),
          const Divider(),
          ListTile(
            leading: _scanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            title: const Text('Rescan Music folder'),
            subtitle: const Text('Imports any new songs added to your device\'s Music folder'),
            onTap: _scanning ? null : _rescanLibrary,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear all app data'),
            subtitle: const Text(
              'Deletes all imported songs, playlists, and practice sets',
            ),
            onTap: () => _confirmClearData(context, ref),
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

  String _summarize(SetDefaults d) {
    final play = '${d.playDurationSeconds ~/ 60}:${(d.playDurationSeconds % 60).toString().padLeft(2, '0')}';
    final cue = switch (d.breakCueMode) {
      BreakCueMode.beepBeforeEnd => 'beep cue',
      BreakCueMode.ambientSong => 'break track',
      _ => 'silence',
    };
    return '$play play \u2022 ${d.breakSeconds}s break ($cue) \u2022 ${d.tempoPercent}% tempo';
  }

  Future<void> _editSetDefaults(
    BuildContext context,
    WidgetRef ref,
    SetDefaults current,
  ) async {
    final result = await showDialog<SetDefaults>(
      context: context,
      builder: (context) => _SetDefaultsDialog(initial: current),
    );
    if (result != null) {
      await ref.read(setDefaultsProvider.notifier).update(result);
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
}

class _SetDefaultsDialog extends ConsumerStatefulWidget {
  const _SetDefaultsDialog({required this.initial});
  final SetDefaults initial;

  @override
  ConsumerState<_SetDefaultsDialog> createState() => _SetDefaultsDialogState();
}

class _SetDefaultsDialogState extends ConsumerState<_SetDefaultsDialog> {
  late int _tempo = widget.initial.tempoPercent;
  late int _play = widget.initial.playDurationSeconds;
  late int _brk = widget.initial.breakSeconds;
  late int _fade = widget.initial.fadeOutSeconds;
  late String _breakCueMode = widget.initial.breakCueMode;
  late int _beepLead = widget.initial.beepLeadSeconds;
  String? _ambientSongId;
  Song? _ambientSong;

  @override
  void initState() {
    super.initState();
    _ambientSongId = widget.initial.ambientSongId;
    if (_ambientSongId != null) _loadAmbientSong(_ambientSongId!);
  }

  Future<void> _loadAmbientSong(String id) async {
    final song = await ref.read(songRepositoryProvider).getById(id);
    if (mounted) setState(() => _ambientSong = song);
  }

  Future<void> _pickAmbientSong() async {
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
                        leading: const Icon(Icons.music_note),
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
      setState(() {
        _ambientSongId = song.id;
        _ambientSong = song;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New set defaults'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tempo: $_tempo%'),
            Slider(
              value: _tempo.toDouble(),
              min: TempoLimits.minPercent.toDouble(),
              max: TempoLimits.maxPercent.toDouble(),
              divisions: TempoLimits.maxPercent - TempoLimits.minPercent,
              onChanged: (v) => setState(() => _tempo = v.round()),
            ),
            Text('Play duration: ${_play}s'),
            Slider(
              value: _play.toDouble(),
              min: 15,
              max: 300,
              divisions: 57,
              onChanged: (v) => setState(() => _play = v.round()),
            ),
            Text('Break: ${_brk}s'),
            Slider(
              value: _brk.toDouble(),
              min: 0,
              max: 120,
              divisions: 24,
              onChanged: (v) => setState(() => _brk = v.round()),
            ),
            Text('Fade-out at cutoff: ${_fade}s'),
            Slider(
              value: _fade.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => setState(() => _fade = v.round()),
            ),
            const SizedBox(height: 12),
            const Text('Break cue', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _breakCueMode,
              onChanged: (v) => setState(() => _breakCueMode = v!),
              child: Column(
                children: const [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Silence'),
                    value: BreakCueMode.silence,
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Silence + beeps before next song'),
                    value: BreakCueMode.beepBeforeEnd,
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Break audio track'),
                    value: BreakCueMode.ambientSong,
                  ),
                ],
              ),
            ),
            if (_breakCueMode == BreakCueMode.beepBeforeEnd) ...[
              Text('Beep lead time: ${_beepLead}s before next song'),
              Slider(
                value: _beepLead.toDouble().clamp(0, _brk.toDouble()),
                min: 0,
                max: _brk.toDouble().clamp(1, double.infinity),
                divisions: _brk.clamp(1, 999),
                onChanged: (v) => setState(() => _beepLead = v.round()),
              ),
            ],
            if (_breakCueMode == BreakCueMode.ambientSong)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note),
                title: Text(_ambientSong?.title ?? 'Choose a track'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickAmbientSong,
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
          onPressed: () => Navigator.of(context).pop(
            SetDefaults(
              tempoPercent: _tempo,
              playDurationSeconds: _play,
              breakSeconds: _brk,
              fadeOutSeconds: _fade,
              breakCueMode: _breakCueMode,
              beepLeadSeconds: _beepLead,
              ambientSongId:
                  _breakCueMode == BreakCueMode.ambientSong ? _ambientSongId : null,
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
