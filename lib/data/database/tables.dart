import 'package:drift/drift.dart';

/// A single imported audio file. Its `uri` is either a plain filesystem
/// path (legacy/app-owned storage) or a SAF `content://` URI (files picked
/// from a bookmarked folder on Android scoped storage).
class Songs extends Table {
  TextColumn get id => text()();
  TextColumn get uri => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get artworkPath => text().nullable()();

  /// BPM automatically detected by the on-device DSP pipeline.
  RealColumn get bpmDetected => real().nullable()();

  /// BPM manually entered/corrected by the user. Takes precedence over
  /// [bpmDetected] everywhere in the UI when present.
  RealColumn get bpmManual => real().nullable()();

  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();

  /// Folder this song was discovered in, if it came from a bookmarked
  /// folder rather than being added directly to a playlist.
  TextColumn get sourceFolderId =>
      text().nullable().references(BookmarkedFolders, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

/// A user-curated playlist (hand-picked songs, explicit order).
class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get dateCreated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Join table: ordered membership of songs within a playlist.
class PlaylistSongs extends Table {
  TextColumn get playlistId =>
      text().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortIndex => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

/// A device folder bookmarked via the Storage Access Framework. Its content
/// is (re)scanned live rather than stored as a fixed song list, so it acts
/// like a dynamic playlist.
class BookmarkedFolders extends Table {
  TextColumn get id => text()();
  TextColumn get treeUri => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get dateAdded =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Enum-like string values for [SetEntries.selectionMode].
class SelectionMode {
  static const randomNoImmediateRepeat = 'randomNoImmediateRepeat';
  static const sequential = 'sequential';
}

/// Enum-like string values for break audio cue mode, used both at the
/// [PracticeSets] (default) and [SetEntries] (override) level.
class BreakCueMode {
  static const silence = 'silence';
  static const beepBeforeEnd = 'beepBeforeEnd';
  static const ambientSong = 'ambientSong';
}

/// A "practice set" (meta-playlist): an ordered sequence of entries, each
/// pulling one song from a playlist or bookmarked folder, played top to
/// bottom with configurable tempo/break/fade defaults.
class PracticeSets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Default tempo as a percentage of original speed (70-130).
  IntColumn get defaultTempoPercent => integer().withDefault(const Constant(100))();
  IntColumn get defaultPlayDurationSeconds =>
      integer().withDefault(const Constant(105))(); // 1:45
  IntColumn get defaultBreakSeconds =>
      integer().withDefault(const Constant(30))();
  IntColumn get defaultFadeOutSeconds =>
      integer().withDefault(const Constant(3))();
  TextColumn get defaultBreakCueMode =>
      text().withDefault(const Constant(BreakCueMode.silence))();
  IntColumn get defaultBeepLeadSeconds =>
      integer().withDefault(const Constant(5))();
  TextColumn get defaultAmbientSongId =>
      text().nullable().references(Songs, #id)();

  DateTimeColumn get dateCreated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single entry (dance slot) within a [PracticeSets]. Sources one random
/// (or sequential) song per play from either a playlist or a bookmarked
/// folder. Any override column left null falls back to the parent set's
/// default.
class SetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get setId =>
      text().references(PracticeSets, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortIndex => integer()();

  /// Display label shown during practice (e.g. "Waltz"). Defaults to the
  /// source playlist/folder name if not set.
  TextColumn get label => text()();

  /// Exactly one of these two should be non-null.
  TextColumn get playlistId =>
      text().nullable().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get folderId => text()
      .nullable()
      .references(BookmarkedFolders, #id, onDelete: KeyAction.cascade)();

  TextColumn get selectionMode => text()
      .withDefault(const Constant(SelectionMode.randomNoImmediateRepeat))();

  /// Last song played for this entry, used to avoid immediate repeats and
  /// to resume position in sequential mode.
  TextColumn get lastPlayedSongId => text().nullable()();

  // Per-entry overrides (null = inherit from parent PracticeSet).
  IntColumn get tempoPercent => integer().nullable()();
  IntColumn get playDurationSeconds => integer().nullable()();
  IntColumn get breakSeconds => integer().nullable()();
  IntColumn get fadeOutSeconds => integer().nullable()();
  TextColumn get breakCueMode => text().nullable()();
  IntColumn get beepLeadSeconds => integer().nullable()();
  TextColumn get ambientSongId =>
      text().nullable().references(Songs, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
