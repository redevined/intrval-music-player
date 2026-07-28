import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_player_service.dart';
import '../services/bpm_detection_service.dart';
import '../services/file_import_service.dart';
import '../services/music_library_scanner.dart';
import 'database/database.dart';
import 'repositories/folder_repository.dart';
import 'repositories/playlist_repository.dart';
import 'repositories/practice_set_repository.dart';
import 'repositories/song_repository.dart';

/// Overridden in `main()` with the instance returned by `AudioService.init`.
final audioHandlerProvider = Provider<AudioPlayerHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main()');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final fileImportServiceProvider = Provider<FileImportService>((ref) {
  return FileImportService();
});

final bpmDetectionServiceProvider = Provider<BpmDetectionService>((ref) {
  return BpmDetectionService();
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository(ref.watch(databaseProvider));
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository(ref.watch(databaseProvider));
});

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository(
    ref.watch(databaseProvider),
    ref.watch(songRepositoryProvider),
    ref.watch(fileImportServiceProvider),
  );
});

final practiceSetRepositoryProvider = Provider<PracticeSetRepository>((ref) {
  return PracticeSetRepository(ref.watch(databaseProvider));
});

final musicLibraryScannerProvider = Provider<MusicLibraryScanner>((ref) {
  return MusicLibraryScanner(
    ref.watch(songRepositoryProvider),
    ref.watch(fileImportServiceProvider),
    ref.watch(bpmDetectionServiceProvider),
  );
});
