# face_detection_lock — Master Plan

> **Goal:** Transform `face_detection_lock` from a basic face-presence widget into a production-grade, standalone face detection & verification package that is fast, battery-efficient, and can optionally connect to `face_gate_cloud` or any backend provider.

---

## Current State (v0.0.1+1)

| Aspect | Status |
|--------|--------|
| Face detection engine | `google_ml_vision` (deprecated) |
| Dart SDK | `>=2.18.2 <3.0.0` (pre-Dart 3) |
| Detection model | Presence only — any face unlocks |
| Error handling | None — crashes on failure |
| Camera management | Memory leaks, no lifecycle awareness |
| Backend support | None |
| Tests | 1 incomplete test |
| Platforms | Android, iOS only |

### Critical Bugs

1. **Memory leak** — internally created `_cameraController` never disposed (`close()` only disposes the passed-in controller)
2. **Image stream never stopped** — `startImageStream()` runs forever, no `stopImageStream()` on dispose
3. **Dead code** — `Completer` in face callback created but never awaited
4. **Widget mapping swapped** — `noFace` state renders `noCameraDetectedErrorScreen`, and `noCameraOnDevice` renders `noFaceLockScreen`
5. **No error handling** — missing try-catch around ML Kit init and camera operations

---

## Phase 1: Foundation Fix — v0.1.0

**Objective:** Fix all critical bugs, modernize dependencies, make the package compile and run reliably on current Flutter.

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 1.1 | Migrate `google_ml_vision` → `google_mlkit_face_detection` | Critical | F1 |
| 1.2 | Upgrade to Dart 3 / Flutter 3.x SDK constraints | Critical | F6 |
| 1.3 | Update `camera` to latest stable, `flutter_bloc` to v8.1+ | Critical | F6 |
| 1.4 | Fix `_cameraController` disposal — dispose internal controller in `close()` | Critical | F2 |
| 1.5 | Stop image stream before disposing camera | Critical | F2 |
| 1.6 | Remove dead `Completer` code | Critical | F2 |
| 1.7 | Fix swapped `noFace` ↔ `noCameraOnDevice` widget mapping | Critical | F3 |
| 1.8 | Add error states: `permissionDenied`, `initializationFailed` | High | F3 |
| 1.9 | Add try-catch around camera init and face detection | High | F3 |
| 1.10 | Request camera permission explicitly with proper error state | High | F3 |
| 1.11 | Add initialization timeout (default 10s, configurable) | Medium | F3 |

**Deliverable:** A package that compiles on current Flutter, doesn't crash, doesn't leak memory, and reports errors properly.

---

## Phase 2: Performance & UX — v0.2.0

**Objective:** Make detection fast, battery-efficient, and the widget pleasant to use.

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 2.1 | Frame throttling — process every Nth frame (configurable `detectionIntervalMs`, default 300ms) | High | F4 |
| 2.2 | Use `ResolutionPreset.low` for detection, separate preview resolution | High | F4 |
| 2.3 | Configurable camera direction (`CameraLensDirection` parameter) | Medium | F5 |
| 2.4 | Configurable `ResolutionPreset` | Medium | F5 |
| 2.5 | Confidence threshold parameter (`minFaceConfidence`, default 0.7) | Medium | F11 |
| 2.6 | Minimum face size parameter (reject too-small/far faces) | Medium | F11 |
| 2.7 | Lock/unlock delay — debounce state changes (avoid flickering) | High | F14 |
| 2.8 | Smooth lock/unlock transitions (fade, slide — configurable) | Medium | F14 |
| 2.9 | Haptic feedback on lock/unlock events | Low | F14 |
| 2.10 | App lifecycle awareness — pause detection when backgrounded, resume on foreground | High | F13 |
| 2.11 | Battery-aware mode — reduce detection frequency below threshold | Medium | F12 |
| 2.12 | Face bounding box debug overlay (opt-in, useful for development) | Medium | F16 |

**Deliverable:** Smooth, battery-friendly detection that doesn't flicker and respects device resources.

---

## Phase 3: Standalone Face Verification — v0.3.0

**Objective:** Upgrade from "any face unlocks" to "only enrolled faces unlock" — fully on-device, no backend required.

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 3.1 | Define `FaceTemplate` model — face embedding vector + metadata | High | F8 |
| 3.2 | On-device face embedding extraction (via ML Kit or TFLite FaceNet/ArcFace) | High | F8 |
| 3.3 | Face enrollment flow — capture N frames, extract embeddings, store template | High | F8 |
| 3.4 | Face matching — cosine similarity between live embedding and stored templates | High | F8 |
| 3.5 | Encrypted local storage for face templates (`flutter_secure_storage` or platform keychain) | High | F20 |
| 3.6 | Enrollment UI widget — `FaceEnrollmentWidget` with guided capture (face box overlay, progress) | Medium | F16 |
| 3.7 | Configurable match threshold (`minMatchScore`, default 0.6) | Medium | F11 |
| 3.8 | Multi-face policy — `MultiFacePolicy.lockIfMultiple` / `.unlockIfAnyMatch` / `.unlockIfAllMatch` | Low | F17 |
| 3.9 | Basic liveness detection — blink detection, head turn challenge | High | F7 |
| 3.10 | Template management API — `enrollFace()`, `deleteFace()`, `listEnrolledFaces()`, `clearAll()` | Medium | F8 |

