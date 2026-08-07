/// App-wide defaults and limits, matching the product plan.
class AppDefaults {
  static const int newSetEntryCount = 5;
  static const int playDurationSeconds = 105; // 1:45
  static const int breakSeconds = 30; // 0:30
  static const int fadeOutSeconds = 3;

  /// Fixed lead time before the beep cue plays during a break - not
  /// user-configurable, to keep the break-cue setup to a single choice.
  static const int beepLeadSeconds = 5;

  /// Fixed fade-in/fade-out length for the break audio track, clamped down
  /// for breaks shorter than twice this.
  static const int breakTrackFadeSeconds = 2;
  static const int tempoPercent = 100;

  /// Default volume for the break cue (ambient track or beep), as a
  /// percentage - both were previously played at full volume, which came
  /// through noticeably louder than the songs themselves.
  static const int breakCueVolumePercent = 80;

  /// Default overall volume boost, in decibels - off by default, so
  /// playback is unchanged unless the user explicitly turns it up.
  static const double volumeBoostDb = 0.0;

  /// Default folder auto-scanned for music, used until the user picks a
  /// different one in Settings.
  static const String musicRootFolder = '/storage/emulated/0/Music';
}

class TempoLimits {
  static const int minPercent = 70;
  static const int maxPercent = 130;
  static const int stepPercent = 1;
}

/// The DSP algorithm used to change playback tempo while preserving pitch -
/// see the ADR on migrating off just_audio/Sonic. Both run through
/// mpv_audio_kit: [rubberband] uses the Rubber Band time-stretch filter
/// (mpv's own rate stays pinned at 1.0); [scaletempo2] instead drives mpv's
/// native playback rate directly with pitch correction enabled. Rubber Band
/// sounds noticeably cleaner at moderate slowdowns and is the default, but
/// scaletempo2 uses less CPU - worth offering as an alternative.
enum TempoAlgorithm { rubberband, scaletempo2 }

/// Overall volume boost applies gain beyond the device's normal 100%
/// output via Android's LoudnessEnhancer, which uses dynamic range
/// compression rather than simple digital gain to raise perceived
/// loudness without immediately hard-clipping. Quality still degrades
/// as the boost increases, so the ceiling here is kept modest.
class VolumeBoostLimits {
  static const double minDb = 0.0;
  static const double maxDb = 12.0;
  static const double stepDb = 0.5;
}

/// Fixed width for every `AlertDialog`'s content, so a dialog's size never
/// changes as the user types into a text field (or based on which fields
/// happen to be present) - all modals in the app should read the same
/// physical size regardless of content.
const double kDialogContentWidth = 400;
