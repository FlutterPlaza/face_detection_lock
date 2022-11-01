import 'dart:developer';

import 'package:face_detection_lock/face_detection_lock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:physical_security_app/main_app_content_placeholder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(title: 'Secure screen Demo', home: WidgetToggle());
  }
}

class WidgetToggle extends HookWidget {
  const WidgetToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isAbove = useState(false);
    return Scaffold(
      body: isAbove.value
          ? BlocProvider(
              create: (context) => FaceDetectionBloc(
                onFaceSnapshot: (faces) {
                  log(faces.toString());
                },
                // cameraController: _yourCameracontroller
              )..add(const FaceDetectionEvent.initializeCam()),
              child: FaceDetectionLock(
                isBlocInitializeAbove: isAbove.value,
                body: MainAppContentPlaceholder(),
              ),
            )
          : FaceDetectionLock(
              body: MainAppContentPlaceholder(),
            ),
      floatingActionButton: ElevatedButton(
        child: Text('Switch to isBlocInitialize = ${!isAbove.value}'),
        onPressed: () {
          isAbove.value = !isAbove.value;
        },
      ),
    );
  }
}
