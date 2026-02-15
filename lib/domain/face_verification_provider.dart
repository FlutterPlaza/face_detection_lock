import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'face_template.dart';

/// Abstract interface for face verification.
///
/// Implement this to provide custom verification backends (cloud APIs,
/// different ML models, etc.). Use [LocalFaceVerificationProvider] for
/// the built-in on-device implementation.
abstract class FaceVerificationProvider {
  /// Verify a detected face against enrolled templates.
  Future<FaceVerificationResult> verify(Face face);

  /// Enroll a new face from multiple sample captures.
  ///
  /// [label] is a human-readable name (e.g. "Owner").
  /// [samples] should contain at least 3 face captures for accuracy.
  Future<FaceTemplate> enroll(String label, List<Face> samples);

  /// Delete an enrolled template by ID.
  Future<void> deleteTemplate(String id);

  /// List all enrolled templates.
  Future<List<FaceTemplate>> listTemplates();

  /// Delete all enrolled templates.
  Future<void> clearAll();

  /// Check a face for liveness (anti-spoofing).
  Future<LivenessResult> checkLiveness(Face face);
}
