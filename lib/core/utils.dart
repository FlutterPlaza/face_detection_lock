import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

typedef HandleDetection = Future<List<Face>> Function(GoogleVisionImage image);

/// get front camera description or return `null` if unavailable
Future<CameraDescription?> getCamera(CameraLensDirection dir) async {
  try {
    final cameras = await availableCameras();
    if (cameras.length == 1) return cameras[0];
    return cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == dir,
    );
  } on CameraException catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

/// Detection method. Returns the list of faces found.
Future<List<Face>> detect(
  CameraImage image,
  HandleDetection handleDetection,
  int cameraLenIndex,
) async {
  final googleImage = GoogleVisionImage.fromBytes(
    _concatenatePlanes(image.planes),
    _buildMetaData(image, rotationIntToImageRotation(cameraLenIndex)),
  );
  return handleDetection(googleImage);
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  for (var plane in planes) {
    allBytes.putUint8List(plane.bytes);
  }
  return allBytes.done().buffer.asUint8List();
}

GoogleVisionImageMetadata _buildMetaData(
  CameraImage image,
  ImageRotation rotation,
) {
  return GoogleVisionImageMetadata(
    rawFormat: image.format.raw,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    planeData: image.planes.map(
      (Plane plane) {
        return GoogleVisionImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList(),
  );
}

/// Returns camera rotation based on camera index.
ImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return ImageRotation.rotation0;
    case 90:
      return ImageRotation.rotation90;
    case 180:
      return ImageRotation.rotation180;
    default:
      assert(rotation == 270);
      return ImageRotation.rotation270;
  }
}
