import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/utils.dart';
import '../../domain/face_template.dart';
import '../../domain/face_verification_provider.dart';

part 'face_detection_event.dart';
part 'face_detection_state.dart';

/// BLoC that manages camera initialization, face detection, and optional
/// face verification.
///
/// ```dart
/// // Basic usage — any face unlocks
/// final bloc = FaceDetectionBloc()..add(const InitializeCam());
///
/// // With verification — only enrolled faces unlock
/// final bloc = FaceDetectionBloc(
///   verificationProvider: LocalFaceVerificationProvider(),
/// )..add(const InitializeCam());
/// ```
class FaceDetectionBloc extends Bloc<FaceDetectionEvent, FaceDetectionState> {
  /// Use an existing camera controller for fine-grained camera control.
  final CameraController? cameraController;

  /// Callback invoked with the list of detected faces each time a face is found.
  final void Function(List<Face>)? onFaceSnapshot;

  /// Camera lens direction. Defaults to front camera.
  final CameraLensDirection camDirection;

  /// Camera resolution preset. Defaults to [ResolutionPreset.low] for
  /// optimal detection performance and battery usage.
  final ResolutionPreset resolution;

  /// Timeout for camera initialization. Defaults to 10 seconds.
  final Duration initTimeout;

  /// Minimum interval between detection runs. Frames arriving faster than
  /// this are skipped. Defaults to 300ms (~3 detections/sec).
  final Duration detectionInterval;

  /// Delay before locking after the last face disappears.
  /// Prevents flicker when a face is momentarily lost. Defaults to 500ms.
  final Duration lockDelay;

  /// Delay before unlocking after a face first appears.
  /// Prevents flicker from brief false positives. Defaults to 0ms (instant).
  final Duration unlockDelay;

  /// Minimum face size relative to the image (0.0–1.0).
  /// Smaller values detect faces further away. Defaults to 0.15.
  final double minFaceSize;

  /// Optional face verification provider. When set, detected faces are
  /// verified against enrolled templates before unlocking.
  final FaceVerificationProvider? verificationProvider;

  /// Whether to run liveness checks during verification.
  /// Only used when [verificationProvider] is set. Defaults to true.
  final bool enableLiveness;

  /// Maximum number of faces allowed before locking.
  /// When `null` (default), any number of faces is accepted.
  final int? maxFaces;

  /// Policy for handling multiple detected faces.
  /// Only applies when [maxFaces] is set. Defaults to [MultiFacePolicy.lockIfMultiple].
  final MultiFacePolicy multiFacePolicy;

  /// Whether to reduce detection frequency when battery is low.
  /// Defaults to `false` (opt-in).
  final bool batteryAwareMode;

  /// Battery level (0–100) below which low-battery detection interval applies.
  /// Only used when [batteryAwareMode] is `true`. Defaults to 20.
  final int batteryThreshold;

  /// Detection interval used when battery is below [batteryThreshold].
  /// Only used when [batteryAwareMode] is `true`. Defaults to 1000ms.
  final Duration lowBatteryDetectionInterval;

  CameraController? _cameraController;
  CameraDescription? _description;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isClosed = false;
  bool _isPaused = false;
  DateTime _lastDetectionTime = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _lockTimer;
  Timer? _unlockTimer;
  // Track the previous state before pause so we can restore it.
  FaceDetectionState? _stateBeforePause;

  // Battery-aware state.
  final Battery _battery;
  int? _cachedBatteryLevel;
  DateTime _lastBatteryCheck = DateTime.fromMillisecondsSinceEpoch(0);

  FaceDetectionBloc({
    this.onFaceSnapshot,
    this.cameraController,
    this.camDirection = CameraLensDirection.front,
    this.resolution = ResolutionPreset.low,
    this.initTimeout = const Duration(seconds: 10),
    this.detectionInterval = const Duration(milliseconds: 300),
    this.lockDelay = const Duration(milliseconds: 500),
    this.unlockDelay = Duration.zero,
    this.minFaceSize = 0.15,
    this.verificationProvider,
    this.enableLiveness = true,
    this.maxFaces,
    this.multiFacePolicy = MultiFacePolicy.lockIfMultiple,
    this.batteryAwareMode = false,
    this.batteryThreshold = 20,
    this.lowBatteryDetectionInterval = const Duration(milliseconds: 1000),
    Battery? battery,
  })  : _battery = battery ?? Battery(),
        super(const FaceDetectionInitial()) {
    on<InitializeCam>(_onInitializeCam);
    on<FaceDetected>(_onFaceDetected);
    on<NoFaceDetected>(_onNoFace);
    on<PauseDetection>(_onPause);
    on<ResumeDetection>(_onResume);
    on<_DebouncedLock>((_, emit) => emit(const FaceDetectionNoFace()));
    on<_DebouncedUnlock>((_, emit) => emit(const FaceDetectionSuccess()));
    on<_FaceUnverified>(_onFaceUnverified);
    on<_TooManyFaces>(_onTooManyFaces);
  }

