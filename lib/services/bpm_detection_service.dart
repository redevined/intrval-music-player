import 'dart:io';

import 'package:just_waveform/just_waveform.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'local_file_staging.dart';

/// Result of an on-device BPM analysis.
class BpmDetectionResult {
  BpmDetectionResult({required this.bpm, required this.confidence});

  final double bpm;

  /// 0.0-1.0 relative strength of the winning periodicity vs. background
  /// noise in the autocorrelation. Low values (< ~0.15) mean the estimate
  /// is unreliable and the user should double check/correct it manually.
  final double confidence;
}

/// Local, on-device BPM estimator.
///
/// Approach: extract a coarse amplitude envelope from the audio file (via
/// `just_waveform`, which decodes the real audio natively), then find the
/// dominant periodicity of that envelope within the plausible dance-tempo
/// range (60-200 BPM) using autocorrelation. This is a standard, simple
/// beat-tracking technique - it is NOT a state-of-the-art beat tracker, and
/// can misfire on complex mixes or lock onto half/double-time. Manual BPM
/// correction (see `SongRepository.setManualBpm`) is the safety net; this
/// mirrors the "Local BPM accuracy" risk called out in the project plan.
class BpmDetectionService {
  static const _envelopeResolutionPerSecond = 50;
  static const _minBpm = 60.0;
  static const _maxBpm = 200.0;
  static const _uuid = Uuid();

  Future<BpmDetectionResult?> detectBpm(String uriOrPath) async {
    final staged = await stageLocalFile(uriOrPath);
    File? waveOutFile;
    try {
      final tempDir = await getTemporaryDirectory();
      waveOutFile = File(p.join(tempDir.path, '${_uuid.v4()}.wave'));

      Waveform? waveform;
      final stream = JustWaveform.extract(
        audioInFile: File(staged.path),
        waveOutFile: waveOutFile,
        zoom: const WaveformZoom.pixelsPerSecond(_envelopeResolutionPerSecond),
      );
      await for (final progress in stream) {
        if (progress.waveform != null) waveform = progress.waveform;
      }
      if (waveform == null || waveform.length < _envelopeResolutionPerSecond * 4) {
        // Too short to reliably estimate a tempo.
        return null;
      }

      final envelope = List<double>.generate(
        waveform.length,
        (i) => (waveform!.getPixelMax(i) - waveform.getPixelMin(i)).abs().toDouble(),
      );

      return _estimateBpmFromEnvelope(envelope, _envelopeResolutionPerSecond);
    } finally {
      await staged.dispose();
      if (waveOutFile != null && await waveOutFile.exists()) {
        await waveOutFile.delete();
      }
    }
  }

  BpmDetectionResult? _estimateBpmFromEnvelope(
    List<double> envelope,
    int samplesPerSecond,
  ) {
    final n = envelope.length;
    final mean = envelope.reduce((a, b) => a + b) / n;
    final centered = envelope.map((v) => v - mean).toList();

    final minLag = (samplesPerSecond * 60 / _maxBpm).round();
    final maxLag = (samplesPerSecond * 60 / _minBpm).round().clamp(0, n - 1);
    if (minLag >= maxLag) return null;

    double bestScore = double.negativeInfinity;
    int bestLag = minLag;
    double totalScore = 0;
    var scoreCount = 0;

    for (var lag = minLag; lag <= maxLag; lag++) {
      double sum = 0;
      for (var i = 0; i < n - lag; i++) {
        sum += centered[i] * centered[i + lag];
      }
      final score = sum / (n - lag);
      totalScore += score.abs();
      scoreCount++;
      if (score > bestScore) {
        bestScore = score;
        bestLag = lag;
      }
    }

    final avgScore = scoreCount == 0 ? 0 : totalScore / scoreCount;
    final confidence = avgScore == 0
        ? 0.0
        : ((bestScore - avgScore) / (bestScore.abs() + avgScore)).clamp(0.0, 1.0);

    final bpm = 60 * samplesPerSecond / bestLag;
    return BpmDetectionResult(bpm: bpm, confidence: confidence);
  }
}
