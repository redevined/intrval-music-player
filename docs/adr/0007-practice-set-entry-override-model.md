# 0007 - Practice set / entry override data model

## Status

Accepted

## Context

The core feature is a "practice set": an ordered sequence of slots (e.g.
Waltz, Tango, Foxtrot), each sourcing one random or sequential song from a
playlist or bookmarked folder, played with a configurable tempo/play
duration/break/fade-out. Most entries in a set typically share the same
timing, but the user explicitly asked for the ability to override any of
these per entry (e.g. "one entry to play shorter than the rest").

## Decision

Model this as two tables: `PracticeSets` holds the set-level defaults
(`defaultTempoPercent`, `defaultPlayDurationSeconds`, `defaultBreakSeconds`,
`defaultFadeOutSeconds`, `defaultBreakCueMode`, `defaultBeepLeadSeconds`,
`defaultAmbientSongId`), and `SetEntries` holds the same fields but
nullable, meaning "inherit from the parent set" when null. Resolution
happens once per entry at playback time in
`PracticeSessionScreen._resolveEntry()`
(`lib/features/player/practice_session_screen.dart`):
`entry.field ?? set.defaultField`.

## Consequences

- Editing a set's defaults automatically propagates to every entry that
  hasn't explicitly overridden that field, without needing to touch
  `SetEntries` rows.
- The UI (`SetBuilderScreen`) represents "inherit" as `null` in override
  sliders/dialogs, with an explicit "reset to inherit" action, rather than
  auto-filling entries with the current default at creation time (which
  would silently decouple them from later default changes).
- `SetEntries.lastPlayedSongId` tracks the most recently played song per
  entry, used to avoid picking the same song twice in a row when the
  entry's source has more than one song.
