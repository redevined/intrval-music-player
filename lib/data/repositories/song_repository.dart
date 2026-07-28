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
  }) {
    final select = _db.select(_db.songs);
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

  Future<String> importSong({
    required String uri,
    required String title,
    String? artist,
    String? album,
    int? durationMs,
    String? artworkPath,
    String? sourceFolderId,
  }) async {
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
        );
    return id;
  }

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
}
