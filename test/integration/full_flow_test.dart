import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:face_detection_lock/face_detection_lock.dart';

/// Hand-rolled mock that extends [ChangeNotifier] and provides a controllable
/// [state] and [stream] for widget tests.
class MockFaceDetectionController extends ChangeNotifier
    implements FaceDetectionController {
  FaceDetectionState _state = const FaceDetectionInitial();
  final StreamController<FaceDetectionState> _streamController =
      StreamController<FaceDetectionState>.broadcast();

  @override
  FaceDetectionState get state => _state;

  @override
  Stream<FaceDetectionState> get stream => _streamController.stream;

  void setState(FaceDetectionState newState) {
    _state = newState;
    _streamController.add(newState);
    notifyListeners();
  }

  void emitStates(List<FaceDetectionState> states) {
    for (final s in states) {
      setState(s);
    }
  }

  @override
  Future<void> close() async {
    await _streamController.close();
    dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late MockFaceDetectionController mockController;

  setUp(() {
    mockController = MockFaceDetectionController();
  });

  tearDown(() {
    mockController.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: FaceDetectionProvider(
        controller: mockController,
        child: const FaceDetectionLock(
          isControllerProvidedAbove: true,
          body: Text('BODY'),
        ),
      ),
    );
  }

  group('Integration: full flow tests', () {
    testWidgets('Full detection cycle: Initial → NoFace → Success → NoFace',
        (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      mockController.emitStates(const [
        FaceDetectionNoFace(),
        FaceDetectionSuccess(),
        FaceDetectionNoFace(),
      ]);
      await tester.pumpAndSettle();

      // Final state is NoFace — screen should be locked.
      expect(
        find.text('No face detected. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.text('BODY'), findsNothing);
    });

    testWidgets('Verification flow: Initial → Unverified → Success',
        (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      mockController.emitStates(const [
        FaceDetectionUnverified(confidence: 0.3),
        FaceDetectionSuccess(),
      ]);
      await tester.pumpAndSettle();

      // Final state is Success — body should be visible.
      expect(find.text('BODY'), findsOneWidget);
    });

    testWidgets('Multi-face lockout: Success → TooManyFaces', (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      mockController.emitStates(const [
        FaceDetectionSuccess(),
        FaceDetectionTooManyFaces(count: 3),
      ]);
      await tester.pumpAndSettle();

      expect(
        find.text('Too many faces detected. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.text('BODY'), findsNothing);
    });

    testWidgets('Pause/resume: Success → Paused → Success', (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      mockController.emitStates(const [
        FaceDetectionSuccess(),
        FaceDetectionPaused(),
        FaceDetectionSuccess(),
      ]);
      await tester.pumpAndSettle();

      // Final state is Success — body should be restored.
      expect(find.text('BODY'), findsOneWidget);
    });

    testWidgets('Permission denied: Initial → PermissionDenied',
        (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      mockController.emitStates(const [
        FaceDetectionPermissionDenied(),
      ]);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Camera permission denied'),
        findsOneWidget,
      );
      expect(find.text('BODY'), findsNothing);
    });

    testWidgets('No camera: Initial → NoCameraOnDevice', (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      mockController.emitStates(const [
        FaceDetectionNoCameraOnDevice(),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('No camera detected on device'), findsOneWidget);
      expect(find.text('BODY'), findsNothing);
    });
  });
}
