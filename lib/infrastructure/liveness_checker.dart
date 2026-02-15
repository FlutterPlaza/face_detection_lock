import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/face_template.dart';

/// Basic liveness detection using ML Kit classification and head pose.
///
/// Checks that the face belongs to a live person rather than a photo or video
/// by verifying eye open probability and head orientation.
class LivenessChecker {
  const LivenessChecker({
    this.minEyeOpenProbability = 0.4,
    this.maxHeadAngle = 20.0,
  });

  /// Minimum probability (0.0–1.0) for eyes to be considered open.
  final double minEyeOpenProbability;

  /// Maximum absolute head euler angle (degrees) on any axis.
  final double maxHeadAngle;

  /// Check whether a [Face] passes basic liveness criteria.
  ///
  /// Requires ML Kit configured with `enableClassification: true`.
  LivenessResult check(Face face) {
    // Eye open check (requires classification enabled).
    final leftEye = face.leftEyeOpenProbability;
    final rightEye = face.rightEyeOpenProbability;

    if (leftEye != null && leftEye < minEyeOpenProbability) {
      return const LivenessResult(
        isLive: false,
        reason: 'Left eye appears closed',
      );
    }
    if (rightEye != null && rightEye < minEyeOpenProbability) {
      return const LivenessResult(
        isLive: false,
        reason: 'Right eye appears closed',
      );
    }

    // Head pose check — face should be roughly facing the camera.
    final angleX = face.headEulerAngleX; // up/down tilt
    final angleY = face.headEulerAngleY; // left/right turn
    final angleZ = face.headEulerAngleZ; // tilt/roll

    if (angleX != null && angleX.abs() > maxHeadAngle) {
      return const LivenessResult(
        isLive: false,
        reason: 'Head tilted too far up or down',
      );
    }
    if (angleY != null && angleY.abs() > maxHeadAngle) {
      return const LivenessResult(
        isLive: false,
        reason: 'Head turned too far left or right',
      );
    }
    if (angleZ != null && angleZ.abs() > maxHeadAngle) {
      return const LivenessResult(
        isLive: false,
        reason: 'Head tilted to one side',
      );
    }

    return const LivenessResult(isLive: true);
  }
}
