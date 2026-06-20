// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_go_no_go.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RouteWaypointGoNoGoResult implements DiagnosticableTreeMixin {

 int get orderIndex; String get launchId; String get launchName; GoNoGoResult get result;
/// Create a copy of RouteWaypointGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteWaypointGoNoGoResultCopyWith<RouteWaypointGoNoGoResult> get copyWith => _$RouteWaypointGoNoGoResultCopyWithImpl<RouteWaypointGoNoGoResult>(this as RouteWaypointGoNoGoResult, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RouteWaypointGoNoGoResult'))
    ..add(DiagnosticsProperty('orderIndex', orderIndex))..add(DiagnosticsProperty('launchId', launchId))..add(DiagnosticsProperty('launchName', launchName))..add(DiagnosticsProperty('result', result));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteWaypointGoNoGoResult&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.launchId, launchId) || other.launchId == launchId)&&(identical(other.launchName, launchName) || other.launchName == launchName)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,orderIndex,launchId,launchName,result);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RouteWaypointGoNoGoResult(orderIndex: $orderIndex, launchId: $launchId, launchName: $launchName, result: $result)';
}


}

/// @nodoc
abstract mixin class $RouteWaypointGoNoGoResultCopyWith<$Res>  {
  factory $RouteWaypointGoNoGoResultCopyWith(RouteWaypointGoNoGoResult value, $Res Function(RouteWaypointGoNoGoResult) _then) = _$RouteWaypointGoNoGoResultCopyWithImpl;
@useResult
$Res call({
 int orderIndex, String launchId, String launchName, GoNoGoResult result
});


$GoNoGoResultCopyWith<$Res> get result;

}
/// @nodoc
class _$RouteWaypointGoNoGoResultCopyWithImpl<$Res>
    implements $RouteWaypointGoNoGoResultCopyWith<$Res> {
  _$RouteWaypointGoNoGoResultCopyWithImpl(this._self, this._then);

  final RouteWaypointGoNoGoResult _self;
  final $Res Function(RouteWaypointGoNoGoResult) _then;

/// Create a copy of RouteWaypointGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderIndex = null,Object? launchId = null,Object? launchName = null,Object? result = null,}) {
  return _then(_self.copyWith(
orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,launchId: null == launchId ? _self.launchId : launchId // ignore: cast_nullable_to_non_nullable
as String,launchName: null == launchName ? _self.launchName : launchName // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GoNoGoResult,
  ));
}
/// Create a copy of RouteWaypointGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoNoGoResultCopyWith<$Res> get result {
  
  return $GoNoGoResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [RouteWaypointGoNoGoResult].
extension RouteWaypointGoNoGoResultPatterns on RouteWaypointGoNoGoResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteWaypointGoNoGoResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteWaypointGoNoGoResult value)  $default,){
final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteWaypointGoNoGoResult value)?  $default,){
final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int orderIndex,  String launchId,  String launchName,  GoNoGoResult result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoResult() when $default != null:
return $default(_that.orderIndex,_that.launchId,_that.launchName,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int orderIndex,  String launchId,  String launchName,  GoNoGoResult result)  $default,) {final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoResult():
return $default(_that.orderIndex,_that.launchId,_that.launchName,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int orderIndex,  String launchId,  String launchName,  GoNoGoResult result)?  $default,) {final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoResult() when $default != null:
return $default(_that.orderIndex,_that.launchId,_that.launchName,_that.result);case _:
  return null;

}
}

}

/// @nodoc


class _RouteWaypointGoNoGoResult with DiagnosticableTreeMixin implements RouteWaypointGoNoGoResult {
  const _RouteWaypointGoNoGoResult({required this.orderIndex, required this.launchId, required this.launchName, required this.result});
  

@override final  int orderIndex;
@override final  String launchId;
@override final  String launchName;
@override final  GoNoGoResult result;

/// Create a copy of RouteWaypointGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteWaypointGoNoGoResultCopyWith<_RouteWaypointGoNoGoResult> get copyWith => __$RouteWaypointGoNoGoResultCopyWithImpl<_RouteWaypointGoNoGoResult>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RouteWaypointGoNoGoResult'))
    ..add(DiagnosticsProperty('orderIndex', orderIndex))..add(DiagnosticsProperty('launchId', launchId))..add(DiagnosticsProperty('launchName', launchName))..add(DiagnosticsProperty('result', result));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteWaypointGoNoGoResult&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.launchId, launchId) || other.launchId == launchId)&&(identical(other.launchName, launchName) || other.launchName == launchName)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,orderIndex,launchId,launchName,result);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RouteWaypointGoNoGoResult(orderIndex: $orderIndex, launchId: $launchId, launchName: $launchName, result: $result)';
}


}

