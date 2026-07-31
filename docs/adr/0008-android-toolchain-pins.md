# 0008 - Pinning Gradle/AGP/Kotlin/jni versions

## Status

Superseded - the AGP/Kotlin/Gradle pin below was **lifted**. Kept for
history and because the `jni` pin it originally travelled with is still
needed.

## Context

`flutter create` (on a very recent Flutter stable channel) scaffolded the
Android project with bleeding-edge toolchain defaults: Android Gradle
Plugin (AGP) 9.0.1, Kotlin 2.3.20, Gradle 9.1.0. Two dependencies had
Android Gradle modules that hard-failed the build under that combination,
both the same class of bug: AGP 9.x hard-fails (instead of just warning,
like 8.7.x) when a plugin's bundled Android module declares a `compileSdk`
lower than what its own transitive `androidx` dependencies require, with no
override hook available once AGP has read it:

- `audiotags` itself hardcoded `compileSdkVersion 31`.
- `file_picker` (via its `flutter_plugin_android_lifecycle` dependency)
  was compiled against API 34 while that dependency needed 36+.

See `docs/TROUBLESHOOTING.md` for the original failure sequence and
failed workaround attempts.

Both turned out to be removable rather than truly needed:
- `audiotags` was replaced with the pure-Dart `audio_metadata_reader` (no
  native Android module at all) - only 4 fields (title/artist/album/
  duration) were ever read from it.
- `file_picker` turned out to be **entirely unused** - all file/folder
  access in this app goes through `saf` (Storage Access Framework); it was
  a leftover dependency with zero references in `lib/`.

With both gone, AGP/Kotlin/Gradle were bumped back to the versions
`flutter create` originally picked and the build succeeds cleanly (aside
from an unrelated, non-fatal "KGP applied by a plugin" warning from
`package_info_plus`/`saf`, about a *future* Flutter breaking change).

The `jni` issue is unrelated to `compileSdk` and still applies: `jni`
1.0.1 (a transitive dependency of `path_provider_android`, and therefore
unavoidable) shipped a breaking Kotlin Gradle Plugin migration in its own
`android/build.gradle` that isn't compatible with this project's Kotlin
version; 1.0.2 reverts it.

## Decision

- Keep pinning `jni: 1.0.2` via `dependency_overrides` in `pubspec.yaml`
  (see above - independent of the AGP pin, still needed).
- **No longer pin** the Android toolchain: `android/settings.gradle.kts`
  and `android/gradle/wrapper/gradle-wrapper.properties` track whatever
  `flutter create` would currently scaffold (AGP 9.0.1, Kotlin 2.3.20,
  Gradle 9.1.0 as of this writing).
- **No longer pin** `url_launcher_android` - the override existed only
  because 6.3.26+ requires AGP 8.9.1+, which is no longer a constraint.

## Consequences

- If a plugin dependency is ever added back with the same bundled-`compileSdk`
  mismatch bug (`audiotags`, `file_picker`, or otherwise), this exact
  failure will resurface. Check `docs/TROUBLESHOOTING.md` item 6 first.
- Building still requires an LTS JDK (21) rather than whatever is newest -
  see the README's "Prerequisites" section and `flutter config --jdk-dir`.
- This ADR is Android-Gradle-specific and has no bearing on the (separate,
  not-yet-done) iOS toolchain setup.
