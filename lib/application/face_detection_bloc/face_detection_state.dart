part of 'face_detection_bloc.dart';

@freezed
class FaceDetectionState with _$FaceDetectionState {
  const factory FaceDetectionState.initial() = _Initial;
  const factory FaceDetectionState.faceDetected() = _FaceDetectedS;
  const factory FaceDetectionState.noFace() = _NOFaceDetected;
  const factory FaceDetectionState.noCameraOnDevice() = _NoCameraOnDevice;
}