/// @nodoc
abstract mixin class _$RouteWaypointGoNoGoResultCopyWith<$Res> implements $RouteWaypointGoNoGoResultCopyWith<$Res> {
  factory _$RouteWaypointGoNoGoResultCopyWith(_RouteWaypointGoNoGoResult value, $Res Function(_RouteWaypointGoNoGoResult) _then) = __$RouteWaypointGoNoGoResultCopyWithImpl;
@override @useResult
$Res call({
 int orderIndex, String launchId, String launchName, GoNoGoResult result
});


@override $GoNoGoResultCopyWith<$Res> get result;

}
/// @nodoc
class __$RouteWaypointGoNoGoResultCopyWithImpl<$Res>
    implements _$RouteWaypointGoNoGoResultCopyWith<$Res> {
  __$RouteWaypointGoNoGoResultCopyWithImpl(this._self, this._then);

  final _RouteWaypointGoNoGoResult _self;
  final $Res Function(_RouteWaypointGoNoGoResult) _then;

/// Create a copy of RouteWaypointGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderIndex = null,Object? launchId = null,Object? launchName = null,Object? result = null,}) {
  return _then(_RouteWaypointGoNoGoResult(
orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,launchId: null == launchId ? _self.launchId : launchId // ignore: cast_nullable_to_non_nullable
as String,launchName: null == launchName ? _self.launchName : launchName // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GoNoGoResult,
  ));
}

/// Create a copy of RouteWaypointGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoNoGoResultCopyWith<$Res> get result {
  
  return $GoNoGoResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

