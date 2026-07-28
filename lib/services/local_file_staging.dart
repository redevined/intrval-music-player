import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:saf/saf.dart';
import 'package:uuid/uuid.dart';

/// A filesystem path guaranteed to be readable by plain `dart:io`/native
/// codec APIs, plus a [dispose] hook to clean up if it was staged to a
/// temp file (SAF `content://` URIs can't be opened directly by most
/// native decoding/tagging libraries, so they're copied locally first).
class StagedFile {
  StagedFile(this.path, this._tempFile);
  final String path;
  final File? _tempFile;

  Future<void> dispose() async {
    final temp = _tempFile;
    if (temp != null && await temp.exists()) {
      await temp.delete();
    }
  }
}

const _uuid = Uuid();

/// Ensures [uriOrPath] is available as a plain local filesystem path.
/// SAF `content://` URIs are copied to a temp cache file first. Callers
/// must call `dispose()` on the result when done with it.
Future<StagedFile> stageLocalFile(String uriOrPath) async {
  if (!uriOrPath.startsWith('content://')) {
    return StagedFile(uriOrPath, null);
  }
  final saf = Saf();
  final tempDir = await getTemporaryDirectory();
  final tempPath =
      p.join(tempDir.path, '${_uuid.v4()}${p.extension(uriOrPath)}');
  await saf.copyToLocalFile(uriOrPath, tempPath);
  return StagedFile(tempPath, File(tempPath));
}
