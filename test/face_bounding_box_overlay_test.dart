import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:face_detection_lock/face_detection_lock.dart';

void main() {
  group('FaceBoundingBoxOverlay', () {
    Face makeFace({Rect? boundingBox, int? trackingId}) {
      return Face(
        boundingBox: boundingBox ?? const Rect.fromLTRB(50, 100, 200, 300),
        landmarks: const {},
        contours: const {},
        trackingId: trackingId,
      );
    }

    testWidgets('renders with empty face list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FaceBoundingBoxOverlay(
            faces: [],
            imageSize: Size(480, 640),
            widgetSize: Size(360, 480),
          ),
        ),
      );

      expect(find.byType(FaceBoundingBoxOverlay), findsOneWidget);
      // CustomPaint is a descendant of FaceBoundingBoxOverlay.
      expect(
        find.descendant(
          of: find.byType(FaceBoundingBoxOverlay),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders CustomPaint with mock faces', (tester) async {
      final faces = [
        makeFace(trackingId: 1),
        makeFace(
          boundingBox: const Rect.fromLTRB(250, 100, 400, 300),
          trackingId: 2,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: FaceBoundingBoxOverlay(
            faces: faces,
            imageSize: const Size(480, 640),
            widgetSize: const Size(360, 480),
          ),
        ),
      );

      expect(find.byType(FaceBoundingBoxOverlay), findsOneWidget);
    });

    test('default parameter values are green, 2.0, no labels, mirror=true',
        () {
      const overlay = FaceBoundingBoxOverlay(
        faces: [],
        imageSize: Size(480, 640),
        widgetSize: Size(360, 480),
      );

      expect(overlay.boxColor, Colors.green);
      expect(overlay.strokeWidth, 2.0);
      expect(overlay.showLabels, isFalse);
      expect(overlay.mirror, isTrue);
    });

    test('custom parameters are accepted', () {
      const overlay = FaceBoundingBoxOverlay(
        faces: [],
        imageSize: Size(1920, 1080),
        widgetSize: Size(400, 300),
        boxColor: Colors.red,
        strokeWidth: 4.0,
        showLabels: true,
        mirror: false,
      );

      expect(overlay.boxColor, Colors.red);
      expect(overlay.strokeWidth, 4.0);
      expect(overlay.showLabels, isTrue);
      expect(overlay.mirror, isFalse);
    });
  });
}
