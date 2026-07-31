import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Pitch-preserving playback-speed control, presented as a labelled panel so
/// it reads as a distinct setting rather than a second scrub bar.
class TempoSlider extends StatelessWidget {
  const TempoSlider({
    super.key,
    required this.percent,
    required this.onChanged,
    this.baseBpm,
  });

  final int percent;
  final ValueChanged<int> onChanged;

  /// The track's own BPM (i.e. at 100% tempo), if known. Shown scaled by
  /// [percent] so it reflects the tempo actually being played, sparing the
  /// player screens from needing a separate (redundant) tempo readout of
  /// their own.
  final double? baseBpm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDefault = percent == AppDefaults.tempoPercent;
    final bpm = baseBpm;
    final effectiveBpm = bpm == null ? null : bpm * percent / 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 18, color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Tempo',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (effectiveBpm != null) ...[
                Text(
                  '${effectiveBpm.round()} BPM',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              _ValuePill(percent: percent, emphasized: !isDefault),
              IconButton(
                tooltip: 'Reset to ${AppDefaults.tempoPercent}%',
                icon: const Icon(Icons.restart_alt, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed:
                    isDefault ? null : () => onChanged(AppDefaults.tempoPercent),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
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
        ],
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.percent, required this.emphasized});

  final int percent;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: emphasized ? colors.primary : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$percent%',
        style: theme.textTheme.labelLarge?.copyWith(
          color: emphasized ? colors.onPrimary : colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
