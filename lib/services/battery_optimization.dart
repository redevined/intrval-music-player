import 'package:permission_handler/permission_handler.dart';

/// Whether intrval is currently exempt from Android's Doze/App Standby
/// battery optimizations - see [requestIgnoreBatteryOptimizations] for why
/// that matters. Always true on iOS/unit tests (no such concept there).
Future<bool> isIgnoringBatteryOptimizations() async {
  try {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  } catch (_) {
    return true;
  }
}

/// Prompts the user to exempt intrval from Android's background battery
/// optimizations.
///
/// `audio_service`'s foreground service drops to a lower-priority state
/// whenever playback is paused (`androidStopForegroundOnPause`, forced to
/// `true` by our `androidNotificationOngoing: true` config in main.dart -
/// see [AudioServiceConfig]'s own assertion). In that state the OS is free
/// to kill the whole process at any time it's backgrounded to reclaim
/// memory - OEM battery managers (observed on a Nothing Phone 2) are
/// especially aggressive about this, and once the process dies every
/// in-app state resets, including [NowPlayingState] - so the mini player
/// doesn't just pause, it disappears entirely on next launch. This is
/// audio_service's own documented mitigation for that.
///
/// A no-op once already granted, on iOS, and in unit tests (no platform
/// channel registered). Deliberately swallows failures the same way
/// [ensureNotificationPermission] does - a denial here should never block
/// playback, just make it less durable in the background.
Future<void> requestIgnoreBatteryOptimizations() async {
  try {
    await Permission.ignoreBatteryOptimizations.request();
  } catch (_) {
    // No platform channel (unit tests) or plugin unavailable - ignore.
  }
}
