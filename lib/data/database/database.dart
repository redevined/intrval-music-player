import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart' show BreakCueMode, SelectionMode;

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Songs,
    Playlists,
    PlaylistSongs,
    BookmarkedFolders,
    PracticeSets,
    SetEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(songs, songs.isHidden);
          }
          if (from < 3) {
            // Collapse any duplicate rows a pre-fix scanner race may have
            // created for the same file before adding the UNIQUE(uri)
            // constraint below (which would otherwise fail to apply).
            await customStatement(
              'DELETE FROM songs WHERE id NOT IN '
              '(SELECT MIN(id) FROM songs GROUP BY uri)',
            );
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_songs_uri_unique ON songs (uri)',
            );
          }
        },
      );

  /// Deletes every row from every table (used by Settings' "Clear all app
  /// data"). Music files on disk are untouched - the Library's auto-scanner
  /// will re-import them fresh next time it runs.
  Future<void> clearAllData() {
    return transaction(() async {
      await delete(setEntries).go();
      await delete(practiceSets).go();
      await delete(playlistSongs).go();
      await delete(playlists).go();
      await delete(songs).go();
      await delete(bookmarkedFolders).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'intrval.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
