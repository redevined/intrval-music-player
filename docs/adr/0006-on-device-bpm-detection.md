# 0006 - On-device BPM detection instead of an online lookup

## Status

Accepted

## Context

The app needs to auto-populate a song's tempo (BPM), with manual correction
available. Two approaches were considered: (a) look up BPM from an online
music database/API by track metadata, or (b) estimate it locally via signal
processing.

## Decision

Originally leaned towards an online lookup, but switched to on-device
detection after considering: ballroom/dance music has poor coverage in
mainstream BPM databases (niche genres, remixes, practice edits), online
APIs often have usage costs/rate limits, and the app's storage model is
local-only (no account/cloud sync to hang an API key or cache against - see
ADR 0003/0004). `BpmDetectionService`
(`lib/services/bpm_detection_service.dart`) extracts a coarse amplitude
envelope via `just_waveform` and finds the dominant periodicity in the
60-200 BPM range via autocorrelation, returning both a BPM estimate and a
confidence score.

## Consequences

- Works fully offline, with no per-song network cost or external dependency.
- This is a standard-but-simple beat-tracking technique, not a
  state-of-the-art beat tracker - it can misfire on complex mixes or lock
  onto half/double-time (e.g. report 90 BPM for a 180 BPM track). Manual
  correction (`SongRepository.setManualBpm`) is the safety net, and
  `bpmManual` always takes precedence over `bpmDetected` in the UI and in
  BPM-based sorting/filtering.
- Flagged in the project plan as a Phase-0 accuracy risk to validate against
  real ballroom tracks on-device (still pending - see the "on-device test"
  item in `docs/TROUBLESHOOTING.md`'s open items).
