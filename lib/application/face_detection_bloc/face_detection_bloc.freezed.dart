// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'face_detection_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$FaceDetectionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializeCam,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializeCam,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializeCam,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) initializeCam,
    required TResult Function(_FaceDetected value) faceDetected,
    required TResult Function(_NoFace value) noFace,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? initializeCam,
    TResult? Function(_FaceDetected value)? faceDetected,
    TResult? Function(_NoFace value)? noFace,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? initializeCam,
    TResult Function(_FaceDetected value)? faceDetected,
    TResult Function(_NoFace value)? noFace,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaceDetectionEventCopyWith<$Res> {
  factory $FaceDetectionEventCopyWith(
          FaceDetectionEvent value, $Res Function(FaceDetectionEvent) then) =
      _$FaceDetectionEventCopyWithImpl<$Res, FaceDetectionEvent>;
}

/// @nodoc
class _$FaceDetectionEventCopyWithImpl<$Res, $Val extends FaceDetectionEvent>
    implements $FaceDetectionEventCopyWith<$Res> {
  _$FaceDetectionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_StartedCopyWith<$Res> {
  factory _$$_StartedCopyWith(
          _$_Started value, $Res Function(_$_Started) then) =
      __$$_StartedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_StartedCopyWithImpl<$Res>
    extends _$FaceDetectionEventCopyWithImpl<$Res, _$_Started>
    implements _$$_StartedCopyWith<$Res> {
  __$$_StartedCopyWithImpl(_$_Started _value, $Res Function(_$_Started) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_Started implements _Started {
  const _$_Started();

  @override
  String toString() {
    return 'FaceDetectionEvent.initializeCam()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_Started);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializeCam,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
  }) {
    return initializeCam();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializeCam,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
  }) {
    return initializeCam?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializeCam,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    required TResult orElse(),
  }) {
    if (initializeCam != null) {
      return initializeCam();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) initializeCam,
    required TResult Function(_FaceDetected value) faceDetected,
    required TResult Function(_NoFace value) noFace,
  }) {
    return initializeCam(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? initializeCam,
    TResult? Function(_FaceDetected value)? faceDetected,
    TResult? Function(_NoFace value)? noFace,
  }) {
    return initializeCam?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? initializeCam,
    TResult Function(_FaceDetected value)? faceDetected,
    TResult Function(_NoFace value)? noFace,
    required TResult orElse(),
  }) {
    if (initializeCam != null) {
      return initializeCam(this);
    }
    return orElse();
  }
}

abstract class _Started implements FaceDetectionEvent {
  const factory _Started() = _$_Started;
}

/// @nodoc
abstract class _$$_FaceDetectedCopyWith<$Res> {
  factory _$$_FaceDetectedCopyWith(
          _$_FaceDetected value, $Res Function(_$_FaceDetected) then) =
      __$$_FaceDetectedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_FaceDetectedCopyWithImpl<$Res>
    extends _$FaceDetectionEventCopyWithImpl<$Res, _$_FaceDetected>
    implements _$$_FaceDetectedCopyWith<$Res> {
  __$$_FaceDetectedCopyWithImpl(
      _$_FaceDetected _value, $Res Function(_$_FaceDetected) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_FaceDetected implements _FaceDetected {
  const _$_FaceDetected();

  @override
  String toString() {
    return 'FaceDetectionEvent.faceDetected()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_FaceDetected);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializeCam,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
  }) {
    return faceDetected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializeCam,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
  }) {
    return faceDetected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializeCam,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    required TResult orElse(),
  }) {
    if (faceDetected != null) {
      return faceDetected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) initializeCam,
    required TResult Function(_FaceDetected value) faceDetected,
    required TResult Function(_NoFace value) noFace,
  }) {
    return faceDetected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? initializeCam,
    TResult? Function(_FaceDetected value)? faceDetected,
    TResult? Function(_NoFace value)? noFace,
  }) {
    return faceDetected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? initializeCam,
    TResult Function(_FaceDetected value)? faceDetected,
    TResult Function(_NoFace value)? noFace,
    required TResult orElse(),
  }) {
    if (faceDetected != null) {
      return faceDetected(this);
    }
    return orElse();
  }
}

abstract class _FaceDetected implements FaceDetectionEvent {
  const factory _FaceDetected() = _$_FaceDetected;
}