  // -- Event handlers --------------------------------------------------------

  void _onFaceDetected(FaceDetected event, Emitter<FaceDetectionState> emit) {
    // Cancel any pending lock timer — face reappeared.
    _lockTimer?.cancel();

    if (state is FaceDetectionSuccess) return;

    if (unlockDelay == Duration.zero) {
      emit(const FaceDetectionSuccess());
    } else {
      _unlockTimer?.cancel();
      _unlockTimer = Timer(unlockDelay, () {
        if (!_isClosed && state is! FaceDetectionSuccess) {
          add(const _DebouncedUnlock());
        }
      });
    }
  }

  void _onNoFace(NoFaceDetected event, Emitter<FaceDetectionState> emit) {
    // Cancel any pending unlock timer — face disappeared.
    _unlockTimer?.cancel();

    if (state is FaceDetectionNoFace) return;
    if (state is! FaceDetectionSuccess) {
      // First detection cycle with no face — emit immediately.
      emit(const FaceDetectionNoFace());
      return;
    }

    // Currently unlocked — apply lock delay.
    if (lockDelay == Duration.zero) {
      emit(const FaceDetectionNoFace());
    } else {
      _lockTimer?.cancel();
      _lockTimer = Timer(lockDelay, () {
        if (!_isClosed && state is FaceDetectionSuccess) {
          add(const _DebouncedLock());
        }
      });
    }
  }

  Future<void> _onPause(
    PauseDetection event,
    Emitter<FaceDetectionState> emit,
  ) async {
    if (_isPaused) return;
    _isPaused = true;
    _lockTimer?.cancel();
    _unlockTimer?.cancel();
    _stateBeforePause = state;

    if (_cameraController?.value.isStreamingImages ?? false) {
      await _cameraController?.stopImageStream();
    }
    emit(const FaceDetectionPaused());
  }

  Future<void> _onResume(
    ResumeDetection event,
    Emitter<FaceDetectionState> emit,
  ) async {
    if (!_isPaused) return;
    _isPaused = false;

    // Restore previous state while camera restarts detection.
    if (_stateBeforePause != null) {
      emit(_stateBeforePause!);
      _stateBeforePause = null;
    }

    if (_cameraController?.value.isInitialized ?? false) {
      _cameraController!.startImageStream(_processImage);
    }
  }

  Future<void> _onInitializeCam(
    InitializeCam event,
    Emitter<FaceDetectionState> emit,
  ) async {
    try {
      _description = await getCamera(camDirection);
      if (_description == null) {
        emit(const FaceDetectionNoCameraOnDevice());
        return;
      }

      _cameraController = cameraController ??
          CameraController(
            _description!,
            resolution,
            imageFormatGroup: platformImageFormatGroup,
            enableAudio: false,
          );

      await _cameraController!.initialize().timeout(
            initTimeout,
            onTimeout: () => throw TimeoutException(
              'Camera initialization timed out',
              initTimeout,
            ),
          );

      if (_isClosed) return;

      final hasVerification = verificationProvider != null;
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: hasVerification
              ? FaceDetectorMode.accurate
              : FaceDetectorMode.fast,
          minFaceSize: minFaceSize,
          enableContours: hasVerification,
          enableClassification: hasVerification && enableLiveness,
        ),
      );

