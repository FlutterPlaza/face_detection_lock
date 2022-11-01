part of 'face_detection_bloc.dart';

@freezed
class FaceDetectionEvent with _$FaceDetectionEvent {
  /// Camera initialization event
  const factory FaceDetectionEvent.initializeCam() = _Started;

  /// FaceDetected event
  const factory FaceDetectionEvent.faceDetected() = _FaceDetected;

  /// no Face detected event.
  const factory FaceDetectionEvent.noFace() = _NoFace;
}
