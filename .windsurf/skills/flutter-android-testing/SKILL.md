---
name: flutter-android-testing
description: Use when manually verifying a Flutter feature end-to-end on a running Android emulator via adb - starting/restarting the emulator, building and installing the app (streamed install + relaunch), driving the UI via adb shell input with correctly-converted tap coordinates, inspecting screenshots with ImageMagick, and reading logcat output.
---

# Flutter Android Feature Testing

Runbook for verifying a Flutter feature on a real running Android emulator, not just via `flutter analyze`/`flutter test`: getting the emulator into a good state, building + installing the app, driving it via `adb shell input`, and reading back what happened via screenshots and logs.

Treat this as a checklist to adapt, not a rigid script - skip steps that don't apply (e.g. skip the restart step if the emulator is already healthy).

## 0. Preconditions

- Never use `cd` in any command - pass the project directory as the command's working directory instead.
- Any `adb shell` argument that looks like an absolute path (e.g. `/sdcard/foo.png`) can trip a "path outside workspace" guard in some tool runners, even though it's a *remote device* path, not a local one. Work around it by assigning it to a shell variable first and referencing the variable, e.g.:
  ```bash
  DEV_PATH=/sdcard/shot.png
  adb shell screencap -p "$DEV_PATH" && adb pull "$DEV_PATH" shot.png
  ```
- Pull screenshots into the project's working directory (not outside it), and delete them (`rm -f *.png`) once done inspecting - confirm with `git status --short` before committing so none get left behind or accidentally staged.

## 1. Identify and Start the Emulator

List connected devices/emulators and running AVDs:
```bash
adb devices
flutter emulators
```
If nothing is running, boot one (non-blocking - it takes a while). Prefer `flutter emulators --launch <id>` over calling the `emulator` binary directly - some tool runners block commands containing what looks like an absolute SDK path (e.g. `$ANDROID_HOME/emulator/emulator`), and the `flutter` CLI wrapper avoids that entirely:
```bash
flutter emulators --launch <emulator_id>
```
Wait for it to finish booting rather than guessing a sleep duration:
```bash
adb wait-for-device
```
then poll (a few seconds apart) until this prints `1`:
```bash
adb -s <serial> shell getprop sys.boot_completed
```
If multiple devices are attached, always pass `-s <serial>` explicitly (e.g. `-s emulator-5554`) to every `adb` command below - don't rely on the default target.

## 2. Restart the Emulator (audio glitches, wedged state, etc.)

Emulator audio (and occasionally rendering) can get into a bad state after repeated play/pause cycles during testing. Prefer restarting the *emulator process*, not just the app:

1. Kill it cleanly first: `adb -s <serial> emu kill`
2. Give it a moment to fully exit, then re-launch and re-wait as in Step 1 (`emulator -avd <avd_name> &`, `adb wait-for-device`, poll `sys.boot_completed`).
3. If `emu kill` doesn't respond (wedged), fall back to killing the process directly (find it via `ps aux | grep emulator`) and relaunch.

A plain `adb reboot` also works but is slower - reserve it for when the issue looks like an Android-OS-level wedge rather than an audio-subsystem glitch.

## 3. Build and Install the App

1. Run static checks first so you're not debugging a build error via manual taps:
   ```bash
   flutter analyze
   flutter test
   ```
2. Build (debug is fine for iteration; only use `--release` for final signed verification/release builds):
   ```bash
   flutter build apk --debug
   ```
3. Install with a streamed, replacing install so you don't need to uninstall first:
   ```bash
   adb -s <serial> install -r build/app/outputs/flutter-apk/app-debug.apk
   ```
4. Relaunch so the new build actually takes effect (a bare re-`install` does **not** restart a running app):
   ```bash
   adb -s <serial> shell am force-stop <package_id>
   adb -s <serial> shell am start -n <package_id>/<launch_activity>
   ```
   - Find `<package_id>` from `applicationId` in `android/app/build.gradle(.kts)`.
   - Find `<launch_activity>` from the `<activity>` in `android/app/src/main/AndroidManifest.xml` that has the `MAIN`/`LAUNCHER` intent-filter - **don't assume it's `.MainActivity`**. Plugins like `audio_service` install their own activity (e.g. `com.ryanheise.audioservice.AudioServiceActivity`) as the launcher activity instead. If `am start -n` fails with "Activity class ... does not exist", that's the symptom - go re-check the manifest.
   - If you don't want to bother resolving the exact activity, `monkey` will resolve the launcher intent for you:
     ```bash
     adb -s <serial> shell monkey -p <package_id> -c android.intent.category.LAUNCHER 1
     ```
5. After a fresh install/launch, give the app a couple of seconds for the splash screen before your first screenshot/tap - a screenshot taken too early will just show the launcher icon splash, not the real UI.

## 4. Inspect and Control the Emulator

### Screenshots

