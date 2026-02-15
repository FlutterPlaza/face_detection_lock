part of 'face_detection_bloc.dart';

/// Base class for all face detection events.
sealed class FaceDetectionEvent {
  const FaceDetectionEvent();
}

/// Initialize the camera and start the face detection image stream.
final class InitializeCam extends FaceDetectionEvent {
  const InitializeCam();
}

/// A face was detected in the camera feed.
final class FaceDetected extends FaceDetectionEvent {
  const FaceDetected();
}

/// No face was detected in the current camera frame.
final class NoFaceDetected extends FaceDetectionEvent {
  const NoFaceDetected();
}

/// Pause face detection (e.g. when the app is backgrounded).
final class PauseDetection extends FaceDetectionEvent {
  const PauseDetection();
}

/// Resume face detection after a pause.
final class ResumeDetection extends FaceDetectionEvent {
  const ResumeDetection();
}