**Deliverable:** A self-contained face verification system. Install the package, enroll a face, lock your app — no server needed.

---

## Phase 4: Backend Integration — v0.4.0

**Objective:** Define a provider abstraction so `face_detection_lock` can verify faces against `face_gate_cloud` or any custom backend.

### 4A: Provider Interface

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 4A.1 | Define `FaceVerificationProvider` abstract interface | High | F9 |
| 4A.2 | Methods: `enroll(faceData) → Result`, `verify(faceData) → VerifyResult`, `delete(userId)`, `health()` | High | F9 |
| 4A.3 | `LocalFaceVerificationProvider` — wraps Phase 3 on-device logic as a provider | High | F9 |
| 4A.4 | `FaceDetectionLock(provider: myProvider)` — inject provider into widget/BLoC | High | F9 |
| 4A.5 | Fallback chain — try remote, fall back to local on network failure | Medium | F9 |

### 4B: `face_gate_cloud` Client

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 4B.1 | `FaceGateCloudProvider` — REST client implementing `FaceVerificationProvider` | High | F10 |
| 4B.2 | Configuration: `baseUrl`, `apiKey`, `timeout`, `retryPolicy` | High | F10 |
| 4B.3 | Secure face data transmission — TLS + optional payload encryption | High | F10 |
| 4B.4 | Token-based auth — JWT/API key management | Medium | F10 |
| 4B.5 | Offline queue — enqueue enrollment/verification when offline, sync on reconnect | Low | F10 |
| 4B.6 | Webhook/callback support — receive async verification results | Low | F10 |

### 4C: Generic Provider Support

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 4C.1 | Document how to implement a custom `FaceVerificationProvider` | Medium | F9 |
| 4C.2 | Example: AWS Rekognition provider | Low | F9 |
| 4C.3 | Example: Azure Face API provider | Low | F9 |

**Deliverable:** Plug-and-play backend support. Use local verification by default, swap in `face_gate_cloud` or any provider with one line.

```dart
// Standalone (default)
FaceDetectionLock(body: MyApp());

// With face_gate_cloud
FaceDetectionLock(
  provider: FaceGateCloudProvider(baseUrl: 'https://api.facegate.io'),
  body: MyApp(),
);

// With custom provider
FaceDetectionLock(
  provider: MyCustomProvider(),
  body: MyApp(),
);
```

---

## Phase 5: Production Hardening — v0.5.0

**Objective:** Comprehensive testing, documentation, and security review.

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 5.1 | Unit tests for BLoC — all state transitions, error paths | High | F15 |
| 5.2 | Unit tests for face matching — similarity thresholds, edge cases | High | F15 |
| 5.3 | Widget tests — all screen states rendered correctly | High | F15 |
| 5.4 | Integration tests — camera mock → detection → state change → UI | High | F15 |
| 5.5 | Golden tests — lock screen, enrollment UI, bounding box overlay | Medium | F15 |
| 5.6 | Mock implementations — `MockCameraController`, `MockFaceDetector`, `MockProvider` | High | F15 |
| 5.7 | Security audit — face template encryption, data-at-rest, data-in-transit | High | F20 |
| 5.8 | Privacy documentation — what data is collected, stored, transmitted | Medium | — |
| 5.9 | API documentation — dartdoc for all public APIs | Medium | — |
| 5.10 | Example app rewrite — showcase all features (standalone, enrolled, backend) | Medium | — |
| 5.11 | Performance benchmarks — detection latency, memory usage, battery impact | Medium | F4 |
| 5.12 | CI/CD pipeline — automated testing, pub.dev publishing | Medium | — |

**Deliverable:** A package ready for production apps with confidence.

---

## Phase 6: Platform Expansion & v1.0 — v1.0.0

**Objective:** Broaden platform support and stabilize the public API.

| # | Task | Priority | Roadmap |
|---|------|----------|---------|
| 6.1 | macOS support — `AVFoundation` camera + Vision framework | Medium | F19 |
| 6.2 | Web support — `getUserMedia` + TensorFlow.js / MediaPipe face detection | Low | F18 |
| 6.3 | Windows support — `MediaCapture` + Windows ML | Low | F19 |
| 6.4 | Linux support — V4L2 camera + OpenCV/dlib | Low | F19 |
| 6.5 | Federated plugin architecture (platform packages) | Medium | F19 |
| 6.6 | API freeze — mark public API as stable, semantic versioning | High | — |
| 6.7 | Migration guide from v0.x → v1.0 | Medium | — |

