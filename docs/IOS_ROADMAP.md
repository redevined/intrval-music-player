# iOS roadmap

The app is currently **Android-only**, confirmed as an explicit scope
decision (see [ADR 0004](adr/0004-storage-access-framework-folders.md)).
`flutter create` scaffolded an `ios/` folder, but it has not been configured
or tested. This doc lists what would need to happen to actually support
iOS, roughly in the order it would need doing.

## 1. Folder import model (biggest piece of work)

`FolderRepository` (`lib/data/repositories/folder_repository.dart`) and
`local_file_staging.dart` are built entirely around the `saf` package,
which only implements Android's Storage Access Framework - **it has no iOS
platform implementation at all**. iOS has no equivalent of "bookmark an
arbitrary folder and keep live-syncing its contents":

- iOS apps are sandboxed; access to user-chosen files/folders happens via
  `UIDocumentPickerViewController` (exposed in Flutter via `file_picker`,
  already a dependency here for other reasons) and requires a
  **security-scoped bookmark** (`NSData`) to be persisted and
  re-resolved (`startAccessingSecurityScopedResource`) on every
  subsequent access.
- Folder picking on iOS returns access to the picked directory but
  enumerating/watching its contents works differently than Android's
  `DocumentFile` tree API - there's no exact equivalent of `saf`'s live
  folder sync.

**Options to evaluate:**
- Support only individual **file** import on iOS (via `file_picker`'s
  multi-file picker), dropping the "live folder" concept for that platform,
  and let iOS users organize via app-managed playlists instead.
- Or implement iOS folder access via `file_picker`'s directory picker +
  manual security-scoped bookmark persistence, re-scanning the folder's
  contents on each app launch (no live filesystem watching).

Either way, this needs a platform-conditional `FolderRepository`
implementation (or a parallel `IosFolderRepository`), selected via
`Platform.isAndroid`/`Platform.isIOS` or a build-time abstraction.

## 2. Audio playback parity

- **Pitch-preservation on `setSpeed()` is unverified on iOS** (see
  [ADR 0005](adr/0005-just-audio-audio-service-playback.md)). `just_audio`
  on iOS uses `AVAudioEngine`/`AVPlayer` under the hood; may need an
  explicit `AVAudioTimePitchAlgorithm` configuration to match Android's
  automatic Sonic-based pitch preservation. Needs on-device testing across
  the full 70%-130% tempo range.
- `audio_service`'s iOS setup needs to be done: `Info.plist`
  `UIBackgroundModes` → `audio`, and its documented `AppDelegate.swift`
  changes (currently untouched - this repo's `ios/Runner/AppDelegate.swift`
  is still the vanilla Flutter template).

## 3. Permissions / Info.plist

None of the following exist yet in `ios/Runner/Info.plist` and need adding
depending on which folder-access approach from #1 is chosen:
- `NSDocumentsFolderUsageDescription` / relevant usage description for
  whichever file-access API is used.
- `UIBackgroundModes: [audio]` for background playback (see #2).
- `UIFileSharingEnabled` / `LSSupportsOpeningDocumentsInPlace` if the app
  should support importing files shared from other apps or the Files app.

## 4. Toolchain

- Xcode is not fully installed in the current dev environment
  (`flutter doctor` reports "Xcode installation is incomplete") - a full
  Xcode install + `sudo xcodebuild -runFirstLaunch` is needed before any iOS
  build can be attempted.
- CocoaPods is not installed (`flutter doctor` flags this too) - needed for
  all the Flutter plugins with native iOS code (`just_audio`,
  `audio_service`, `path_provider`, `permission_handler`, `file_picker`,
  `audiotags`, etc.).
- None of the Android-specific Gradle/AGP/Kotlin/JDK toolchain issues in
  [`docs/TROUBLESHOOTING.md`](TROUBLESHOOTING.md) apply to iOS, but an
  equivalent "does everything actually compile" pass should be expected -
  Flutter plugins with poorly-maintained iOS podspecs are just as plausible
  a source of build friction as the Android Gradle issues were.

## 5. Permission handling

`SettingsScreen` and `FolderRepository` currently request Android-specific
permissions (`Permission.audio`, `Permission.manageExternalStorage` via
`permission_handler`). iOS's permission model for file/media access differs
significantly (mostly implicit via the document picker's UI rather than a
runtime permission prompt) - this code path needs a platform branch.

## 6. Testing

- No iOS simulator/device testing has been done at all.
- `flutter build ios`/`flutter build ipa` have not been attempted.
- App icons, launch screen, and any iOS-specific UI polish (safe areas,
  Cupertino-style widgets if desired) are untouched - the app currently
  only uses Material widgets.
