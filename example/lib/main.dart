import 'dart:developer';

import 'package:face_detection_lock/face_detection_lock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Face Detection Lock Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DemoSelector(),
    );
  }
}

// ---------------------------------------------------------------------------
// Demo selector — three modes
// ---------------------------------------------------------------------------

enum DemoMode { basic, verification, advanced }

class DemoSelector extends StatefulWidget {
  const DemoSelector({super.key});

  @override
  State<DemoSelector> createState() => _DemoSelectorState();
}

class _DemoSelectorState extends State<DemoSelector> {
  DemoMode _mode = DemoMode.basic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_mode) {
        DemoMode.basic => const _BasicDemo(),
        DemoMode.verification => const _VerificationDemo(),
        DemoMode.advanced => const _AdvancedDemo(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _mode.index,
        onDestinationSelected: (i) => setState(() {
          _mode = DemoMode.values[i];
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.face),
            label: 'Basic',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user),
            label: 'Verification',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud),
            label: 'Advanced',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Basic — any face unlocks (simplest usage)
// ---------------------------------------------------------------------------

class _BasicDemo extends StatelessWidget {
  const _BasicDemo();

  @override
  Widget build(BuildContext context) {
    return const FaceDetectionLock(
      body: _UnlockedContent(title: 'Basic Mode'),
      enableHapticFeedback: true,
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Verification — local on-device face verification
// ---------------------------------------------------------------------------

class _VerificationDemo extends StatelessWidget {
  const _VerificationDemo();

  @override
  Widget build(BuildContext context) {
    return FaceDetectionLock(
      verificationProvider: LocalFaceVerificationProvider(),
      unverifiedScreen: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Face not recognized',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Enroll your face first via the provider API.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
      body: const _UnlockedContent(title: 'Verification Mode'),
      enableHapticFeedback: true,
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Advanced — BLoC managed above, with fallback provider
// ---------------------------------------------------------------------------

class _AdvancedDemo extends StatelessWidget {
  const _AdvancedDemo();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaceDetectionBloc(
        onFaceSnapshot: (faces) {
          log('Detected ${faces.length} face(s)');
        },
        detectionInterval: const Duration(milliseconds: 500),
        lockDelay: const Duration(seconds: 1),
        minFaceSize: 0.2,
        // Example: fallback provider (cloud → local).
        // In production, replace with a real FaceGateCloudProvider:
        //
        // verificationProvider: FallbackVerificationProvider(
        //   primary: FaceGateCloudProvider(
        //     baseUrl: 'https://api.facegate.example.com',
        //     apiKey: 'your-api-key',
        //   ),
        //   fallback: LocalFaceVerificationProvider(),
        // ),
      )..add(const InitializeCam()),
      child: const FaceDetectionLock(
        isBlocInitializeAbove: true,
        body: _UnlockedContent(title: 'Advanced Mode'),
        transitionDuration: Duration(milliseconds: 400),
        enableHapticFeedback: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared unlocked content
// ---------------------------------------------------------------------------

class _UnlockedContent extends StatelessWidget {
  const _UnlockedContent({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_open, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Screen is unlocked!'),
        ],
      ),
    );
  }
}
