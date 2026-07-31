# Troubleshooting / bug log

Chronological log of build/toolchain issues hit while getting
`flutter build apk` working on a fresh macOS dev machine, with root causes
and fixes. Kept for future contributors hitting the same errors, and as
context for why `pubspec.yaml`/`android/settings.gradle.kts`/
`android/gradle/wrapper/gradle-wrapper.properties` have the pins they do
(see also [ADR 0008](adr/0008-android-toolchain-pins.md)).

## 1. `flutter` command not found

**Symptom:** Flutter SDK not installed.

**Fix:** `brew install --cask flutter`.

## 2. `flutter build apk` fails with "No Android SDK found"

**Symptom:** `flutter doctor` shows no Android toolchain at all.

**Fix:** Install a CLI-only Android SDK and point Flutter at it:

```
brew install --cask android-commandlinetools
```

then set `ANDROID_HOME` and install the actual SDK components (Homebrew's
cask only provides the `sdkmanager` tool itself, not any platform/build
tools):

```
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

`brew install android-platform-tools` alone is **not** sufficient - that
formula only provides `adb`/`fastboot`, not a compilable SDK.

## 3. `sdkmanager` fails with "Unable to locate a Java Runtime"

**Symptom:** `sdkmanager --list_installed` errors before printing anything
useful.

**Fix:** Install a JDK (`brew install openjdk`, or a versioned formula - see
next item for why versioned matters) and either export `JAVA_HOME`/`PATH`
for the shell running these commands, or use `flutter config --jdk-dir`
(see item 4).

## 4. `flutter build apk` fails with `Unsupported class file major version 70`

**Symptom:** Gradle fails deep into the build with a cryptic class-file
version error, even though `flutter doctor` reports Java as fine.

**Root cause:** The default Homebrew `openjdk` formula resolves to the
*latest* JDK release (in this case JDK 26) - too new for the project's
pinned Gradle version to run on. This is unrelated to the project's own
`sourceCompatibility`/`jvmTarget` settings (which target Java 17); it's
about which JDK **runs Gradle itself**, not which JDK the app code compiles
against.

**Fix:** Install a stable LTS JDK side-by-side without disturbing the
existing global `java`:

```
brew install openjdk@21
```

Homebrew installs this **keg-only** (not linked into `PATH`), so it won't
change what `java -version` resolves to elsewhere. Point Flutter's Gradle
builds at it specifically:

```
flutter config --jdk-dir="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
```

## 5. `flutter build apk` fails with `Could not find method kotlin() for arguments [...] on project ':jni'`

**Symptom:** Gradle fails evaluating the `jni` package's bundled
`android/build.gradle`.

**Root cause:** `jni` 1.0.1 (a transitive dependency of
`path_provider_android`, and therefore unavoidable - `path_provider` is used
throughout this app and by several other plugins) shipped a Kotlin Gradle
Plugin migration in its Android module that isn't compatible with this
project's Gradle/AGP/Kotlin combination. Confirmed via `jni`'s changelog:
version 1.0.2's first line is *"Revert an unnecessary (and breaking) KGP
migration."*

This was a dead end at first: since `sqlite3` (used by `drift`) is *also* a
transitive path to `jni`/`flutter_rust_bridge` (sqlite3 3.0.0+ moved to Dart
"build hooks"/native-assets, which needs `jni` on Android), we initially
pinned `sqlite3: 2.9.4` (pre-native-assets) via `dependency_overrides`,
assuming that was the source. It wasn't - `jni` is unconditionally pulled in
by `path_provider_android` regardless of the `sqlite3` version, and pinning
`sqlite3` down to 2.9.4 broke `drift` 2.34.x's Dart layer (it calls
`CommonPreparedStatement.close()`, an API only present in `sqlite3` 3.0+).

**Fix:** Remove the `sqlite3` override; pin `jni` directly instead:

```yaml
dependency_overrides:
  jni: 1.0.2
```

## 6. `flutter build apk` fails with `It is too late to set compileSdk` / `:audiotags is currently compiled against android-31`

**Symptom:** Once past issue 5, the build reaches actual compilation and
fails with a long list of "Dependency X requires compiling against version
33/34 of the Android APIs" errors pointing at the `audiotags` plugin's
bundled Android module, followed by a hard `BUILD FAILED`.

**Root cause:** `audiotags`'s own `android/build.gradle` hardcodes an
outdated `compileSdkVersion 31`, while its transitive androidx dependencies
require 33/34+. Older AGP versions only *warn* about this mismatch; AGP
9.0.1 (the version `flutter create` picked by default on this Flutter
release) hard-fails the build instead.

**Attempted (failed) workarounds**, in order, kept here so nobody re-tries
them:

1. Force `compileSdk = 36` on all subprojects via a root
   `subprojects { afterEvaluate { ... } }` block → failed with
   `Cannot run Project.afterEvaluate(Action) when the project is already
   evaluated` for some plugin subprojects, due to evaluation-order
   differences introduced by Flutter's declarative plugin loader.
2. Scope the same override to `plugins.withId("com.android.library") {
   afterEvaluate { ... } }` applied to *all* subprojects → fixed
   `audiotags`, but broke `audio_service` with `It is too late to set
   compileSdk. It has already been read to configure this project.`
   (AGP had already consumed `audio_service`'s correct value earlier in its
   evaluation).
3. Scope the override to *only* the `:audiotags` project, still via
   `afterEvaluate` → still hit the same "too late" error, this time for
   `:audiotags` itself. AGP reads/locks `compileSdk` as soon as the
   module's own `android {}` block finishes executing, which is *before*
   `afterEvaluate` fires for that project. There is no supported hook to
   override it after the fact once AGP has read it.

**Actual fix:** Downgrade the whole Android toolchain to versions where this
is a warning, not a hard failure. In `android/settings.gradle.kts`:

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.2" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}
```

and in `android/gradle/wrapper/gradle-wrapper.properties` (AGP 8.7.x isn't
tested against Gradle 9.x):

```
distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-all.zip
```

This produces "Flutter support for your project's Gradle/AGP/Kotlin version
will soon be dropped" warnings on every build - expected and non-fatal for
now.

**Update:** this pin was later lifted entirely - `audiotags` was replaced
with a pure-Dart alternative, and separately `file_picker` turned out to be
an unused leftover dependency with the exact same `compileSdk`-mismatch bug.
See [ADR 0008](adr/0008-android-toolchain-pins.md) for the full story; the
`android/settings.gradle.kts`/`gradle-wrapper.properties` pins from this
item no longer apply. Kept here in case a future dependency reintroduces
the same failure mode.

## Open items

- **Not yet done:** a real on-device/emulator functional test (folder
  import → BPM detection accuracy → pitch-preserving tempo playback → full
  practice-set sequencing). Everything above only gets the APK to *build*;
  it hasn't been run yet. Android SDK/emulator setup in this environment
  only reached the point of compiling successfully.
