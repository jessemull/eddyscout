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
mixin _$PlannedRoute {

 String get putInLaunchId; String get takeOutLaunchId; RiverSystem get riverSystem; List<List<double>> get polylineLonLat; double get lengthMeters; String? get reachId;
/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedRouteCopyWith<PlannedRoute> get copyWith => _$PlannedRouteCopyWithImpl<PlannedRoute>(this as PlannedRoute, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedRoute&&(identical(other.putInLaunchId, putInLaunchId) || other.putInLaunchId == putInLaunchId)&&(identical(other.takeOutLaunchId, takeOutLaunchId) || other.takeOutLaunchId == takeOutLaunchId)&&(identical(other.riverSystem, riverSystem) || other.riverSystem == riverSystem)&&const DeepCollectionEquality().equals(other.polylineLonLat, polylineLonLat)&&(identical(other.lengthMeters, lengthMeters) || other.lengthMeters == lengthMeters)&&(identical(other.reachId, reachId) || other.reachId == reachId));
}


@override
int get hashCode => Object.hash(runtimeType,putInLaunchId,takeOutLaunchId,riverSystem,const DeepCollectionEquality().hash(polylineLonLat),lengthMeters,reachId);

@override
String toString() {
  return 'PlannedRoute(putInLaunchId: $putInLaunchId, takeOutLaunchId: $takeOutLaunchId, riverSystem: $riverSystem, polylineLonLat: $polylineLonLat, lengthMeters: $lengthMeters, reachId: $reachId)';
}


}

/// @nodoc
abstract mixin class $PlannedRouteCopyWith<$Res>  {
  factory $PlannedRouteCopyWith(PlannedRoute value, $Res Function(PlannedRoute) _then) = _$PlannedRouteCopyWithImpl;
@useResult
$Res call({
 String putInLaunchId, String takeOutLaunchId, RiverSystem riverSystem, List<List<double>> polylineLonLat, double lengthMeters, String? reachId
});




}
/// @nodoc
class _$PlannedRouteCopyWithImpl<$Res>
    implements $PlannedRouteCopyWith<$Res> {
  _$PlannedRouteCopyWithImpl(this._self, this._then);

  final PlannedRoute _self;
  final $Res Function(PlannedRoute) _then;

/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? putInLaunchId = null,Object? takeOutLaunchId = null,Object? riverSystem = null,Object? polylineLonLat = null,Object? lengthMeters = null,Object? reachId = freezed,}) {
  return _then(_self.copyWith(
putInLaunchId: null == putInLaunchId ? _self.putInLaunchId : putInLaunchId // ignore: cast_nullable_to_non_nullable
as String,takeOutLaunchId: null == takeOutLaunchId ? _self.takeOutLaunchId : takeOutLaunchId // ignore: cast_nullable_to_non_nullable
as String,riverSystem: null == riverSystem ? _self.riverSystem : riverSystem // ignore: cast_nullable_to_non_nullable
as RiverSystem,polylineLonLat: null == polylineLonLat ? _self.polylineLonLat : polylineLonLat // ignore: cast_nullable_to_non_nullable
as List<List<double>>,lengthMeters: null == lengthMeters ? _self.lengthMeters : lengthMeters // ignore: cast_nullable_to_non_nullable
as double,reachId: freezed == reachId ? _self.reachId : reachId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String putInLaunchId,  String takeOutLaunchId,  RiverSystem riverSystem,  List<List<double>> polylineLonLat,  double lengthMeters,  String? reachId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedRoute() when $default != null:
return $default(_that.putInLaunchId,_that.takeOutLaunchId,_that.riverSystem,_that.polylineLonLat,_that.lengthMeters,_that.reachId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String putInLaunchId,  String takeOutLaunchId,  RiverSystem riverSystem,  List<List<double>> polylineLonLat,  double lengthMeters,  String? reachId)  $default,) {final _that = this;
switch (_that) {
case _PlannedRoute():
return $default(_that.putInLaunchId,_that.takeOutLaunchId,_that.riverSystem,_that.polylineLonLat,_that.lengthMeters,_that.reachId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String putInLaunchId,  String takeOutLaunchId,  RiverSystem riverSystem,  List<List<double>> polylineLonLat,  double lengthMeters,  String? reachId)?  $default,) {final _that = this;
switch (_that) {
case _PlannedRoute() when $default != null:
return $default(_that.putInLaunchId,_that.takeOutLaunchId,_that.riverSystem,_that.polylineLonLat,_that.lengthMeters,_that.reachId);case _:
  return null;

}
}

}

/// @nodoc


class _PlannedRoute implements PlannedRoute {
  const _PlannedRoute({required this.putInLaunchId, required this.takeOutLaunchId, required this.riverSystem, required final  List<List<double>> polylineLonLat, required this.lengthMeters, this.reachId}): _polylineLonLat = polylineLonLat;
  

@override final  String putInLaunchId;
@override final  String takeOutLaunchId;
@override final  RiverSystem riverSystem;
 final  List<List<double>> _polylineLonLat;
@override List<List<double>> get polylineLonLat {
  if (_polylineLonLat is EqualUnmodifiableListView) return _polylineLonLat;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_polylineLonLat);
}

@override final  double lengthMeters;
@override final  String? reachId;

/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedRouteCopyWith<_PlannedRoute> get copyWith => __$PlannedRouteCopyWithImpl<_PlannedRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedRoute&&(identical(other.putInLaunchId, putInLaunchId) || other.putInLaunchId == putInLaunchId)&&(identical(other.takeOutLaunchId, takeOutLaunchId) || other.takeOutLaunchId == takeOutLaunchId)&&(identical(other.riverSystem, riverSystem) || other.riverSystem == riverSystem)&&const DeepCollectionEquality().equals(other._polylineLonLat, _polylineLonLat)&&(identical(other.lengthMeters, lengthMeters) || other.lengthMeters == lengthMeters)&&(identical(other.reachId, reachId) || other.reachId == reachId));
}


