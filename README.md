[![pub package](https://img.shields.io/pub/v/face_detection_lock.svg)](https://pub.dev/packages/face_detection_lock)
[![CI](https://github.com/FlutterPlaza/face_detection_lock/actions/workflows/ci.yml/badge.svg)](https://github.com/FlutterPlaza/face_detection_lock/actions/workflows/ci.yml)
[![pub points](https://img.shields.io/pub/points/face_detection_lock)](https://pub.dev/packages/face_detection_lock/score)
[![pub popularity](https://img.shields.io/pub/popularity/face_detection_lock)](https://pub.dev/packages/face_detection_lock/score)
[![pub likes](https://img.shields.io/pub/likes/face_detection_lock)](https://pub.dev/packages/face_detection_lock/score)
[![License: BSD](https://img.shields.io/badge/License-BSD-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.10-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)](https://pub.dev/packages/face_detection_lock)

# face_detection_lock

A Flutter package for iOS and Android that locks your app (or parts of it) behind face detection. Optionally verify against enrolled face templates for identity-based access control.

## Features

- **Face presence lock** — screen locks when no face is detected
- **Face verification** — optionally unlock only for enrolled faces (on-device or cloud)
- **Liveness detection** — anti-spoofing via eye-open + head-pose checks
- **Multi-face policy** — lock on multiple faces, or unlock if any/all match
- **Battery-aware mode** — reduces detection frequency on low battery
- **Lifecycle-aware** — auto pauses/resumes with app lifecycle
- **Animated transitions** — smooth fade between lock/unlock with optional haptic feedback
- **Debug overlay** — face bounding box overlay for development and enrollment flows
- **Encrypted storage** — `SecureTemplateStore` for on-device face template persistence
- **Cloud-ready** — `FaceGateCloudProvider` for remote verification, or bring your own backend
- **Customizable** — 9 states, all with custom screen overrides
- **No Firebase required** — uses `google_mlkit_face_detection` directly

## Getting Started

### Installation

```yaml
dependencies:
  face_detection_lock: ^0.2.0
```

### Platform Setup

#### iOS

Add camera permission keys to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera is used for face detection to unlock the app.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is not used but required by the camera plugin.</string>
```

#### Android

Set minimum SDK version to 21 or higher in `android/app/build.gradle`:

```groovy
minSdkVersion 21
```

## Usage

### Basic — any face unlocks

```dart
FaceDetectionLock(
  body: MyApp(),
);
```

### With verification — only enrolled faces unlock

```dart
FaceDetectionLock(
  verificationProvider: LocalFaceVerificationProvider(),
  body: MyApp(),
);
```

### Advanced — external controller with face snapshot callback

```dart
MaterialApp(
  home: FaceDetectionProvider(
    controller: FaceDetectionController(
      cameraController: controller,
      onFaceSnapshot: (faces) => print('${faces.length} faces'),
      verificationProvider: provider,
      maxFaces: 1,
      batteryAwareMode: true,
    )..initializeCamera(),
    child: FaceDetectionLock(
      isControllerProvidedAbove: true,
      body: SecurePage(),
    ),
  ),
);
```

### Debug overlay — face bounding boxes

```dart
Stack(
  children: [
    CameraPreview(controller),
    FaceBoundingBoxOverlay(
      faces: detectedFaces,
      imageSize: Size(480, 640),
      widgetSize: Size(screenWidth, screenHeight),
    ),
  ],
);
```

## Custom Screens

Every state supports custom UI overrides:

```dart
FaceDetectionLock(
  body: MyApp(),
  noFaceLockScreen: MyCustomLockScreen(),
  unverifiedScreen: MyUnverifiedScreen(),
  tooManyFacesScreen: MyTooManyFacesScreen(),
  permissionDeniedScreen: MyPermissionScreen(),
  noCameraDetectedErrorScreen: MyCameraErrorScreen(),
  initializingCameraScreen: MyLoadingScreen(),
  pausedScreen: MyPausedScreen(),
  errorScreen: (msg) => MyErrorScreen(message: msg),
);
```

## Privacy

This package processes facial contour features on-device — no raw images are stored or transmitted by default. See [PRIVACY.md](PRIVACY.md) for full details on data handling, GDPR/CCPA compliance, and maximum-privacy configuration.

## Contributing

Contributions are welcome! Please open an issue or pull request at [GitHub](https://github.com/FlutterPlaza/face_detection_lock).

## License

BSD 3-Clause — see [LICENSE](LICENSE) for details.
