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

/// Scans [defaultLibraryRoots] for audio files not yet imported, imports
/// them, and immediately runs BPM detection on each new song, persisting
/// the result. Safe to call repeatedly - already-imported files (matched by
/// their filesystem path) are skipped.
class MusicLibraryScanner {
  MusicLibraryScanner(this._songRepository, this._importService, this._bpmService);

  final SongRepository _songRepository;
  final FileImportService _importService;
  final BpmDetectionService _bpmService;

  Future<void>? _inFlight;

  /// If a scan is already running, returns its Future instead of starting a
  /// redundant second pass (metadata/BPM extraction is expensive, and while
  /// [SongRepository.importSong] is safe to call concurrently, there's no
  /// reason to do the extraction work twice for the same files).
  Future<void> scan() => _inFlight ??= _doScan().whenComplete(() => _inFlight = null);

  Future<void> _doScan() async {
    if (!await _ensurePermission()) return;

    final existingUris = await _songRepository.allUris();

    for (final root in defaultLibraryRoots) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;

      final entities = await dir.list(recursive: true, followLinks: false).toList();
      for (final entity in entities) {
        if (entity is! File) continue;
        if (!isAudioFileName(entity.path)) continue;
        if (existingUris.contains(entity.path)) continue;

        final metadata = await _importService.extractMetadata(entity.path);
        final songId = await _songRepository.importSong(
          uri: entity.path,
          title: metadata.title,
          artist: metadata.artist,
          album: metadata.album,
          durationMs: metadata.durationMs,
        );

        final bpmResult = await _bpmService.detectBpm(entity.path);
        if (bpmResult != null) {
          await _songRepository.setDetectedBpm(songId, bpmResult.bpm);
        }
      }
    }
  }

  /// Requests the runtime permission needed to read shared audio storage:
  /// `READ_MEDIA_AUDIO` on Android 13+, falling back to legacy
  /// `READ_EXTERNAL_STORAGE` on older versions. Both are already declared
  /// in AndroidManifest.xml.
  Future<bool> _ensurePermission() async {
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) return true;
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }
}