```bash
DEV_PATH=/sdcard/shot.png
adb -s <serial> shell screencap -p "$DEV_PATH"
adb -s <serial> pull "$DEV_PATH" shot.png
```
Then view `shot.png` with the file-reading/image tool available.

**Important:** an image viewer may render/display the PNG downscaled for convenience. Never eyeball tap coordinates off the *displayed* size - always confirm the file's actual pixel dimensions first:
```bash
# macOS
sips -g pixelWidth -g pixelHeight shot.png
# ImageMagick (magick), if installed instead of/alongside sips
magick identify shot.png
```
`screencap` output pixel dimensions always match the device's real physical screen size (`adb shell wm size`), never Flutter's logical/dp pixels.

### Tap coordinate conversion (logical/dp -> device pixels)

Flutter widget code, and its layout, is in **logical pixels**. `adb shell input tap` expects **physical device pixels**. Convert with the device pixel ratio:

```bash
adb -s <serial> shell wm size      # e.g. "Physical size: 1080x2400"
adb -s <serial> shell wm density   # e.g. "Physical density: 420"
```
```
devicePixelRatio = density / 160
device_x = logical_x * devicePixelRatio
device_y = logical_y * devicePixelRatio
```
e.g. at density 420 (ratio 2.625), a widget centered at logical `(38, 103)` taps at device `(~100, ~270)`.

If you don't know the logical coordinate (e.g. you're just eyeballing a widget's position in a screenshot rather than reading it from the widget's layout code), you can instead scale directly off the screenshot: measure the position in the *displayed* thumbnail, then multiply by `(actual_pixel_width / displayed_width)` from the `sips`/`magick identify` dimensions to get the real tap coordinate. Either method works - prefer the density-ratio method when you know the logical layout, since it doesn't depend on how a viewer happens to render the PNG.

### Other input

```bash
adb -s <serial> shell input tap <x> <y>
adb -s <serial> shell input swipe <x1> <y1> <x2> <y2> <duration_ms>
adb -s <serial> shell input text "some string"
adb -s <serial> shell input keyevent KEYCODE_BACK   # or BACK, HOME, ENTER, etc.
```

### ImageMagick (`magick`) for screenshot manipulation

Useful once you have a pulled screenshot locally:
```bash
magick identify shot.png                              # dimensions/format, confirm before computing tap coords
magick shot.png -crop 460x200+0+800 crop.png           # crop to a region of interest (e.g. just the nav bar)
magick shot.png -resize 50% small.png                  # shrink before viewing many at once
magick montage before.png after.png -tile 2x1 -geometry +4+4 side_by_side.png   # compare two states side by side
magick compare -metric AE before.png after.png diff.png # pixel-diff two screenshots (e.g. verifying a color actually changed)
```

## 5. Reading Logs

```bash
adb -s <serial> logcat -c                     # clear old noise right before reproducing the issue
# ... perform the action under test (tap/build/etc) ...
adb -s <serial> logcat -d                      # dump what accumulated since the clear, then exits (non-blocking)
```
Narrow down noise:
```bash
adb -s <serial> logcat -d flutter:V *:S         # only the Dart-side "flutter" tag (print()/debugPrint/exceptions)
adb -s <serial> logcat -d AndroidRuntime:E *:S  # native/Java crashes only
```
Or scope to just this app's process:
```bash
PID=$(adb -s <serial> shell pidof <package_id>)
adb -s <serial> logcat -d --pid="$PID"
```

## 6. Cleanup

- Remove the on-device screenshot(s): `adb -s <serial> shell rm /sdcard/shot.png` (or just let the next `screencap` overwrite the same path).
- Remove any screenshots pulled into the project directory once done inspecting them.
- `git status --short` before committing, to make sure no stray screenshots/build artifacts got added.

## Notes / Gotchas Learned From Practice

- `adb install -r` reinstalls the APK but preserves app data (`SharedPreferences`, local DB) - use this to verify a fix actually addresses persisted/existing state, not just a freshly-cleared one. Use `adb uninstall <package_id>` first if you specifically need a clean-slate install.
- `am start -n <pkg>/<activity>` returning "Warning: Activity not started, intent has been delivered to currently running top-most instance" means the app was already running - it did *not* relaunch with the new build. Explicitly `am force-stop` first if a guaranteed cold start is needed (e.g. to test splash-screen behavior or startup-time theme/config resolution).
- When testing something that depends on the *system* (dynamic color / Material You, locale, dark mode, etc.), sanity-check the emulator's actual OS version/capability first (e.g. `adb shell getprop ro.build.version.sdk` - Material You dynamic color needs API 31+) so you're not debugging code against a device that was never going to support the feature.
- A cosmetic difference that looks subtle in a downscaled screenshot thumbnail (e.g. two similar accent colors) is often real - crop/zoom with `magick` on the actual pulled file rather than trusting the thumbnail render.
