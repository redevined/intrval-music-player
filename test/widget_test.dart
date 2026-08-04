// Smoke test for the intrval app shell: verifies the four bottom navigation
// destinations render and that switching tabs works, using an in-memory
// database and a real (but unexercised) audio handler.

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intrval_music_player/app.dart';
import 'package:intrval_music_player/data/database/database.dart';
import 'package:intrval_music_player/data/providers.dart';
import 'package:intrval_music_player/services/audio_player_service.dart';
import 'package:intrval_music_player/services/music_library_scanner.dart';

/// The real scanner hits platform channels (permission_handler) and the
/// filesystem, neither of which are available in the widget test harness -
/// stub it out so it's a no-op.
class _NoopMusicLibraryScanner implements MusicLibraryScanner {
  @override
  Future<void> scan() async {}

  @override
  Future<void> retryUnanalyzed() async {}

  @override
  bool get isAnalyzing => false;

  @override
  Stream<bool> get analyzingStream => const Stream.empty();

  @override
  void dispose() {}
}

void main() {
  testWidgets('HomeShell renders all nav destinations and switches tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(
            AppDatabase.forTesting(NativeDatabase.memory()),
          ),
          audioHandlerProvider.overrideWithValue(AudioPlayerHandler()),
          musicLibraryScannerProvider.overrideWithValue(_NoopMusicLibraryScanner()),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const IntrvalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsWidgets);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Sets'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // The set-defaults controls live behind a modal now, opened from a
    // button in the "Sets" section.
    expect(find.text('SETS'), findsOneWidget);
    expect(find.text('New set defaults'), findsOneWidget);

    await tester.tap(find.text('New set defaults'));
    await tester.pumpAndSettle();
    expect(find.text('Tempo'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dispose the widget tree (and its ProviderScope/database) inside the
    // test's async zone, then pump once more so drift's zero-duration
    // stream-cleanup timer fires before the test framework asserts that no
    // timers are left pending.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
