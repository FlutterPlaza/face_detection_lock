/// Face detection lock screen widget for Flutter.
///
/// Provides a drop-in widget that locks its content behind face detection,
/// with optional face verification against enrolled templates.
///
/// ```dart
/// // Any face unlocks
/// FaceDetectionLock(body: MyApp());
///
/// // Only enrolled faces unlock
/// FaceDetectionLock(
///   verificationProvider: LocalFaceVerificationProvider(),
///   body: MyApp(),
/// );
/// ```
///
/// Supported platforms: Android, iOS.
library face_detection_lock;

export 'application/face_detection_bloc/face_detection_bloc.dart';
export 'domain/face_template.dart';
export 'domain/face_template_store.dart';
export 'domain/face_verification_provider.dart';
export 'infrastructure/face_feature_extractor.dart';
export 'infrastructure/face_gate_cloud_provider.dart';
export 'infrastructure/fallback_verification_provider.dart';
export 'infrastructure/liveness_checker.dart';
export 'infrastructure/local_face_verification.dart';
export 'view/face_detection_widget.dart';
