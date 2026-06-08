// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planned_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GpxPoint {

 double get latitude; double get longitude; double? get elevationMeters; DateTime? get timestamp;
/// Create a copy of GpxPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GpxPointCopyWith<GpxPoint> get copyWith => _$GpxPointCopyWithImpl<GpxPoint>(this as GpxPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GpxPoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.elevationMeters, elevationMeters) || other.elevationMeters == elevationMeters)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,elevationMeters,timestamp);

@override
String toString() {
  return 'GpxPoint(latitude: $latitude, longitude: $longitude, elevationMeters: $elevationMeters, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $GpxPointCopyWith<$Res>  {
  factory $GpxPointCopyWith(GpxPoint value, $Res Function(GpxPoint) _then) = _$GpxPointCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double? elevationMeters, DateTime? timestamp
});




}
/// @nodoc
class _$GpxPointCopyWithImpl<$Res>
    implements $GpxPointCopyWith<$Res> {
  _$GpxPointCopyWithImpl(this._self, this._then);

  final GpxPoint _self;
  final $Res Function(GpxPoint) _then;

/// Create a copy of GpxPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? elevationMeters = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,elevationMeters: freezed == elevationMeters ? _self.elevationMeters : elevationMeters // ignore: cast_nullable_to_non_nullable
as double?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GpxPoint].
extension GpxPointPatterns on GpxPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GpxPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GpxPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GpxPoint value)  $default,){
final _that = this;
switch (_that) {
case _GpxPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GpxPoint value)?  $default,){
final _that = this;
switch (_that) {
case _GpxPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? elevationMeters,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GpxPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.elevationMeters,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? elevationMeters,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _GpxPoint():
return $default(_that.latitude,_that.longitude,_that.elevationMeters,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double? elevationMeters,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _GpxPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.elevationMeters,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _GpxPoint implements GpxPoint {
  const _GpxPoint({required this.latitude, required this.longitude, this.elevationMeters, this.timestamp});
  

@override final  double latitude;
@override final  double longitude;
@override final  double? elevationMeters;
@override final  DateTime? timestamp;

/// Create a copy of GpxPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GpxPointCopyWith<_GpxPoint> get copyWith => __$GpxPointCopyWithImpl<_GpxPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GpxPoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.elevationMeters, elevationMeters) || other.elevationMeters == elevationMeters)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,elevationMeters,timestamp);

@override
String toString() {
  return 'GpxPoint(latitude: $latitude, longitude: $longitude, elevationMeters: $elevationMeters, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$GpxPointCopyWith<$Res> implements $GpxPointCopyWith<$Res> {
  factory _$GpxPointCopyWith(_GpxPoint value, $Res Function(_GpxPoint) _then) = __$GpxPointCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double? elevationMeters, DateTime? timestamp
});




}
/// @nodoc
class __$GpxPointCopyWithImpl<$Res>
    implements _$GpxPointCopyWith<$Res> {
  __$GpxPointCopyWithImpl(this._self, this._then);

  final _GpxPoint _self;
  final $Res Function(_GpxPoint) _then;

/// Create a copy of GpxPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? elevationMeters = freezed,Object? timestamp = freezed,}) {
  return _then(_GpxPoint(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,elevationMeters: freezed == elevationMeters ? _self.elevationMeters : elevationMeters // ignore: cast_nullable_to_non_nullable
as double?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$PlannedRoute {

 List<GpxPoint> get points; LaunchPoint? get putIn; LaunchPoint? get takeOut; double? get lengthMeters; String? get name; RouteOrigin get origin;
/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedRouteCopyWith<PlannedRoute> get copyWith => _$PlannedRouteCopyWithImpl<PlannedRoute>(this as PlannedRoute, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedRoute&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.putIn, putIn) || other.putIn == putIn)&&(identical(other.takeOut, takeOut) || other.takeOut == takeOut)&&(identical(other.lengthMeters, lengthMeters) || other.lengthMeters == lengthMeters)&&(identical(other.name, name) || other.name == name)&&(identical(other.origin, origin) || other.origin == origin));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(points),putIn,takeOut,lengthMeters,name,origin);

@override
String toString() {
  return 'PlannedRoute(points: $points, putIn: $putIn, takeOut: $takeOut, lengthMeters: $lengthMeters, name: $name, origin: $origin)';
}


}

/// @nodoc
abstract mixin class $PlannedRouteCopyWith<$Res>  {
  factory $PlannedRouteCopyWith(PlannedRoute value, $Res Function(PlannedRoute) _then) = _$PlannedRouteCopyWithImpl;
@useResult
$Res call({
 List<GpxPoint> points, LaunchPoint? putIn, LaunchPoint? takeOut, double? lengthMeters, String? name, RouteOrigin origin
});


$LaunchPointCopyWith<$Res>? get putIn;$LaunchPointCopyWith<$Res>? get takeOut;

}
/// @nodoc
class _$PlannedRouteCopyWithImpl<$Res>
    implements $PlannedRouteCopyWith<$Res> {
  _$PlannedRouteCopyWithImpl(this._self, this._then);

  final PlannedRoute _self;
  final $Res Function(PlannedRoute) _then;

/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? putIn = freezed,Object? takeOut = freezed,Object? lengthMeters = freezed,Object? name = freezed,Object? origin = null,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<GpxPoint>,putIn: freezed == putIn ? _self.putIn : putIn // ignore: cast_nullable_to_non_nullable
as LaunchPoint?,takeOut: freezed == takeOut ? _self.takeOut : takeOut // ignore: cast_nullable_to_non_nullable
as LaunchPoint?,lengthMeters: freezed == lengthMeters ? _self.lengthMeters : lengthMeters // ignore: cast_nullable_to_non_nullable
as double?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as RouteOrigin,
  ));
}
/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchPointCopyWith<$Res>? get putIn {
    if (_self.putIn == null) {
    return null;
  }

  return $LaunchPointCopyWith<$Res>(_self.putIn!, (value) {
    return _then(_self.copyWith(putIn: value));
  });
}/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchPointCopyWith<$Res>? get takeOut {
    if (_self.takeOut == null) {
    return null;
  }

  return $LaunchPointCopyWith<$Res>(_self.takeOut!, (value) {
    return _then(_self.copyWith(takeOut: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlannedRoute].
extension PlannedRoutePatterns on PlannedRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannedRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannedRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannedRoute value)  $default,){
final _that = this;
switch (_that) {
case _PlannedRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannedRoute value)?  $default,){
final _that = this;
switch (_that) {
case _PlannedRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GpxPoint> points,  LaunchPoint? putIn,  LaunchPoint? takeOut,  double? lengthMeters,  String? name,  RouteOrigin origin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedRoute() when $default != null:
return $default(_that.points,_that.putIn,_that.takeOut,_that.lengthMeters,_that.name,_that.origin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GpxPoint> points,  LaunchPoint? putIn,  LaunchPoint? takeOut,  double? lengthMeters,  String? name,  RouteOrigin origin)  $default,) {final _that = this;
switch (_that) {
case _PlannedRoute():
return $default(_that.points,_that.putIn,_that.takeOut,_that.lengthMeters,_that.name,_that.origin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GpxPoint> points,  LaunchPoint? putIn,  LaunchPoint? takeOut,  double? lengthMeters,  String? name,  RouteOrigin origin)?  $default,) {final _that = this;
switch (_that) {
case _PlannedRoute() when $default != null:
return $default(_that.points,_that.putIn,_that.takeOut,_that.lengthMeters,_that.name,_that.origin);case _:
  return null;

}
}

}

/// @nodoc


class _PlannedRoute extends PlannedRoute {
  const _PlannedRoute({required final  List<GpxPoint> points, this.putIn, this.takeOut, this.lengthMeters, this.name, this.origin = RouteOrigin.planner}): _points = points,super._();
  

 final  List<GpxPoint> _points;
@override List<GpxPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  LaunchPoint? putIn;
@override final  LaunchPoint? takeOut;
@override final  double? lengthMeters;
@override final  String? name;
@override@JsonKey() final  RouteOrigin origin;

/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedRouteCopyWith<_PlannedRoute> get copyWith => __$PlannedRouteCopyWithImpl<_PlannedRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedRoute&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.putIn, putIn) || other.putIn == putIn)&&(identical(other.takeOut, takeOut) || other.takeOut == takeOut)&&(identical(other.lengthMeters, lengthMeters) || other.lengthMeters == lengthMeters)&&(identical(other.name, name) || other.name == name)&&(identical(other.origin, origin) || other.origin == origin));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_points),putIn,takeOut,lengthMeters,name,origin);

