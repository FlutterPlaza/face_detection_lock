import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/face_template.dart';
import '../domain/face_template_store.dart';
import '../domain/face_verification_provider.dart';
import 'face_feature_extractor.dart';
import 'liveness_checker.dart';

/// On-device face verification using ML Kit face contours.
///
/// Extracts normalized contour features from detected faces and compares
/// them against enrolled templates using cosine similarity.
///
/// ```dart
/// final provider = LocalFaceVerificationProvider();
///
/// // Enroll (collect faces via onFaceSnapshot callback first)
/// final template = await provider.enroll('Owner', collectedFaces);
///
/// // Verify
/// final result = await provider.verify(detectedFace);
/// print(result.isMatch); // true if face matches an enrolled template
/// ```
class LocalFaceVerificationProvider implements FaceVerificationProvider {
  LocalFaceVerificationProvider({
    FaceTemplateStore? store,
    this.minMatchScore = 0.6,
    this.enableLiveness = true,
    LivenessChecker? livenessChecker,
  })  : store = store ?? InMemoryTemplateStore(),
        _livenessChecker = livenessChecker ?? const LivenessChecker();

  /// Template storage backend. Defaults to [InMemoryTemplateStore].
  final FaceTemplateStore store;

  /// Minimum cosine similarity score (0.0–1.0) to consider a match.
  final double minMatchScore;

  /// Whether to run liveness checks during verification.
  final bool enableLiveness;

  final LivenessChecker _livenessChecker;

  int _nextId = 0;

  @override
  Future<FaceVerificationResult> verify(Face face) async {
    final features = FaceFeatureExtractor.extractFeatures(face);
    if (features == null) {
      return const FaceVerificationResult(
        isMatch: false,
        confidence: 0.0,
      );
    }

    final templates = await store.getAll();
    if (templates.isEmpty) {
      // No enrolled templates — can't verify, treat as match
      // (detection-only mode when no templates exist).
      return const FaceVerificationResult(
        isMatch: true,
        confidence: 1.0,
      );
    }

    String? bestId;
    var bestScore = 0.0;

    for (final template in templates) {
      final score = FaceFeatureExtractor.cosineSimilarity(
        features,
        template.features,
      );
      if (score > bestScore) {
        bestScore = score;
        bestId = template.id;
      }
    }

    return FaceVerificationResult(
      isMatch: bestScore >= minMatchScore,
      confidence: bestScore.clamp(0.0, 1.0),
      matchedTemplateId: bestScore >= minMatchScore ? bestId : null,
    );
  }

  @override
  Future<FaceTemplate> enroll(String label, List<Face> samples) async {
    if (samples.isEmpty) {
      throw ArgumentError(
          'At least one face sample is required for enrollment');
    }

    final featureVectors = <List<double>>[];

    for (final face in samples) {
      final features = FaceFeatureExtractor.extractFeatures(face);
      if (features != null) {
        featureVectors.add(features);
      }
    }

    if (featureVectors.isEmpty) {
      throw StateError(
        'Could not extract features from any sample. '
        'Ensure ML Kit is configured with enableContours: true.',
      );
    }

    final averaged = FaceFeatureExtractor.averageFeatures(featureVectors);
    final id = 'face_${_nextId++}_${DateTime.now().millisecondsSinceEpoch}';

    final template = FaceTemplate(
      id: id,
      label: label,
      features: averaged,
    );

    await store.save(template);
    return template;
  }

  @override
  Future<void> deleteTemplate(String id) => store.delete(id);

  @override
  Future<List<FaceTemplate>> listTemplates() => store.getAll();

  @override
  Future<void> clearAll() => store.clear();

  @override
  Future<LivenessResult> checkLiveness(Face face) async {
    return _livenessChecker.check(face);
  }
}
