# Privacy Policy — face_detection_lock

This document describes how the `face_detection_lock` Flutter package handles personal and biometric data.

## What Data Is Collected

- **Facial contour features** — numeric vectors derived from facial landmarks (e.g. jaw outline, eye positions). These are mathematical representations, not images or photographs.
- **No raw images are stored.** Camera frames are processed in real-time by Google ML Kit and immediately discarded after feature extraction.
- **No analytics, telemetry, or tracking** is collected by this package.

## What Data Is Stored Locally

- **In-memory (default):** `InMemoryTemplateStore` holds face templates in RAM only. Data is lost when the app is terminated.
- **Encrypted on-device:** `SecureTemplateStore` persists templates using `flutter_secure_storage`, which uses the platform keystore (Android Keystore / iOS Keychain). Data is encrypted at rest.
- **No data is written to plain-text files, shared preferences, or unencrypted databases.**

## What Data Is Transmitted

- **Nothing by default.** When using `LocalFaceVerificationProvider`, all processing stays on-device. No network requests are made.
- **Cloud provider (opt-in):** If `FaceGateCloudProvider` or a custom `FaceVerificationProvider` is configured, face feature vectors (not images) are transmitted to the configured backend via HTTPS.
  - The `apiKey` is sent as a Bearer token in the `Authorization` header.
  - No data is sent to Anthropic, Google, or any third party by this package.

## Data Retention and Deletion

- **Delete a single template:** `provider.deleteTemplate(id)` or `store.delete(id)`
- **Delete all templates:** `provider.clearAll()` or `store.clear()`
- **In-memory data** is automatically cleared when the app process ends.
- **Encrypted data** persists until explicitly deleted via the API above or until the app is uninstalled (platform keystore behavior).

## GDPR / CCPA Compliance Notes

- Face templates constitute **biometric data** under GDPR (Article 9) and CCPA. You must:
  - Obtain **explicit user consent** before enrolling face templates.
  - Provide a mechanism to **view and delete** stored templates (use `listTemplates()` and `deleteTemplate()`).
  - Disclose biometric data collection in your app's privacy policy.
- This package provides the **technical controls** (encryption, deletion APIs). You are responsible for the **legal compliance** of your app.

## Configuring for Maximum Privacy

```dart
// On-device only — no network, no persistence
FaceDetectionLock(
  body: MySecureApp(),
  // No verificationProvider → any face unlocks, nothing stored
);

// On-device verification with encrypted storage, no cloud
final store = SecureTemplateStore();
final provider = LocalFaceVerificationProvider(templateStore: store);
FaceDetectionLock(
  verificationProvider: provider,
  body: MySecureApp(),
);
```

## Contact

For privacy questions about this package, open an issue at:
https://github.com/FlutterPlaza/face_detection_lock/issues
