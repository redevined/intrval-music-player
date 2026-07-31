import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

import 'local_file_staging.dart';

/// Normalized metadata for a track, regardless of whether it was read from
/// a plain filesystem path or a SAF `content://` URI.
class ImportedTrackMetadata {
  ImportedTrackMetadata({
    required this.title,
    this.artist,
    this.album,
    this.durationMs,
  });

  final String title;
  final String? artist;
  final String? album;
  final int? durationMs;
}

const _audioExtensions = {
  '.mp3',
  '.m4a',
  '.aac',
  '.wav',
  '.flac',
  '.ogg',
  '.opus',
  '.wma',
  '.aiff',
};

bool isAudioFileName(String name) =>
    _audioExtensions.contains(p.extension(name).toLowerCase());

/// If [contentUri] is a SAF document on the device's primary external
/// storage volume, resolves it to the equivalent plain filesystem path
/// (e.g. `/storage/emulated/0/Music/song.mp3`). Returns null for URIs on
/// other volumes/providers (SD cards, cloud providers, etc.) where no
/// direct path is available.
String? resolvePrimaryStoragePath(String contentUri) {
  if (!contentUri.startsWith('content://com.android.externalstorage.documents/')) {
    return null;
  }
  final segments = Uri.parse(contentUri).pathSegments;
  final docIndex = segments.indexOf('document');
  if (docIndex == -1 || docIndex + 1 >= segments.length) return null;

  final docId = segments[docIndex + 1]; // e.g. "primary:Music/song.mp3"
  final colonIndex = docId.indexOf(':');
  if (colonIndex == -1) return null;

  final volume = docId.substring(0, colonIndex);
  if (volume != 'primary') return null;
  return '/storage/emulated/0/${docId.substring(colonIndex + 1)}';
}

/// Handles reading tag metadata for both local file paths and SAF
/// `content://` URIs (by staging the latter to a temp local file first,
/// since the tag reader needs a real `File`, not a content URI).
class FileImportService {
  Future<ImportedTrackMetadata> extractMetadata(String uriOrPath) async {
    final staged = await stageLocalFile(uriOrPath);
    try {
      final tag = readMetadata(File(staged.path), getImage: false);
      final fallbackTitle = p.basenameWithoutExtension(uriOrPath);
      return ImportedTrackMetadata(
        title: (tag.title?.isNotEmpty ?? false) ? tag.title! : fallbackTitle,
        artist: tag.artist,
        album: tag.album,
        durationMs: tag.duration?.inMilliseconds,
      );
    } catch (_) {
      // Corrupt/unsupported tag data shouldn't block import: fall back to
      // the filename as the title, leave the rest for the user to edit.
      return ImportedTrackMetadata(
        title: p.basenameWithoutExtension(uriOrPath),
      );
    } finally {
      await staged.dispose();
    }
  }
}
