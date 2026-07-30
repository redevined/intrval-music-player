import 'package:flutter/material.dart';

/// Large rounded tile that stands in for album art (which the library doesn't
/// extract yet). A soft two-tone gradient plus an optional badge keeps the
/// player screens from looking like a bare form, without pretending to be
/// artwork that isn't there.
class PlayerArtwork extends StatelessWidget {
  const PlayerArtwork({
    super.key,
    this.icon = Icons.music_note,
    this.badge,
    this.dimmed = false,
  });

  final IconData icon;

  /// Small pill rendered over the bottom of the tile, e.g. the tempo the
  /// current track is playing at.
  final Widget? badge;

  /// Mutes the tile while nothing is actually sounding (session breaks).
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dimmed
                ? [colors.surfaceContainerHigh, colors.surfaceContainerLow]
                : [colors.primaryContainer, colors.tertiaryContainer],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 96,
              color: (dimmed ? colors.onSurfaceVariant : colors.onPrimaryContainer)
                  .withValues(alpha: 0.55),
            ),
            if (badge != null)
              Positioned(
                bottom: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.labelLarge,
                      child: badge!,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
