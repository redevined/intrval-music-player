import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intrval_music_player/data/database/database.dart';
import 'package:intrval_music_player/data/providers.dart';
import 'package:intrval_music_player/features/player/now_playing_controller.dart';
import 'package:intrval_music_player/features/player/practice_session_controller.dart';
import 'package:intrval_music_player/services/audio_player_service.dart';

/// Records what playback was asked to do, without touching just_audio. Only
/// the members the controllers actually use are implemented; anything else
/// would be a bug in this test's assumptions, so it throws loudly.
class FakeAudioHandler implements AudioPlayerHandler {
  final loadedUris = <String>[];
  bool playing = false;
  int stopCount = 0;
  double? tempoPercent;

  @override
  void Function()? onTrackComplete;

  @override
  Future<void> loadTrack({
    required String uriOrPath,
    required MediaItem item,
    double tempoPercent = 100,
  }) async {
    loadedUris.add(uriOrPath);
    this.tempoPercent = tempoPercent;
  }

  @override
  Future<void> play() async => playing = true;

  @override
  Future<void> pause() async => playing = false;

  @override
  Future<void> stop() async {
    playing = false;
    stopCount++;
  }

  @override
  Future<void> setTempoPercent(double percent) async => tempoPercent = percent;

  @override
  Future<void> fadeOutAndStop(Duration duration) async => stop();

  @override
  Future<void> seek(Duration position) async {}

  @override
  Duration get position => Duration.zero;

  @override
  Duration? get duration => const Duration(minutes: 3);

  @override
  bool get isPlaying => playing;

  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'FakeAudioHandler received an unexpected call: ${invocation.memberName}',
    );
  }
}

void main() {
  late AppDatabase db;
  late FakeAudioHandler handler;
  late ProviderContainer container;
  late PracticeSetRepositoryHarness harness;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    handler = FakeAudioHandler();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      audioHandlerProvider.overrideWithValue(handler),
    ]);
    harness = PracticeSetRepositoryHarness(container);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  PracticeSessionController controller() =>
      container.read(practiceSessionProvider.notifier);

  PracticeSessionState? session() => container.read(practiceSessionProvider);

  test('starts at the first entry and plays a song from its playlist', () async {
    final set = await harness.createSetWithEntries(['Waltz', 'Tango']);

    await controller().start(set);

    final s = session()!;
    expect(s.phase, SessionPhase.playing);
    expect(s.entryIndex, 0);
    expect(s.currentEntry!.label, 'Waltz');
    expect(s.positionLabel, '1 / 2');
    expect(s.nextEntry!.label, 'Tango');
    expect(s.currentSong, isNotNull);
    expect(handler.loadedUris, hasLength(1));
    expect(handler.playing, isTrue);
  });

  test('skip advances through the set and then completes it', () async {
    final set = await harness.createSetWithEntries(['Waltz', 'Tango']);
    await controller().start(set);

    controller().skip();
    await pumpEventQueue();

    expect(session()!.entryIndex, 1);
    expect(session()!.currentEntry!.label, 'Tango');
    expect(session()!.nextEntry, isNull);
    expect(session()!.phase, SessionPhase.playing);

    controller().skip();
    await pumpEventQueue();

    expect(session()!.phase, SessionPhase.complete);
    expect(session()!.isActive, isFalse);
  });

  test('a track ending naturally starts the entry break', () async {
    final set =
        await harness.createSetWithEntries(['Waltz', 'Tango'], breakSeconds: 25);
    await controller().start(set);

    // The handler reports completion the way just_audio would.
    handler.onTrackComplete!();
    await pumpEventQueue();

    final s = session()!;
    expect(s.phase, SessionPhase.breaking);
    expect(s.breakSecondsRemaining, 25);
    expect(s.breakTotalSeconds, 25);
  });

  test('the last entry never gets a break - it completes straight away',
      () async {
    final set = await harness.createSetWithEntries(['Waltz'], breakSeconds: 25);
    await controller().start(set);

    handler.onTrackComplete!();
    await pumpEventQueue();

    expect(session()!.phase, SessionPhase.complete);
  });

  test('session state outlives its listeners, so leaving the screen keeps it',
      () async {
    final set = await harness.createSetWithEntries(['Waltz']);
    await controller().start(set);

    // A screen subscribing and going away again must not tear the session
    // down - that is what makes playback continue after navigating back.
    final sub = container.listen(practiceSessionProvider, (_, _) {});
    sub.close();
    await pumpEventQueue();

    expect(session(), isNotNull);
    expect(session()!.phase, SessionPhase.playing);
  });

  test('an entry whose playlist is empty is skipped, not stuck on loading',
      () async {
    final set = await harness.createSetWithEntries(
      ['Empty', 'Tango'],
      emptyFirstEntry: true,
    );

    await controller().start(set);
    await pumpEventQueue();

    expect(session()!.entryIndex, 1);
    expect(session()!.currentEntry!.label, 'Tango');
    expect(session()!.phase, SessionPhase.playing);
  });

  test('pausing and resuming drives the handler', () async {
    final set = await harness.createSetWithEntries(['Waltz']);
    await controller().start(set);

    controller().togglePause();
    expect(session()!.paused, isTrue);
    expect(handler.playing, isFalse);

    controller().togglePause();
    await pumpEventQueue();
    expect(session()!.paused, isFalse);
    expect(handler.playing, isTrue);
  });

  test('pausing freezes the cutoff countdown instead of it draining in the background',
      () async {
    final set =
        await harness.createSetWithEntries(['Waltz'], playDurationSeconds: 5);
    await controller().start(set);
    expect(session()!.cutoffRemainingSeconds, 5);

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final afterOneTick = session()!.cutoffRemainingSeconds!;
    expect(afterOneTick, lessThan(5));

    controller().togglePause();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    // Frozen while paused - must not have ticked down further.
    expect(session()!.cutoffRemainingSeconds, afterOneTick);

    controller().togglePause();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(session()!.cutoffRemainingSeconds, lessThan(afterOneTick));
  });

  test('stop clears the session and releases the handler', () async {
    final set = await harness.createSetWithEntries(['Waltz']);
    await controller().start(set);

    await controller().stop();

    expect(session(), isNull);
    expect(handler.stopCount, greaterThan(0));
    // Auto-advance for ad-hoc queues is wired back up.
    expect(handler.onTrackComplete, isNotNull);
  });

  test('starting an ad-hoc queue ends a running session', () async {
    final set = await harness.createSetWithEntries(['Waltz']);
    await controller().start(set);
    expect(session(), isNotNull);

    final songs = await container.read(songRepositoryProvider).watchAll().first;
    await container.read(nowPlayingProvider.notifier).playQueue(songs, 0);

    expect(session(), isNull);
    expect(container.read(nowPlayingProvider), isNotNull);
  });

  test('entry tempo is applied and can be overridden live', () async {
    final set = await harness.createSetWithEntries(['Waltz'], tempoPercent: 85);
    await controller().start(set);

    expect(session()!.tempoPercent, 85);
    expect(handler.tempoPercent, 85);

    await controller().setTempo(110);

    expect(session()!.tempoPercent, 110);
    expect(handler.tempoPercent, 110);
  });
}

