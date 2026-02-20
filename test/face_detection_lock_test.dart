import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:face_detection_lock/face_detection_lock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Widget tests
  // ---------------------------------------------------------------------------
  group('FaceDetectionLock', () {
    test('can be instantiated with defaults', () {
      const widget = FaceDetectionLock(
        isControllerProvidedAbove: true,
        body: Text('Hello World'),
      );
      expect(widget, isNotNull);
      expect(widget.isControllerProvidedAbove, isTrue);
      expect(widget.enableHapticFeedback, isFalse);
      expect(widget.transitionDuration, const Duration(milliseconds: 300));
      expect(widget.unverifiedScreen, isNull);
      expect(widget.verificationProvider, isNull);
    });

    test('accepts custom transition and haptic settings', () {
      const widget = FaceDetectionLock(
        body: Text('Secure'),
        transitionDuration: Duration(milliseconds: 500),
        enableHapticFeedback: true,
      );
      expect(widget.transitionDuration, const Duration(milliseconds: 500));
      expect(widget.enableHapticFeedback, isTrue);
    });

    test('accepts unverifiedScreen parameter', () {
      const widget = FaceDetectionLock(
        body: Text('Main'),
        unverifiedScreen: Text('Not recognized'),
      );
      expect(widget.unverifiedScreen, isNotNull);
    });

    test('accepts verificationProvider parameter', () {
      final provider = LocalFaceVerificationProvider();
      final widget = FaceDetectionLock(
        body: const Text('Secure'),
        verificationProvider: provider,
      );
      expect(widget.verificationProvider, same(provider));
    });

    test('accepts maxFaces and multiFacePolicy parameters', () {
      const widget = FaceDetectionLock(
        body: Text('Secure'),
        maxFaces: 1,
        multiFacePolicy: MultiFacePolicy.unlockIfAllMatch,
      );
      expect(widget.maxFaces, 1);
      expect(widget.multiFacePolicy, MultiFacePolicy.unlockIfAllMatch);
    });

    test('accepts tooManyFacesScreen parameter', () {
      const widget = FaceDetectionLock(
        body: Text('Main'),
        tooManyFacesScreen: Text('Too many'),
      );
      expect(widget.tooManyFacesScreen, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Controller tests
  // ---------------------------------------------------------------------------
  group('FaceDetectionController', () {
    test('can be instantiated with defaults', () {
      final controller = FaceDetectionController();
      expect(controller.state, isA<FaceDetectionInitial>());
      expect(controller.detectionInterval, const Duration(milliseconds: 300));
      expect(controller.lockDelay, const Duration(milliseconds: 500));
      expect(controller.unlockDelay, Duration.zero);
      expect(controller.minFaceSize, 0.15);
      expect(controller.resolution, ResolutionPreset.low);
      expect(controller.verificationProvider, isNull);
      expect(controller.enableLiveness, isTrue);
      controller.close();
    });

    test('can be instantiated with custom performance settings', () {
      final controller = FaceDetectionController(
        detectionInterval: const Duration(milliseconds: 100),
        lockDelay: const Duration(seconds: 2),
        unlockDelay: const Duration(milliseconds: 200),
        minFaceSize: 0.3,
        resolution: ResolutionPreset.medium,
      );
      expect(controller.detectionInterval, const Duration(milliseconds: 100));
      expect(controller.lockDelay, const Duration(seconds: 2));
      expect(controller.unlockDelay, const Duration(milliseconds: 200));
      expect(controller.minFaceSize, 0.3);
      expect(controller.resolution, ResolutionPreset.medium);
      controller.close();
    });

    test('initial state is FaceDetectionInitial', () {
      final controller = FaceDetectionController();
      expect(controller.state, isA<FaceDetectionInitial>());
      controller.close();
    });

    test('accepts verificationProvider parameter', () {
      final provider = LocalFaceVerificationProvider();
      final controller = FaceDetectionController(
        verificationProvider: provider,
        enableLiveness: false,
      );
      expect(controller.verificationProvider, same(provider));
      expect(controller.enableLiveness, isFalse);
      controller.close();
    });

    test('accepts maxFaces and multiFacePolicy parameters', () {
      final controller = FaceDetectionController(
        maxFaces: 1,
        multiFacePolicy: MultiFacePolicy.unlockIfAnyMatch,
      );
      expect(controller.maxFaces, 1);
      expect(controller.multiFacePolicy, MultiFacePolicy.unlockIfAnyMatch);
      controller.close();
    });

    test('maxFaces defaults to null and multiFacePolicy to lockIfMultiple', () {
      final controller = FaceDetectionController();
      expect(controller.maxFaces, isNull);
      expect(controller.multiFacePolicy, MultiFacePolicy.lockIfMultiple);
      controller.close();
    });

    test('accepts battery-aware parameters', () {
      final controller = FaceDetectionController(
        batteryAwareMode: true,
        batteryThreshold: 30,
        lowBatteryDetectionInterval: const Duration(milliseconds: 2000),
      );
      expect(controller.batteryAwareMode, isTrue);
      expect(controller.batteryThreshold, 30);
      expect(
        controller.lowBatteryDetectionInterval,
        const Duration(milliseconds: 2000),
      );
      controller.close();
    });

    test('battery-aware defaults are off with threshold 20 and 1000ms', () {
      final controller = FaceDetectionController();
      expect(controller.batteryAwareMode, isFalse);
      expect(controller.batteryThreshold, 20);
      expect(
        controller.lowBatteryDetectionInterval,
        const Duration(milliseconds: 1000),
      );
      controller.close();
    });
  });

  // ---------------------------------------------------------------------------
  // Domain model tests
  // ---------------------------------------------------------------------------
  group('FaceTemplate', () {
    test('can be created and serialized to JSON', () {
      final template = FaceTemplate(
        id: 'test_1',
        label: 'Alice',
        features: [0.1, 0.2, 0.3],
      );
      expect(template.id, 'test_1');
      expect(template.label, 'Alice');
      expect(template.features, [0.1, 0.2, 0.3]);
      expect(template.createdAt, isNotNull);

      final json = template.toJson();
      expect(json['id'], 'test_1');
      expect(json['label'], 'Alice');
    });

    test('can be deserialized from JSON', () {
      final json = {
        'id': 'test_2',
        'label': 'Bob',
        'features': [0.4, 0.5, 0.6],
        'createdAt': '2025-01-01T00:00:00.000',
      };
      final template = FaceTemplate.fromJson(json);
      expect(template.id, 'test_2');
      expect(template.label, 'Bob');
      expect(template.features, [0.4, 0.5, 0.6]);
    });
  });

  group('FaceVerificationResult', () {
    test('holds match data', () {
      const result = FaceVerificationResult(
        isMatch: true,
        confidence: 0.95,
        matchedTemplateId: 'tmpl_1',
      );
      expect(result.isMatch, isTrue);
      expect(result.confidence, 0.95);
      expect(result.matchedTemplateId, 'tmpl_1');
    });

    test('holds no-match data', () {
      const result = FaceVerificationResult(
        isMatch: false,
        confidence: 0.3,
      );
      expect(result.isMatch, isFalse);
      expect(result.matchedTemplateId, isNull);
    });
  });

  group('LivenessResult', () {
    test('live result', () {
      const result = LivenessResult(isLive: true);
      expect(result.isLive, isTrue);
      expect(result.reason, isNull);
    });

    test('not live with reason', () {
      const result = LivenessResult(
        isLive: false,
        reason: 'Eyes closed',
      );
      expect(result.isLive, isFalse);
      expect(result.reason, 'Eyes closed');
    });
  });

  // ---------------------------------------------------------------------------
  // Infrastructure tests
  // ---------------------------------------------------------------------------
  group('FaceFeatureExtractor', () {
    test('cosineSimilarity returns 1.0 for identical vectors', () {
      final v = [1.0, 2.0, 3.0];
      final score = FaceFeatureExtractor.cosineSimilarity(v, v);
      expect(score, closeTo(1.0, 1e-10));
    });

    test('cosineSimilarity returns 0.0 for orthogonal vectors', () {
      final a = [1.0, 0.0];
      final b = [0.0, 1.0];
      final score = FaceFeatureExtractor.cosineSimilarity(a, b);
      expect(score, closeTo(0.0, 1e-10));
    });

    test('cosineSimilarity returns 0.0 for empty vectors', () {
      final score = FaceFeatureExtractor.cosineSimilarity([], []);
      expect(score, 0.0);
    });

    test('cosineSimilarity returns 0.0 for mismatched lengths', () {
      final score = FaceFeatureExtractor.cosineSimilarity([1.0], [1.0, 2.0]);
      expect(score, 0.0);
    });

    test('averageFeatures with single vector returns copy', () {
      final vectors = [
        [1.0, 2.0, 3.0]
      ];
      final result = FaceFeatureExtractor.averageFeatures(vectors);
      expect(result, [1.0, 2.0, 3.0]);
      // Should be a copy, not the same list.
      expect(identical(result, vectors.first), isFalse);
    });

    test('averageFeatures computes element-wise mean', () {
      final vectors = [
        [2.0, 4.0],
        [4.0, 6.0],
      ];
      final result = FaceFeatureExtractor.averageFeatures(vectors);
      expect(result, [3.0, 5.0]);
    });

    test('averageFeatures returns empty for empty input', () {
      final result = FaceFeatureExtractor.averageFeatures([]);
      expect(result, isEmpty);
    });
  });

  group('InMemoryTemplateStore', () {
    late InMemoryTemplateStore store;

    setUp(() {
      store = InMemoryTemplateStore();
    });

    test('save and retrieve', () async {
      final template = FaceTemplate(
        id: 't1',
        label: 'Test',
        features: [0.1, 0.2],
      );
      await store.save(template);
      final retrieved = await store.get('t1');
      expect(retrieved, isNotNull);
      expect(retrieved!.label, 'Test');
    });

    test('getAll returns all templates', () async {
      await store.save(
        FaceTemplate(id: 'a', label: 'A', features: [1.0]),
      );
      await store.save(
        FaceTemplate(id: 'b', label: 'B', features: [2.0]),
      );
      final all = await store.getAll();
      expect(all.length, 2);
    });

    test('delete removes template', () async {
      await store.save(
        FaceTemplate(id: 'x', label: 'X', features: [1.0]),
      );
      await store.delete('x');
      expect(await store.get('x'), isNull);
    });

    test('clear removes all templates', () async {
      await store.save(
        FaceTemplate(id: 'a', label: 'A', features: [1.0]),
      );
      await store.save(
        FaceTemplate(id: 'b', label: 'B', features: [2.0]),
      );
      await store.clear();
      expect(await store.getAll(), isEmpty);
    });
  });

  group('LocalFaceVerificationProvider', () {
    test('verify returns match when no templates enrolled', () async {
      final provider = LocalFaceVerificationProvider();
      final templates = await provider.listTemplates();
      expect(templates, isEmpty);
    });

    test('enroll throws on empty samples', () {
      final provider = LocalFaceVerificationProvider();
      expect(
        () => provider.enroll('Test', []),
        throwsArgumentError,
      );
    });

    test('deleteTemplate and clearAll work', () async {
      final provider = LocalFaceVerificationProvider();
      expect(await provider.listTemplates(), isEmpty);
      await provider.clearAll();
      expect(await provider.listTemplates(), isEmpty);
    });
  });

  group('LivenessChecker', () {
    test('can be instantiated with defaults', () {
      const checker = LivenessChecker();
      expect(checker.minEyeOpenProbability, 0.4);
      expect(checker.maxHeadAngle, 20.0);
    });

    test('can be instantiated with custom thresholds', () {
      const checker = LivenessChecker(
        minEyeOpenProbability: 0.6,
        maxHeadAngle: 15.0,
      );
      expect(checker.minEyeOpenProbability, 0.6);
      expect(checker.maxHeadAngle, 15.0);
    });
  });

  // ---------------------------------------------------------------------------
  // SecureTemplateStore tests
  // ---------------------------------------------------------------------------
  group('SecureTemplateStore', () {
    late _FakeSecureStorage fakeStorage;
    late SecureTemplateStore store;

    setUp(() {
      fakeStorage = _FakeSecureStorage();
      store = SecureTemplateStore(storage: fakeStorage);
    });

    test('save and retrieve a template', () async {
      final template = FaceTemplate(
        id: 't1',
        label: 'Alice',
        features: [0.1, 0.2, 0.3],
      );
      await store.save(template);

      final retrieved = await store.get('t1');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 't1');
      expect(retrieved.label, 'Alice');
      expect(retrieved.features, [0.1, 0.2, 0.3]);
    });

    test('get returns null for missing template', () async {
      final result = await store.get('nonexistent');
      expect(result, isNull);
    });

    test('getAll returns all saved templates', () async {
      await store.save(FaceTemplate(id: 'a', label: 'A', features: [1.0]));
      await store.save(FaceTemplate(id: 'b', label: 'B', features: [2.0]));

      final all = await store.getAll();
      expect(all.length, 2);
      expect(all.map((t) => t.id).toSet(), {'a', 'b'});
    });

    test('save overwrites existing template', () async {
      await store.save(FaceTemplate(id: 'x', label: 'Old', features: [1.0]));
      await store.save(FaceTemplate(id: 'x', label: 'New', features: [2.0]));

      final all = await store.getAll();
      expect(all.length, 1);
      expect(all.first.label, 'New');
    });

    test('delete removes a template', () async {
      await store.save(FaceTemplate(id: 'x', label: 'X', features: [1.0]));
      await store.delete('x');

      expect(await store.get('x'), isNull);
      expect(await store.getAll(), isEmpty);
    });

    test('delete non-existent template is no-op', () async {
      await store.save(FaceTemplate(id: 'a', label: 'A', features: [1.0]));
      await store.delete('nonexistent');

      final all = await store.getAll();
      expect(all.length, 1);
    });

    test('clear removes all templates', () async {
      await store.save(FaceTemplate(id: 'a', label: 'A', features: [1.0]));
      await store.save(FaceTemplate(id: 'b', label: 'B', features: [2.0]));
      await store.clear();

      expect(await store.getAll(), isEmpty);
      expect(await store.get('a'), isNull);
      expect(await store.get('b'), isNull);
    });

    test('preserves template createdAt through round-trip', () async {
      final date = DateTime(2025, 6, 15, 12, 30);
      final template = FaceTemplate(
        id: 'dt',
        label: 'Date Test',
        features: [1.0, 2.0],
        createdAt: date,
      );
      await store.save(template);

      final retrieved = await store.get('dt');
      expect(retrieved!.createdAt, date);
    });
  });

  // ---------------------------------------------------------------------------
  // FallbackVerificationProvider tests
  // ---------------------------------------------------------------------------
  group('FallbackVerificationProvider', () {
    test('can be instantiated with two providers', () {
      final primary = LocalFaceVerificationProvider();
      final fallback = LocalFaceVerificationProvider();
      final provider = FallbackVerificationProvider(
        primary: primary,
        fallback: fallback,
      );
      expect(provider.primary, same(primary));
      expect(provider.fallback, same(fallback));
    });

    test('listTemplates uses fallback on primary failure', () async {
      final primary = _FailingProvider();
      final fallback = LocalFaceVerificationProvider();
      Object? capturedError;

      final provider = FallbackVerificationProvider(
        primary: primary,
        fallback: fallback,
        onFallback: (error, _) => capturedError = error,
      );

      final templates = await provider.listTemplates();
      expect(templates, isEmpty);
      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('intentional'));
    });

    test('clearAll uses fallback on primary failure', () async {
      final primary = _FailingProvider();
      final fallback = LocalFaceVerificationProvider();
      var fallbackCalled = false;

      final provider = FallbackVerificationProvider(
        primary: primary,
        fallback: fallback,
        onFallback: (_, __) => fallbackCalled = true,
      );

      await provider.clearAll();
      expect(fallbackCalled, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // FaceGateCloudProvider tests
  // ---------------------------------------------------------------------------
  group('FaceGateCloudProvider', () {
    test('can be instantiated with required params', () {
      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
      );
      expect(provider.baseUrl, 'https://api.example.com');
      expect(provider.apiKey, isNull);
      expect(provider.timeout, const Duration(seconds: 10));
      expect(provider.retryCount, 1);
      expect(provider.basePath, '/api/v1');
      provider.close();
    });

    test('can be instantiated with all params', () {
      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key',
        timeout: const Duration(seconds: 5),
        retryCount: 3,
        basePath: '/v2',
      );
      expect(provider.apiKey, 'test-key');
      expect(provider.timeout, const Duration(seconds: 5));
      expect(provider.retryCount, 3);
      expect(provider.basePath, '/v2');
      provider.close();
    });

    test('health returns true on 200 with ok status', () async {
      final mockClient = MockClient((_) async {
        return http.Response('{"status": "ok"}', 200);
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(await provider.health(), isTrue);
      provider.close();
    });

    test('health returns false on error', () async {
      final mockClient = MockClient((_) async {
        return http.Response('Internal Server Error', 500);
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
        retryCount: 0,
      );

      expect(await provider.health(), isFalse);
      provider.close();
    });

    test('listTemplates parses response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/templates');
        return http.Response(
          jsonEncode({
            'templates': [
              {
                'id': 't1',
                'label': 'Alice',
                'features': [0.1, 0.2],
                'createdAt': '2025-01-01T00:00:00.000',
              },
            ],
          }),
          200,
        );
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      final templates = await provider.listTemplates();
      expect(templates.length, 1);
      expect(templates.first.id, 't1');
      expect(templates.first.label, 'Alice');
      provider.close();
    });

    test('deleteTemplate sends DELETE request', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/api/v1/templates/tmpl_42');
        return http.Response('', 204);
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      await provider.deleteTemplate('tmpl_42');
      provider.close();
    });

    test('clearAll sends DELETE to templates endpoint', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/api/v1/templates');
        return http.Response('', 204);
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      await provider.clearAll();
      provider.close();
    });

    test('sends Authorization header when apiKey is set', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer test-key-123');
        return http.Response('{"status": "ok"}', 200);
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key-123',
        httpClient: mockClient,
      );

      await provider.health();
      provider.close();
    });

    test('throws FaceGateCloudException on 4xx errors', () async {
      final mockClient = MockClient((_) async {
        return http.Response('{"error": "not found"}', 404);
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      expect(
        () => provider.listTemplates(),
        throwsA(isA<FaceGateCloudException>()),
      );
      provider.close();
    });

    test('FaceGateCloudException has statusCode and message', () {
      const exception = FaceGateCloudException(
        statusCode: 401,
        message: 'Unauthorized',
      );
      expect(exception.statusCode, 401);
      expect(exception.message, 'Unauthorized');
      expect(exception.toString(), contains('401'));
      expect(exception.toString(), contains('Unauthorized'));
    });

    test('error response contains generic status text, not raw body (4xx)',
        () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          '{"error": "detailed PII info about user@example.com"}',
          400,
        );
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
      );

      try {
        await provider.listTemplates();
        fail('Should have thrown');
      } on FaceGateCloudException catch (e) {
        expect(e.statusCode, 400);
        expect(e.message, 'Bad Request');
        expect(e.message, isNot(contains('user@example.com')));
      }
      provider.close();
    });

    test('error response contains generic status text, not raw body (5xx)',
        () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          'Internal stack trace with sensitive data',
          500,
        );
      });

      final provider = FaceGateCloudProvider(
        baseUrl: 'https://api.example.com',
        httpClient: mockClient,
        retryCount: 0,
      );

      try {
        await provider.listTemplates();
        fail('Should have thrown');
      } on FaceGateCloudException catch (e) {
        expect(e.statusCode, 500);
        expect(e.message, 'Server Error');
        expect(e.message, isNot(contains('stack trace')));
      }
      provider.close();
    });
  });

  // ---------------------------------------------------------------------------
  // State / Event tests
  // ---------------------------------------------------------------------------
  group('FaceDetectionState', () {
    test('FaceDetectionUnverified carries confidence', () {
      const state = FaceDetectionUnverified(confidence: 0.42);
      expect(state.confidence, 0.42);
    });

    test('FaceDetectionUnverified defaults confidence to 0.0', () {
      const state = FaceDetectionUnverified();
      expect(state.confidence, 0.0);
    });

    test('FaceDetectionTooManyFaces carries count', () {
      const state = FaceDetectionTooManyFaces(count: 5);
      expect(state.count, 5);
    });
  });

  group('MultiFacePolicy', () {
    test('has expected values', () {
      expect(MultiFacePolicy.values.length, 3);
      expect(MultiFacePolicy.lockIfMultiple, isNotNull);
      expect(MultiFacePolicy.unlockIfAnyMatch, isNotNull);
      expect(MultiFacePolicy.unlockIfAllMatch, isNotNull);
    });
  });
}

// -- Test helpers -------------------------------------------------------------

/// Fake in-memory implementation of [FlutterSecureStorage] for tests.
class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

/// A provider that always throws, used to test fallback behavior.
class _FailingProvider implements FaceVerificationProvider {
  @override
  Future<FaceVerificationResult> verify(Face face) =>
      throw Exception('intentional verify failure');

  @override
  Future<FaceTemplate> enroll(String label, List<Face> samples) =>
      throw Exception('intentional enroll failure');

  @override
  Future<void> deleteTemplate(String id) =>
      throw Exception('intentional delete failure');

  @override
  Future<List<FaceTemplate>> listTemplates() =>
      throw Exception('intentional listTemplates failure');

  @override
  Future<void> clearAll() => throw Exception('intentional clearAll failure');

  @override
  Future<LivenessResult> checkLiveness(Face face) =>
      throw Exception('intentional liveness failure');
}
