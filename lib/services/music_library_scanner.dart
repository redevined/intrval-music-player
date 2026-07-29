import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../data/repositories/song_repository.dart';
import 'bpm_detection_service.dart';
import 'file_import_service.dart';

/// Default OS directories auto-scanned for music, without requiring the
/// user to explicitly pick a folder via SAF. This is the Library's primary
/// song source; bookmarked (SAF-picked) folders remain a separate,
/// explicit opt-in used from Playlists.
const defaultLibraryRoots = ['/storage/emulated/0/Music'];

/// Scans [defaultLibraryRoots] for audio files not yet imported and imports
/// them. Safe to call repeatedly - already-imported files (matched by their
/// filesystem path) are skipped.
///
/// Work is deliberately split in two: importing a file only needs its tag
/// header (fast), while BPM detection decodes the whole file (seconds per
/// song). Interleaving them made each song appear in the library only after
/// the previous song's analysis finished, so the list trickled in one row at
/// a time. BPM detection therefore runs as a separate background pass that
/// fills in `bpmDetected` afterwards; the UI picks the values up through the
/// database's reactive streams.
class MusicLibraryScanner {
  MusicLibraryScanner(
    this._songRepository,
    this._importService,
    this._bpmService, {
    List<String> roots = defaultLibraryRoots,
    Future<bool> Function()? ensurePermission,
    // An initializing formal is not an option here: named parameters cannot
    // be private, so `this._roots` would be invalid.
    // ignore: prefer_initializing_formals
  })  : _roots = roots,
        _ensurePermission = ensurePermission ?? _requestAudioPermission;

  final SongRepository _songRepository;
  final FileImportService _importService;
  final BpmDetectionService _bpmService;

  /// Overridable so tests can point the scan at a temp directory instead of
  /// the device's real (and, off-device, nonexistent) Music folder.
  final List<String> _roots;

  /// Overridable so tests don't have to stand up the permission plugin.
  final Future<bool> Function() _ensurePermission;

  Future<void>? _inFlight;
  Future<void>? _bpmPass;

  /// Songs whose analysis returned no usable result this session. Detection
  /// legitimately gives up on some files (too short, unsupported codec), and
  /// those rows keep matching [SongRepository.songsMissingBpm], so remember
  /// them to avoid re-decoding the same files on every rescan. Deliberately
  /// in-memory only: a fresh app start gets to try again.
  final _unanalyzable = <String>{};

  /// Completes once newly found files have been imported. If a scan is
  /// already running, returns its Future instead of starting a redundant
  /// second pass (while [SongRepository.importSong] is safe to call
  /// concurrently, there's no reason to extract metadata twice for the same
  /// files).
  ///
  /// Note this intentionally does *not* wait for BPM detection: it returns
  /// as soon as the songs are visible, and analysis continues in the
  /// background.
  Future<void> scan() => _inFlight ??= _doScan().whenComplete(() => _inFlight = null);

  Future<void> _doScan() async {
    if (!await _ensurePermission()) return;
    await _importNewFiles();
    unawaited(_detectMissingBpm());
  }

  Future<void> _importNewFiles() async {
    final existingUris = await _songRepository.allUris();

    for (final root in _roots) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;

      final entities = await dir.list(recursive: true, followLinks: false).toList();
      for (final entity in entities) {
        if (entity is! File) continue;
        if (!isAudioFileName(entity.path)) continue;
        if (existingUris.contains(entity.path)) continue;

        final metadata = await _importService.extractMetadata(entity.path);
        await _songRepository.importSong(
          uri: entity.path,
          title: metadata.title,
          artist: metadata.artist,
          album: metadata.album,
          durationMs: metadata.durationMs,
        );
      }
    }
  }

  /// Analyzes every song still missing a BPM, one at a time, persisting each
  /// result as it lands. Covers songs imported by any route, not just the
  /// ones this scan happened to add. Joins an already-running pass rather
  /// than starting a competing one.
  Future<void> _detectMissingBpm() =>
      _bpmPass ??= _runBpmPass().whenComplete(() => _bpmPass = null);

  Future<void> _runBpmPass() async {
    final pending = await _songRepository.songsMissingBpm();
    for (final song in pending) {
      if (_unanalyzable.contains(song.id)) continue;
      try {
        final result = await _bpmService.detectBpm(song.uri);
        if (result != null) {
          await _songRepository.setDetectedBpm(song.id, result.bpm);
        } else {
          _unanalyzable.add(song.id);
        }
      } catch (_) {
        // A single unreadable file must not abort the whole backlog.
        _unanalyzable.add(song.id);
      }
    }
  }
}

/// Requests the runtime permission needed to read shared audio storage:
/// `READ_MEDIA_AUDIO` on Android 13+, falling back to legacy
/// `READ_EXTERNAL_STORAGE` on older versions. Both are already declared
/// in AndroidManifest.xml.
Future<bool> _requestAudioPermission() async {
  final audioStatus = await Permission.audio.request();
  if (audioStatus.isGranted) return true;
  final storageStatus = await Permission.storage.request();
  return storageStatus.isGranted;
}
