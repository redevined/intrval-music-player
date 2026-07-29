import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:intrval_music_player/data/database/database.dart';
import 'package:intrval_music_player/data/repositories/song_repository.dart';
import 'package:intrval_music_player/services/bpm_detection_service.dart';
import 'package:intrval_music_player/services/file_import_service.dart';
import 'package:intrval_music_player/services/music_library_scanner.dart';

/// Returns metadata straight from the filename - no plugins, no I/O.
class _FakeImportService extends FileImportService {
  @override
  Future<ImportedTrackMetadata> extractMetadata(String uriOrPath) async {
    return ImportedTrackMetadata(title: p.basenameWithoutExtension(uriOrPath));
  }
}

/// Stands in for the real (slow, native-decoding) detector. Each call parks
/// on a completer the test controls, so the test can observe exactly what
/// has been imported while analysis is still outstanding.
class _BlockingBpmService extends BpmDetectionService {
  final calls = <String>[];
  final _gates = <Completer<BpmDetectionResult?>>[];

  @override
  Future<BpmDetectionResult?> detectBpm(String uriOrPath) {
    calls.add(uriOrPath);
    final gate = Completer<BpmDetectionResult?>();
    _gates.add(gate);
    return gate.future;
  }

  /// Releases the oldest outstanding analysis with [bpm] (or no result),
  /// then lets the pass advance to the next song.
  Future<void> release({double? bpm}) async {
    final gate = _gates.removeAt(0);
    gate.complete(
      bpm == null ? null : BpmDetectionResult(bpm: bpm, confidence: 0.9),
    );
    await pumpEventQueue();
  }
}

void main() {
  late AppDatabase db;
  late SongRepository songs;
  late Directory musicDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    songs = SongRepository(db);
    musicDir = await Directory.systemTemp.createTemp('scanner_test_music');
    for (final name in ['a.mp3', 'b.mp3', 'c.mp3']) {
      await File(p.join(musicDir.path, name)).writeAsString('not real audio');
    }
    // A non-audio file that must be ignored by the walk.
    await File(p.join(musicDir.path, 'cover.jpg')).writeAsString('x');
  });

  tearDown(() async {
    await db.close();
    await musicDir.delete(recursive: true);
  });

  MusicLibraryScanner buildScanner(_BlockingBpmService bpm) =>
      MusicLibraryScanner(
        songs,
        _FakeImportService(),
        bpm,
        roots: [musicDir.path],
        ensurePermission: () async => true,
      );

  test('imports every song without waiting for BPM analysis', () async {
    final bpm = _BlockingBpmService();

    // scan() resolves even though no analysis has been allowed to finish.
    await buildScanner(bpm).scan();

    final imported = await songs.watchAll().first;
    expect(
      imported.map((s) => s.title),
      containsAll(<String>['a', 'b', 'c']),
      reason: 'all songs should be visible before any BPM result lands',
    );
    expect(imported, hasLength(3), reason: 'the .jpg must not be imported');
    expect(
      imported.every((s) => s.bpmDetected == null),
      isTrue,
      reason: 'analysis is still outstanding, so no BPM should be stored yet',
    );
  });

  test('analyzes songs one at a time, persisting each result as it lands',
      () async {
    final bpm = _BlockingBpmService();
    await buildScanner(bpm).scan();
    await pumpEventQueue();

    // Only the first analysis is in flight - the pass must not fan out.
    expect(bpm.calls, hasLength(1));

    await bpm.release(bpm: 128);

    final analyzed = await songs.songsMissingBpm();
    expect(analyzed, hasLength(2), reason: 'one song should now have a BPM');
    expect(bpm.calls, hasLength(2), reason: 'the next song should be started');

    await bpm.release(bpm: 90);
    await bpm.release(bpm: 140);

    final remaining = await songs.songsMissingBpm();
    expect(remaining, isEmpty);
    final stored = await songs.watchAll().first;
    expect(
      stored.map((s) => s.bpmDetected).whereType<double>().toSet(),
      {128.0, 90.0, 140.0},
    );
  });

  test('a song that cannot be analyzed does not stall the backlog', () async {
    final bpm = _BlockingBpmService();
    await buildScanner(bpm).scan();
    await pumpEventQueue();

    await bpm.release(); // no usable result for the first song
    await bpm.release(bpm: 100);
    await bpm.release(bpm: 110);

    expect(bpm.calls, hasLength(3), reason: 'every song should be attempted');
    final stored = await songs.watchAll().first;
    expect(
      stored.where((s) => s.bpmDetected != null),
      hasLength(2),
      reason: 'the two successful analyses should still be persisted',
    );
  });

  test('rescanning re-imports nothing and skips already-analyzed songs',
      () async {
    final bpm = _BlockingBpmService();
    final scanner = buildScanner(bpm);
    await scanner.scan();
    await pumpEventQueue();
    await bpm.release(bpm: 120);
    await bpm.release(bpm: 121);
    await bpm.release(bpm: 122);

    await scanner.scan();
    await pumpEventQueue();

    expect(await songs.watchAll().first, hasLength(3));
    expect(
      bpm.calls,
      hasLength(3),
      reason: 'songs with a stored BPM should not be re-analyzed',
    );
  });
}
