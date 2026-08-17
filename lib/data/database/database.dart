import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart' show BreakCueMode;

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
  int get schemaVersion => 6;

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
          if (from < 4) {
            await m.addColumn(songs, songs.isFavorite);
          }
          if (from < 5) {
            await m.addColumn(practiceSets, practiceSets.repeatEnabled);
          }
          if (from < 6) {
            // These per-set/per-entry overrides were superseded by single
            // global settings (breakCueModeProvider/fadeOutSecondsProvider)
            // and were never actually read anywhere; folderId/selectionMode
            // /lastPlayedSongId are similarly dead - sets have only been
            // creatable from playlists for a while, and song selection now
            // lives entirely in PracticeSessionController's in-memory pools.
            //
            // Uses an explicit table rebuild rather than repeated
            // Migrator.dropColumn calls - the latter was observed on-device
            // to corrupt a retained column (defaultBreakSeconds silently
            // reset to its schema default) when dropping several columns
            // from the same table in one migration. TableMigration copies
            // every column that still exists (by name) into the recreated
            // table and drops the rest, which is safe for this case since
            // none of the retained columns are being renamed or need a
            // value transformation.
            await m.alterTable(TableMigration(practiceSets));
            await m.alterTable(TableMigration(setEntries));
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
