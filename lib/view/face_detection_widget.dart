import 'package:camera/camera.dart';
import 'package:face_detection_lock/application/face_detection_bloc/face_detection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FaceDetectionLock extends StatelessWidget {
  const FaceDetectionLock({
    Key? key,
    required this.body,
    this.noCameraDetectedErrorScreen,
    this.noFaceLockScreen,
    this.initializingCameraScreen,
    this.isBlocInitializeAbove = false,
    this.cameraController,
  }) : super(key: key);

  /// The primary content of the FaceDetectionLock.
  ///
  /// [body] is the widget you which to secure with the face
  /// detection lock screen.
  final Widget body;

  /// Set this to `true` if you which to initialize the blocProvider higher in the widget tree
  /// and use the [FaceDetectionLock] widget in different places in your app.
  /// for instance;
  /// ```dart
  ///   BlocProvider.value(
  ///     value: FaceDetectionBloc()
  ///             ..add(FaceDetectionEvent.initializeCam()),
  ///     child: WidgetToSecureOrParentOfWidgetToSecure()
  /// );
  /// ```
  /// then use the [FaceDetectionLock] as follows
  /// ```dart
  ///     return FaceDetectionLock(
  ///       isBlocInitializeAbove: true,
  ///       body: WidgetToSecure(),
  ///   );
  /// ```
  final bool? isBlocInitializeAbove;

  /// Custom error widget in case the camera was not detected or initialized. Default is provided
  final Widget? noCameraDetectedErrorScreen;

  /// Custom lock screen to replace placeholder NoFaceDetectedScreen
  final Widget? noFaceLockScreen;

  /// Camera initialization loading screen page
  final Widget? initializingCameraScreen;

  /// If you are using the camera in several places in your app and you want
  /// to pass an existing controller into the BlocProvider. Then make sure you
  /// set [isBlocInitializeAbove] to true afterwards
  final CameraController? cameraController;
  static late FaceDetectionBloc _faceDetectionBloc;
  @override
  Widget build(BuildContext context) {
    if (isBlocInitializeAbove != null && isBlocInitializeAbove == true) {
      return _FaceDetectionBody(
        body: body,
        noCameraDetectedErrorScreen: noCameraDetectedErrorScreen,
        noFaceLockScreen: noFaceLockScreen,
        initializingCameraScreen: initializingCameraScreen,
      );
    }
    _faceDetectionBloc = FaceDetectionBloc(cameraController: cameraController)
      ..add(const FaceDetectionEvent.initializeCam());
    return BlocProvider.value(
      value: _faceDetectionBloc,
      child: _FaceDetectionBody(
        body: body,
        noCameraDetectedErrorScreen: noCameraDetectedErrorScreen,
        noFaceLockScreen: noFaceLockScreen,
        initializingCameraScreen: initializingCameraScreen,
      ),
    );
  }
}

class _FaceDetectionBody extends StatelessWidget {
  const _FaceDetectionBody({
    Key? key,
    required this.body,
    this.noCameraDetectedErrorScreen,
    this.noFaceLockScreen,
    this.initializingCameraScreen,
  }) : super(key: key);

  final Widget body;
  final Widget? noCameraDetectedErrorScreen;
  final Widget? noFaceLockScreen;
  final Widget? initializingCameraScreen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaceDetectionBloc, FaceDetectionState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => Center(
              child: initializingCameraScreen ??
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Initializing Camera...'),
                      SizedBox(height: 10),
                      CircularProgressIndicator(),
                    ],
                  )),
          faceDetected: (_) => body,
          noFace: (_) =>
              noCameraDetectedErrorScreen ??
              const NoCameraDetectedWidget(
                  message:
                      'No face detected...This is a lock screen placeholder'),
          noCameraOnDevice: (_) =>
              noFaceLockScreen ??
              const NoCameraDetectedWidget(
                  message: 'No Camera detected on Device'),
        );
      },
    );
  }
}

class NoCameraDetectedWidget extends StatelessWidget {
  const NoCameraDetectedWidget({Key? key, required this.message})
      : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
