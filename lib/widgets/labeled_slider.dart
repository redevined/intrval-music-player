import 'package:flutter/material.dart';

/// A label + current-value row with a [Slider] underneath. Used everywhere
/// a tempo/play-duration/break/fade-out style setting is edited (Settings'
/// new-set defaults, and a practice set's own defaults/per-entry overrides)
/// so those three places don't each reimplement the same row.
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 0),
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
              Text(valueLabel, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
