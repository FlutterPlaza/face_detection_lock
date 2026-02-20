import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:face_detection_lock/face_detection_lock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('FaceDetectionController state transitions', () {
    // -- FaceDetected ---------------------------------------------------------

    test('FaceDetected emits Success immediately when unlockDelay is zero',
        () async {
      final controller = FaceDetectionController(unlockDelay: Duration.zero);
      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [const FaceDetectionSuccess()]);
      sub.cancel();
      await controller.close();
    });

    test('FaceDetected with unlockDelay emits Success after delay', () async {
      final controller = FaceDetectionController(
        unlockDelay: const Duration(milliseconds: 50),
      );
      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states, [const FaceDetectionSuccess()]);
      sub.cancel();
      await controller.close();
    });

    test('duplicate FaceDetected when already Success emits nothing', () async {
      final controller = FaceDetectionController();
      // Seed: bring to Success state first.
      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, <FaceDetectionState>[]);
      sub.cancel();
      await controller.close();
    });

    // -- NoFaceDetected -------------------------------------------------------

    test('NoFaceDetected from Initial emits NoFace immediately', () async {
      final controller = FaceDetectionController();
      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateNoFace();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [const FaceDetectionNoFace()]);
      sub.cancel();
      await controller.close();
    });

    test('NoFaceDetected from Success with zero lockDelay emits NoFace',
        () async {
      final controller = FaceDetectionController(lockDelay: Duration.zero);
      // Seed: bring to Success state.
      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateNoFace();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [const FaceDetectionNoFace()]);
      sub.cancel();
      await controller.close();
    });

    test('NoFaceDetected from Success with lockDelay emits NoFace after delay',
        () async {
      final controller = FaceDetectionController(
        lockDelay: const Duration(milliseconds: 50),
      );
      // Seed: bring to Success state.
      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateNoFace();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states, [const FaceDetectionNoFace()]);
      sub.cancel();
      await controller.close();
    });

    test('duplicate NoFaceDetected when already NoFace emits nothing',
        () async {
      final controller = FaceDetectionController();
      // Seed: bring to NoFace state.
      controller.simulateNoFace();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateNoFace();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, <FaceDetectionState>[]);
      sub.cancel();
      await controller.close();
    });

    // -- Lock delay cancelled by FaceDetected ---------------------------------

    test(
        'FaceDetected cancels pending lock timer (face reappears during delay)',
        () async {
      final controller = FaceDetectionController(
        lockDelay: const Duration(milliseconds: 200),
      );
      // Seed: bring to Success state.
      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateNoFace(); // starts lock timer
      await Future<void>.delayed(const Duration(milliseconds: 50));
      controller.simulateFaceDetected(); // cancels lock timer
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Should NOT emit NoFace — the lock timer was cancelled.
      expect(states, <FaceDetectionState>[]);
      sub.cancel();
      await controller.close();
    });

    // -- Unlock delay cancelled by NoFaceDetected -----------------------------

    test('NoFaceDetected cancels pending unlock timer', () async {
      final controller = FaceDetectionController(
        unlockDelay: const Duration(milliseconds: 200),
      );
      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateFaceDetected(); // starts unlock timer
      await Future<void>.delayed(const Duration(milliseconds: 50));
      controller.simulateNoFace(); // cancels unlock timer
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Should emit NoFace (initial → noFace path, not success).
      expect(states, [const FaceDetectionNoFace()]);
      sub.cancel();
      await controller.close();
    });

    // -- Pause / Resume -------------------------------------------------------

    test('pause() emits Paused', () async {
      final controller = FaceDetectionController();
      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.pause();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [const FaceDetectionPaused()]);
      sub.cancel();
      await controller.close();
    });

    test('duplicate pause() emits nothing', () async {
      final controller = FaceDetectionController();
      // Seed: bring to Paused state.
      controller.pause();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.pause();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, <FaceDetectionState>[]);
      sub.cancel();
      await controller.close();
    });

    test('Pause then Resume restores previous state (Success)', () async {
      final controller = FaceDetectionController();
      // Seed: bring to Success state.
      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.pause();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      controller.resume();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const FaceDetectionPaused(),
        const FaceDetectionSuccess(),
      ]);
      sub.cancel();
      await controller.close();
    });

    test('Pause then Resume restores previous state (NoFace)', () async {
      final controller = FaceDetectionController();
      // Seed: bring to NoFace state.
      controller.simulateNoFace();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.pause();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      controller.resume();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const FaceDetectionPaused(),
        const FaceDetectionNoFace(),
      ]);
      sub.cancel();
      await controller.close();
    });

    // -- Full flow: face → no face → face -------------------------------------

    test('full cycle: face detected, face lost, face detected again', () async {
      final controller = FaceDetectionController(
        lockDelay: Duration.zero,
        unlockDelay: Duration.zero,
      );
      final states = <FaceDetectionState>[];
      final sub = controller.stream.listen(states.add);

      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller.simulateNoFace();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller.simulateFaceDetected();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const FaceDetectionSuccess(),
        const FaceDetectionNoFace(),
        const FaceDetectionSuccess(),
      ]);
      sub.cancel();
      await controller.close();
    });

    // -- Close ----------------------------------------------------------------

    test('close completes without error', () async {
      final controller = FaceDetectionController();
      await controller.close();
    });
  });
}
