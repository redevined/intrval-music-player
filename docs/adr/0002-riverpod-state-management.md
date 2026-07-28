# 0002 - Riverpod for state management

## Status

Accepted

## Context

The app has several independent but related streams of state: the Drift
database (reactive queries), the audio playback engine, and UI-local state
(search/sort filters, dialogs, in-progress practice session state). Needed a
DI/state solution that plays well with `StreamProvider`-style reactive data
from Drift and is testable without a `BuildContext`.

## Decision

Use `flutter_riverpod`. Repositories and services (`SongRepository`,
`PlaylistRepository`, `FolderRepository`, `PracticeSetRepository`,
`FileImportService`, `BpmDetectionService`, `AudioPlayerHandler`) are exposed
via `Provider`s in `lib/data/providers.dart`, and screen-level reactive data
uses `StreamProvider`/`StreamProvider.family` wrapping Drift's `.watch()`
queries directly.

## Consequences

- Widgets consume state via `ConsumerWidget`/`ConsumerStatefulWidget` and
  `ref.watch`/`ref.read`; no `BuildContext`-based DI needed for services.
- `audioHandlerProvider` is a placeholder (`throw UnimplementedError`)
  overridden in `main()` once `AudioService.init()` resolves - this keeps
  the async platform-service bootstrap out of the provider graph itself.
- Widget tests override `databaseProvider`/`audioHandlerProvider` directly
  (see `test/widget_test.dart`) rather than needing a full DI container.