/// Builds practice sets backed by a real playlist of songs.
class PracticeSetRepositoryHarness {
  PracticeSetRepositoryHarness(this._container);

  final ProviderContainer _container;

  Future<PracticeSet> createSetWithEntries(
    List<String> entryLabels, {
    int? breakSeconds,
    int? tempoPercent,
    int? playDurationSeconds,
    bool emptyFirstEntry = false,
  }) async {
    final songs = _container.read(songRepositoryProvider);
    final playlists = _container.read(playlistRepositoryProvider);
    final sets = _container.read(practiceSetRepositoryProvider);

    final songId = await songs.importSong(uri: '/music/one.mp3', title: 'One');
    final songId2 = await songs.importSong(uri: '/music/two.mp3', title: 'Two');
    final playlistId = await playlists.create('Pool');
    await playlists.addSong(playlistId, songId);
    await playlists.addSong(playlistId, songId2);
    final emptyPlaylistId = await playlists.create('Empty pool');

    final setId = await sets.create('Practice');
    for (var i = 0; i < entryLabels.length; i++) {
      final useEmpty = emptyFirstEntry && i == 0;
      final entryId = await sets.addEntry(
        setId,
        label: entryLabels[i],
        playlistId: useEmpty ? emptyPlaylistId : playlistId,
      );
      if (breakSeconds != null || tempoPercent != null || playDurationSeconds != null) {
        await sets.updateEntry(
          entryId,
          SetEntriesCompanion(
            breakSeconds:
                breakSeconds != null ? Value(breakSeconds) : const Value.absent(),
            tempoPercent:
                tempoPercent != null ? Value(tempoPercent) : const Value.absent(),
            playDurationSeconds: playDurationSeconds != null
                ? Value(playDurationSeconds)
                : const Value.absent(),
          ),
        );
      }
    }
    return (await sets.getById(setId))!;
  }
}
