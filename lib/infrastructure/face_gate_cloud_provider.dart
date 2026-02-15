import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;

import '../domain/face_template.dart';
import '../domain/face_verification_provider.dart';
import 'face_feature_extractor.dart';
import 'liveness_checker.dart';

/// A [FaceVerificationProvider] that delegates verification and template
/// storage to a remote REST API (e.g. `face_gate_cloud`).
///
/// Face features are extracted on-device using [FaceFeatureExtractor] and
/// sent as numeric vectors to the backend. The backend performs matching
/// and stores templates.
///
/// ```dart
/// final provider = FaceGateCloudProvider(
///   baseUrl: 'https://api.facegate.example.com',
///   apiKey: 'your-api-key',
/// );
///
/// // Use standalone
/// final result = await provider.verify(detectedFace);
///
/// // Or inject into the lock widget via BLoC
/// FaceDetectionBloc(verificationProvider: provider);
/// ```
///
/// ## Implementing a custom backend
///
/// Any HTTP server that conforms to the following contract will work:
///
/// | Method | Path | Body | Response |
/// |--------|------|------|----------|
/// | POST | /api/v1/verify | `{"features": [...]}` | `{"isMatch": bool, "confidence": double, "matchedTemplateId": string?}` |
/// | POST | /api/v1/enroll | `{"label": string, "features": [...]}` | `{"id": string, "label": string, "features": [...], "createdAt": string}` |
/// | GET | /api/v1/templates | — | `[{"id": ..., "label": ..., ...}, ...]` |
/// | DELETE | /api/v1/templates/{id} | — | 204 |
/// | DELETE | /api/v1/templates | — | 204 |
/// | GET | /api/v1/health | — | `{"status": "ok"}` |
class FaceGateCloudProvider implements FaceVerificationProvider {
  FaceGateCloudProvider({
    required this.baseUrl,
    this.apiKey,
    this.timeout = const Duration(seconds: 10),
    this.retryCount = 1,
    this.basePath = '/api/v1',
    http.Client? httpClient,
    LivenessChecker? livenessChecker,
  })  : _client = httpClient ?? http.Client(),
        _livenessChecker = livenessChecker ?? const LivenessChecker(),
        _ownsClient = httpClient == null;

  /// Base URL of the face verification API (e.g. `https://api.facegate.io`).
  final String baseUrl;

  /// Optional API key sent in the `Authorization` header as `Bearer`.
  final String? apiKey;

  /// HTTP request timeout. Defaults to 10 seconds.
  final Duration timeout;

  /// Number of retry attempts on transient failures (5xx, timeout).
  /// Defaults to 1 (one retry after initial failure).
  final int retryCount;

  /// Base path prefix for all API endpoints. Defaults to `/api/v1`.
  final String basePath;

  final http.Client _client;
  final LivenessChecker _livenessChecker;
  final bool _ownsClient;

  // -- FaceVerificationProvider -----------------------------------------------

  @override
  Future<FaceVerificationResult> verify(Face face) async {
    final features = _extractOrThrow(face);

    final body = await _post('/verify', {'features': features});

    return FaceVerificationResult(
      isMatch: body['isMatch'] as bool,
      confidence: (body['confidence'] as num).toDouble(),
      matchedTemplateId: body['matchedTemplateId'] as String?,
    );
  }

  @override
  Future<FaceTemplate> enroll(String label, List<Face> samples) async {
    if (samples.isEmpty) {
      throw ArgumentError('At least one face sample is required for enrollment');
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

    final body = await _post('/enroll', {
      'label': label,
      'features': averaged,
    });

    return FaceTemplate.fromJson(body);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _delete('/templates/$id');
  }

  @override
  Future<List<FaceTemplate>> listTemplates() async {
    final body = await _get('/templates');
    final list = body['templates'] as List;
    return list
        .map((e) => FaceTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearAll() async {
    await _delete('/templates');
  }

  @override
  Future<LivenessResult> checkLiveness(Face face) async {
    // Liveness is checked on-device — no need to send data to the cloud.
    return _livenessChecker.check(face);
  }

  // -- Health check -----------------------------------------------------------

  /// Check if the remote API is reachable and healthy.
  Future<bool> health() async {
    try {
      final body = await _get('/health');
      return body['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  // -- Cleanup ----------------------------------------------------------------

  /// Close the underlying HTTP client.
  ///
  /// Only closes the client if it was created internally. If you passed
  /// a custom [httpClient], you are responsible for closing it.
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  // -- HTTP helpers -----------------------------------------------------------

  List<double> _extractOrThrow(Face face) {
    final features = FaceFeatureExtractor.extractFeatures(face);
    if (features == null) {
      throw StateError(
        'Could not extract features from face. '
        'Ensure ML Kit is configured with enableContours: true.',
      );
    }
    return features;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$basePath$path');

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    return _withRetry(() async {
      final response = await _client
          .post(
            _uri(path),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(timeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> _get(String path) async {
    return _withRetry(() async {
      final response = await _client
          .get(_uri(path), headers: _headers)
          .timeout(timeout);
      return _handleResponse(response);
    });
  }

  Future<void> _delete(String path) async {
    await _withRetry(() async {
      final response = await _client
          .delete(_uri(path), headers: _headers)
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return <String, dynamic>{};
      }
      return _handleResponse(response);
    });
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw FaceGateCloudException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  Future<T> _withRetry<T>(Future<T> Function() fn) async {
    var lastError = Object();
    for (var attempt = 0; attempt <= retryCount; attempt++) {
      try {
        return await fn();
      } catch (e) {
        lastError = e;
        final isRetryable = _isRetryable(e);
        if (!isRetryable || attempt == retryCount) rethrow;
        debugPrint(
          'FaceGateCloud: attempt ${attempt + 1} failed, retrying: $e',
        );
      }
    }
    // Unreachable, but satisfies the type system.
    throw lastError;
  }

  bool _isRetryable(Object error) {
    if (error is FaceGateCloudException) {
      return error.statusCode >= 500;
    }
    // Timeout and network errors are retryable.
    return error is http.ClientException ||
        error.toString().contains('TimeoutException');
  }
}

/// Exception thrown when the face_gate_cloud API returns an error.
class FaceGateCloudException implements Exception {
  const FaceGateCloudException({
    required this.statusCode,
    required this.message,
  });

  /// HTTP status code returned by the API.
  final int statusCode;

  /// Error message from the API response body.
  final String message;

  @override
  String toString() => 'FaceGateCloudException($statusCode): $message';
}
