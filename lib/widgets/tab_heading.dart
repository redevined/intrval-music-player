import 'package:flutter/material.dart';

/// Title row used by the 4 root tab screens (Library, Playlists, Sets,
/// Settings): the app icon followed by the screen's heading. Not used on
/// sub-screens (playlist/set detail, etc).
class TabHeading extends StatelessWidget {
  const TabHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/app_icon_rounded.png', width: 32, height: 32),
        ),
        const SizedBox(width: 12),
        Text(title),
      ],
    );
  }
}