@override
int get hashCode => Object.hash(runtimeType,putInLaunchId,takeOutLaunchId,riverSystem,const DeepCollectionEquality().hash(_polylineLonLat),lengthMeters,reachId);

@override
String toString() {
  return 'PlannedRoute(putInLaunchId: $putInLaunchId, takeOutLaunchId: $takeOutLaunchId, riverSystem: $riverSystem, polylineLonLat: $polylineLonLat, lengthMeters: $lengthMeters, reachId: $reachId)';
}


}

/// @nodoc
abstract mixin class _$PlannedRouteCopyWith<$Res> implements $PlannedRouteCopyWith<$Res> {
  factory _$PlannedRouteCopyWith(_PlannedRoute value, $Res Function(_PlannedRoute) _then) = __$PlannedRouteCopyWithImpl;
@override @useResult
$Res call({
 String putInLaunchId, String takeOutLaunchId, RiverSystem riverSystem, List<List<double>> polylineLonLat, double lengthMeters, String? reachId
});




}
/// @nodoc
class __$PlannedRouteCopyWithImpl<$Res>
    implements _$PlannedRouteCopyWith<$Res> {
  __$PlannedRouteCopyWithImpl(this._self, this._then);

  final _PlannedRoute _self;
  final $Res Function(_PlannedRoute) _then;

/// Create a copy of PlannedRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? putInLaunchId = null,Object? takeOutLaunchId = null,Object? riverSystem = null,Object? polylineLonLat = null,Object? lengthMeters = null,Object? reachId = freezed,}) {
  return _then(_PlannedRoute(
putInLaunchId: null == putInLaunchId ? _self.putInLaunchId : putInLaunchId // ignore: cast_nullable_to_non_nullable
as String,takeOutLaunchId: null == takeOutLaunchId ? _self.takeOutLaunchId : takeOutLaunchId // ignore: cast_nullable_to_non_nullable
as String,riverSystem: null == riverSystem ? _self.riverSystem : riverSystem // ignore: cast_nullable_to_non_nullable
as RiverSystem,polylineLonLat: null == polylineLonLat ? _self._polylineLonLat : polylineLonLat // ignore: cast_nullable_to_non_nullable
as List<List<double>>,lengthMeters: null == lengthMeters ? _self.lengthMeters : lengthMeters // ignore: cast_nullable_to_non_nullable
as double,reachId: freezed == reachId ? _self.reachId : reachId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
