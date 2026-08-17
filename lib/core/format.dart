/// Formats [d] as `m:ss`, clamping negative durations to zero. Shared by
/// every place in the app that shows an elapsed/remaining time readout
/// (seek bar, song tiles, mini-player).
String formatDuration(Duration d) {
  final clamped = d.isNegative ? Duration.zero : d;
  final minutes = clamped.inMinutes;
  final seconds = clamped.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
