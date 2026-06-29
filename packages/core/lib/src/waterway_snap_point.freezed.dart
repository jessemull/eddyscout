// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'waterway_snap_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WaterwaySnapPoint {

 double get latitude; double get longitude; double get distanceMeters; String? get reachId;
/// Create a copy of WaterwaySnapPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaterwaySnapPointCopyWith<WaterwaySnapPoint> get copyWith => _$WaterwaySnapPointCopyWithImpl<WaterwaySnapPoint>(this as WaterwaySnapPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaterwaySnapPoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.reachId, reachId) || other.reachId == reachId));
}


@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,distanceMeters,reachId);

@override
String toString() {
  return 'WaterwaySnapPoint(latitude: $latitude, longitude: $longitude, distanceMeters: $distanceMeters, reachId: $reachId)';
}


}

/// @nodoc
abstract mixin class $WaterwaySnapPointCopyWith<$Res>  {
  factory $WaterwaySnapPointCopyWith(WaterwaySnapPoint value, $Res Function(WaterwaySnapPoint) _then) = _$WaterwaySnapPointCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double distanceMeters, String? reachId
});




}
/// @nodoc
class _$WaterwaySnapPointCopyWithImpl<$Res>
    implements $WaterwaySnapPointCopyWith<$Res> {
  _$WaterwaySnapPointCopyWithImpl(this._self, this._then);

  final WaterwaySnapPoint _self;
  final $Res Function(WaterwaySnapPoint) _then;

/// Create a copy of WaterwaySnapPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? distanceMeters = null,Object? reachId = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,reachId: freezed == reachId ? _self.reachId : reachId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WaterwaySnapPoint].
extension WaterwaySnapPointPatterns on WaterwaySnapPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaterwaySnapPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaterwaySnapPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaterwaySnapPoint value)  $default,){
final _that = this;
switch (_that) {
case _WaterwaySnapPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaterwaySnapPoint value)?  $default,){
final _that = this;
switch (_that) {
case _WaterwaySnapPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double distanceMeters,  String? reachId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaterwaySnapPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.distanceMeters,_that.reachId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double distanceMeters,  String? reachId)  $default,) {final _that = this;
switch (_that) {
case _WaterwaySnapPoint():
return $default(_that.latitude,_that.longitude,_that.distanceMeters,_that.reachId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double distanceMeters,  String? reachId)?  $default,) {final _that = this;
switch (_that) {
case _WaterwaySnapPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.distanceMeters,_that.reachId);case _:
  return null;

}
}

}

/// @nodoc


class _WaterwaySnapPoint implements WaterwaySnapPoint {
  const _WaterwaySnapPoint({required this.latitude, required this.longitude, required this.distanceMeters, this.reachId});
  

@override final  double latitude;
@override final  double longitude;
@override final  double distanceMeters;
@override final  String? reachId;

/// Create a copy of WaterwaySnapPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaterwaySnapPointCopyWith<_WaterwaySnapPoint> get copyWith => __$WaterwaySnapPointCopyWithImpl<_WaterwaySnapPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaterwaySnapPoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.reachId, reachId) || other.reachId == reachId));
}


@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,distanceMeters,reachId);

@override
String toString() {
  return 'WaterwaySnapPoint(latitude: $latitude, longitude: $longitude, distanceMeters: $distanceMeters, reachId: $reachId)';
}


}

/// @nodoc
abstract mixin class _$WaterwaySnapPointCopyWith<$Res> implements $WaterwaySnapPointCopyWith<$Res> {
  factory _$WaterwaySnapPointCopyWith(_WaterwaySnapPoint value, $Res Function(_WaterwaySnapPoint) _then) = __$WaterwaySnapPointCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double distanceMeters, String? reachId
});




}
/// @nodoc
class __$WaterwaySnapPointCopyWithImpl<$Res>
    implements _$WaterwaySnapPointCopyWith<$Res> {
  __$WaterwaySnapPointCopyWithImpl(this._self, this._then);

  final _WaterwaySnapPoint _self;
  final $Res Function(_WaterwaySnapPoint) _then;

/// Create a copy of WaterwaySnapPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? distanceMeters = null,Object? reachId = freezed,}) {
  return _then(_WaterwaySnapPoint(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,reachId: freezed == reachId ? _self.reachId : reachId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
