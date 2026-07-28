# intrval

A tempo-controlled, practice-set music player for dancers. Build ordered
"practice sets" out of your playlists/folders, play a random (or sequential)
song from each in turn, with per-entry control over tempo, play duration
(with fade-out), break time, and break audio cues.

**Platform status: Android only.** See
[`docs/IOS_ROADMAP.md`](docs/IOS_ROADMAP.md) for what's missing for iOS.

## Features

- **Practice Sets** - ordered sequences of playlist/folder entries, played
  top to bottom with configurable tempo, play duration, break, and fade-out,
  overridable per entry.
- **Standard Player** - play any song, playlist, or folder on demand, with
  the same pitch-preserving tempo control (70%-130%, 1% steps).
- **Playlists** - create, reorder, and manage hand-picked song lists.
- **Library** - import local folders (via Android's Storage Access
  Framework) or individual files, with search/sort/filter, including by BPM.
- **On-device BPM detection** - no network calls; estimates tempo via
  amplitude-envelope autocorrelation, with manual override/correction.
- **Background playback** - lock-screen/notification media controls via
  `audio_service`.

## Tech stack

| Concern | Package |
| --- | --- |
| Framework | Flutter (Dart) |
| State management | `flutter_riverpod` |
| Local database | `drift` (SQLite) |
| Folder access | `saf` (Android Storage Access Framework) |
| Audio playback | `just_audio` + `audio_service` + `audio_session` |
| Tag reading | `audiotags` |
| BPM detection | `just_waveform` (amplitude envelope) + custom autocorrelation |

See [`docs/adr/`](docs/adr) for the reasoning behind these choices.

## Project structure

```
lib/
  core/            App-wide constants and theme.
  data/
    database/      Drift schema (tables.dart) and database class.
    repositories/   CRUD + query logic per entity (songs, playlists, folders, sets).
    providers.dart  Riverpod wiring for db/repositories/services.
  services/        File import, BPM detection, audio playback (audio_service handler).
  features/        One folder per screen area: library, playlists, sets, player, settings.
  widgets/         Shared widgets (song tile, BPM edit dialog, tempo slider).
```

## Getting started

### Prerequisites

- Flutter SDK (stable channel).
- Android SDK (`cmdline-tools`, `platform-tools`, a platform image, and
  matching build-tools) with `ANDROID_HOME` set.
- A JDK compatible with this project's pinned Gradle/AGP versions - see
  [`docs/adr/0008-android-toolchain-pins.md`](docs/adr/0008-android-toolchain-pins.md).
  Bleeding-edge JDKs (e.g. a `brew install openjdk` that resolves to the
  latest release) may be **too new** for Gradle; if `flutter doctor` or the
  build complains, install an LTS JDK (21) instead and point Flutter at it:
  ```
  flutter config --jdk-dir="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
  ```

### Setup

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter test
flutter analyze
```

### Run / build

```
flutter run                 # on a connected device/emulator
flutter build apk --debug   # produces build/app/outputs/flutter-apk/app-debug.apk
```

## Documentation

- [`docs/adr/`](docs/adr) - Architecture Decision Records for the major
  technical choices (framework, database, audio stack, BPM detection,
  storage model, Android toolchain pins).
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) - build/toolchain bugs
  encountered so far and how they were fixed.
- [`docs/IOS_ROADMAP.md`](docs/IOS_ROADMAP.md) - what's Android-specific
  today and what would need to change to support iOS.
