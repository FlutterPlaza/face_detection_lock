import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// A debug/enrollment overlay that draws bounding boxes around detected faces.
///
/// Place this widget on top of a camera preview using a [Stack]:
///
/// ```dart
/// Stack(
///   children: [
///     CameraPreview(controller),
///     FaceBoundingBoxOverlay(
///       faces: detectedFaces,
///       imageSize: Size(480, 640),
///       widgetSize: Size(screenWidth, screenHeight),
///     ),
///   ],
/// );
/// ```
class FaceBoundingBoxOverlay extends StatelessWidget {
  const FaceBoundingBoxOverlay({
    super.key,
    required this.faces,
    required this.imageSize,
    required this.widgetSize,
    this.boxColor = Colors.green,
    this.strokeWidth = 2.0,
    this.showLabels = false,
    this.mirror = true,
  });

  /// List of detected faces to draw bounding boxes for.
  final List<Face> faces;

  /// The size of the camera image in pixels.
  final Size imageSize;

  /// The size of this widget (the display area).
  final Size widgetSize;

  /// Color of the bounding box rectangles. Defaults to green.
  final Color boxColor;

  /// Stroke width of the bounding box lines. Defaults to 2.0.
  final double strokeWidth;

  /// Whether to show tracking ID labels above each bounding box.
  /// Defaults to `false`.
  final bool showLabels;

  /// Whether to mirror the coordinates horizontally.
  /// Set to `true` for the front camera (default), `false` for the rear camera.
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widgetSize,
      painter: _FaceBoundingBoxPainter(
        faces: faces,
        imageSize: imageSize,
        widgetSize: widgetSize,
        boxColor: boxColor,
        strokeWidth: strokeWidth,
        showLabels: showLabels,
        mirror: mirror,
      ),
    );
  }
}

class _FaceBoundingBoxPainter extends CustomPainter {
  _FaceBoundingBoxPainter({
    required this.faces,
    required this.imageSize,
    required this.widgetSize,
    required this.boxColor,
    required this.strokeWidth,
    required this.showLabels,
    required this.mirror,
  });

  final List<Face> faces;
  final Size imageSize;
  final Size widgetSize;
  final Color boxColor;
  final double strokeWidth;
  final bool showLabels;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    final scaleX = widgetSize.width / imageSize.width;
    final scaleY = widgetSize.height / imageSize.height;

    final paint = Paint()
      ..color = boxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final face in faces) {
      final rect = face.boundingBox;

      double left = rect.left * scaleX;
      double top = rect.top * scaleY;
      double right = rect.right * scaleX;
      double bottom = rect.bottom * scaleY;

      if (mirror) {
        final mirroredLeft = widgetSize.width - right;
        final mirroredRight = widgetSize.width - left;
        left = mirroredLeft;
        right = mirroredRight;
      }

      final scaledRect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(scaledRect, paint);

      if (showLabels && face.trackingId != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'ID: ${face.trackingId}',
            style: TextStyle(
              color: boxColor,
              fontSize: 12,
              background: Paint()..color = Colors.black54,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(left, top - textPainter.height - 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FaceBoundingBoxPainter oldDelegate) {
    return oldDelegate.faces != faces ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.widgetSize != widgetSize ||
        oldDelegate.boxColor != boxColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.mirror != mirror;
  }
}
