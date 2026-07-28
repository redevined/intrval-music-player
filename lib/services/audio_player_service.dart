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

  /// Called when the current track finishes playing naturally.
  void Function()? onTrackComplete;

  Stream<Duration> get positionStream => _player.positionStream;
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
    const steps = 20;
    final stepDuration = duration ~/ steps;
    final startVolume = _player.volume;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(stepDuration);
      final v = startVolume * (1 - i / steps);
      await _player.setVolume(v.clamp(0.0, 1.0));
    }
    await _player.stop();
    await _player.setVolume(startVolume);
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
