import 'package:flutter/material.dart';

import '../core/format.dart';

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
    this.stopAt,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onSeek;

  /// Shows the trailing label as `-m:ss` time-left instead of total length.
  final bool remainingAsCountdown;

  /// Optional marker drawn on the track at this position - the point where
  /// playback will be cut off (e.g. a practice set entry's play-duration
  /// limit). The caller should only update this in response to a seek (or
  /// a new song starting), not on every position tick - the cutoff is
  /// time-based rather than position-based, so its on-track position
  /// otherwise never moves and recomputing it every tick just makes it
  /// wiggle.
  final Duration? stopAt;

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
        ? '-${formatDuration(widget.duration - shown)}'
        : formatDuration(widget.duration);

    final startLabel = formatDuration(shown);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final markerLabelStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.error,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final stopAt = widget.stopAt;
    final markerFraction =
        stopAt == null ? null : (stopAt.inMilliseconds / maxMs).clamp(0.0, 1.0);

    return Column(
      children: [
        SliderTheme(
          data: theme.sliderTheme.copyWith(
            // The scrub bar is the one place a taller track earns its keep:
            // it doubles as the primary progress readout for the screen.
            trackHeight: 6,
            thumbSize: const WidgetStatePropertyAll(Size(4, 22)),
            trackShape: _MarkedSliderTrackShape(
              markerFraction: markerFraction,
              markerColor: theme.colorScheme.error,
            ),
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
        // The marker's own time label (when there's a cutoff to show) is
        // overlaid on this same row rather than reserving a row of its own
        // above it - keeps the start/end readout at a fixed vertical
        // position regardless of whether a marker is present.
        LayoutBuilder(
          builder: (context, constraints) {
            final row = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(startLabel, style: labelStyle),
                Text(trailing, style: labelStyle),
              ],
            );
            if (markerFraction == null) return row;

            final trackWidth = constraints.maxWidth;
            final markerText = formatDuration(stopAt!);
            final markerWidth = _measure(markerText, markerLabelStyle);
            // Keep the marker label clear of the start/end labels sharing
            // the row with it - if there isn't room for it between the
            // two, it's close enough to one of the edges that the tick
            // alone still reads fine on its own.
            const gap = 6.0;
            final minLeft = _measure(startLabel, labelStyle) + gap;
            final maxLeft =
                trackWidth - _measure(trailing, labelStyle) - gap - markerWidth;
            if (minLeft > maxLeft) return row;
            final left =
                (trackWidth * markerFraction - markerWidth / 2).clamp(minLeft, maxLeft);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                row,
                Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(markerText, style: markerLabelStyle),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static double _measure(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }
}

/// Draws the normal Material track, then an extra vertical tick at
/// [markerFraction] (0-1 along the track) - used to show where playback will
/// be cut off. Extends the default shape (rather than painting independently
/// on top via a Stack) so the tick uses the exact same track rect the real
/// track is drawn in, including thumb/overlay insets.
class _MarkedSliderTrackShape extends RoundedRectSliderTrackShape {
  const _MarkedSliderTrackShape({required this.markerFraction, required this.markerColor});

  final double? markerFraction;
  final Color markerColor;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    final fraction = markerFraction;
    if (fraction == null) return;

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final dx = trackRect.left + trackRect.width * fraction;
    final paint = Paint()
      ..color = markerColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    context.canvas.drawLine(
      Offset(dx, trackRect.top - 5),
      Offset(dx, trackRect.bottom + 5),
      paint,
    );
  }
}
