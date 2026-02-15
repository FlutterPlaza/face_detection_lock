# Migration Guide: v0.0.1 to v1.0.0

This guide covers all breaking changes when upgrading from the original
`face_detection_lock` v0.0.1 to v1.0.0.

---

## 1. SDK Requirements

**Before:**
```yaml
environment:
  sdk: '>=2.18.2 <3.0.0'
```

**After:**
```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'
```

Action: Update your `pubspec.yaml` SDK constraints and migrate to Dart 3.

---

## 2. Dependency Changes

The deprecated `google_ml_vision` package has been replaced:

**Before:**
```yaml
dependencies:
  google_ml_vision: ^0.0.7
```

**After:**
```yaml
dependencies:
  google_mlkit_face_detection: ^0.12.0
```

Action: No code changes needed — the migration is handled internally.
Remove `google_ml_vision` from your `pubspec.yaml` if you depended on it
directly.

---

## 3. New States

The BLoC now emits additional states. If you use exhaustive `switch` on
`FaceDetectionState`, you must handle these:

| New State | When Emitted |
|-----------|-------------|
| `FaceDetectionPaused` | App backgrounded / detection paused |
| `FaceDetectionPermissionDenied` | Camera permission denied |
| `FaceDetectionInitializationFailed(message)` | Camera or detector init error |
| `FaceDetectionUnverified(confidence)` | Face detected but not verified |

**Before (v0.0.1 — 4 states):**
```dart
switch (state) {
  FaceDetectionInitial() => ...,
  FaceDetectionSuccess() => ...,
  FaceDetectionNoFace() => ...,
  FaceDetectionNoCameraOnDevice() => ...,
}
```

**After (v1.0.0 — 8 states):**
```dart
switch (state) {
  FaceDetectionInitial() => ...,
  FaceDetectionSuccess() => ...,
  FaceDetectionNoFace() => ...,
  FaceDetectionNoCameraOnDevice() => ...,
  FaceDetectionPaused() => ...,
  FaceDetectionPermissionDenied() => ...,
  FaceDetectionInitializationFailed(:final message) => ...,
  FaceDetectionUnverified(:final confidence) => ...,
}
```

---

## 4. Widget Parameters

### New parameters on `FaceDetectionLock`

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| `permissionDeniedScreen` | `Widget?` | Built-in | Custom permission denied UI |
| `pausedScreen` | `Widget?` | Built-in | Custom paused UI |
| `errorScreen` | `Widget Function(String)?` | Built-in | Custom error UI |
| `unverifiedScreen` | `Widget?` | Built-in | Custom unverified face UI |
| `verificationProvider` | `FaceVerificationProvider?` | `null` | Enable face verification |
| `transitionDuration` | `Duration` | 300ms | Fade animation duration |
| `enableHapticFeedback` | `bool` | `false` | Haptic on lock/unlock |

All new parameters are optional with sensible defaults — no code changes
are required unless you want to use the new features.

### Fixed widget mapping

In v0.0.1, `noFaceLockScreen` and `noCameraDetectedErrorScreen` were swapped
internally. This is fixed in v1.0.0. If you had worked around the bug by
swapping them yourself, revert that workaround.

---

## 5. BLoC Constructor Parameters

The `FaceDetectionBloc` constructor now accepts additional configuration:

```dart
FaceDetectionBloc(
  // Existing
  onFaceSnapshot: ...,
  cameraController: ...,

  // New in v0.2.0+
  camDirection: CameraLensDirection.front,  // default
  resolution: ResolutionPreset.low,         // default
  initTimeout: Duration(seconds: 10),       // default
  detectionInterval: Duration(milliseconds: 300), // default
  lockDelay: Duration(milliseconds: 500),   // default
  unlockDelay: Duration.zero,               // default
  minFaceSize: 0.15,                        // default

  // New in v0.3.0+
  verificationProvider: null,               // default (detection only)
  enableLiveness: true,                     // default
)
```

All new parameters are optional — existing code continues to work.

---

## 6. Face Verification (Optional)

v1.0.0 adds optional face verification. To upgrade from "any face unlocks"
to "only enrolled faces unlock":

```dart
// 1. Create a provider
final provider = LocalFaceVerificationProvider();

// 2. Enroll a face (collect samples via onFaceSnapshot first)
final template = await provider.enroll('Owner', collectedFaces);

// 3. Use with the widget
FaceDetectionLock(
  verificationProvider: provider,
  body: MyApp(),
);
```

This is entirely opt-in — omitting `verificationProvider` preserves the
original "any face unlocks" behavior.

---

## 7. Removed / Renamed

- The internal `Completer` dead code has been removed.
- No public API was renamed or removed from v0.0.1.