/// @nodoc
mixin _$RouteWaypointGoNoGoFailure implements DiagnosticableTreeMixin {

 int get orderIndex; String get launchId; String get launchName; AppFailure get failure;
/// Create a copy of RouteWaypointGoNoGoFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteWaypointGoNoGoFailureCopyWith<RouteWaypointGoNoGoFailure> get copyWith => _$RouteWaypointGoNoGoFailureCopyWithImpl<RouteWaypointGoNoGoFailure>(this as RouteWaypointGoNoGoFailure, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RouteWaypointGoNoGoFailure'))
    ..add(DiagnosticsProperty('orderIndex', orderIndex))..add(DiagnosticsProperty('launchId', launchId))..add(DiagnosticsProperty('launchName', launchName))..add(DiagnosticsProperty('failure', failure));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteWaypointGoNoGoFailure&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.launchId, launchId) || other.launchId == launchId)&&(identical(other.launchName, launchName) || other.launchName == launchName)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,orderIndex,launchId,launchName,failure);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RouteWaypointGoNoGoFailure(orderIndex: $orderIndex, launchId: $launchId, launchName: $launchName, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $RouteWaypointGoNoGoFailureCopyWith<$Res>  {
  factory $RouteWaypointGoNoGoFailureCopyWith(RouteWaypointGoNoGoFailure value, $Res Function(RouteWaypointGoNoGoFailure) _then) = _$RouteWaypointGoNoGoFailureCopyWithImpl;
@useResult
$Res call({
 int orderIndex, String launchId, String launchName, AppFailure failure
});




}
/// @nodoc
class _$RouteWaypointGoNoGoFailureCopyWithImpl<$Res>
    implements $RouteWaypointGoNoGoFailureCopyWith<$Res> {
  _$RouteWaypointGoNoGoFailureCopyWithImpl(this._self, this._then);

  final RouteWaypointGoNoGoFailure _self;
  final $Res Function(RouteWaypointGoNoGoFailure) _then;

/// Create a copy of RouteWaypointGoNoGoFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderIndex = null,Object? launchId = null,Object? launchName = null,Object? failure = null,}) {
  return _then(_self.copyWith(
orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,launchId: null == launchId ? _self.launchId : launchId // ignore: cast_nullable_to_non_nullable
as String,launchName: null == launchName ? _self.launchName : launchName // ignore: cast_nullable_to_non_nullable
as String,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteWaypointGoNoGoFailure].
extension RouteWaypointGoNoGoFailurePatterns on RouteWaypointGoNoGoFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteWaypointGoNoGoFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteWaypointGoNoGoFailure value)  $default,){
final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteWaypointGoNoGoFailure value)?  $default,){
final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int orderIndex,  String launchId,  String launchName,  AppFailure failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoFailure() when $default != null:
return $default(_that.orderIndex,_that.launchId,_that.launchName,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int orderIndex,  String launchId,  String launchName,  AppFailure failure)  $default,) {final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoFailure():
return $default(_that.orderIndex,_that.launchId,_that.launchName,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int orderIndex,  String launchId,  String launchName,  AppFailure failure)?  $default,) {final _that = this;
switch (_that) {
case _RouteWaypointGoNoGoFailure() when $default != null:
return $default(_that.orderIndex,_that.launchId,_that.launchName,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _RouteWaypointGoNoGoFailure with DiagnosticableTreeMixin implements RouteWaypointGoNoGoFailure {
  const _RouteWaypointGoNoGoFailure({required this.orderIndex, required this.launchId, required this.launchName, required this.failure});
  

@override final  int orderIndex;
@override final  String launchId;
@override final  String launchName;
@override final  AppFailure failure;

/// Create a copy of RouteWaypointGoNoGoFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteWaypointGoNoGoFailureCopyWith<_RouteWaypointGoNoGoFailure> get copyWith => __$RouteWaypointGoNoGoFailureCopyWithImpl<_RouteWaypointGoNoGoFailure>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RouteWaypointGoNoGoFailure'))
    ..add(DiagnosticsProperty('orderIndex', orderIndex))..add(DiagnosticsProperty('launchId', launchId))..add(DiagnosticsProperty('launchName', launchName))..add(DiagnosticsProperty('failure', failure));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteWaypointGoNoGoFailure&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.launchId, launchId) || other.launchId == launchId)&&(identical(other.launchName, launchName) || other.launchName == launchName)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,orderIndex,launchId,launchName,failure);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RouteWaypointGoNoGoFailure(orderIndex: $orderIndex, launchId: $launchId, launchName: $launchName, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$RouteWaypointGoNoGoFailureCopyWith<$Res> implements $RouteWaypointGoNoGoFailureCopyWith<$Res> {
  factory _$RouteWaypointGoNoGoFailureCopyWith(_RouteWaypointGoNoGoFailure value, $Res Function(_RouteWaypointGoNoGoFailure) _then) = __$RouteWaypointGoNoGoFailureCopyWithImpl;
@override @useResult
$Res call({
 int orderIndex, String launchId, String launchName, AppFailure failure
});




}
/// @nodoc
class __$RouteWaypointGoNoGoFailureCopyWithImpl<$Res>
    implements _$RouteWaypointGoNoGoFailureCopyWith<$Res> {
  __$RouteWaypointGoNoGoFailureCopyWithImpl(this._self, this._then);

  final _RouteWaypointGoNoGoFailure _self;
  final $Res Function(_RouteWaypointGoNoGoFailure) _then;

/// Create a copy of RouteWaypointGoNoGoFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderIndex = null,Object? launchId = null,Object? launchName = null,Object? failure = null,}) {
  return _then(_RouteWaypointGoNoGoFailure(
orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,launchId: null == launchId ? _self.launchId : launchId // ignore: cast_nullable_to_non_nullable
as String,launchName: null == launchName ? _self.launchName : launchName // ignore: cast_nullable_to_non_nullable
as String,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

/// @nodoc
mixin _$RouteGoNoGoResult implements DiagnosticableTreeMixin {

 GoNoGoVerdict get verdict; DateTime get computedAt; List<RouteWaypointGoNoGoResult> get waypointResults; List<RouteWaypointGoNoGoFailure> get waypointFailures; List<GoNoGoReason> get triggeringReasons; RouteWaypointGoNoGoResult? get triggeringWaypoint;
/// Create a copy of RouteGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteGoNoGoResultCopyWith<RouteGoNoGoResult> get copyWith => _$RouteGoNoGoResultCopyWithImpl<RouteGoNoGoResult>(this as RouteGoNoGoResult, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RouteGoNoGoResult'))
    ..add(DiagnosticsProperty('verdict', verdict))..add(DiagnosticsProperty('computedAt', computedAt))..add(DiagnosticsProperty('waypointResults', waypointResults))..add(DiagnosticsProperty('waypointFailures', waypointFailures))..add(DiagnosticsProperty('triggeringReasons', triggeringReasons))..add(DiagnosticsProperty('triggeringWaypoint', triggeringWaypoint));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteGoNoGoResult&&(identical(other.verdict, verdict) || other.verdict == verdict)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt)&&const DeepCollectionEquality().equals(other.waypointResults, waypointResults)&&const DeepCollectionEquality().equals(other.waypointFailures, waypointFailures)&&const DeepCollectionEquality().equals(other.triggeringReasons, triggeringReasons)&&(identical(other.triggeringWaypoint, triggeringWaypoint) || other.triggeringWaypoint == triggeringWaypoint));
}


@override
int get hashCode => Object.hash(runtimeType,verdict,computedAt,const DeepCollectionEquality().hash(waypointResults),const DeepCollectionEquality().hash(waypointFailures),const DeepCollectionEquality().hash(triggeringReasons),triggeringWaypoint);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RouteGoNoGoResult(verdict: $verdict, computedAt: $computedAt, waypointResults: $waypointResults, waypointFailures: $waypointFailures, triggeringReasons: $triggeringReasons, triggeringWaypoint: $triggeringWaypoint)';
}


}

/// @nodoc
abstract mixin class $RouteGoNoGoResultCopyWith<$Res>  {
  factory $RouteGoNoGoResultCopyWith(RouteGoNoGoResult value, $Res Function(RouteGoNoGoResult) _then) = _$RouteGoNoGoResultCopyWithImpl;
@useResult
$Res call({
 GoNoGoVerdict verdict, DateTime computedAt, List<RouteWaypointGoNoGoResult> waypointResults, List<RouteWaypointGoNoGoFailure> waypointFailures, List<GoNoGoReason> triggeringReasons, RouteWaypointGoNoGoResult? triggeringWaypoint
});


$RouteWaypointGoNoGoResultCopyWith<$Res>? get triggeringWaypoint;

}
/// @nodoc
class _$RouteGoNoGoResultCopyWithImpl<$Res>
    implements $RouteGoNoGoResultCopyWith<$Res> {
  _$RouteGoNoGoResultCopyWithImpl(this._self, this._then);

  final RouteGoNoGoResult _self;
  final $Res Function(RouteGoNoGoResult) _then;

/// Create a copy of RouteGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verdict = null,Object? computedAt = null,Object? waypointResults = null,Object? waypointFailures = null,Object? triggeringReasons = null,Object? triggeringWaypoint = freezed,}) {
  return _then(_self.copyWith(
verdict: null == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as GoNoGoVerdict,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,waypointResults: null == waypointResults ? _self.waypointResults : waypointResults // ignore: cast_nullable_to_non_nullable
as List<RouteWaypointGoNoGoResult>,waypointFailures: null == waypointFailures ? _self.waypointFailures : waypointFailures // ignore: cast_nullable_to_non_nullable
as List<RouteWaypointGoNoGoFailure>,triggeringReasons: null == triggeringReasons ? _self.triggeringReasons : triggeringReasons // ignore: cast_nullable_to_non_nullable
as List<GoNoGoReason>,triggeringWaypoint: freezed == triggeringWaypoint ? _self.triggeringWaypoint : triggeringWaypoint // ignore: cast_nullable_to_non_nullable
as RouteWaypointGoNoGoResult?,
  ));
}
/// Create a copy of RouteGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteWaypointGoNoGoResultCopyWith<$Res>? get triggeringWaypoint {
    if (_self.triggeringWaypoint == null) {
    return null;
  }

  return $RouteWaypointGoNoGoResultCopyWith<$Res>(_self.triggeringWaypoint!, (value) {
    return _then(_self.copyWith(triggeringWaypoint: value));
  });
}
}


