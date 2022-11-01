import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:face_detection_lock/face_detection_lock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('FaceDetectionLock can be initialized', () {
    final widget = FaceDetectionLock(
      isBlocInitializeAbove: true,
      body: Container(
        child: const Text('Hello World'),
      ),
    );
    // expect(widget,);
  });
}
