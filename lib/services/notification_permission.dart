import 'package:permission_handler/permission_handler.dart';

/// Requests the Android 13+ `POST_NOTIFICATIONS` permission needed for
/// `audio_service`'s media playback notification (declared in
/// AndroidManifest.xml) - without it, the OS silently drops that
/// notification even though playback itself keeps working fine, which is
/// what field testing on a Nothing Phone 2 surfaced as "no mini player".
///
/// A no-op once already granted/denied, on pre-13 Android, and on iOS.
/// Deliberately swallows failures (e.g. no platform channel registered in
/// unit tests) since this is a nice-to-have prompt, not a playback
/// blocker - callers fire this off without awaiting it.
Future<void> ensureNotificationPermission() async {
  try {
    await Permission.notification.request();
  } catch (_) {
    // No platform channel (unit tests) or plugin unavailable - ignore.
  }
}