/// Adds pattern-matching-related methods to [RouteGoNoGoResult].
extension RouteGoNoGoResultPatterns on RouteGoNoGoResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteGoNoGoResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteGoNoGoResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteGoNoGoResult value)  $default,){
final _that = this;
switch (_that) {
case _RouteGoNoGoResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteGoNoGoResult value)?  $default,){
final _that = this;
switch (_that) {
case _RouteGoNoGoResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GoNoGoVerdict verdict,  DateTime computedAt,  List<RouteWaypointGoNoGoResult> waypointResults,  List<RouteWaypointGoNoGoFailure> waypointFailures,  List<GoNoGoReason> triggeringReasons,  RouteWaypointGoNoGoResult? triggeringWaypoint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteGoNoGoResult() when $default != null:
return $default(_that.verdict,_that.computedAt,_that.waypointResults,_that.waypointFailures,_that.triggeringReasons,_that.triggeringWaypoint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GoNoGoVerdict verdict,  DateTime computedAt,  List<RouteWaypointGoNoGoResult> waypointResults,  List<RouteWaypointGoNoGoFailure> waypointFailures,  List<GoNoGoReason> triggeringReasons,  RouteWaypointGoNoGoResult? triggeringWaypoint)  $default,) {final _that = this;
switch (_that) {
case _RouteGoNoGoResult():
return $default(_that.verdict,_that.computedAt,_that.waypointResults,_that.waypointFailures,_that.triggeringReasons,_that.triggeringWaypoint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GoNoGoVerdict verdict,  DateTime computedAt,  List<RouteWaypointGoNoGoResult> waypointResults,  List<RouteWaypointGoNoGoFailure> waypointFailures,  List<GoNoGoReason> triggeringReasons,  RouteWaypointGoNoGoResult? triggeringWaypoint)?  $default,) {final _that = this;
switch (_that) {
case _RouteGoNoGoResult() when $default != null:
return $default(_that.verdict,_that.computedAt,_that.waypointResults,_that.waypointFailures,_that.triggeringReasons,_that.triggeringWaypoint);case _:
  return null;

}
}

}

/// @nodoc


class _RouteGoNoGoResult with DiagnosticableTreeMixin implements RouteGoNoGoResult {
  const _RouteGoNoGoResult({required this.verdict, required this.computedAt, required final  List<RouteWaypointGoNoGoResult> waypointResults, required final  List<RouteWaypointGoNoGoFailure> waypointFailures, required final  List<GoNoGoReason> triggeringReasons, this.triggeringWaypoint}): _waypointResults = waypointResults,_waypointFailures = waypointFailures,_triggeringReasons = triggeringReasons;
  

@override final  GoNoGoVerdict verdict;
@override final  DateTime computedAt;
 final  List<RouteWaypointGoNoGoResult> _waypointResults;
@override List<RouteWaypointGoNoGoResult> get waypointResults {
  if (_waypointResults is EqualUnmodifiableListView) return _waypointResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypointResults);
}

 final  List<RouteWaypointGoNoGoFailure> _waypointFailures;
@override List<RouteWaypointGoNoGoFailure> get waypointFailures {
  if (_waypointFailures is EqualUnmodifiableListView) return _waypointFailures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypointFailures);
}

 final  List<GoNoGoReason> _triggeringReasons;
