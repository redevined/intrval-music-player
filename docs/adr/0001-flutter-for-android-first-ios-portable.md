# 0001 - Flutter for an Android-first, iOS-portable app

## Status

Accepted

## Context

The app is primarily needed on Android, but should be portable to iOS later
without a full rewrite. Options considered: native Android (Kotlin) only,
Flutter, React Native.

## Decision

Build with Flutter (Dart). Native Android would give the tightest platform
integration but no path to iOS without a second codebase. React Native has
weaker/less mature audio-background-playback plugins than Flutter's
`just_audio`/`audio_service` ecosystem, which is a core requirement here.

## Consequences

- Single codebase for UI, business logic, and most services.
- A handful of platform-specific concerns remain isolated behind
  abstractions where possible (see ADR 0004 for the one significant
  Android-only piece: folder access via SAF).
- Flutter's plugin ecosystem quality varies; several plugins used here
  (`audiotags`, `saf`, transitively `jni` via `path_provider_android`) had
  Android Gradle toolchain compatibility issues that needed pinning - see
  ADR 0008 and `docs/TROUBLESHOOTING.md`.
