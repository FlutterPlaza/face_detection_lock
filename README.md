
A flutter package for IOS and Android to secure all or part of your app under face detection.  


## Features
- Widget will lock screen when a face is not detected looking at phone
- A snapshot of the face which unlocked the screen can be accessed via a callback function.


## Getting started

First, this package used google Mk kit for face detection. So you have to connect your project to a firebase project and past the `google-services.json` file in the `android/app/` directory in your flutter project. 

Second, add camera as a dependency in your `pubspec.yaml` file.

#iOS 
* This package uses the camera for face detection. So make sure you request for camera permission.

Add two rows to the `ios/Runner/Info.plist`:

one with the key Privacy - Camera Usage Description and a usage description.
and one with the key Privacy - Microphone Usage Description and a usage description.
If editing Info.plist as text, add:

```
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
```

#Android 
Change the minimum Android SDK version to 21 (or higher) in your `android/app/build.gradle file`.

```minSdkVersion 21```

## Usage
If you wish to use this widget only to lock only a single page of your app or the whole app, then you can simply wrap the page you want to lock or the whole app with `FaceDetectionLock` widget respectively as follows; 

 ```dart
    return FaceDetectionLock(
        body: MyAppOrWidgetToSecure()
    );
```

However, if you wish to pass an existing camera controller and/or get hold of the faces that triggered the app unlock, then do the following. 

- You can get hold of the faces, that unlocked the device
- via a call back function. For this function to be initialized
- you need to set the `isBlocInitializeAbove` to `true` and make
- sure you initialize the `FaceDetectionBloc` a widget above and
- call the `initializeCam` event prior to calling the `FaceDetectionLock`
 for example
 ```dart
   MaterialApp(
   home: BlocProvider(
         create:(context) => FaceDetectionBloc(cameraController: controller, onFaceSnapshot: callbackFunction )
                   ..add(const FaceDetectionEvent.initializeCam());
         child: BodyWidget()
        )
 )
 ```

 Then make sure that when calling the `FaceDetectionLock` widget lower in the widget true you set the parameter `isBlocInitializeAbove` to true. For instance

 ```dart
    return FaceDetectionLock(
        isBlocInitializeAbove: true, 
        body: BankAccountPageToSecure()
    );
```