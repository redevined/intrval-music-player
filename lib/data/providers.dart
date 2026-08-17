import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../services/audio_player_service.dart';
import '../services/bpm_detection_service.dart';
import '../services/file_import_service.dart';
import '../services/music_library_scanner.dart';
import 'database/database.dart';
import 'repositories/app_settings_repository.dart';
import 'repositories/folder_repository.dart';
import 'repositories/playlist_repository.dart';
import 'repositories/practice_set_repository.dart';
import 'repositories/song_repository.dart';

/// Overridden in `main()` with the instance returned by `AudioService.init`.
final audioHandlerProvider = Provider<AudioPlayerHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main()');
});

/// Overridden in `main()` with the instance returned by
/// `SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

/// App/build version info, shown in the Settings "About" section - read
/// once and cached for the app's lifetime rather than re-fetched per screen.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(ref.watch(sharedPreferencesProvider));
});

final setDefaultsProvider =
    StateNotifierProvider<SimpleSettingController<SetDefaults>, SetDefaults>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(repo.saveSetDefaults, repo.setDefaults);
    });

final musicRootFolderProvider =
    StateNotifierProvider<SimpleSettingController<String>, String>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(
        repo.saveMusicRootFolder,
        repo.musicRootFolder,
      );
    });

/// The break-cue behavior (silence / beeps / audio track) is a single global
/// setting, not something worth deciding per practice set - every session
/// picks it up live from here rather than storing it per set.
final breakCueModeProvider =
    StateNotifierProvider<SimpleSettingController<String>, String>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(repo.saveBreakCueMode, repo.breakCueMode);
    });

/// Volume for whichever break cue is currently selected (ambient track or
/// beep) - same reasoning as [breakCueModeProvider].
final breakCueVolumeProvider =
    StateNotifierProvider<SimpleSettingController<int>, int>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(
        repo.saveBreakCueVolumePercent,
        repo.breakCueVolumePercent,
      );
    });

/// Overall volume boost applied to all playback - a single global setting,
/// since the device not being loud enough is a property of the room/
/// speakers rather than of whatever happens to be playing.
final volumeBoostDbProvider =
    StateNotifierProvider<SimpleSettingController<double>, double>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(repo.saveVolumeBoostDb, repo.volumeBoostDb);
    });

/// Whether songs are normalized to a consistent target loudness - a single
/// global setting, same reasoning as [volumeBoostDbProvider].
final audioNormalizationEnabledProvider =
    StateNotifierProvider<SimpleSettingController<bool>, bool>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(
        repo.saveAudioNormalizationEnabled,
        repo.audioNormalizationEnabled,
      );
    });

/// Same reasoning as [breakCueModeProvider]: a single global behavior rather
/// than something worth deciding per practice set.
final fadeOutSecondsProvider =
    StateNotifierProvider<SimpleSettingController<int>, int>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(repo.saveFadeOutSeconds, repo.fadeOutSeconds);
    });

/// The tempo-stretch DSP algorithm (see [TempoAlgorithm]) - a single global
/// setting, same reasoning as [breakCueModeProvider]. Defaults to Rubber
/// Band.
final tempoAlgorithmProvider =
    StateNotifierProvider<SimpleSettingController<TempoAlgorithm>, TempoAlgorithm>((ref) {
      final repo = ref.watch(appSettingsRepositoryProvider);
      return SimpleSettingController(repo.saveTempoAlgorithm, repo.tempoAlgorithm);
    });

/// The app-icon theme-cycling easter egg's current choice - see
/// [ThemeSeedOption].
final themeSeedProvider =
    StateNotifierProvider<ThemeSeedController, ThemeSeedOption>((ref) {
      return ThemeSeedController(ref.watch(appSettingsRepositoryProvider));
    });

/// The device's Material You palette (Android 12+ only) - null everywhere
/// else, including while it's still resolving. Resolved once and cached for
/// the app's lifetime; feeds [ThemeSeedOption.system].
///
/// `CorePalette` is deprecated upstream in `material_color_utilities` (in
/// favor of `DynamicScheme`), but it's still `dynamic_color`'s own current
/// public return type for this call - nothing to migrate to on our end yet.
// ignore: deprecated_member_use
final systemCorePaletteProvider = FutureProvider<CorePalette?>((ref) async {
  try {
    return await DynamicColorPlugin.getCorePalette();
  } catch (_) {
    return null;
  }
});

final fileImportServiceProvider = Provider<FileImportService>((ref) {
  return FileImportService();
});

final bpmDetectionServiceProvider = Provider<BpmDetectionService>((ref) {
  return BpmDetectionService();
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository(ref.watch(databaseProvider));
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository(ref.watch(databaseProvider));
});

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository(
    ref.watch(databaseProvider),
    ref.watch(songRepositoryProvider),
    ref.watch(fileImportServiceProvider),
  );
});

final practiceSetRepositoryProvider = Provider<PracticeSetRepository>((ref) {
  return PracticeSetRepository(ref.watch(databaseProvider));
});

final musicLibraryScannerProvider = Provider<MusicLibraryScanner>((ref) {
  final scanner = MusicLibraryScanner(
    ref.watch(songRepositoryProvider),
    ref.watch(fileImportServiceProvider),
    ref.watch(bpmDetectionServiceProvider),
    roots: [ref.watch(musicRootFolderProvider)],
  );
  ref.onDispose(scanner.dispose);
  return scanner;
});

/// (total songs, songs still missing a BPM) for the Settings > Library
/// analysis-status entry - see [SongRepository.watchBpmProgress].
final bpmProgressProvider = StreamProvider.autoDispose<(int, int)>((ref) {
  return ref.watch(songRepositoryProvider).watchBpmProgress();
});

/// Whether the scanner's background BPM pass is currently running - see
/// [MusicLibraryScanner.analyzingStream].
final bpmAnalyzingProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref.watch(musicLibraryScannerProvider).analyzingStream;
});