@override List<GoNoGoReason> get triggeringReasons {
  if (_triggeringReasons is EqualUnmodifiableListView) return _triggeringReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_triggeringReasons);
}

@override final  RouteWaypointGoNoGoResult? triggeringWaypoint;

/// Create a copy of RouteGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteGoNoGoResultCopyWith<_RouteGoNoGoResult> get copyWith => __$RouteGoNoGoResultCopyWithImpl<_RouteGoNoGoResult>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RouteGoNoGoResult'))
    ..add(DiagnosticsProperty('verdict', verdict))..add(DiagnosticsProperty('computedAt', computedAt))..add(DiagnosticsProperty('waypointResults', waypointResults))..add(DiagnosticsProperty('waypointFailures', waypointFailures))..add(DiagnosticsProperty('triggeringReasons', triggeringReasons))..add(DiagnosticsProperty('triggeringWaypoint', triggeringWaypoint));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteGoNoGoResult&&(identical(other.verdict, verdict) || other.verdict == verdict)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt)&&const DeepCollectionEquality().equals(other._waypointResults, _waypointResults)&&const DeepCollectionEquality().equals(other._waypointFailures, _waypointFailures)&&const DeepCollectionEquality().equals(other._triggeringReasons, _triggeringReasons)&&(identical(other.triggeringWaypoint, triggeringWaypoint) || other.triggeringWaypoint == triggeringWaypoint));
}


