import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import 'app_settings_repository.dart';

class PracticeSetRepository {
  PracticeSetRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<PracticeSet>> watchAll() {
    return (_db.select(_db.practiceSets)
          ..orderBy([(s) => OrderingTerm(expression: s.name)]))
        .watch();
  }

  Future<PracticeSet?> getById(String id) =>
      (_db.select(_db.practiceSets)..where((s) => s.id.equals(id)))
          .getSingleOrNull();

  Stream<PracticeSet?> watchById(String id) =>
      (_db.select(_db.practiceSets)..where((s) => s.id.equals(id)))
          .watchSingleOrNull();

  /// Creates a new practice set. If [defaults] is given (the user's
  /// configured Settings > New set defaults), it seeds the set's default_*
  /// columns explicitly; otherwise the table's hardcoded schema defaults
  /// apply.
  Future<String> create(String name, {SetDefaults? defaults}) async {
    final id = _uuid.v4();
    await _db.into(_db.practiceSets).insert(
          PracticeSetsCompanion.insert(
            id: id,
            name: name,
            defaultTempoPercent: defaults != null
                ? Value(defaults.tempoPercent)
                : const Value.absent(),
            defaultPlayDurationSeconds: defaults != null
                ? Value(defaults.playDurationSeconds)
                : const Value.absent(),
            defaultBreakSeconds: defaults != null
                ? Value(defaults.breakSeconds)
                : const Value.absent(),
          ),
        );
    return id;
  }

  Future<void> update(String id, PracticeSetsCompanion changes) {
    return (_db.update(_db.practiceSets)..where((s) => s.id.equals(id)))
        .write(changes);
  }

  Future<void> rename(String id, String name) {
    return update(id, PracticeSetsCompanion(name: Value(name)));
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.practiceSets)..where((s) => s.id.equals(id))).go();

  Stream<List<SetEntry>> watchEntries(String setId) {
    return (_db.select(_db.setEntries)
          ..where((e) => e.setId.equals(setId))
          ..orderBy([(e) => OrderingTerm(expression: e.sortIndex)]))
        .watch();
  }

  Future<String> addEntry(
    String setId, {
    required String label,
    String? playlistId,
    String? folderId,
  }) async {
    final currentMax = await (_db.selectOnly(_db.setEntries)
          ..addColumns([_db.setEntries.sortIndex.max()])
          ..where(_db.setEntries.setId.equals(setId)))
        .getSingleOrNull();
    final nextIndex =
        (currentMax?.read(_db.setEntries.sortIndex.max()) ?? -1) + 1;

    final id = _uuid.v4();
    await _db.into(_db.setEntries).insert(
          SetEntriesCompanion.insert(
            id: id,
            setId: setId,
            sortIndex: nextIndex,
            label: label,
            playlistId: Value(playlistId),
            folderId: Value(folderId),
          ),
        );
    return id;
  }

  Future<void> updateEntry(String id, SetEntriesCompanion changes) {
    return (_db.update(_db.setEntries)..where((e) => e.id.equals(id)))
        .write(changes);
  }

  Future<void> removeEntry(String id) =>
      (_db.delete(_db.setEntries)..where((e) => e.id.equals(id))).go();

  Future<void> reorderEntries(String setId, List<String> orderedEntryIds) {
    return _db.transaction(() async {
      for (var i = 0; i < orderedEntryIds.length; i++) {
        await (_db.update(_db.setEntries)
              ..where((e) => e.id.equals(orderedEntryIds[i])))
            .write(SetEntriesCompanion(sortIndex: Value(i)));
      }
    });
  }
}