/// @nodoc
abstract class _$$_NoFaceCopyWith<$Res> {
  factory _$$_NoFaceCopyWith(_$_NoFace value, $Res Function(_$_NoFace) then) =
      __$$_NoFaceCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_NoFaceCopyWithImpl<$Res>
    extends _$FaceDetectionEventCopyWithImpl<$Res, _$_NoFace>
    implements _$$_NoFaceCopyWith<$Res> {
  __$$_NoFaceCopyWithImpl(_$_NoFace _value, $Res Function(_$_NoFace) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_NoFace implements _NoFace {
  const _$_NoFace();

  @override
  String toString() {
    return 'FaceDetectionEvent.noFace()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_NoFace);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializeCam,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
  }) {
    return noFace();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializeCam,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
  }) {
    return noFace?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializeCam,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    required TResult orElse(),
  }) {
    if (noFace != null) {
      return noFace();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) initializeCam,
    required TResult Function(_FaceDetected value) faceDetected,
    required TResult Function(_NoFace value) noFace,
  }) {
    return noFace(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? initializeCam,
    TResult? Function(_FaceDetected value)? faceDetected,
    TResult? Function(_NoFace value)? noFace,
  }) {
    return noFace?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? initializeCam,
    TResult Function(_FaceDetected value)? faceDetected,
    TResult Function(_NoFace value)? noFace,
    required TResult orElse(),
  }) {
    if (noFace != null) {
      return noFace(this);
    }
    return orElse();
  }
}

abstract class _NoFace implements FaceDetectionEvent {
  const factory _NoFace() = _$_NoFace;
}

/// @nodoc
mixin _$FaceDetectionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
    required TResult Function() noCameraOnDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
    TResult? Function()? noCameraOnDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    TResult Function()? noCameraOnDevice,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FaceDetectedS value) faceDetected,
    required TResult Function(_NOFaceDetected value) noFace,
    required TResult Function(_NoCameraOnDevice value) noCameraOnDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FaceDetectedS value)? faceDetected,
    TResult? Function(_NOFaceDetected value)? noFace,
    TResult? Function(_NoCameraOnDevice value)? noCameraOnDevice,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FaceDetectedS value)? faceDetected,
    TResult Function(_NOFaceDetected value)? noFace,
    TResult Function(_NoCameraOnDevice value)? noCameraOnDevice,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaceDetectionStateCopyWith<$Res> {
  factory $FaceDetectionStateCopyWith(
          FaceDetectionState value, $Res Function(FaceDetectionState) then) =
      _$FaceDetectionStateCopyWithImpl<$Res, FaceDetectionState>;
}

/// @nodoc
class _$FaceDetectionStateCopyWithImpl<$Res, $Val extends FaceDetectionState>
    implements $FaceDetectionStateCopyWith<$Res> {
  _$FaceDetectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_InitialCopyWith<$Res> {
  factory _$$_InitialCopyWith(
          _$_Initial value, $Res Function(_$_Initial) then) =
      __$$_InitialCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_InitialCopyWithImpl<$Res>
    extends _$FaceDetectionStateCopyWithImpl<$Res, _$_Initial>
    implements _$$_InitialCopyWith<$Res> {
  __$$_InitialCopyWithImpl(_$_Initial _value, $Res Function(_$_Initial) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_Initial implements _Initial {
  const _$_Initial();

  @override
  String toString() {
    return 'FaceDetectionState.initial()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
    required TResult Function() noCameraOnDevice,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
    TResult? Function()? noCameraOnDevice,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    TResult Function()? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FaceDetectedS value) faceDetected,
    required TResult Function(_NOFaceDetected value) noFace,
    required TResult Function(_NoCameraOnDevice value) noCameraOnDevice,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FaceDetectedS value)? faceDetected,
    TResult? Function(_NOFaceDetected value)? noFace,
    TResult? Function(_NoCameraOnDevice value)? noCameraOnDevice,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FaceDetectedS value)? faceDetected,
    TResult Function(_NOFaceDetected value)? noFace,
    TResult Function(_NoCameraOnDevice value)? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements FaceDetectionState {
  const factory _Initial() = _$_Initial;
}

/// @nodoc
abstract class _$$_FaceDetectedSCopyWith<$Res> {
  factory _$$_FaceDetectedSCopyWith(
          _$_FaceDetectedS value, $Res Function(_$_FaceDetectedS) then) =
      __$$_FaceDetectedSCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_FaceDetectedSCopyWithImpl<$Res>
    extends _$FaceDetectionStateCopyWithImpl<$Res, _$_FaceDetectedS>
    implements _$$_FaceDetectedSCopyWith<$Res> {
  __$$_FaceDetectedSCopyWithImpl(
      _$_FaceDetectedS _value, $Res Function(_$_FaceDetectedS) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_FaceDetectedS implements _FaceDetectedS {
  const _$_FaceDetectedS();

  @override
  String toString() {
    return 'FaceDetectionState.faceDetected()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_FaceDetectedS);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
    required TResult Function() noCameraOnDevice,
  }) {
    return faceDetected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
    TResult? Function()? noCameraOnDevice,
  }) {
    return faceDetected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    TResult Function()? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (faceDetected != null) {
      return faceDetected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FaceDetectedS value) faceDetected,
    required TResult Function(_NOFaceDetected value) noFace,
    required TResult Function(_NoCameraOnDevice value) noCameraOnDevice,
  }) {
    return faceDetected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FaceDetectedS value)? faceDetected,
    TResult? Function(_NOFaceDetected value)? noFace,
    TResult? Function(_NoCameraOnDevice value)? noCameraOnDevice,
  }) {
    return faceDetected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FaceDetectedS value)? faceDetected,
    TResult Function(_NOFaceDetected value)? noFace,
    TResult Function(_NoCameraOnDevice value)? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (faceDetected != null) {
      return faceDetected(this);
    }
    return orElse();
  }
}

