import 'package:camera/camera.dart';
import 'package:face_detection_lock/application/face_detection_controller.dart';
import 'package:face_detection_lock/domain/face_template.dart';
import 'package:face_detection_lock/domain/face_verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides a [FaceDetectionController] to the widget tree via [InheritedWidget].
class FaceDetectionProvider extends InheritedWidget {
  const FaceDetectionProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The [FaceDetectionController] instance available to descendants.
  final FaceDetectionController controller;

  /// Retrieve the nearest [FaceDetectionController] from the widget tree.
  static FaceDetectionController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<FaceDetectionProvider>();
    assert(provider != null, 'No FaceDetectionProvider found in context');
    return provider!.controller;
  }

  @override
  bool updateShouldNotify(FaceDetectionProvider oldWidget) =>
      controller != oldWidget.controller;
}

/// A widget that locks its [body] behind face detection.
///
/// When a face is detected (and optionally verified), the [body] is shown.
/// Otherwise, a lock screen is displayed.
///
/// ```dart
/// // Simplest usage — any face unlocks
/// FaceDetectionLock(body: MyApp());
///
/// // With verification — only enrolled faces unlock
/// FaceDetectionLock(
///   verificationProvider: LocalFaceVerificationProvider(),
///   body: MyApp(),
/// );
/// ```
class FaceDetectionLock extends StatelessWidget {
  const FaceDetectionLock({
    super.key,
    required this.body,
    this.noCameraDetectedErrorScreen,
    this.noFaceLockScreen,
    this.initializingCameraScreen,
    this.permissionDeniedScreen,
    this.pausedScreen,
    this.errorScreen,
    this.unverifiedScreen,
    this.tooManyFacesScreen,
    this.isControllerProvidedAbove = false,
    this.cameraController,
    this.verificationProvider,
    this.maxFaces,
    this.multiFacePolicy = MultiFacePolicy.lockIfMultiple,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.enableHapticFeedback = false,
  });

  /// The widget to secure behind the face detection lock.
  final Widget body;

  /// Set to `true` if the [FaceDetectionProvider] is initialized higher in the
  /// widget tree.
  final bool isControllerProvidedAbove;

  /// Custom error widget shown when no camera is detected on the device.
  final Widget? noCameraDetectedErrorScreen;

  /// Custom lock screen shown when no face is detected.
  final Widget? noFaceLockScreen;

  /// Custom loading screen shown while the camera is initializing.
  final Widget? initializingCameraScreen;

  /// Custom screen shown when camera permission is denied.
  final Widget? permissionDeniedScreen;

  /// Custom screen shown when detection is paused (app backgrounded).
  final Widget? pausedScreen;

  /// Custom screen shown when initialization fails.
  final Widget Function(String message)? errorScreen;

  /// Custom screen shown when a face is detected but not verified.
  final Widget? unverifiedScreen;

  /// Custom screen shown when more faces than [maxFaces] are detected.
  final Widget? tooManyFacesScreen;

  /// Pass an existing [CameraController] if you manage the camera elsewhere.
  final CameraController? cameraController;

  /// Optional face verification provider.
  ///
  /// When set, detected faces are verified against enrolled templates
  /// before unlocking. Supports any [FaceVerificationProvider] — local,
  /// cloud, or custom.
  ///
  /// Only used when [isControllerProvidedAbove] is false (the widget creates
  /// the controller internally). When managing the controller yourself, pass
  /// the provider directly to [FaceDetectionController].
  final FaceVerificationProvider? verificationProvider;

  /// Maximum number of faces allowed before locking.
  /// When `null` (default), any number of faces is accepted.
  /// Only used when [isControllerProvidedAbove] is false.
  final int? maxFaces;

  /// Policy for handling multiple detected faces.
  /// Only used when [isControllerProvidedAbove] is false.
  final MultiFacePolicy multiFacePolicy;

  /// Duration of the fade transition between lock/unlock states.
  final Duration transitionDuration;

  /// Whether to trigger haptic feedback on lock/unlock transitions.
  final bool enableHapticFeedback;

  static FaceDetectionController? _controller;

  @override
  Widget build(BuildContext context) {
    if (isControllerProvidedAbove) {
      return _LifecycleAwareBody(
        body: body,
        noCameraDetectedErrorScreen: noCameraDetectedErrorScreen,
        noFaceLockScreen: noFaceLockScreen,
        initializingCameraScreen: initializingCameraScreen,
        permissionDeniedScreen: permissionDeniedScreen,
        pausedScreen: pausedScreen,
        errorScreen: errorScreen,
        unverifiedScreen: unverifiedScreen,
        tooManyFacesScreen: tooManyFacesScreen,
        transitionDuration: transitionDuration,
        enableHapticFeedback: enableHapticFeedback,
      );
    }
    _controller = FaceDetectionController(
      cameraController: cameraController,
      verificationProvider: verificationProvider,
      maxFaces: maxFaces,
      multiFacePolicy: multiFacePolicy,
    )..initializeCamera();
    return FaceDetectionProvider(
      controller: _controller!,
      child: _LifecycleAwareBody(
        body: body,
        noCameraDetectedErrorScreen: noCameraDetectedErrorScreen,
        noFaceLockScreen: noFaceLockScreen,
        initializingCameraScreen: initializingCameraScreen,
        permissionDeniedScreen: permissionDeniedScreen,
        pausedScreen: pausedScreen,
        errorScreen: errorScreen,
        unverifiedScreen: unverifiedScreen,
        tooManyFacesScreen: tooManyFacesScreen,
        transitionDuration: transitionDuration,
        enableHapticFeedback: enableHapticFeedback,
      ),
    );
  }
}

