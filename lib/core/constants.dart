/// App-wide defaults and limits, matching the product plan.
class AppDefaults {
  static const int newSetEntryCount = 5;
  static const int playDurationSeconds = 105; // 1:45
  static const int breakSeconds = 30; // 0:30
  static const int fadeOutSeconds = 3;
  static const int beepLeadSeconds = 5;
  static const int tempoPercent = 100;

  /// Default folder auto-scanned for music, used until the user picks a
  /// different one in Settings.
  static const String musicRootFolder = '/storage/emulated/0/Music';
}

class TempoLimits {
  static const int minPercent = 70;
  static const int maxPercent = 130;
  static const int stepPercent = 1;
}
