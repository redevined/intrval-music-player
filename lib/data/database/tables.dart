import 'package:drift/drift.dart';

/// A single imported audio file. Its `uri` is either a plain filesystem
/// path (legacy/app-owned storage) or a SAF `content://` URI (files picked
/// from a bookmarked folder on Android scoped storage).
class Songs extends Table {
  TextColumn get id => text()();

  /// Filesystem path or content:// URI this song was imported from. Unique
  /// so the library scanner can safely re-run (including concurrently)
  /// without ever creating duplicate rows for the same file.
  TextColumn get uri => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer().nullable()();

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

  /// Hidden songs are excluded from the Library list and from every
  /// playlist (see [PlaylistRepository.watchSongs]). Toggled manually from
  /// the Library's per-song menu, or set automatically by
  /// [MusicLibraryScanner] when a song's backing file is no longer found on
  /// disk (moved/deleted). A "show hidden" filter in Settings reveals them
  /// again for manual unhiding either way.
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  /// Toggled from the Library/Playlist three-dot menu and the player's
  /// heart button. Drives the favorite-only filter in Library/Playlist
  /// views.
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

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

/// Enum-like string values for the global break audio cue mode setting
/// (see `breakCueModeProvider`).
class BreakCueMode {
  static const silence = 'silence';
  static const beepBeforeEnd = 'beepBeforeEnd';
  static const ambientSong = 'ambientSong';
}

/// A "practice set" (meta-playlist): an ordered sequence of entries, each
/// pulling one song from a playlist, played top to bottom with a
/// configurable tempo/break. The break cue (silence/beep/ambient track) and
/// its fade-out are single global settings (see `breakCueModeProvider`,
/// `fadeOutSecondsProvider`), not something decided per set.
class PracticeSets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Default tempo as a percentage of original speed (70-130).
  IntColumn get defaultTempoPercent => integer().withDefault(const Constant(100))();
  IntColumn get defaultPlayDurationSeconds =>
      integer().withDefault(const Constant(105))(); // 1:45
  IntColumn get defaultBreakSeconds =>
      integer().withDefault(const Constant(30))();

  /// When true, a session loops back to the first entry after the last one
  /// finishes (indefinitely) instead of completing. See
  /// [PracticeSessionController._advance].
  BoolColumn get repeatEnabled =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get dateCreated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single entry (dance slot) within a [PracticeSets]. Sources one random
/// song per play from a playlist. Any override column left null falls back
/// to the parent set's default.
class SetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get setId =>
      text().references(PracticeSets, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortIndex => integer()();

  /// Display label shown during practice (e.g. "Waltz"). Defaults to the
  /// source playlist's name if not set.
  TextColumn get label => text()();

  TextColumn get playlistId =>
      text().nullable().references(Playlists, #id, onDelete: KeyAction.cascade)();

  // Per-entry overrides (null = inherit from parent PracticeSet).
  IntColumn get tempoPercent => integer().nullable()();
  IntColumn get playDurationSeconds => integer().nullable()();
  IntColumn get breakSeconds => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
