# face_detection_lock — Master Plan

> **Goal:** Transform `face_detection_lock` from a basic face-presence widget into a production-grade, standalone face detection & verification package that is fast, battery-efficient, and can optionally connect to `face_gate_cloud` or any backend provider.

**Current version:** v0.3.0
**Tests:** 106 passing
**Platforms:** Android, iOS

---

## Progress Overview

| Phase | Focus | Status |
|-------|-------|--------|
| 1 | Foundation Fix | **Done** |
| 2 | Performance & UX | **Done** |
| 3 | Standalone Face Verification | **Done** |
| 4 | Backend Integration | **Done** (except 4B.5, 4B.6, 4C) |
| 5 | Production Hardening | **Done** (except 5.5, 5.11) |
| 6 | Platform Expansion & v1.0 | **Partial** (API docs + migration done; platforms deferred) |

---

## Checklist — What's Done

- [x] Migrate `google_ml_vision` → `google_mlkit_face_detection` (F1)
- [x] Fix memory leaks — camera disposal, image stream cleanup (F2)
- [x] Add error states — permissionDenied, initializationFailed (F3)
- [x] Frame throttling — configurable `detectionInterval` (F4)
- [x] Configurable camera direction & resolution (F5)
- [x] Dart 3 + Flutter 3.x migration (F6)
- [x] Liveness detection — eye open + head euler angle checks (F7)
- [x] Local face enrollment & matching — contour features + cosine similarity (F8)
- [x] `FaceVerificationProvider` abstract interface (F9)
- [x] `FaceGateCloudProvider` — REST client with retry, Bearer auth (F10)
- [x] Sensitivity & confidence threshold configuration (F11)
- [x] Lifecycle-aware detection — pause/resume on app lifecycle (F13)
- [x] Lock/unlock animations (AnimatedSwitcher) & haptic feedback (F14)
- [x] Comprehensive test suite — 106 tests (controller, widget, unit, integration) (F15)
- [x] Multi-face policy — `lockIfMultiple` / `unlockIfAnyMatch` / `unlockIfAllMatch` (F17)
- [x] `FallbackVerificationProvider` — primary + fallback chain
- [x] `FaceDetectionLock` widget — 9 states, all customizable
- [x] Example app — 3 demo modes (Basic, Verification, Advanced)
- [x] GitHub Actions CI — `flutter analyze` + `flutter test`
- [x] Comprehensive dartdoc on all public APIs
- [x] `CHANGELOG.md` with full version history
- [x] `MIGRATION.md` — upgrade guide from v0.0.1
- [x] Encrypted local face template storage — `SecureTemplateStore` via `flutter_secure_storage` (F20)
- [x] Battery-aware mode — reduces detection frequency on low battery (F12)
- [x] Face bounding box overlay widget — debug/enrollment overlay (F16)
- [x] Integration tests — full flow, verification, multi-face, pause/resume (5.4)
- [x] Security audit — sanitized error messages, guarded debug prints, PII docs (5.7)
- [x] Privacy documentation — `PRIVACY.md` with GDPR/CCPA notes (5.8)
- [x] Zero external state management — `ChangeNotifier` + `InheritedWidget` + `ListenableBuilder` (F21)

---

## Checklist — What's Left

### Low Priority

- [ ] **5.5 — Golden tests**
  Visual regression tests for lock screen, enrollment UI, bounding box overlay.

- [ ] **5.11 — Performance benchmarks**
  Measure detection latency, memory usage, and battery impact.

- [ ] **4B.5 — Offline queue**
  Enqueue enrollment/verification when offline, sync on reconnect.

- [ ] **4B.6 — Webhook/callback support**
  Receive async verification results from cloud provider.

- [ ] **4C.1 — Custom provider documentation**
  Guide: how to implement a custom `FaceVerificationProvider`.

- [ ] **4C.2 — Example AWS Rekognition provider**

- [ ] **4C.3 — Example Azure Face API provider**

- [ ] **F18 — Web platform support**
  Requires replacing ML Kit with TensorFlow.js / MediaPipe.

- [ ] **F19 — Desktop platform support (macOS, Windows, Linux)**
  ML Kit is mobile-only. Desktop needs alternative detection engine.

---

## face_gate API Compatibility

The `face_gate` project is a **face-based age verification** framework, not a
face identity/template system. The APIs serve different purposes:

| Aspect | `face_detection_lock` | `face_gate_cloud` |
|--------|----------------------|-------------------|
| Purpose | Face **identity** (enrolled templates) | Face **age** estimation |
| Endpoints | `/verify`, `/enroll`, `/templates` | `/v1/verify-age`, `/v1/usage` |
| Input | Feature vectors (contour data) | Base64 image bytes |
| Auth | Bearer token | Bearer token (same) |
| HTTP lib | `http: ^1.2.0` | `http: ^1.2.0` (same) |

**No compatibility changes needed.** The `FaceVerificationProvider` abstraction
already supports any backend. Users can write a custom adapter to bridge
face_gate's age API if needed.

---

## Architecture (Current)

```
┌──────────────────────────────────────────────────┐
│                   App Layer                       │
│  FaceDetectionLock(                               │
│    verificationProvider: ...,                     │
│    maxFaces: 1,                                   │
│    body: MyApp(),                                 │
│  )                                                │
└──────────────┬───────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────┐
│         FaceDetectionController                   │
│  States: Initial | Success | NoFace | Paused |    │
│    NoCameraOnDevice | PermissionDenied |          │
│    InitializationFailed | Unverified |            │
│    TooManyFaces                                   │
│  Features: frame throttling, debounce,            │
│    lifecycle, multi-face policy, liveness         │
└──────────────┬───────────────────────────────────┘
               │
┌──────────────▼───────────────────────────────────┐
│       FaceVerificationProvider (interface)         │
│  ┌──────────────┐ ┌──────────────┐ ┌───────────┐ │
│  │ Local        │ │ FaceGate     │ │ Fallback  │ │
│  │ Provider     │ │ Cloud        │ │ Provider  │ │
│  │ (on-device)  │ │ Provider     │ │ (chain)   │ │
│  └──────┬───────┘ └──────┬───────┘ └─────┬─────┘ │
└─────────┼────────────────┼───────────────┼───────┘
          │                │               │
┌─────────▼──────┐  ┌─────▼──────┐  ┌─────▼──────┐
│ ML Kit         │  │ REST API   │  │ Any custom │
│ Contours +     │  │ (face      │  │ backend    │
│ Cosine         │  │ identity   │  │            │
│ Similarity     │  │ matching)  │  │            │
└────────────────┘  └────────────┘  └────────────┘
```

---

## Screen Disable Triggers

| # | Trigger | State | Status |
|---|---------|-------|--------|
| 1 | Wrong face detected | `FaceDetectionUnverified(confidence)` | **Done** |
| 2 | No face detected | `FaceDetectionNoFace` | **Done** |
| 3 | Too many faces (> maxFaces) | `FaceDetectionTooManyFaces(count)` | **Done** |

---

## Public API Surface (Frozen)

### Widget
- `FaceDetectionLock` — 14 parameters, all documented

### Controller
- `FaceDetectionController` (extends `ChangeNotifier`) — 13 parameters
- `FaceDetectionProvider` — `InheritedWidget` for dependency injection
- 3 public methods: `initializeCamera()`, `pause()`, `resume()`
- 9 public states: `Initial`, `Success`, `NoFace`, `Paused`, `NoCameraOnDevice`, `PermissionDenied`, `InitializationFailed`, `Unverified`, `TooManyFaces`

### Domain
- `FaceVerificationProvider` — abstract interface (6 methods)
- `FaceTemplate`, `FaceVerificationResult`, `LivenessResult` — data models
- `FaceTemplateStore`, `InMemoryTemplateStore`, `SecureTemplateStore` — storage abstraction
- `MultiFacePolicy` — enum (3 values)

### Infrastructure
- `LocalFaceVerificationProvider` — on-device verification
- `FaceGateCloudProvider` — REST client
- `FallbackVerificationProvider` — primary + fallback chain
- `FaceFeatureExtractor` — contour feature extraction + cosine similarity
- `LivenessChecker` — eye + head pose anti-spoofing

---

## Key Design Decisions

1. **Provider pattern** — `FaceVerificationProvider` allows any backend without lock-in.
2. **Local-first** — Works fully offline. Backend providers are opt-in.
3. **Opt-in complexity** — `FaceDetectionLock(body: child)` just works. Verification, liveness, multi-face are all opt-in.
4. **No Firebase dependency** — `google_mlkit_face_detection` needs no Firebase config.
5. **Battery and privacy first** — Frame throttling, lifecycle awareness, configurable intervals.
6. **Part of FlutterPlaza Security Suite** — Complements `no_screenshot`, `no_screen_mirror`, `no_shoulder_surf`.
7. **Zero external state management** — Uses Flutter SDK primitives (`ChangeNotifier`, `InheritedWidget`, `ListenableBuilder`). Users are free to use any state management solution.