      _cameraController!.startImageStream(_processImage);
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        emit(const FaceDetectionPermissionDenied());
      } else {
        emit(FaceDetectionInitializationFailed(e.description ?? e.code));
      }
    } on TimeoutException {
      emit(const FaceDetectionInitializationFailed(
        'Camera initialization timed out',
      ));
    } catch (e) {
      emit(FaceDetectionInitializationFailed(e.toString()));
    }
  }

  // -- Frame processing ------------------------------------------------------

  /// Returns the effective detection interval, accounting for battery level
  /// when [batteryAwareMode] is enabled.
  Future<Duration> _effectiveDetectionInterval() async {
    if (!batteryAwareMode) return detectionInterval;

    final now = DateTime.now();
    // Refresh battery level every 30 seconds to avoid per-frame queries.
    if (_cachedBatteryLevel == null ||
        now.difference(_lastBatteryCheck).inSeconds >= 30) {
      try {
        _cachedBatteryLevel = await _battery.batteryLevel;
        _lastBatteryCheck = now;
      } catch (_) {
        // Battery query failed — fall back to normal interval.
        return detectionInterval;
      }
    }

    if (_cachedBatteryLevel! <= batteryThreshold) {
      return lowBatteryDetectionInterval;
    }
    return detectionInterval;
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isDetecting || _isClosed || _isPaused) return;

    // Frame throttling — skip if within the detection interval.
    final now = DateTime.now();
    final interval = await _effectiveDetectionInterval();
    if (now.difference(_lastDetectionTime) < interval) return;
    _lastDetectionTime = now;

    _isDetecting = true;

    try {
      final inputImage = cameraImageToInputImage(
        image,
        _description!.sensorOrientation,
      );

      if (inputImage == null || _isClosed) {
        _isDetecting = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);

      if (_isClosed) return;

      if (faces.isNotEmpty) {
        onFaceSnapshot?.call(faces);

        // Multi-face policy check.
        if (maxFaces != null && faces.length > maxFaces!) {
          if (multiFacePolicy == MultiFacePolicy.lockIfMultiple) {
            add(_TooManyFaces(count: faces.length));
            return;
          }
          // unlockIfAnyMatch / unlockIfAllMatch proceed to verification.
        }

        if (verificationProvider != null) {
          await _verifyFaces(faces);
        } else {
          add(const FaceDetected());
        }
      } else {
        add(const NoFaceDetected());
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Face detection error');
      }
    } finally {
      _isDetecting = false;
    }
  }

  // -- Verification ----------------------------------------------------------

  /// Picks the largest face (closest to camera) for verification.
  Face _selectBestFace(List<Face> faces) {
    if (faces.length == 1) return faces.first;
    return faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA >= areaB ? a : b;
    });
  }

  Future<void> _verifyFaces(List<Face> faces) async {
    // When unlockIfAllMatch, verify every face. Otherwise verify the best one.
    if (multiFacePolicy == MultiFacePolicy.unlockIfAllMatch &&
        faces.length > 1) {
      return _verifyAllFaces(faces);
    }

    final face = _selectBestFace(faces);

    // Liveness check — treat spoofed faces as "no face".
    if (enableLiveness) {
      final liveness = await verificationProvider!.checkLiveness(face);
      if (!liveness.isLive) {
        add(const NoFaceDetected());
        return;
      }
    }

    final result = await verificationProvider!.verify(face);
    if (_isClosed) return;

    if (result.isMatch) {
      add(const FaceDetected());
    } else {
      add(_FaceUnverified(confidence: result.confidence));
    }
  }

  /// Verify ALL faces — only unlock if every face matches.
  Future<void> _verifyAllFaces(List<Face> faces) async {
    var worstConfidence = 1.0;

    for (final face in faces) {
      if (_isClosed) return;

      if (enableLiveness) {
        final liveness = await verificationProvider!.checkLiveness(face);
        if (!liveness.isLive) {
          add(const NoFaceDetected());
          return;
        }
      }

      final result = await verificationProvider!.verify(face);
      if (_isClosed) return;

      if (!result.isMatch) {
        add(_FaceUnverified(confidence: result.confidence));
        return;
      }

      if (result.confidence < worstConfidence) {
        worstConfidence = result.confidence;
      }
    }

    // All faces matched.
    add(const FaceDetected());
  }

  void _onFaceUnverified(
    _FaceUnverified event,
    Emitter<FaceDetectionState> emit,
  ) {
    // Cancel any pending unlock/lock timers — wrong face is present.
    _unlockTimer?.cancel();
    _lockTimer?.cancel();
    emit(FaceDetectionUnverified(confidence: event.confidence));
  }

  void _onTooManyFaces(
    _TooManyFaces event,
    Emitter<FaceDetectionState> emit,
  ) {
    _unlockTimer?.cancel();
    _lockTimer?.cancel();
    emit(FaceDetectionTooManyFaces(count: event.count));
  }

  // -- Cleanup ---------------------------------------------------------------

  @override
  Future<void> close() async {
    _isClosed = true;
    _lockTimer?.cancel();
    _unlockTimer?.cancel();

    if (_cameraController?.value.isStreamingImages ?? false) {
      await _cameraController?.stopImageStream();
    }

    // Only dispose the controller we created internally.
    if (cameraController == null) {
      await _cameraController?.dispose();
    }

    await _faceDetector?.close();

    return super.close();
  }
}

// -- Internal debounce events (not part of the public API) -------------------

final class _DebouncedLock extends FaceDetectionEvent {
  const _DebouncedLock();
}

final class _DebouncedUnlock extends FaceDetectionEvent {
  const _DebouncedUnlock();
}

final class _FaceUnverified extends FaceDetectionEvent {
  const _FaceUnverified({this.confidence = 0.0});
  final double confidence;
}

final class _TooManyFaces extends FaceDetectionEvent {
  const _TooManyFaces({required this.count});
  final int count;
}