@override
int get hashCode => Object.hash(runtimeType,verdict,computedAt,const DeepCollectionEquality().hash(_waypointResults),const DeepCollectionEquality().hash(_waypointFailures),const DeepCollectionEquality().hash(_triggeringReasons),triggeringWaypoint);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RouteGoNoGoResult(verdict: $verdict, computedAt: $computedAt, waypointResults: $waypointResults, waypointFailures: $waypointFailures, triggeringReasons: $triggeringReasons, triggeringWaypoint: $triggeringWaypoint)';
}


}

/// @nodoc
abstract mixin class _$RouteGoNoGoResultCopyWith<$Res> implements $RouteGoNoGoResultCopyWith<$Res> {
  factory _$RouteGoNoGoResultCopyWith(_RouteGoNoGoResult value, $Res Function(_RouteGoNoGoResult) _then) = __$RouteGoNoGoResultCopyWithImpl;
@override @useResult
$Res call({
 GoNoGoVerdict verdict, DateTime computedAt, List<RouteWaypointGoNoGoResult> waypointResults, List<RouteWaypointGoNoGoFailure> waypointFailures, List<GoNoGoReason> triggeringReasons, RouteWaypointGoNoGoResult? triggeringWaypoint
});


@override $RouteWaypointGoNoGoResultCopyWith<$Res>? get triggeringWaypoint;

}
/// @nodoc
class __$RouteGoNoGoResultCopyWithImpl<$Res>
    implements _$RouteGoNoGoResultCopyWith<$Res> {
  __$RouteGoNoGoResultCopyWithImpl(this._self, this._then);

  final _RouteGoNoGoResult _self;
  final $Res Function(_RouteGoNoGoResult) _then;

/// Create a copy of RouteGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verdict = null,Object? computedAt = null,Object? waypointResults = null,Object? waypointFailures = null,Object? triggeringReasons = null,Object? triggeringWaypoint = freezed,}) {
  return _then(_RouteGoNoGoResult(
verdict: null == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as GoNoGoVerdict,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,waypointResults: null == waypointResults ? _self._waypointResults : waypointResults // ignore: cast_nullable_to_non_nullable
as List<RouteWaypointGoNoGoResult>,waypointFailures: null == waypointFailures ? _self._waypointFailures : waypointFailures // ignore: cast_nullable_to_non_nullable
as List<RouteWaypointGoNoGoFailure>,triggeringReasons: null == triggeringReasons ? _self._triggeringReasons : triggeringReasons // ignore: cast_nullable_to_non_nullable
as List<GoNoGoReason>,triggeringWaypoint: freezed == triggeringWaypoint ? _self.triggeringWaypoint : triggeringWaypoint // ignore: cast_nullable_to_non_nullable
as RouteWaypointGoNoGoResult?,
  ));
}

/// Create a copy of RouteGoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteWaypointGoNoGoResultCopyWith<$Res>? get triggeringWaypoint {
    if (_self.triggeringWaypoint == null) {
    return null;
  }

  return $RouteWaypointGoNoGoResultCopyWith<$Res>(_self.triggeringWaypoint!, (value) {
    return _then(_self.copyWith(triggeringWaypoint: value));
  });
}
}

// dart format on
