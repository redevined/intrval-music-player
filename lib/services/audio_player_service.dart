import 'dart:async';
import 'dart:typed_data';

import 'package:mpv_audio_kit/mpv_audio_kit.dart' as mak;

import '../core/constants.dart';

/// Wraps three `mpv_audio_kit` players (main track, break-countdown beep,
/// break audio track) and the OS media session (lock-screen / notification
/// controls) for the main player, behind the same small surface the rest of
/// the app used against just_audio + audio_service.
///
/// Tempo is applied via one of two swappable algorithms - see
/// [TempoAlgorithm] and [setTempoAlgorithm] - defaulting to the Rubber Band
/// time-stretch DSP filter (`RubberbandSettings`), which preserves pitch
/// more cleanly than mpv's own scaletempo2 at moderate slowdowns - see the
/// ADR on migrating off just_audio/Sonic.
class AudioPlayerHandler {
  AudioPlayerHandler() {
    _player.stream.completed.listen((completed) {
      if (completed) onTrackComplete?.call();
    });
    _player.setMediaSession(
      const mak.MediaSession(
        actions: {
          mak.MediaAction.play,
          mak.MediaAction.pause,
          mak.MediaAction.playPause,
          mak.MediaAction.next,
          mak.MediaAction.previous,
          mak.MediaAction.seek,
        },
        // We manage our own ad-hoc/practice queues rather than loading a
        // playlist into mpv itself, so next/previous have to be handled by
        // us - see _handleMediaSessionCommand below.
        autoApplyPlaylistNavigation: false,
      ),
    );
    _player.stream.mediaSessionCommands.listen(_handleMediaSessionCommand);
  }

  final mak.Player _player = mak.Player();

  // A separate player for short UI cues (currently just the break-countdown
  // beep) so it can play alongside whatever - if anything - the main player
  // is doing, without disturbing its loaded track/position/tempo.
  final mak.Player _cuePlayer = mak.Player();

  // A separate player for the break audio track, so it can loop/fade
  // independently of the main player and the short beep cue.
  final mak.Player _breakPlayer = mak.Player();

  /// Called when the current track finishes playing naturally.
  void Function()? onTrackComplete;

  /// Called on a lock-screen/notification "skip to next/previous" press.
  /// mpv has no playlist of its own loaded (each track is loaded
  /// individually via [loadTrack]), so these commands only surface on
  /// [mak.Player.stream.mediaSessionCommands] rather than doing anything on
  /// their own - forward them to whichever controller currently owns the
  /// queue.
  void Function()? onSkipNext;
  void Function()? onSkipPrevious;

  void _handleMediaSessionCommand(mak.MediaSessionCommand command) {
    switch (command) {
      case mak.MediaSessionCommandNext():
        onSkipNext?.call();
      case mak.MediaSessionCommandPrevious():
        onSkipPrevious?.call();
      case _:
        break;
    }
  }

  Stream<Duration> get positionStream => _player.stream.position;
  Duration get position => _player.state.position;
  Duration? get duration =>
      _player.state.duration == Duration.zero ? null : _player.state.duration;

  /// Embedded cover art for whichever track is currently loaded, read
  /// straight off the file by the engine itself - correct immediately, even
  /// for tracks imported before `FileImportService` started extracting and
  /// caching artwork at import time. Emits once per file load: the art's
  /// raw bytes, or null if that file has none.
  Stream<Uint8List?> get coverArtStream =>
      _player.stream.coverArt.map((art) => art?.bytes);

  /// Mirrors `playWhenReady` (the user's intent to play), not the momentary
  /// `playing` flag, which can flicker false during brief buffering/seeks -
  /// matches just_audio's old `AudioPlayer.playing` semantics so the
  /// play/pause button doesn't flicker along with it.
  bool get isPlaying => _player.state.playWhenReady;
  Stream<bool> get playingStream => _player.stream.playWhenReady;

  Future<void> loadTrack({
    required String uriOrPath,
    required String title,
    String? artist,
    String? album,
    Duration? duration,
    double tempoPercent = 100,
  }) async {
    final uri =
        uriOrPath.contains('://') ? uriOrPath : Uri.file(uriOrPath).toString();
    await _player.open(mak.Media(uri), play: false);
    await setTempoPercent(tempoPercent);
    await _player.setMediaSession(
      (_player.state.mediaSession ?? const mak.MediaSession()).copyWith(
        title: title,
        artist: artist,
        album: album,
        duration: duration,
      ),
    );
  }

  TempoAlgorithm _tempoAlgorithm = TempoAlgorithm.rubberband;
  double _tempoPercent = 100;

  /// [percent] is 70-130, matching the app's tempo slider range.
  Future<void> setTempoPercent(double percent) async {
    _tempoPercent = percent;
    await _applyTempo();
  }

  /// Switches which DSP does the tempo/pitch stretching - see
  /// [TempoAlgorithm]. Re-applies the current tempo through the new
  /// algorithm immediately, so a change made mid-playback takes effect
  /// without needing a seek/reload.
  Future<void> setTempoAlgorithm(TempoAlgorithm algorithm) async {
    if (_tempoAlgorithm == algorithm) return;
    _tempoAlgorithm = algorithm;
    await _applyTempo();
  }