abstract class _FaceDetectedS implements FaceDetectionState {
  const factory _FaceDetectedS() = _$_FaceDetectedS;
}

/// @nodoc
abstract class _$$_NOFaceDetectedCopyWith<$Res> {
  factory _$$_NOFaceDetectedCopyWith(
          _$_NOFaceDetected value, $Res Function(_$_NOFaceDetected) then) =
      __$$_NOFaceDetectedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_NOFaceDetectedCopyWithImpl<$Res>
    extends _$FaceDetectionStateCopyWithImpl<$Res, _$_NOFaceDetected>
    implements _$$_NOFaceDetectedCopyWith<$Res> {
  __$$_NOFaceDetectedCopyWithImpl(
      _$_NOFaceDetected _value, $Res Function(_$_NOFaceDetected) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_NOFaceDetected implements _NOFaceDetected {
  const _$_NOFaceDetected();

  @override
  String toString() {
    return 'FaceDetectionState.noFace()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_NOFaceDetected);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
    required TResult Function() noCameraOnDevice,
  }) {
    return noFace();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
    TResult? Function()? noCameraOnDevice,
  }) {
    return noFace?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    TResult Function()? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (noFace != null) {
      return noFace();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FaceDetectedS value) faceDetected,
    required TResult Function(_NOFaceDetected value) noFace,
    required TResult Function(_NoCameraOnDevice value) noCameraOnDevice,
  }) {
    return noFace(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FaceDetectedS value)? faceDetected,
    TResult? Function(_NOFaceDetected value)? noFace,
    TResult? Function(_NoCameraOnDevice value)? noCameraOnDevice,
  }) {
    return noFace?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FaceDetectedS value)? faceDetected,
    TResult Function(_NOFaceDetected value)? noFace,
    TResult Function(_NoCameraOnDevice value)? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (noFace != null) {
      return noFace(this);
    }
    return orElse();
  }
}

abstract class _NOFaceDetected implements FaceDetectionState {
  const factory _NOFaceDetected() = _$_NOFaceDetected;
}

/// @nodoc
abstract class _$$_NoCameraOnDeviceCopyWith<$Res> {
  factory _$$_NoCameraOnDeviceCopyWith(
          _$_NoCameraOnDevice value, $Res Function(_$_NoCameraOnDevice) then) =
      __$$_NoCameraOnDeviceCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_NoCameraOnDeviceCopyWithImpl<$Res>
    extends _$FaceDetectionStateCopyWithImpl<$Res, _$_NoCameraOnDevice>
    implements _$$_NoCameraOnDeviceCopyWith<$Res> {
  __$$_NoCameraOnDeviceCopyWithImpl(
      _$_NoCameraOnDevice _value, $Res Function(_$_NoCameraOnDevice) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_NoCameraOnDevice implements _NoCameraOnDevice {
  const _$_NoCameraOnDevice();

  @override
  String toString() {
    return 'FaceDetectionState.noCameraOnDevice()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$_NoCameraOnDevice);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() faceDetected,
    required TResult Function() noFace,
    required TResult Function() noCameraOnDevice,
  }) {
    return noCameraOnDevice();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? faceDetected,
    TResult? Function()? noFace,
    TResult? Function()? noCameraOnDevice,
  }) {
    return noCameraOnDevice?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? faceDetected,
    TResult Function()? noFace,
    TResult Function()? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (noCameraOnDevice != null) {
      return noCameraOnDevice();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FaceDetectedS value) faceDetected,
    required TResult Function(_NOFaceDetected value) noFace,
    required TResult Function(_NoCameraOnDevice value) noCameraOnDevice,
  }) {
    return noCameraOnDevice(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FaceDetectedS value)? faceDetected,
    TResult? Function(_NOFaceDetected value)? noFace,
    TResult? Function(_NoCameraOnDevice value)? noCameraOnDevice,
  }) {
    return noCameraOnDevice?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FaceDetectedS value)? faceDetected,
    TResult Function(_NOFaceDetected value)? noFace,
    TResult Function(_NoCameraOnDevice value)? noCameraOnDevice,
    required TResult orElse(),
  }) {
    if (noCameraOnDevice != null) {
      return noCameraOnDevice(this);
    }
    return orElse();
  }
}

abstract class _NoCameraOnDevice implements FaceDetectionState {
  const factory _NoCameraOnDevice() = _$_NoCameraOnDevice;
}