@override
String toString() {
  return 'PlannedRoute(points: $points, putIn: $putIn, takeOut: $takeOut, lengthMeters: $lengthMeters, name: $name, origin: $origin)';
}


}

/// @nodoc
abstract mixin class _$PlannedRouteCopyWith<$Res> implements $PlannedRouteCopyWith<$Res> {
  factory _$PlannedRouteCopyWith(_PlannedRoute value, $Res Function(_PlannedRoute) _then) = __$PlannedRouteCopyWithImpl;
@override @useResult
$Res call({
 List<GpxPoint> points, LaunchPoint? putIn, LaunchPoint? takeOut, double? lengthMeters, String? name, RouteOrigin origin
});


@override $LaunchPointCopyWith<$Res>? get putIn;@override $LaunchPointCopyWith<$Res>? get takeOut;

}
/// @nodoc
class __$PlannedRouteCopyWithImpl<$Res>
    implements _$PlannedRouteCopyWith<$Res> {
  __$PlannedRouteCopyWithImpl(this._self, this._then);

  final _PlannedRoute _self;
  final $Res Function(_PlannedRoute) _then;

/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? putIn = freezed,Object? takeOut = freezed,Object? lengthMeters = freezed,Object? name = freezed,Object? origin = null,}) {
  return _then(_PlannedRoute(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<GpxPoint>,putIn: freezed == putIn ? _self.putIn : putIn // ignore: cast_nullable_to_non_nullable
as LaunchPoint?,takeOut: freezed == takeOut ? _self.takeOut : takeOut // ignore: cast_nullable_to_non_nullable
as LaunchPoint?,lengthMeters: freezed == lengthMeters ? _self.lengthMeters : lengthMeters // ignore: cast_nullable_to_non_nullable
as double?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as RouteOrigin,
  ));
}

/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchPointCopyWith<$Res>? get putIn {
    if (_self.putIn == null) {
    return null;
  }

  return $LaunchPointCopyWith<$Res>(_self.putIn!, (value) {
    return _then(_self.copyWith(putIn: value));
  });
}/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchPointCopyWith<$Res>? get takeOut {
    if (_self.takeOut == null) {
    return null;
  }

  return $LaunchPointCopyWith<$Res>(_self.takeOut!, (value) {
    return _then(_self.copyWith(takeOut: value));
  });
}
}

// dart format on
