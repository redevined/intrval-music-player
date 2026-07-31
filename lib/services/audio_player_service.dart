import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Wraps a `just_audio` player behind an `audio_service` [BaseAudioHandler]
/// so playback survives screen-off and exposes standard lock-screen /
/// notification media controls (play/pause/skip).
///
/// Tempo is applied via [AudioPlayer.setSpeed]. On Android's default
/// ExoPlayer backend this preserves pitch automatically (only `speed` is
/// changed while `pitch` stays at its default of 1.0, so the built-in Sonic
/// time-stretcher kicks in). iOS pitch-preservation behavior should be
/// verified against a real device/simulator as part of the Phase 0 spike
/// noted in the project plan - just_audio may need an explicit
/// `AVAudioTimePitchAlgorithm` configuration there for perfect parity.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  AudioPlayerHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        onTrackComplete?.call();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  // A separate player for short UI cues (currently just the break-countdown
  // beep) so it can play alongside whatever - if anything - the main player
  // is doing, without disturbing its loaded track/position/tempo.
  final AudioPlayer _cuePlayer = AudioPlayer();

  // A separate player for the break audio track, so it can loop/fade
  // independently of the main player and the short beep cue.
  final AudioPlayer _breakPlayer = AudioPlayer();

  /// Called when the current track finishes playing naturally.
  void Function()? onTrackComplete;

  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;

  Future<void> loadTrack({
    required String uriOrPath,
    required MediaItem item,
    double tempoPercent = 100,
  }) async {
    mediaItem.add(item);
    final source = uriOrPath.startsWith('content://') ||
            uriOrPath.startsWith('http://') ||
            uriOrPath.startsWith('https://')
        ? AudioSource.uri(Uri.parse(uriOrPath))
        : AudioSource.uri(Uri.file(uriOrPath));
    await _player.setAudioSource(source);
    await setTempoPercent(tempoPercent);
  }

  /// [percent] is 70-130, matching the app's tempo slider range.
  Future<void> setTempoPercent(double percent) => _player.setSpeed(percent / 100.0);

  /// Plays the break-countdown beep cue. `SystemSound.play` was tried here
  /// first, but it's routed through Android's UI "touch sound" effect
  /// channel - silent whenever that system setting is off, and inaudibly
  /// quiet even when it's on. A bundled asset played through just_audio
  /// goes out at normal media volume instead, so it's reliably audible.
  Future<void> playBeep() async {
    try {
      await _cuePlayer.setAsset('assets/sounds/beeps.mp3');
      await _cuePlayer.play();
    } catch (_) {
      // A missing/undecodable cue asset shouldn't take the session down.
    }
  }

  /// Starts the bundled break audio track looping at zero volume, then fades
  /// it in over [fadeDuration]. Pair with [fadeOutAndStopBreakTrack] (or
  /// [stopBreakTrack] for an immediate cut, e.g. on skip) to end it.
  Future<void> playBreakTrack({Duration fadeDuration = const Duration(seconds: 2)}) async {
    try {
      await _breakPlayer.setAsset('assets/sounds/break_audio_track.mp3');
      await _breakPlayer.setLoopMode(LoopMode.one);
      await _breakPlayer.setVolume(0);
      unawaited(_breakPlayer.play());
      await _fade(_breakPlayer, from: 0, to: 1, duration: fadeDuration);
    } catch (_) {
      // A missing/undecodable break track just means a silent break.
    }
  }

  /// Fades the break track out over [fadeDuration] and stops it.
  Future<void> fadeOutAndStopBreakTrack({Duration fadeDuration = const Duration(seconds: 2)}) async {
    await _fade(_breakPlayer, from: _breakPlayer.volume, to: 0, duration: fadeDuration);
    await _breakPlayer.stop();
  }

  /// Stops the break track immediately, with no fade - used when the user
  /// skips out of a break early.
  Future<void> stopBreakTrack() => _breakPlayer.stop();

  void pauseBreakTrack() => _breakPlayer.pause();

  Future<void> resumeBreakTrack() => _breakPlayer.play();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
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
    final startVolume = _player.volume;
    await _fade(_player, from: startVolume, to: 0, duration: duration);
    await _player.stop();
    await _player.setVolume(startVolume);
  }

  /// Linearly ramps [player]'s volume from [from] to [to] over [duration].
  Future<void> _fade(
    AudioPlayer player, {
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
      await player.setVolume(v.clamp(0.0, 1.0));
    }
  }

  void _broadcastState(PlaybackEvent event) {
    const processingStateMap = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    };
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 3],
      processingState:
          processingStateMap[_player.processingState] ?? AudioProcessingState.idle,
      playing: _player.playing,
      updatePosition: _player.position,
      speed: _player.speed,
    ));
  }
}
