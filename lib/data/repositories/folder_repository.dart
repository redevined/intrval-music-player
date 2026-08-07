import 'package:drift/drift.dart';
import 'package:saf/saf.dart';
import 'package:uuid/uuid.dart';

import '../../services/file_import_service.dart';
import '../database/database.dart';
import 'song_repository.dart';

class FolderRepository {
  FolderRepository(this._db, this._songRepository, this._importService);

  final AppDatabase _db;
  final SongRepository _songRepository;
  final FileImportService _importService;
  final _saf = Saf();
  static const _uuid = Uuid();

  Stream<List<BookmarkedFolder>> watchAll() {
    return (_db.select(_db.bookmarkedFolders)
          ..orderBy([(f) => OrderingTerm(expression: f.displayName)]))
        .watch();
  }

  /// Opens the system directory picker (SAF), persists the permission
  /// grant, and stores a bookmark row. Returns null if the user cancelled.
  Future<String?> pickAndBookmarkFolder() async {
    final dir = await _saf.pickDirectory();
    if (dir == null) return null;

    final id = _uuid.v4();
    await _db.into(_db.bookmarkedFolders).insert(
          BookmarkedFoldersCompanion.insert(
            id: id,
            treeUri: dir.uri,
            displayName: dir.name,
          ),
        );
    await syncFolder(id);
    return id;
  }

  Future<void> delete(String id) async {
    final folder = await (_db.select(_db.bookmarkedFolders)
          ..where((f) => f.id.equals(id)))
        .getSingleOrNull();
    if (folder != null) {
      await _saf.releasePersistedPermission(folder.treeUri);
    }
    await (_db.delete(_db.bookmarkedFolders)..where((f) => f.id.equals(id)))
        .go();
  }

  /// Re-scans a bookmarked folder's contents via SAF and imports any audio
  /// files not already tracked as Songs for this folder.
  ///
  /// SAF URIs on the device's primary storage volume are resolved to their
  /// plain filesystem path (the same representation the default Music
  /// folder auto-scanner uses) before importing, so a folder that overlaps
  /// with the auto-scanned library dedupes against it instead of creating
  /// duplicate entries for the same file.
  Future<void> syncFolder(String folderId) async {
    final folder = await (_db.select(_db.bookmarkedFolders)
          ..where((f) => f.id.equals(folderId)))
        .getSingleOrNull();
    if (folder == null) return;

    final entries = await _saf.list(folder.treeUri);
    final existing = await _songRepository.songsForFolder(folderId);
    final existingUris = existing.map((s) => s.uri).toSet();

    for (final entry in entries) {
      if (entry.isDir) continue;
      if (!isAudioFileName(entry.name)) continue;

      final canonicalUri = resolvePrimaryStoragePath(entry.uri) ?? entry.uri;
      if (existingUris.contains(canonicalUri)) continue;

      final metadata = await _importService.extractMetadata(entry.uri);
      await _songRepository.importSong(
        uri: canonicalUri,
        title: metadata.title,
        artist: metadata.artist,
        album: metadata.album,
        durationMs: metadata.durationMs,
        artworkPath: metadata.artworkPath,
        sourceFolderId: folderId,
      );
    }
  }
}
