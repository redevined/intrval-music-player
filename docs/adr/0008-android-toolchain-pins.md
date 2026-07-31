# 0008 - Pinning Gradle/AGP/Kotlin/jni versions

## Status

Accepted

## Context

`flutter create` (on a very recent Flutter stable channel) scaffolded the
Android project with bleeding-edge toolchain defaults: Android Gradle
Plugin (AGP) 9.0.1, Kotlin 2.3.20, Gradle 9.1.0. Several dependencies in
this project (`audiotags`, and transitively `jni` via `path_provider_android`)
have Android Gradle modules that are not compatible with that combination -
see `docs/TROUBLESHOOTING.md` for the full failure sequence. None of the
incompatibilities could be worked around from the consuming app's Gradle
files once discovered (e.g. AGP 9.x hard-fails on a plugin's mismatched
`compileSdk` with no override hook available post-evaluation).

## Decision

- Pin `jni: 1.0.2` via `dependency_overrides` in `pubspec.yaml` (1.0.1, a
  transitive dependency of `path_provider_android`, shipped a breaking
  Kotlin Gradle Plugin migration that 1.0.2 reverts).
- Pin `url_launcher_android: 6.3.25` via `dependency_overrides` (6.3.26+
  bumps `androidx.core:core` to 1.17.0, and 6.3.27+ also bumps
  `androidx.browser:browser` to 1.9.0 - both require AGP 8.9.1+, newer than
  the pin below).
- Pin the Android toolchain to versions from before AGP started hard-failing
  on plugin `compileSdk` mismatches, in `android/settings.gradle.kts`:
  - `com.android.application` → `8.7.2`
  - `org.jetbrains.kotlin.android` → `2.1.0`
- Pin Gradle itself to `8.10.2` in
  `android/gradle/wrapper/gradle-wrapper.properties`, since AGP 8.7.x is not
  tested against Gradle 9.x.

## Consequences

- `flutter build apk`/`flutter run` print "Flutter support for your
  project's Gradle/AGP/Kotlin version will soon be dropped" warnings. These
  are non-fatal today; revisit this pin once `audiotags` (or a replacement
  tag-reading package) fixes its bundled `compileSdk`, or once `jni` ships a
  release that's compatible with a newer AGP without the KGP migration bug.
- Building also requires an LTS JDK (21) rather than whatever is newest -
  see the README's "Prerequisites" section and `flutter config --jdk-dir`.
- This pin is Android-Gradle-specific and has no bearing on the (separate,
  not-yet-done) iOS toolchain setup.
