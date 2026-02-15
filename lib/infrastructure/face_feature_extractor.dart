import 'dart:math';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Extracts a normalized feature vector from ML Kit face contour data.
///
/// Contour points are normalized to the face bounding box (0.0–1.0 range)
/// so features are scale- and position-invariant.
class FaceFeatureExtractor {
  /// Ordered contour types used for feature extraction.
  /// The order is fixed so feature vectors are always aligned.
  static const _contourTypes = [
    FaceContourType.face,
    FaceContourType.leftEyebrowTop,
    FaceContourType.leftEyebrowBottom,
    FaceContourType.rightEyebrowTop,
    FaceContourType.rightEyebrowBottom,
    FaceContourType.leftEye,
    FaceContourType.rightEye,
    FaceContourType.upperLipTop,
    FaceContourType.upperLipBottom,
    FaceContourType.lowerLipTop,
    FaceContourType.lowerLipBottom,
    FaceContourType.noseBridge,
    FaceContourType.noseBottom,
    FaceContourType.leftCheek,
    FaceContourType.rightCheek,
  ];

  /// Extract a normalized feature vector from a [Face].
  ///
  /// Returns null if the face has no contour data (ensure ML Kit is configured
  /// with `enableContours: true`).
  static List<double>? extractFeatures(Face face) {
    final box = face.boundingBox;
    if (box.width == 0 || box.height == 0) return null;

    final features = <double>[];

    for (final type in _contourTypes) {
      final contour = face.contours[type];
      if (contour == null) return null;

      for (final point in contour.points) {
        // Normalize to 0.0–1.0 relative to bounding box.
        features.add((point.x - box.left) / box.width);
        features.add((point.y - box.top) / box.height);
      }
    }

    if (features.isEmpty) return null;
    return features;
  }

  /// Average multiple feature vectors element-wise.
  ///
  /// Used during enrollment to create a stable template from multiple samples.
  static List<double> averageFeatures(List<List<double>> vectors) {
    if (vectors.isEmpty) return [];
    if (vectors.length == 1) return List.of(vectors.first);

    final length = vectors.first.length;
    final averaged = List<double>.filled(length, 0.0);

    for (final vec in vectors) {
      for (var i = 0; i < length; i++) {
        averaged[i] += vec[i];
      }
    }

    final count = vectors.length.toDouble();
    for (var i = 0; i < length; i++) {
      averaged[i] /= count;
    }

    return averaged;
  }

  /// Compute cosine similarity between two feature vectors.
  ///
  /// Returns a value between -1.0 and 1.0, where 1.0 means identical.
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;

    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;

    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    final denominator = sqrt(normA) * sqrt(normB);
    if (denominator == 0) return 0.0;

    return dot / denominator;
  }
}
