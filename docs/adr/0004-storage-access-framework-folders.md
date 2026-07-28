# 0004 - Storage Access Framework for folder import

## Status

Accepted (Android-only; see `docs/IOS_ROADMAP.md`)

## Context

The app needs to let users "bookmark" a folder of music (e.g. an SD card
directory of ballroom tracks) and have the app treat its contents as a
dynamic, live-synced source for playlists/practice sets, without copying
files into app-private storage. On Android, scoped storage (Android 10+)
means the app cannot browse arbitrary filesystem paths directly - it must
use the Storage Access Framework (SAF) to get a persistable `content://`
URI permission for a user-picked tree.

## Decision

Use the `saf` package to pick a folder tree, persist the permission grant,
and enumerate/read files under it via `content://` URIs. `FolderRepository`
(`lib/data/repositories/folder_repository.dart`) wraps this: picking,
bookmarking, deleting, and re-syncing a folder's song list.
Metadata/BPM-reading code that needs a real filesystem path (e.g.
`audiotags`, `just_waveform`) stages the SAF URI to a temp local file first
via `lib/services/local_file_staging.dart`.

## Consequences

- **This is Android-only.** The `saf` package has no iOS implementation
  (Storage Access Framework is an Android-specific concept). Confirmed with
  the user that Android-only is acceptable for now.
- Every read of a SAF-sourced file pays a one-time staging cost (copy to a
  temp file), cleaned up immediately after use.
- iOS would need a fundamentally different UX for this feature (the
  "bookmark a live folder" model doesn't map cleanly onto iOS's sandboxed,
  security-scoped-bookmark file access model) - see
  `docs/IOS_ROADMAP.md`.
