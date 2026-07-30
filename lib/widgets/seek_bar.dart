import 'package:flutter/material.dart';

/// Slim scrub bar with the elapsed/remaining readout underneath it.
///
/// While the user drags, the thumb follows the finger instead of the incoming
/// position stream (which would otherwise yank it back until the seek lands).
/// Pass a null [onSeek] for a read-only bar - used for the practice-session
/// break countdown, which isn't seekable.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.onSeek,
    this.remainingAsCountdown = false,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onSeek;

  /// Shows the trailing label as `-m:ss` time-left instead of total length.
  final bool remainingAsCountdown;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragMilliseconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A zero-length track would make Slider assert on max <= min; keep a
    // 1ms floor so an unknown duration renders as an empty bar instead.
    final maxMs = widget.duration.inMilliseconds.toDouble().clamp(1, double.infinity);
    final positionMs = widget.position.inMilliseconds.toDouble().clamp(0, maxMs);
    final valueMs = _dragMilliseconds ?? positionMs;
    final shown = Duration(milliseconds: valueMs.round());
    final trailing = widget.remainingAsCountdown
        ? '-${_format(widget.duration - shown)}'
        : _format(widget.duration);

    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Column(
      children: [
        SliderTheme(
          data: theme.sliderTheme.copyWith(
            // The scrub bar is the one place a taller track earns its keep:
            // it doubles as the primary progress readout for the screen.
            trackHeight: 6,
            thumbSize: const WidgetStatePropertyAll(Size(4, 22)),
          ),
          child: Slider(
            value: valueMs.toDouble(),
            max: maxMs.toDouble(),
            onChanged: widget.onSeek == null
                ? null
                : (v) => setState(() => _dragMilliseconds = v),
            onChangeEnd: widget.onSeek == null
                ? null
                : (v) {
                    widget.onSeek!(Duration(milliseconds: v.round()));
                    setState(() => _dragMilliseconds = null);
                  },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_format(shown), style: labelStyle),
            Text(trailing, style: labelStyle),
          ],
        ),
      ],
    );
  }

  static String _format(Duration d) {
    final clamped = d.isNegative ? Duration.zero : d;
    final m = clamped.inMinutes;
    final s = clamped.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
