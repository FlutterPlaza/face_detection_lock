import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/face_template.dart';
import '../domain/face_verification_provider.dart';

/// A verification provider that tries a [primary] provider first and
/// falls back to [fallback] when the primary fails.
///
/// Useful for remote-first setups where the cloud provider should be
/// tried first, with on-device verification as a safety net:
///
/// ```dart
/// final provider = FallbackVerificationProvider(
///   primary: FaceGateCloudProvider(baseUrl: 'https://api.example.com'),
///   fallback: LocalFaceVerificationProvider(),
/// );
/// ```
class FallbackVerificationProvider implements FaceVerificationProvider {
  FallbackVerificationProvider({
    required this.primary,
    required this.fallback,
    this.onFallback,
  });

  /// The preferred provider tried first.
  final FaceVerificationProvider primary;

  /// The backup provider used when [primary] throws.
  final FaceVerificationProvider fallback;

  /// Optional callback invoked when the fallback is used.
  /// Receives the error and stack trace from the primary.
  ///
  /// **Privacy note:** The [error] object may contain PII (e.g. face
  /// template data or API response bodies). Do not log it in production
  /// or transmit it to external services without sanitization.
  final void Function(Object error, StackTrace stack)? onFallback;

  @override
  Future<FaceVerificationResult> verify(Face face) =>
      _withFallback(() => primary.verify(face), () => fallback.verify(face));

  @override
  Future<FaceTemplate> enroll(String label, List<Face> samples) =>
      _withFallback(
        () => primary.enroll(label, samples),
        () => fallback.enroll(label, samples),
      );

  @override
  Future<void> deleteTemplate(String id) => _withFallback(
        () => primary.deleteTemplate(id),
        () => fallback.deleteTemplate(id),
      );

  @override
  Future<List<FaceTemplate>> listTemplates() => _withFallback(
        () => primary.listTemplates(),
        () => fallback.listTemplates(),
      );

  @override
  Future<void> clearAll() => _withFallback(
        () => primary.clearAll(),
        () => fallback.clearAll(),
      );

  @override
  Future<LivenessResult> checkLiveness(Face face) => _withFallback(
        () => primary.checkLiveness(face),
        () => fallback.checkLiveness(face),
      );

  Future<T> _withFallback<T>(
    Future<T> Function() primaryFn,
    Future<T> Function() fallbackFn,
  ) async {
    try {
      return await primaryFn();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Primary provider failed, using fallback');
      }
      onFallback?.call(e, stack);
      return fallbackFn();
    }
  }
}
