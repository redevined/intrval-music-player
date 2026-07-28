import 'package:audiotags/audiotags.dart';
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

/// Handles reading tag metadata for both local file paths and SAF
/// `content://` URIs (by staging the latter to a temp local file first,
/// since the underlying tag-reading native code needs a real path).
class FileImportService {
  Future<ImportedTrackMetadata> extractMetadata(String uriOrPath) async {
    final staged = await stageLocalFile(uriOrPath);
    try {
      final tag = await AudioTags.read(staged.path);
      final fallbackTitle = p.basenameWithoutExtension(uriOrPath);
      return ImportedTrackMetadata(
        title: (tag?.title?.isNotEmpty ?? false) ? tag!.title! : fallbackTitle,
        artist: tag?.trackArtist,
        album: tag?.album,
        durationMs: tag?.duration != null ? tag!.duration! * 1000 : null,
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