  /// Applies [_tempoPercent] through whichever engine [_tempoAlgorithm]
  /// currently selects. The two engines must never both be "live" at once
  /// (their effects would compound), so each branch turns the other one
  /// off - pinning mpv's native rate back to 1.0 before enabling the
  /// Rubber Band filter, or disabling the filter before handing the rate
  /// to mpv - rather than just toggling the one that changed.
  Future<void> _applyTempo() async {
    final factor = _tempoPercent / 100.0;
    switch (_tempoAlgorithm) {
      case TempoAlgorithm.rubberband:
        await _player.setRate(1.0);
        await _player.setPitchCorrection(false);
        await _player.updateAudioEffects(
          (e) => e.copyWith(
            rubberband: mak.RubberbandSettings(enabled: true, tempo: factor),
          ),
        );
      case TempoAlgorithm.scaletempo2:
        await _player.updateAudioEffects(
          (e) => e.copyWith(
            rubberband: mak.RubberbandSettings(enabled: false, tempo: factor),
          ),
        );
        await _player.setPitchCorrection(true);
        await _player.setRate(factor);
    }
  }

  /// Applies an overall volume boost (in decibels, see [VolumeBoostLimits])
  /// on top of the device's normal output, to every player - so it's heard
  /// consistently across songs, the break track, and the beep cue. A
  /// brick-wall limiter is enabled alongside the gain to catch peaks pushed
  /// over full scale, mirroring what Android's LoudnessEnhancer did to
  /// avoid immediately hard-clipping. Left disabled at 0dB so playback is
  /// unchanged by default.
  Future<void> setVolumeBoostDb(double db) async {
    final enabled = db > 0;
    await Future.wait([
      _player.setVolumeGain(db),
      _cuePlayer.setVolumeGain(db),
      _breakPlayer.setVolumeGain(db),
    ]);
    final limiter = mak.AlimiterSettings(enabled: enabled, limit: 0.99);
    await Future.wait([
      _player.updateAudioEffects((e) => e.copyWith(alimiter: limiter)),
      _cuePlayer.updateAudioEffects((e) => e.copyWith(alimiter: limiter)),
      _breakPlayer.updateAudioEffects((e) => e.copyWith(alimiter: limiter)),
    ]);
  }

  /// Plays the break-countdown beep cue. `SystemSound.play` was tried here
  /// first, but it's routed through Android's UI "touch sound" effect
  /// channel - silent whenever that system setting is off, and inaudibly
  /// quiet even when it's on. A bundled asset played at normal media volume
  /// instead is reliably audible.
  Future<void> playBeep({double volume = 1.0}) async {
    try {
      await _cuePlayer.open(mak.Media('asset:///assets/sounds/beeps.mp3'));
      await _cuePlayer.setVolume(volume * 100);
      await _cuePlayer.play();
    } catch (_) {
      // A missing/undecodable cue asset shouldn't take the session down.
    }
  }

  /// Starts the bundled break audio track looping at zero volume, then fades
  /// it in to [targetVolume] over [fadeDuration]. Pair with
  /// [fadeOutAndStopBreakTrack] (or [stopBreakTrack] for an immediate cut,
  /// e.g. on skip) to end it.
  Future<void> playBreakTrack({
    Duration fadeDuration = const Duration(seconds: 2),
    double targetVolume = 1.0,
  }) async {
    try {
      await _breakPlayer.open(mak.Media('asset:///assets/sounds/break_audio_track.mp3'));
      await _breakPlayer.setLoop(mak.Loop.file);
      await _breakPlayer.setVolume(0);
      unawaited(_breakPlayer.play());
      await _fade(_breakPlayer, from: 0, to: targetVolume * 100, duration: fadeDuration);
    } catch (_) {
      // A missing/undecodable break track just means a silent break.
    }
  }

  /// Fades the break track out over [fadeDuration] and stops it.
  Future<void> fadeOutAndStopBreakTrack({Duration fadeDuration = const Duration(seconds: 2)}) async {
    await _fade(_breakPlayer, from: _breakPlayer.state.volume, to: 0, duration: fadeDuration);
    await _breakPlayer.stop();
  }

  /// Stops the break track immediately, with no fade - used when the user
  /// skips out of a break early.
  Future<void> stopBreakTrack() => _breakPlayer.stop();

  void pauseBreakTrack() => _breakPlayer.pause();

  Future<void> resumeBreakTrack() => _breakPlayer.play();

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> seek(Duration position) => _player.seek(position);

  /// Linearly fades volume to 0 over [duration], then stops playback and
  /// restores volume to full for the next track. Used for the "hard
  /// fade-out to silence at cutoff" behavior when a song exceeds its
  /// configured max play duration.
  Future<void> fadeOutAndStop(Duration duration) async {
    if (duration <= Duration.zero) {
      await _player.stop();
      return;
    }
    final startVolume = _player.state.volume;
    await _fade(_player, from: startVolume, to: 0, duration: duration);
    await _player.stop();
    await _player.setVolume(startVolume);
  }

  /// Linearly ramps [player]'s volume (0-100 scale) from [from] to [to]
  /// over [duration].
  Future<void> _fade(
    mak.Player player, {
    required double from,
    required double to,
    required Duration duration,
  }) async {
    if (duration <= Duration.zero) {
      await player.setVolume(to);
      return;
    }
    const steps = 20;
    final stepDuration = duration ~/ steps;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(stepDuration);
      final v = from + (to - from) * (i / steps);
      await player.setVolume(v.clamp(0.0, 100.0));
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _cuePlayer.dispose();
    await _breakPlayer.dispose();
  }
}
