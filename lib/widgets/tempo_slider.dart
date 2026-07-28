import 'package:flutter/material.dart';

import '../core/constants.dart';

class TempoSlider extends StatelessWidget {
  const TempoSlider({
    super.key,
    required this.percent,
    required this.onChanged,
  });

  final int percent;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.slow_motion_video),
        Expanded(
          child: Slider(
            value: percent.toDouble(),
            min: TempoLimits.minPercent.toDouble(),
            max: TempoLimits.maxPercent.toDouble(),
            divisions: (TempoLimits.maxPercent - TempoLimits.minPercent) ~/
                TempoLimits.stepPercent,
            label: '$percent%',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text('$percent%', textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
