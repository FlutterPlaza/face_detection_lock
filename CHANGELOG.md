# Changelog

All notable changes to this project will be documented in this file.

## 0.3.0

### Changed
- **Removed `flutter_bloc` dependency** — replaced `FaceDetectionBloc` with
  `FaceDetectionController` (extends `ChangeNotifier`). No external state
  management dependency required.
- **Removed `bloc_test` dev dependency** — tests now use standard `test()` with
  stream collection instead of `blocTest<>`.
- **Removed event pattern** — replaced `add(Event)` dispatch with direct
  methods: `initializeCamera()`, `pause()`, `resume()`, `close()`.
- **Renamed `FaceDetectionBlocProvider`** → `FaceDetectionProvider` — a
  lightweight `InheritedWidget` for dependency injection.
- **Renamed `isBlocInitializeAbove`** → `isControllerProvidedAbove`.
- **Widget internals** — `BlocConsumer` replaced with `ListenableBuilder`.
- State file is now a standalone import (no longer a `part` file).

### Migration (from 0.2.x)
- Replace `FaceDetectionBloc` with `FaceDetectionController`.
- Replace `FaceDetectionBlocProvider(bloc: ...)` with
  `FaceDetectionProvider(controller: ...)`.
- Replace `bloc.add(const InitializeCam())` with `controller.initializeCamera()`.
- Replace `bloc.add(const PauseDetection())` with `controller.pause()`.
- Replace `bloc.add(const ResumeDetection())` with `controller.resume()`.
- Replace `isBlocInitializeAbove` with `isControllerProvidedAbove`.
- Remove `flutter_bloc` from your app's `pubspec.yaml`.

## 0.2.0

### Added
- **Face verification** — optional `verificationProvider` parameter enables
  "only enrolled faces unlock" mode.
- **`FaceVerificationProvider`** — abstract interface for pluggable verification
  backends (local, cloud, or custom).
- **`LocalFaceVerificationProvider`** — on-device verification using ML Kit
  contour-based feature extraction and cosine similarity matching.
- **`FaceGateCloudProvider`** — REST client implementing `FaceVerificationProvider`
  with configurable `baseUrl`, `apiKey`, `timeout`, `retryCount`, and `basePath`.
- **`FallbackVerificationProvider`** — wraps a primary and fallback provider for
  resilient verification (e.g. cloud-first with local fallback).
- **`FaceFeatureExtractor`** — normalized contour feature extraction with cosine
  similarity and feature averaging utilities.
- **`LivenessChecker`** — basic anti-spoofing via eye open probability and head
  euler angle checks.
- **`FaceTemplate`** / **`FaceVerificationResult`** / **`LivenessResult`** domain
  models with JSON serialization.
- **`FaceTemplateStore`** — abstract template storage with `InMemoryTemplateStore`
  implementation.
- **`FaceDetectionUnverified`** state — emitted when a face is detected but does
  not match any enrolled template.
- **Frame throttling** — configurable `detectionInterval` (default 300ms) skips
  redundant frames for battery efficiency.
- **Debounced lock/unlock** — `lockDelay` and `unlockDelay` prevent UI flicker
  from momentary detection gaps.
- **Smooth transitions** — `AnimatedSwitcher` with configurable
  `transitionDuration` between lock/unlock states.
- **Haptic feedback** — optional `enableHapticFeedback` on state transitions.
- **Lifecycle awareness** — automatically pauses detection when the app is
  backgrounded and resumes on foreground.
- **Pause / Resume** methods and `FaceDetectionPaused` state with
  previous-state restoration.
- Configurable `camDirection`, `resolution`, and `minFaceSize` parameters.
- Unit tests (15 test cases) and widget tests (17 test cases).
- GitHub Actions CI pipeline (`flutter analyze` + `flutter test`).
- Example app with three demo modes: Basic, Verification, and Advanced.
- Comprehensive dartdoc comments on all public APIs.
- `MIGRATION.md` — migration guide from v0.0.1.

### Fixed
- Memory leak — internal `CameraController` is now properly disposed.
- Image stream never stopped on dispose.
- Swapped `noFace` / `noCameraOnDevice` widget mapping.
- Removed dead `Completer` code.

### Changed
- **Migrated** from deprecated `google_ml_vision` to `google_mlkit_face_detection`.
- **Upgraded** to Dart 3 / Flutter 3.x SDK constraints.
- Added `FaceDetectionPermissionDenied` and `FaceDetectionInitializationFailed`
  error states.
- Added try-catch around camera init and face detection.
- Added configurable camera initialization timeout (`initTimeout`).
- Added explicit camera permission handling.

### Dependencies
- `google_mlkit_face_detection: ^0.12.0` (replaces `google_ml_vision`)
- `http: ^1.2.0`

## 0.0.1

- Initial release.
- Widget locks screen when no face is detected.
- Face snapshot accessible via callback.
