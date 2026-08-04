import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intrval_music_player/data/database/database.dart';
import 'package:intrval_music_player/data/providers.dart';
import 'package:intrval_music_player/features/player/now_playing_controller.dart';
import 'package:intrval_music_player/services/audio_player_service.dart';

/// Records what playback was asked to do, without touching just_audio. Only
/// the members [NowPlayingController] actually uses are implemented -
/// anything else would be a bug in this test's assumptions, so it throws
/// loudly.
class FakeAudioHandler implements AudioPlayerHandler {
  final loadedUris = <String>[];
  bool playing = false;

  @override
  void Function()? onTrackComplete;

  @override
  Future<void> loadTrack({
    required String uriOrPath,
    required MediaItem item,
    double tempoPercent = 100,
  }) async {
    loadedUris.add(uriOrPath);
  }

  @override
  Future<void> play() async => playing = true;

  @override
  Future<void> pause() async => playing = false;

  @override
  Future<void> stop() async => playing = false;

  @override
  Future<void> setTempoPercent(double percent) async {}

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

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    handler = FakeAudioHandler();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      audioHandlerProvider.overrideWithValue(handler),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  NowPlayingController controller() =>
      container.read(nowPlayingProvider.notifier);

  NowPlayingState? state() => container.read(nowPlayingProvider);

  Future<List<Song>> importSongs(int count) async {
    final repo = container.read(songRepositoryProvider);
    final songs = <Song>[];
    for (var i = 0; i < count; i++) {
      final id = await repo.importSong(uri: '/music/$i.mp3', title: 'Song $i');
      songs.add((await repo.getById(id))!);
    }
    return songs;
  }

  test('next/previous walk the queue sequentially with shuffle off', () async {
    final songs = await importSongs(3);
    await controller().playQueue(songs, 0);

    expect(state()!.currentSong.uri, '/music/0.mp3');
    expect(state()!.hasNext, isTrue);
    expect(state()!.hasPrevious, isFalse);

    await controller().next();
    expect(state()!.currentSong.uri, '/music/1.mp3');

    await controller().next();
    expect(state()!.currentSong.uri, '/music/2.mp3');
    expect(state()!.hasNext, isFalse, reason: 'repeat is off and this is the last track');

    await controller().previous();
    expect(state()!.currentSong.uri, '/music/1.mp3');
  });

  test('next() does nothing past the last track when repeat is off', () async {
    final songs = await importSongs(2);
    await controller().playQueue(songs, 1);
    final loadedBefore = handler.loadedUris.length;

    await controller().next();

    expect(state()!.currentSong.uri, '/music/1.mp3', reason: 'should not have moved');
    expect(handler.loadedUris.length, loadedBefore, reason: 'no new track should load');
  });

  test('cycleRepeatMode cycles off -> all -> one -> off', () async {
    final songs = await importSongs(2);
    await controller().playQueue(songs, 0);

    expect(state()!.repeatMode, QueueRepeatMode.off);
    controller().cycleRepeatMode();
    expect(state()!.repeatMode, QueueRepeatMode.all);
    controller().cycleRepeatMode();
    expect(state()!.repeatMode, QueueRepeatMode.one);
    controller().cycleRepeatMode();
    expect(state()!.repeatMode, QueueRepeatMode.off);
  });

  test('repeat-all wraps next() back to the first track at the end', () async {
    final songs = await importSongs(3);
    await controller().playQueue(songs, 2);
    controller().cycleRepeatMode(); // -> all

    expect(state()!.hasNext, isTrue, reason: 'repeat-all always has a next track');
    await controller().next();

    expect(state()!.currentSong.uri, '/music/0.mp3');
  });

  test('repeat-one replays the same track on natural completion instead of advancing', () async {
    final songs = await importSongs(2);
    await controller().playQueue(songs, 0);
    controller().cycleRepeatMode(); // -> all
    controller().cycleRepeatMode(); // -> one
    final loadedBefore = handler.loadedUris.length;

    handler.onTrackComplete!();
    await Future<void>.delayed(Duration.zero);

    expect(state()!.currentSong.uri, '/music/0.mp3', reason: 'must not have advanced');
    expect(
      handler.loadedUris.length,
      loadedBefore + 1,
      reason: 'should have reloaded the same track to replay it',
    );
  });

  test('a user-pressed next() still advances during repeat-one (unlike auto-complete)', () async {
    final songs = await importSongs(2);
    await controller().playQueue(songs, 0);
    controller().cycleRepeatMode(); // -> all
    controller().cycleRepeatMode(); // -> one

    await controller().next();

    expect(state()!.currentSong.uri, '/music/1.mp3');
  });

  test('auto-complete advances normally when repeat is off', () async {
    final songs = await importSongs(3);
    await controller().playQueue(songs, 0);

    handler.onTrackComplete!();
    await Future<void>.delayed(Duration.zero);

    expect(state()!.currentSong.uri, '/music/1.mp3');
  });

  test('toggleShuffle randomizes order without interrupting the current track', () async {
    final songs = await importSongs(6);
    await controller().playQueue(songs, 3);
    final currentBefore = state()!.currentSong.uri;

    controller().toggleShuffle();

    final s = state()!;
    expect(s.shuffleEnabled, isTrue);
    expect(s.currentSong.uri, currentBefore, reason: 'toggling shuffle must not skip tracks');
    expect(
      s.order.toSet(),
      Set<int>.from(List.generate(songs.length, (i) => i)),
      reason: 'order must remain a permutation of every song',
    );
  });

  test('toggling shuffle off restores sequential order, still on the same track', () async {
    final songs = await importSongs(5);
    await controller().playQueue(songs, 2);
    final currentBefore = state()!.currentSong.uri;

    controller().toggleShuffle();
    controller().toggleShuffle();

    final s = state()!;
    expect(s.shuffleEnabled, isFalse);
    expect(s.order, List.generate(songs.length, (i) => i));
    expect(s.currentSong.uri, currentBefore);
  });
}
