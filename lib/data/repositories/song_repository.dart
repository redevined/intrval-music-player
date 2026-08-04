import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

enum SongSortField { title, artist, album, dateAdded, duration, bpm }

class SongRepository {
  SongRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Song>> watchAll({
    String? query,
    double? minBpm,
    double? maxBpm,
    SongSortField sortField = SongSortField.title,
    bool ascending = true,
    bool onlyHidden = false,
    bool onlyFavorite = false,
  }) {
    final select = _db.select(_db.songs);
    select.where((s) => s.isHidden.equals(onlyHidden));
    if (onlyFavorite) {
      select.where((s) => s.isFavorite.equals(true));
    }
    if (query != null && query.trim().isNotEmpty) {
      final like = '%${query.trim()}%';
      select.where((s) =>
          s.title.like(like) | s.artist.like(like) | s.album.like(like));
    }
    if (minBpm != null || maxBpm != null) {
      select.where((s) {
        final bpm = coalesce([s.bpmManual, s.bpmDetected]);
        Expression<bool> cond = const Constant(true);
        if (minBpm != null) cond = cond & bpm.isBiggerOrEqualValue(minBpm);
        if (maxBpm != null) cond = cond & bpm.isSmallerOrEqualValue(maxBpm);
        return cond;
      });
    }
    final mode = ascending ? OrderingMode.asc : OrderingMode.desc;
    select.orderBy([
      (s) => switch (sortField) {
            SongSortField.title => OrderingTerm(expression: s.title, mode: mode),
            SongSortField.artist => OrderingTerm(expression: s.artist, mode: mode),
            SongSortField.album => OrderingTerm(expression: s.album, mode: mode),
            SongSortField.dateAdded =>
              OrderingTerm(expression: s.dateAdded, mode: mode),
            SongSortField.duration =>
              OrderingTerm(expression: s.durationMs, mode: mode),
            SongSortField.bpm => OrderingTerm(
                expression: coalesce([s.bpmManual, s.bpmDetected]),
                mode: mode,
              ),
          },
    ]);
    return select.watch();
  }

  Future<Song?> getById(String id) =>
      (_db.select(_db.songs)..where((s) => s.id.equals(id)))
          .getSingleOrNull();

  /// Imports a song, or returns the existing song's id if [uri] was already
  /// imported (e.g. by another source resolving to the same canonical
  /// path - see [FolderRepository.syncFolder]). If the existing row isn't
  /// yet attributed to a bookmarked folder and [sourceFolderId] is given,
  /// it's backfilled so `songsForFolder` keeps reflecting this folder's
  /// current contents even when its files were already in the library.
  ///
  /// Wrapped in a transaction (and backed by a UNIQUE(uri) constraint) so
  /// this is safe to call concurrently - e.g. an overlapping double
  /// invocation of the library scanner - without ever creating duplicate
  /// rows for the same file.
  Future<String> importSong({
    required String uri,
    required String title,
    String? artist,
    String? album,
    int? durationMs,
    String? artworkPath,
    String? sourceFolderId,
  }) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.songs)..where((s) => s.uri.equals(uri)))
          .getSingleOrNull();
      if (existing != null) {
        if (sourceFolderId != null && existing.sourceFolderId == null) {
          await (_db.update(_db.songs)..where((s) => s.id.equals(existing.id)))
              .write(SongsCompanion(sourceFolderId: Value(sourceFolderId)));
        }
        return existing.id;
      }

      final id = _uuid.v4();
      await _db.into(_db.songs).insert(
            SongsCompanion.insert(
              id: id,
              uri: uri,
              title: title,
              artist: Value(artist),
              album: Value(album),
              durationMs: Value(durationMs),
              artworkPath: Value(artworkPath),
              sourceFolderId: Value(sourceFolderId),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return id;
    });
  }

  /// Songs that have never had a BPM analysis result stored. Drives the
  /// library scanner's background BPM pass, so songs imported by any route
  /// (default-root scan or bookmarked folder sync) eventually get analyzed.
  Future<List<Song>> songsMissingBpm() =>
      (_db.select(_db.songs)..where((s) => s.bpmDetected.isNull())).get();

  Future<void> setDetectedBpm(String songId, double bpm) {
    return (_db.update(_db.songs)..where((s) => s.id.equals(songId)))
        .write(SongsCompanion(bpmDetected: Value(bpm)));
  }

  Future<void> setManualBpm(String songId, double? bpm) {
    return (_db.update(_db.songs)..where((s) => s.id.equals(songId)))
        .write(SongsCompanion(bpmManual: Value(bpm)));
  }

  Future<void> updateMetadata(
    String songId, {
    required String title,
    String? artist,
  }) {
    return (_db.update(_db.songs)..where((s) => s.id.equals(songId))).write(
      SongsCompanion(
        title: Value(title),
        artist: Value(artist),
      ),
    );
  }

  Future<void> deleteSong(String id) =>
      (_db.delete(_db.songs)..where((s) => s.id.equals(id))).go();

  Future<List<Song>> songsForFolder(String folderId) =>
      (_db.select(_db.songs)..where((s) => s.sourceFolderId.equals(folderId)))
          .get();

  Future<void> setHidden(String songId, bool hidden) {
    return (_db.update(_db.songs)..where((s) => s.id.equals(songId)))
        .write(SongsCompanion(isHidden: Value(hidden)));
  }

  Future<void> setFavorite(String songId, bool favorite) {
    return (_db.update(_db.songs)..where((s) => s.id.equals(songId)))
        .write(SongsCompanion(isFavorite: Value(favorite)));
  }

  /// All currently-imported song URIs, used by the library auto-scanner to
  /// skip files that have already been imported.
  Future<Set<String>> allUris() async {
    final rows = await (_db.selectOnly(_db.songs)..addColumns([_db.songs.uri])).get();
    return rows.map((r) => r.read(_db.songs.uri)!).toSet();
  }
}
