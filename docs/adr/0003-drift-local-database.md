# 0003 - Drift (SQLite) as the local database

## Status

Accepted

## Context

The app needs structured, relational local storage: songs (with metadata
and BPM), playlists (ordered song membership), bookmarked folders, and
practice sets with ordered entries that reference either a playlist or a
folder. All storage is local-only (see ADR on storage model, folded into
this one: no cloud sync is planned). Needed reactive queries so the UI
updates automatically as data changes (e.g. importing songs while the
Library screen is open).

## Decision

Use `drift` on top of SQLite (`sqlite3_flutter_libs` for the native binary
on Android). Schema lives in `lib/data/database/tables.dart`
(`Songs`, `Playlists`, `PlaylistSongs`, `BookmarkedFolders`, `PracticeSets`,
`SetEntries`), with generated code via `drift_dev`/`build_runner`.
`SelectionMode` and `BreakCueMode` are plain string-constant classes rather
than SQL enums, since Drift doesn't have first-class enum columns across all
its backends.

## Consequences

- Reactive `.watch()` queries back `StreamProvider`s directly - no manual
  cache invalidation needed in the UI layer.
- Foreign keys use `KeyAction.cascade` for ownership relations (e.g.
  deleting a playlist cascades to its `PlaylistSongs` rows).
- `sqlite3` package version must stay below the 3.0.0 "build hooks"/native
  assets migration for now, or `AppDatabase`'s Android dependency chain
  changes - see ADR 0008 and `docs/TROUBLESHOOTING.md` for the dead-end we
  hit trying to pin it down and why it turned out to be unnecessary.
- `AppDatabase.forTesting(executor)` constructor exists specifically to
  support in-memory (`NativeDatabase.memory()`) databases in widget tests.
