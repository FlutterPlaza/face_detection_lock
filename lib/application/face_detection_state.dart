/// Base class for all face detection states.
///
/// Use pattern matching to handle each state in your UI:
///
/// ```dart
/// switch (state) {
///   FaceDetectionInitial() => showLoading(),
///   FaceDetectionSuccess() => showContent(),
///   FaceDetectionNoFace() => showLockScreen(),
///   // ...
/// }
/// ```
sealed class FaceDetectionState {
  const FaceDetectionState();
}

/// Camera is being initialized. This is the initial state.
final class FaceDetectionInitial extends FaceDetectionState {
  const FaceDetectionInitial();
}

/// A face was detected (and verified, if a provider is configured).
/// The screen is unlocked.
final class FaceDetectionSuccess extends FaceDetectionState {
  const FaceDetectionSuccess();
}

/// No face is visible in the camera feed. The screen is locked.
final class FaceDetectionNoFace extends FaceDetectionState {
  const FaceDetectionNoFace();
}

/// Detection is paused (e.g. the app was backgrounded).
final class FaceDetectionPaused extends FaceDetectionState {
  const FaceDetectionPaused();
}

/// No camera was found on the device.
final class FaceDetectionNoCameraOnDevice extends FaceDetectionState {
  const FaceDetectionNoCameraOnDevice();
}

/// The user denied camera permission.
final class FaceDetectionPermissionDenied extends FaceDetectionState {
  const FaceDetectionPermissionDenied();
}

/// Camera or detector initialization failed.
final class FaceDetectionInitializationFailed extends FaceDetectionState {
  const FaceDetectionInitializationFailed(this.message);

  /// Human-readable error message describing the failure.
  final String message;
}

/// A face was detected but did not match any enrolled template.
final class FaceDetectionUnverified extends FaceDetectionState {
  const FaceDetectionUnverified({this.confidence = 0.0});

  /// Similarity score from the best match attempt (0.0–1.0).
  final double confidence;
}

/// More faces than allowed were detected. The screen is locked.
final class FaceDetectionTooManyFaces extends FaceDetectionState {
  const FaceDetectionTooManyFaces({required this.count});

  /// Number of faces detected in the current frame.
  final int count;
}
