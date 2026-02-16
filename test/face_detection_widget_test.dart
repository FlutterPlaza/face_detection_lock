import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:face_detection_lock/face_detection_lock.dart';

class MockFaceDetectionBloc
    extends MockBloc<FaceDetectionEvent, FaceDetectionState>
    implements FaceDetectionBloc {}

void main() {
  late MockFaceDetectionBloc mockBloc;

  setUp(() {
    mockBloc = MockFaceDetectionBloc();
  });

  tearDown(() {
    mockBloc.close();
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
      home: BlocProvider<FaceDetectionBloc>.value(
        value: mockBloc,
        child: FaceDetectionLock(
          isBlocInitializeAbove: true,
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
      when(() => mockBloc.state).thenReturn(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject());

      expect(find.text('Initializing Camera...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Initial state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const FaceDetectionInitial());
      await tester.pumpWidget(buildSubject(
        initializingCameraScreen: const Text('CUSTOM LOADING'),
      ));

      expect(find.text('CUSTOM LOADING'), findsOneWidget);
      expect(find.text('Initializing Camera...'), findsNothing);
    });

    testWidgets('Success state shows body', (tester) async {
      when(() => mockBloc.state).thenReturn(const FaceDetectionSuccess());
      await tester.pumpWidget(buildSubject());

      expect(find.text('BODY'), findsOneWidget);
    });

    testWidgets('NoFace state shows default lock screen', (tester) async {
      when(() => mockBloc.state).thenReturn(const FaceDetectionNoFace());
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('No face detected. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('NoFace state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const FaceDetectionNoFace());
      await tester.pumpWidget(buildSubject(
        noFaceLockScreen: const Text('CUSTOM LOCK'),
      ));

      expect(find.text('CUSTOM LOCK'), findsOneWidget);
    });

    testWidgets('Paused state shows default paused screen', (tester) async {
      when(() => mockBloc.state).thenReturn(const FaceDetectionPaused());
      await tester.pumpWidget(buildSubject());

      expect(find.text('Detection paused.'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    });

    testWidgets('Paused state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const FaceDetectionPaused());
      await tester.pumpWidget(buildSubject(
        pausedScreen: const Text('CUSTOM PAUSED'),
      ));

      expect(find.text('CUSTOM PAUSED'), findsOneWidget);
    });

    testWidgets('NoCameraOnDevice state shows error', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionNoCameraOnDevice());
      await tester.pumpWidget(buildSubject());

      expect(find.text('No camera detected on device'), findsOneWidget);
      expect(find.byIcon(Icons.no_photography_outlined), findsOneWidget);
    });

    testWidgets('NoCameraOnDevice state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionNoCameraOnDevice());
      await tester.pumpWidget(buildSubject(
        noCameraDetectedErrorScreen: const Text('NO CAM'),
      ));

      expect(find.text('NO CAM'), findsOneWidget);
    });

    testWidgets('PermissionDenied state shows permission screen',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionPermissionDenied());
      await tester.pumpWidget(buildSubject());

      expect(find.textContaining('Camera permission denied'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('PermissionDenied state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionPermissionDenied());
      await tester.pumpWidget(buildSubject(
        permissionDeniedScreen: const Text('CUSTOM PERM'),
      ));

      expect(find.text('CUSTOM PERM'), findsOneWidget);
    });

    testWidgets('Unverified state shows default unverified screen',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionUnverified(confidence: 0.3));
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('Face not recognized. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);
    });

    testWidgets('Unverified state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionUnverified(confidence: 0.3));
      await tester.pumpWidget(buildSubject(
        unverifiedScreen: const Text('CUSTOM UNVERIFIED'),
      ));

      expect(find.text('CUSTOM UNVERIFIED'), findsOneWidget);
    });

    testWidgets('InitializationFailed state shows error with message',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionInitializationFailed('Oops'));
      await tester.pumpWidget(buildSubject());

      expect(find.textContaining('Oops'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('InitializationFailed state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionInitializationFailed('Oops'));
      await tester.pumpWidget(buildSubject(
        errorScreen: (msg) => Text('ERR: $msg'),
      ));

      expect(find.text('ERR: Oops'), findsOneWidget);
    });

    testWidgets('TooManyFaces state shows default screen', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionTooManyFaces(count: 3));
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('Too many faces detected. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
    });

    testWidgets('TooManyFaces state shows custom screen when provided',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const FaceDetectionTooManyFaces(count: 3));
      await tester.pumpWidget(buildSubject(
        tooManyFacesScreen: const Text('CUSTOM TOO MANY'),
      ));

      expect(find.text('CUSTOM TOO MANY'), findsOneWidget);
    });

    // -- State transitions ----------------------------------------------------

    testWidgets('transitions from NoFace to Success shows body',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const FaceDetectionNoFace(),
          const FaceDetectionSuccess(),
        ]),
        initialState: const FaceDetectionInitial(),
      );
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('BODY'), findsOneWidget);
    });
  });
}
