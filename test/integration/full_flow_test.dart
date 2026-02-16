import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<FaceDetectionBloc>.value(
        value: mockBloc,
        child: const FaceDetectionLock(
          isBlocInitializeAbove: true,
          body: Text('BODY'),
        ),
      ),
    );
  }

  group('Integration: full flow tests', () {
    testWidgets('Full detection cycle: Initial → NoFace → Success → NoFace',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable(const [
          FaceDetectionInitial(),
          FaceDetectionNoFace(),
          FaceDetectionSuccess(),
          FaceDetectionNoFace(),
        ]),
        initialState: const FaceDetectionInitial(),
      );

      await tester.pumpWidget(buildSubject());
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
      whenListen(
        mockBloc,
        Stream.fromIterable(const [
          FaceDetectionInitial(),
          FaceDetectionUnverified(confidence: 0.3),
          FaceDetectionSuccess(),
        ]),
        initialState: const FaceDetectionInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Final state is Success — body should be visible.
      expect(find.text('BODY'), findsOneWidget);
    });

    testWidgets('Multi-face lockout: Success → TooManyFaces', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable(const [
          FaceDetectionSuccess(),
          FaceDetectionTooManyFaces(count: 3),
        ]),
        initialState: const FaceDetectionInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('Too many faces detected. Screen is locked.'),
        findsOneWidget,
      );
      expect(find.text('BODY'), findsNothing);
    });

    testWidgets('Pause/resume: Success → Paused → Success', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable(const [
          FaceDetectionSuccess(),
          FaceDetectionPaused(),
          FaceDetectionSuccess(),
        ]),
        initialState: const FaceDetectionInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Final state is Success — body should be restored.
      expect(find.text('BODY'), findsOneWidget);
    });

    testWidgets('Permission denied: Initial → PermissionDenied',
        (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable(const [
          FaceDetectionInitial(),
          FaceDetectionPermissionDenied(),
        ]),
        initialState: const FaceDetectionInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Camera permission denied'),
        findsOneWidget,
      );
      expect(find.text('BODY'), findsNothing);
    });

    testWidgets('No camera: Initial → NoCameraOnDevice', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable(const [
          FaceDetectionInitial(),
          FaceDetectionNoCameraOnDevice(),
        ]),
        initialState: const FaceDetectionInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No camera detected on device'), findsOneWidget);
      expect(find.text('BODY'), findsNothing);
    });
  });
}
