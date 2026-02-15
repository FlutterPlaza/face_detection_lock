import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Get camera description for the given direction, or null if unavailable.
Future<CameraDescription?> getCamera(CameraLensDirection dir) async {
  try {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return null;
    if (cameras.length == 1) return cameras[0];
    return cameras.firstWhere(
      (camera) => camera.lensDirection == dir,
      orElse: () => cameras[0],
    );
  } on CameraException catch (e) {
    debugPrint('getCamera error: $e');
    return null;
  }
}

/// Convert a [CameraImage] to an [InputImage] for ML Kit processing.
///
/// Returns null if the image format or rotation cannot be determined.
InputImage? cameraImageToInputImage(
  CameraImage image,
  int sensorOrientation,
) {
  final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  if (rotation == null) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  // nv21 (Android) and bgra8888 (iOS) are single-plane formats.
  // yuv420 (Android fallback) has multiple planes that must be concatenated.
  final Uint8List bytes;
  if (image.planes.length == 1) {
    bytes = image.planes[0].bytes;
  } else {
    bytes = _concatenatePlanes(image.planes);
  }

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final allBytes = WriteBuffer();
  for (final plane in planes) {
    allBytes.putUint8List(plane.bytes);
  }
  return allBytes.done().buffer.asUint8List();
}

/// Preferred image format group for the current platform.
ImageFormatGroup get platformImageFormatGroup {
  if (Platform.isAndroid) return ImageFormatGroup.nv21;
  return ImageFormatGroup.bgra8888;
}
