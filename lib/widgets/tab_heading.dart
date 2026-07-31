import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

/// Title row used by the 4 root tab screens (Library, Playlists, Sets,
/// Settings): the app icon followed by the screen's heading. Not used on
/// sub-screens (playlist/set detail, etc).
///
/// Easter egg: tapping the icon cycles the app's color scheme through
/// [ThemeSeedOption] - see `core/theme.dart`.
class TabHeading extends ConsumerWidget {
  const TabHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAvailable =
        ref.watch(systemCorePaletteProvider).valueOrNull != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ref
              .read(themeSeedProvider.notifier)
              .cycle(systemAvailable: systemAvailable),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/app_icon_rounded.png',
              width: 32,
              height: 32,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(title),
      ],
    );
  }
}
