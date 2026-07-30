import 'package:flutter/material.dart';

/// Common layout for both player screens (ad-hoc queue and practice session)
/// so they read as the same view, with slots for the extra context a practice
/// session needs. Keeping the arrangement in one place is what stops the two
/// from drifting apart visually.
class PlayerShell extends StatelessWidget {
  const PlayerShell({
    super.key,
    required this.appBarTitle,
    this.appBarActions,
    required this.artwork,
    this.contextHeader,
    required this.title,
    this.subtitle,
    required this.progress,
    this.tempo,
    required this.controls,
    this.footer,
  });

  final String appBarTitle;
  final List<Widget>? appBarActions;

  final Widget artwork;

  /// Optional block between the artwork and the title - the practice session
  /// uses it for the entry name and its position in the set.
  final Widget? contextHeader;

  final String title;
  final String? subtitle;

  final Widget progress;
  final Widget? tempo;
  final Widget controls;

  /// Optional trailing block, e.g. "Next up".
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: appBarActions,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The artwork is the flexible element: it takes the space left
            // over so the controls stay put on short screens instead of the
            // column overflowing.
            final artworkMax = (constraints.maxHeight * 0.38).clamp(0.0, 340.0);

            final content = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: artworkMax),
                    child: artwork,
                  ),
                ),
                const SizedBox(height: 28),
                if (contextHeader != null) ...[
                  contextHeader!,
                  const SizedBox(height: 16),
                ],
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 24),
                progress,
                if (tempo != null) ...[
                  const SizedBox(height: 20),
                  tempo!,
                ],
                const SizedBox(height: 20),
                controls,
                if (footer != null) ...[
                  const SizedBox(height: 20),
                  footer!,
                ],
              ],
            );

            // On a short screen the centered column can outgrow the
            // available height; let it scroll rather than overflow, without
            // relying on Spacer (which needs bounded constraints a scroll
            // view can't give it).
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Round primary play/pause button - the one deliberately heavy element on
/// the player screens.
class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.playing, required this.onPressed});

  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: colors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 38,
              color: colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary transport control (skip/previous), styled as a quiet tonal
/// circle so the play button stays dominant.
class TransportButton extends StatelessWidget {
  const TransportButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 28,
      style: IconButton.styleFrom(
        backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        foregroundColor: colors.onSurface,
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(14),
      ),
      icon: Icon(icon),
    );
  }
}
