// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimerState {

 TimerStatus get status; int get totalSeconds; int get secondsLeft; DateTime? get sessionStart; DateTime? get endAt; LogTrigger? get logTrigger;
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerStateCopyWith<TimerState> get copyWith => _$TimerStateCopyWithImpl<TimerState>(this as TimerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TimerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.totalSeconds, _this.totalSeconds) || other.totalSeconds == _this.totalSeconds)&&(identical(other.secondsLeft, _this.secondsLeft) || other.secondsLeft == _this.secondsLeft)&&(identical(other.sessionStart, _this.sessionStart) || other.sessionStart == _this.sessionStart)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.logTrigger, _this.logTrigger) || other.logTrigger == _this.logTrigger));
}


@override
int get hashCode {
  final _this = this as TimerState;
  return Object.hash(runtimeType,_this.status,_this.totalSeconds,_this.secondsLeft,_this.sessionStart,_this.endAt,_this.logTrigger);
}

@override
String toString() {
  final _this = this as TimerState;
  return 'TimerState(status: ${_this.status}, totalSeconds: ${_this.totalSeconds}, secondsLeft: ${_this.secondsLeft}, sessionStart: ${_this.sessionStart}, endAt: ${_this.endAt}, logTrigger: ${_this.logTrigger})';
}


}

/// @nodoc
abstract mixin class $TimerStateCopyWith<$Res>  {
  factory $TimerStateCopyWith(TimerState value, $Res Function(TimerState) _then) = _$TimerStateCopyWithImpl;
@useResult
$Res call({
 TimerStatus status, int totalSeconds, int secondsLeft, DateTime? sessionStart, DateTime? endAt, LogTrigger? logTrigger
});




}
/// @nodoc
class _$TimerStateCopyWithImpl<$Res>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._self, this._then);

  final TimerState _self;
  final $Res Function(TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? totalSeconds = null,Object? secondsLeft = null,Object? sessionStart = freezed,Object? endAt = freezed,Object? logTrigger = freezed,}) {
  return _then(TimerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,secondsLeft: null == secondsLeft ? _self.secondsLeft : secondsLeft // ignore: cast_nullable_to_non_nullable
as int,sessionStart: freezed == sessionStart ? _self.sessionStart : sessionStart // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,logTrigger: freezed == logTrigger ? _self.logTrigger : logTrigger // ignore: cast_nullable_to_non_nullable
as LogTrigger?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerState value)  $default,){
final _that = this;
switch (_that) {
case _TimerState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerState value)?  $default,){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TimerStatus status,  int totalSeconds,  int secondsLeft,  DateTime? sessionStart,  DateTime? endAt,  LogTrigger? logTrigger)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.totalSeconds,_that.secondsLeft,_that.sessionStart,_that.endAt,_that.logTrigger);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TimerStatus status,  int totalSeconds,  int secondsLeft,  DateTime? sessionStart,  DateTime? endAt,  LogTrigger? logTrigger)  $default,) {final _that = this;
switch (_that) {
case _TimerState():
return $default(_that.status,_that.totalSeconds,_that.secondsLeft,_that.sessionStart,_that.endAt,_that.logTrigger);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TimerStatus status,  int totalSeconds,  int secondsLeft,  DateTime? sessionStart,  DateTime? endAt,  LogTrigger? logTrigger)?  $default,) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.totalSeconds,_that.secondsLeft,_that.sessionStart,_that.endAt,_that.logTrigger);case _:
  return null;

}
}

}

/// @nodoc


class _TimerState implements TimerState {
  const _TimerState({required this.status, required this.totalSeconds, required this.secondsLeft, this.sessionStart, this.endAt, this.logTrigger});
  

@override final  TimerStatus status;
@override final  int totalSeconds;
@override final  int secondsLeft;
@override final  DateTime? sessionStart;
@override final  DateTime? endAt;
@override final  LogTrigger? logTrigger;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerStateCopyWith<_TimerState> get copyWith => __$TimerStateCopyWithImpl<_TimerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerState&&(identical(other.status, status) || other.status == status)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds)&&(identical(other.secondsLeft, secondsLeft) || other.secondsLeft == secondsLeft)&&(identical(other.sessionStart, sessionStart) || other.sessionStart == sessionStart)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.logTrigger, logTrigger) || other.logTrigger == logTrigger));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,totalSeconds,secondsLeft,sessionStart,endAt,logTrigger);
}

@override
String toString() {
    return 'TimerState(status: $status, totalSeconds: $totalSeconds, secondsLeft: $secondsLeft, sessionStart: $sessionStart, endAt: $endAt, logTrigger: $logTrigger)';
}


}

/// @nodoc
abstract mixin class _$TimerStateCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory _$TimerStateCopyWith(_TimerState value, $Res Function(_TimerState) _then) = __$TimerStateCopyWithImpl;
@override @useResult
$Res call({
 TimerStatus status, int totalSeconds, int secondsLeft, DateTime? sessionStart, DateTime? endAt, LogTrigger? logTrigger
});




}
/// @nodoc
class __$TimerStateCopyWithImpl<$Res>
    implements _$TimerStateCopyWith<$Res> {
  __$TimerStateCopyWithImpl(this._self, this._then);

  final _TimerState _self;
  final $Res Function(_TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? totalSeconds = null,Object? secondsLeft = null,Object? sessionStart = freezed,Object? endAt = freezed,Object? logTrigger = freezed,}) {
  return _then(_TimerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,secondsLeft: null == secondsLeft ? _self.secondsLeft : secondsLeft // ignore: cast_nullable_to_non_nullable
as int,sessionStart: freezed == sessionStart ? _self.sessionStart : sessionStart // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,logTrigger: freezed == logTrigger ? _self.logTrigger : logTrigger // ignore: cast_nullable_to_non_nullable
as LogTrigger?,
  ));
}


}

// dart format on
