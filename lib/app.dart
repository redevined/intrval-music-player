import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'data/providers.dart';
import 'features/library/library_screen.dart';
import 'features/playlists/playlist_list_screen.dart';
import 'features/sets/set_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'widgets/mini_player.dart';

class IntrvalApp extends ConsumerWidget {
  const IntrvalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSeedOption = ref.watch(themeSeedProvider);
    final corePalette = ref.watch(systemCorePaletteProvider).valueOrNull;

    return MaterialApp(
      title: 'intrval',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(
        themeSeedOption,
        systemScheme: corePalette?.toColorScheme(brightness: Brightness.light),
      ),
      darkTheme: AppTheme.dark(
        themeSeedOption,
        systemScheme: corePalette?.toColorScheme(brightness: Brightness.dark),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  static const _screens = [
    LibraryScreen(),
    PlaylistListScreen(),
    SetListScreen(),
    SettingsScreen(),
  ];

  // Each tab gets its own Navigator so pushing a detail screen (playlist
  // detail, set builder) only replaces that tab's content - the bottom
  // nav bar and mini player live outside these and stay put.
  Widget _buildTab(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => _screens[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final tabNavigator = _navigatorKeys[_index].currentState;
        if (tabNavigator != null && tabNavigator.canPop()) {
          tabNavigator.pop();
        } else {
          // Nothing left to pop: this PopScope wraps HomeShell itself
          // (MaterialApp.home), so calling Navigator.of(context).maybePop()
          // here would just re-invoke this exact same PopScope callback
          // again (didPop always false, since canPop is false above),
          // recursing forever via the microtask queue until it saturates
          // the main thread and trips an ANR. Exit the app directly instead.
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: List.generate(_screens.length, _buildTab),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayer(),
            NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) {
                _navigatorKeys[i].currentState?.popUntil(
                  (route) => route.isFirst,
                );
                setState(() => _index = i);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.library_music),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.queue_music),
                  label: 'Playlists',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timelapse),
                  label: 'Sets',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
