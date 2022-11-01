import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import '../../core/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'face_detection_event.dart';
part 'face_detection_state.dart';

part 'face_detection_bloc.freezed.dart';

final handleDetection = GoogleVision.instance.faceDetector();

class FaceDetectionBloc extends Bloc<FaceDetectionEvent, FaceDetectionState> {
  /// You can use an existing camera controller if you want fine control of the camera
  final CameraController? cameraController;
  CameraController? _cameraController;

  /// You can get hold of the faces, that unlocked the device
  /// via a call back function. For this function to be initialized
  /// you need to set the `isBlocInitializeAbove` to `true` and make
  /// sure you initialize the `FaceDetectionBloc` a widget above and
  /// call the `initializeCam` event prior to calling the `FaceDetectionLock`
  /// for example
  /// ```dart
  ///   MaterialApp(
  ///   home: BlocProvider(
  ///       create:(context) => FaceDetectionBloc(cameraController: controller, onFaceSnapshot: callbackFunction )
  ///                 ..add(const _FaceDetectionEvent.initializeCam());
  ///       child: BodyWidget()
  ///      )
  /// )
  /// ```
  final void Function(List<Face>)? onFaceSnapshot;

  CameraLensDirection camDirection = CameraLensDirection.front;
  CameraDescription? description;
  bool isDetecting = false;

  FaceDetectionBloc({this.onFaceSnapshot, this.cameraController})
      : super(const FaceDetectionState.initial()) {
    on<FaceDetectionEvent>((event, emit) async {
      await event.when(
        initializeCam: () async {
          description ??= await getCamera(camDirection);
          if (description == null) {
            emit(const FaceDetectionState.noCameraOnDevice());
          } else {
            _cameraController = cameraController ??
                CameraController(description!, ResolutionPreset.low);
            await _cameraController?.initialize();

            _cameraController?.startImageStream((CameraImage image) async {
              if (isDetecting) return;
              isDetecting = true;
              final facesList = await Future.microtask(
                () => detect(
                  image,
                  handleDetection.processImage,
                  description!.sensorOrientation,
                ),
              );
              if (facesList.isNotEmpty) {
                add(const FaceDetectionEvent.faceDetected());
                if (onFaceSnapshot != null) {
                  final completer = Completer();
                  completer.complete([
                    onFaceSnapshot!(facesList),
                  ]);
                }
              } else if (facesList.isEmpty ||
                  !_cameraController!.value.isInitialized) {
                add(const FaceDetectionEvent.noFace());
              }
              isDetecting = false;
            });
          }
        },
        faceDetected: () async {
          if (state != const FaceDetectionState.faceDetected()) {
            emit(const FaceDetectionState.faceDetected());
          }
        },
        noFace: () async {
          if (state != const FaceDetectionState.noFace()) {
            emit(const FaceDetectionState.noFace());
          }
        },
      );
    });
  }
  @override
  Future<void> close() {
    cameraController?.dispose();
    return super.close();
  }
}