**Deliverable:** Stable v1.0.0 on pub.dev with multi-platform support.

---

## Architecture Overview (Target)

```
┌──────────────────────────────────────────────────┐
│                   App Layer                       │
│  FaceDetectionLock(provider: ..., body: ...)      │
└──────────────┬───────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────┐
│              BLoC / State Management              │
│  FaceDetectionBloc                                │
│  States: initial | detecting | faceDetected |     │
│          noFace | locked | error(reason)          │
└──────────────┬───────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────┐
│          FaceVerificationProvider (interface)      │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │   Local      │  │ FaceGate     │  │ Custom   │ │
│  │   Provider   │  │ Cloud        │  │ Provider │ │
│  │   (on-device)│  │ Provider     │  │          │ │
│  └──────┬──────┘  └──────┬───────┘  └────┬─────┘ │
└─────────┼────────────────┼───────────────┼───────┘
          │                │               │
┌─────────▼──────┐  ┌─────▼──────┐  ┌─────▼──────┐
│ ML Kit /       │  │ REST/gRPC  │  │ AWS/Azure/ │
│ TFLite         │  │ to         │  │ Custom API │
│ Face Detection │  │ face_gate  │  │            │
│ + Embedding    │  │ _cloud     │  │            │
└────────────────┘  └────────────┘  └────────────┘
```

---

## Directory Structure (Target)

```
lib/
├── face_detection_lock.dart              # Public API exports
├── src/
│   ├── application/
│   │   └── face_detection_bloc/
│   │       ├── face_detection_bloc.dart
│   │       ├── face_detection_event.dart
│   │       └── face_detection_state.dart
│   ├── domain/
│   │   ├── models/
│   │   │   ├── face_template.dart        # Face embedding + metadata
│   │   │   ├── verify_result.dart        # Verification outcome
│   │   │   └── detection_config.dart     # Sensitivity, thresholds
│   │   └── providers/
│   │       ├── face_verification_provider.dart   # Abstract interface
│   │       ├── local_provider.dart               # On-device verification
│   │       └── face_gate_cloud_provider.dart      # Remote backend client
│   ├── infrastructure/
│   │   ├── camera/
│   │   │   ├── camera_service.dart       # Camera lifecycle management
│   │   │   └── frame_processor.dart      # Throttled frame processing
│   │   ├── detection/
│   │   │   ├── face_detector.dart        # ML Kit wrapper
│   │   │   └── face_embedder.dart        # Embedding extraction
│   │   ├── storage/
│   │   │   └── secure_template_store.dart # Encrypted local storage
│   │   └── liveness/
│   │       └── liveness_detector.dart    # Anti-spoofing checks
│   └── view/
│       ├── face_detection_lock.dart      # Main lock widget
│       ├── face_enrollment_widget.dart   # Enrollment UI
│       └── face_debug_overlay.dart       # Bounding box overlay
```

---

## Release Timeline (Suggested)

| Phase | Version | Focus | Depends On |
|-------|---------|-------|------------|
| 1 | v0.1.0 | Foundation Fix | — |
| 2 | v0.2.0 | Performance & UX | Phase 1 |
| 3 | v0.3.0 | Standalone Verification | Phase 2 |
| 4 | v0.4.0 | Backend Integration | Phase 3 |
| 5 | v0.5.0 | Production Hardening | Phase 4 |
| 6 | v1.0.0 | Platform Expansion & Stable API | Phase 5 |

---

## Key Design Decisions

1. **Provider pattern over hard-coded backends** — The `FaceVerificationProvider` interface means we never lock users into a specific backend. Local-first by default, remote when needed.

2. **Local-first, offline-capable** — The package must work without any network connection. Backend providers are additive, not required.

3. **Opt-in complexity** — Basic usage (`FaceDetectionLock(body: child)`) stays simple. Advanced features (enrollment, providers, liveness) are opt-in via parameters.

4. **No Firebase dependency** — Migrating to `google_mlkit_face_detection` removes the Firebase/google-services.json requirement. The package should have zero mandatory native configuration.

5. **Battery and privacy first** — Frame throttling, lifecycle awareness, and configurable detection intervals are not optional — they ship in Phase 2.

6. **Part of FlutterPlaza Security Suite** — This package complements `no_screenshot`, `no_screen_mirror`, and `no_shoulder_surf`. The `no_shoulder_surf` P18 feature (multi-face detection) can delegate to this package's detection engine.
