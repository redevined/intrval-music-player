import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

class PlaylistRepository {
  PlaylistRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Playlist>> watchAll() {
    return (_db.select(_db.playlists)
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .watch();
  }

  Future<String> create(String name) async {
    final id = _uuid.v4();
    await _db.into(_db.playlists).insert(
          PlaylistsCompanion.insert(id: id, name: name),
        );
    return id;
  }

  Future<void> rename(String id, String name) {
    return (_db.update(_db.playlists)..where((p) => p.id.equals(id)))
        .write(PlaylistsCompanion(name: Value(name)));
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.playlists)..where((p) => p.id.equals(id))).go();

  /// Songs in a playlist, in their stored order, joined with song data.
  /// Excludes hidden songs - including ones the library scanner hid
  /// automatically because their backing file was moved/deleted (see
  /// [MusicLibraryScanner]) - so a playlist never surfaces a song it can't
  /// actually play.
  Stream<List<Song>> watchSongs(String playlistId) {
    final query = _db.select(_db.playlistSongs).join([
      innerJoin(_db.songs, _db.songs.id.equalsExp(_db.playlistSongs.songId)),
    ])
      ..where(_db.playlistSongs.playlistId.equals(playlistId) &
          _db.songs.isHidden.equals(false))
      ..orderBy([OrderingTerm.asc(_db.playlistSongs.sortIndex)]);
    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(_db.songs)).toList(),
        );
  }

  /// IDs of every playlist [songId] currently belongs to - used to show
  /// membership status in the "add to playlist" picker.
  Stream<Set<String>> watchPlaylistIdsForSong(String songId) {
    final query = _db.select(_db.playlistSongs)
      ..where((ps) => ps.songId.equals(songId));
    return query
        .watch()
        .map((rows) => rows.map((r) => r.playlistId).toSet());
  }

  Future<void> addSong(String playlistId, String songId) async {
    final currentMax = await (_db.selectOnly(_db.playlistSongs)
          ..addColumns([_db.playlistSongs.sortIndex.max()])
          ..where(_db.playlistSongs.playlistId.equals(playlistId)))
        .getSingleOrNull();
    final nextIndex =
        (currentMax?.read(_db.playlistSongs.sortIndex.max()) ?? -1) + 1;
    await _db.into(_db.playlistSongs).insert(
          PlaylistSongsCompanion.insert(
            playlistId: playlistId,
            songId: songId,
            sortIndex: nextIndex,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeSong(String playlistId, String songId) {
    return (_db.delete(_db.playlistSongs)
          ..where((ps) =>
              ps.playlistId.equals(playlistId) & ps.songId.equals(songId)))
        .go();
  }

  Future<void> reorder(String playlistId, List<String> orderedSongIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedSongIds.length; i++) {
        await (_db.update(_db.playlistSongs)
              ..where((ps) =>
                  ps.playlistId.equals(playlistId) &
                  ps.songId.equals(orderedSongIds[i])))
            .write(PlaylistSongsCompanion(sortIndex: Value(i)));
      }
    });
  }
}
