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

  // Stubs for all remaining FaceDetectionController members.
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

  Widget buildSubject({
    Widget? noFaceLockScreen,
    Widget? noCameraDetectedErrorScreen,
    Widget? initializingCameraScreen,
    Widget? permissionDeniedScreen,
    Widget? pausedScreen,
    Widget? unverifiedScreen,
    Widget? tooManyFacesScreen,
    Widget Function(String)? errorScreen,
  }) {
    return MaterialApp(
      home: FaceDetectionProvider(
        controller: mockController,
        child: FaceDetectionLock(
          isControllerProvidedAbove: true,
          body: const Text('BODY'),
          noFaceLockScreen: noFaceLockScreen,
          noCameraDetectedErrorScreen: noCameraDetectedErrorScreen,
          initializingCameraScreen: initializingCameraScreen,
          permissionDeniedScreen: permissionDeniedScreen,
          pausedScreen: pausedScreen,
          unverifiedScreen: unverifiedScreen,
          tooManyFacesScreen: tooManyFacesScreen,
          errorScreen: errorScreen,
        ),
      ),
    );
  }

  group('FaceDetectionLock widget states', () {
    testWidgets('Initial state shows loading indicator', (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      expect(find.text('Initializing Camera...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Initial state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject(
        initializingCameraScreen: const Text('CUSTOM LOADING'),
      ));

      expect(find.text('CUSTOM LOADING'), findsOneWidget);
      expect(find.text('Initializing Camera...'), findsNothing);
    });

    testWidgets('Success state shows body', (tester) async {
      mockController.setState(const FaceDetectionSuccess());
      await tester.pumpWidget(buildSubject());

      expect(find.text('BODY'), findsOneWidget);
    });

    testWidgets('NoFace state shows default lock screen', (tester) async {
      mockController.setState(const FaceDetectionNoFace());
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('No face detected. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('NoFace state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionNoFace());
      await tester.pumpWidget(buildSubject(
        noFaceLockScreen: const Text('CUSTOM LOCK'),
      ));

      expect(find.text('CUSTOM LOCK'), findsOneWidget);
    });

    testWidgets('Paused state shows default paused screen', (tester) async {
      mockController.setState(const FaceDetectionPaused());
      await tester.pumpWidget(buildSubject());

      expect(find.text('Detection paused.'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    });

    testWidgets('Paused state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionPaused());
      await tester.pumpWidget(buildSubject(
        pausedScreen: const Text('CUSTOM PAUSED'),
      ));

      expect(find.text('CUSTOM PAUSED'), findsOneWidget);
    });

    testWidgets('NoCameraOnDevice state shows error', (tester) async {
      mockController.setState(const FaceDetectionNoCameraOnDevice());
      await tester.pumpWidget(buildSubject());

      expect(find.text('No camera detected on device'), findsOneWidget);
      expect(find.byIcon(Icons.no_photography_outlined), findsOneWidget);
    });

    testWidgets('NoCameraOnDevice state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionNoCameraOnDevice());
      await tester.pumpWidget(buildSubject(
        noCameraDetectedErrorScreen: const Text('NO CAM'),
      ));

      expect(find.text('NO CAM'), findsOneWidget);
    });

    testWidgets('PermissionDenied state shows permission screen',
        (tester) async {
      mockController.setState(const FaceDetectionPermissionDenied());
      await tester.pumpWidget(buildSubject());

      expect(find.textContaining('Camera permission denied'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('PermissionDenied state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionPermissionDenied());
      await tester.pumpWidget(buildSubject(
        permissionDeniedScreen: const Text('CUSTOM PERM'),
      ));

      expect(find.text('CUSTOM PERM'), findsOneWidget);
    });

    testWidgets('Unverified state shows default unverified screen',
        (tester) async {
      mockController.setState(const FaceDetectionUnverified(confidence: 0.3));
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('Face not recognized. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);
    });

    testWidgets('Unverified state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionUnverified(confidence: 0.3));
      await tester.pumpWidget(buildSubject(
        unverifiedScreen: const Text('CUSTOM UNVERIFIED'),
      ));

      expect(find.text('CUSTOM UNVERIFIED'), findsOneWidget);
    });

    testWidgets('InitializationFailed state shows error with message',
        (tester) async {
      mockController.setState(const FaceDetectionInitializationFailed('Oops'));
      await tester.pumpWidget(buildSubject());

      expect(find.textContaining('Oops'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('InitializationFailed state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionInitializationFailed('Oops'));
      await tester.pumpWidget(buildSubject(
        errorScreen: (msg) => Text('ERR: $msg'),
      ));

      expect(find.text('ERR: Oops'), findsOneWidget);
    });

    testWidgets('TooManyFaces state shows default screen', (tester) async {
      mockController.setState(const FaceDetectionTooManyFaces(count: 3));
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('Too many faces detected. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
    });

    testWidgets('TooManyFaces state shows custom screen when provided',
        (tester) async {
      mockController.setState(const FaceDetectionTooManyFaces(count: 3));
      await tester.pumpWidget(buildSubject(
        tooManyFacesScreen: const Text('CUSTOM TOO MANY'),
      ));

      expect(find.text('CUSTOM TOO MANY'), findsOneWidget);
    });

    // -- State transitions ----------------------------------------------------

    testWidgets('transitions from NoFace to Success shows body',
        (tester) async {
      mockController.setState(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      mockController.emitStates(const [
        FaceDetectionNoFace(),
        FaceDetectionSuccess(),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('BODY'), findsOneWidget);
    });
  });
}
