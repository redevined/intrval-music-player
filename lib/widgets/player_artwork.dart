import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Large rounded tile showing a song's cover art, when it has one embedded.
/// Falls back to a soft two-tone gradient with an icon - and always does so
/// during a session break, when there's no "current song" to show art for -
/// so the player screens never look like a bare form, without pretending to
/// be artwork that isn't there.
class PlayerArtwork extends StatelessWidget {
  const PlayerArtwork({
    super.key,
    this.artworkBytes,
    this.icon = Icons.music_note,
    this.badge,
    this.dimmed = false,
  });

  /// Cover art read live off the currently loaded track by the playback
  /// engine itself - see `AudioPlayerHandler.coverArtStream`.
  final Uint8List? artworkBytes;

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 96,
                color: (dimmed ? colors.onSurfaceVariant : colors.onPrimaryContainer)
                    .withValues(alpha: 0.55),
              ),
              if (!dimmed && artworkBytes != null)
                Positioned.fill(
                  child: Image.memory(
                    artworkBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    // Falls through to the icon underneath on malformed
                    // image bytes, rather than erroring out.
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
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
      ),
    );
  }
}
