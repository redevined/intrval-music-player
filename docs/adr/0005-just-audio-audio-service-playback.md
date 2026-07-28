# 0005 - just_audio + audio_service for playback

## Status

Accepted

## Context

Requirements: gapless local file playback, pitch-preserving tempo control
in a 70%-130% range, background playback with lock-screen/notification
media controls, and a hard fade-out-to-silence when a track exceeds its
configured play-time cutoff.

## Decision

Use `just_audio` as the playback engine and wrap it in a `BaseAudioHandler`
(`AudioPlayerHandler` in `lib/services/audio_player_service.dart`) via
`audio_service`, which provides the OS-level media session, notification,
and lock-screen controls. Tempo is applied via `AudioPlayer.setSpeed()`;
pitch is left at its default (1.0), which on Android's default ExoPlayer
backend engages the built-in Sonic time-stretcher automatically, preserving
pitch while changing speed. Fade-out is implemented manually as a stepped
volume ramp (`fadeOutAndStop`) rather than relying on a built-in API, since
neither package exposes one.

## Consequences

- `AudioService.init()` must run once at app startup before `runApp()`
  (see `lib/main.dart`); the resulting handler is injected into Riverpod via
  `audioHandlerProvider.overrideWithValue(...)`.
- Android manifest requires the `AudioServiceActivity`,
  `AudioService`/`MediaButtonReceiver` components, plus
  `WAKE_LOCK`/`FOREGROUND_SERVICE`/`FOREGROUND_SERVICE_MEDIA_PLAYBACK`
  permissions - all present in
  `android/app/src/main/AndroidManifest.xml`.
- **Open risk (flagged in code comments, not yet verified on-device):**
  iOS's pitch-preservation behavior under `setSpeed()` has not been
  confirmed and may need an explicit `AVAudioTimePitchAlgorithm`
  configuration - this is an iOS-specific follow-up, not a blocker for the
  current Android-only scope.
- The fade-out is a coarse 20-step manual ramp; acceptable for a short (0-10s)
  fade but not sample-accurate.