/// Wraps the detection body with app lifecycle observation so the camera
/// pauses when the app is backgrounded and resumes on foreground.
class _LifecycleAwareBody extends StatefulWidget {
  const _LifecycleAwareBody({
    required this.body,
    this.noCameraDetectedErrorScreen,
    this.noFaceLockScreen,
    this.initializingCameraScreen,
    this.permissionDeniedScreen,
    this.pausedScreen,
    this.errorScreen,
    this.unverifiedScreen,
    this.tooManyFacesScreen,
    required this.transitionDuration,
    required this.enableHapticFeedback,
  });

  final Widget body;
  final Widget? noCameraDetectedErrorScreen;
  final Widget? noFaceLockScreen;
  final Widget? initializingCameraScreen;
  final Widget? permissionDeniedScreen;
  final Widget? pausedScreen;
  final Widget Function(String message)? errorScreen;
  final Widget? unverifiedScreen;
  final Widget? tooManyFacesScreen;
  final Duration transitionDuration;
  final bool enableHapticFeedback;

  @override
  State<_LifecycleAwareBody> createState() => _LifecycleAwareBodyState();
}

class _LifecycleAwareBodyState extends State<_LifecycleAwareBody>
    with WidgetsBindingObserver {
  FaceDetectionState? _previousState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = FaceDetectionProvider.of(context);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        controller.pause();
      case AppLifecycleState.resumed:
        controller.resume();
    }
  }

  bool _isLockTransition(FaceDetectionState prev, FaceDetectionState curr) {
    final wasLocked = prev is FaceDetectionNoFace ||
        prev is FaceDetectionUnverified ||
        prev is FaceDetectionTooManyFaces;
    final isUnlocked = curr is FaceDetectionSuccess;
    final wasUnlocked = prev is FaceDetectionSuccess;
    final isLocked = curr is FaceDetectionNoFace ||
        curr is FaceDetectionUnverified ||
        curr is FaceDetectionTooManyFaces;
    return (wasLocked && isUnlocked) || (wasUnlocked && isLocked);
  }

  void _handleHapticFeedback(FaceDetectionState state) {
    if (!widget.enableHapticFeedback) return;
    if (_previousState != null && _isLockTransition(_previousState!, state)) {
      if (state is FaceDetectionSuccess) {
        HapticFeedback.lightImpact();
      } else if (state is FaceDetectionNoFace ||
          state is FaceDetectionUnverified ||
          state is FaceDetectionTooManyFaces) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = FaceDetectionProvider.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        _handleHapticFeedback(state);
        _previousState = state;

        final child = _buildForState(state);
        return AnimatedSwitcher(
          duration: widget.transitionDuration,
          child: KeyedSubtree(
            key: ValueKey(state.runtimeType),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildForState(FaceDetectionState state) {
    return switch (state) {
      FaceDetectionInitial() => Center(
          child: widget.initializingCameraScreen ??
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Initializing Camera...'),
                  SizedBox(height: 10),
                  CircularProgressIndicator(),
                ],
              ),
        ),
      FaceDetectionSuccess() => widget.body,
      FaceDetectionNoFace() => widget.noFaceLockScreen ??
          const _DefaultStatusScreen(
            message: 'No face detected. Screen is locked.',
            icon: Icons.lock_outline,
          ),
      FaceDetectionPaused() => widget.pausedScreen ??
          widget.noFaceLockScreen ??
          const _DefaultStatusScreen(
            message: 'Detection paused.',
            icon: Icons.pause_circle_outline,
          ),
      FaceDetectionNoCameraOnDevice() => widget.noCameraDetectedErrorScreen ??
          const _DefaultStatusScreen(
            message: 'No camera detected on device',
            icon: Icons.no_photography_outlined,
          ),
      FaceDetectionPermissionDenied() => widget.permissionDeniedScreen ??
          const _DefaultStatusScreen(
            message: 'Camera permission denied.\n'
                'Please grant camera access in Settings.',
            icon: Icons.camera_alt_outlined,
          ),
      FaceDetectionUnverified() => widget.unverifiedScreen ??
          const _DefaultStatusScreen(
            message: 'Face not recognized. Screen is locked.',
            icon: Icons.person_off_outlined,
          ),
      FaceDetectionTooManyFaces() => widget.tooManyFacesScreen ??
          const _DefaultStatusScreen(
            message: 'Too many faces detected. Screen is locked.',
            icon: Icons.groups_outlined,
          ),
      FaceDetectionInitializationFailed(message: final msg) =>
        widget.errorScreen?.call(msg) ??
            _DefaultStatusScreen(
              message: 'Initialization failed:\n$msg',
              icon: Icons.error_outline,
            ),
    };
  }
}

class _DefaultStatusScreen extends StatelessWidget {
  const _DefaultStatusScreen({
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
