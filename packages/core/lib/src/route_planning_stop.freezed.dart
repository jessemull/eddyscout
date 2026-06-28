// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_planning_stop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoutePlanningStop {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutePlanningStop);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoutePlanningStop()';
}


}

/// @nodoc
class $RoutePlanningStopCopyWith<$Res>  {
$RoutePlanningStopCopyWith(RoutePlanningStop _, $Res Function(RoutePlanningStop) __);
}


/// Adds pattern-matching-related methods to [RoutePlanningStop].
extension RoutePlanningStopPatterns on RoutePlanningStop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CatalogRoutePlanningStop value)?  catalog,TResult Function( SnapRoutePlanningStop value)?  snap,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CatalogRoutePlanningStop() when catalog != null:
return catalog(_that);case SnapRoutePlanningStop() when snap != null:
return snap(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CatalogRoutePlanningStop value)  catalog,required TResult Function( SnapRoutePlanningStop value)  snap,}){
final _that = this;
switch (_that) {
case CatalogRoutePlanningStop():
return catalog(_that);case SnapRoutePlanningStop():
return snap(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CatalogRoutePlanningStop value)?  catalog,TResult? Function( SnapRoutePlanningStop value)?  snap,}){
final _that = this;
switch (_that) {
case CatalogRoutePlanningStop() when catalog != null:
return catalog(_that);case SnapRoutePlanningStop() when snap != null:
return snap(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LaunchPoint launch)?  catalog,TResult Function( String id,  double latitude,  double longitude,  String label,  String? reachId)?  snap,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CatalogRoutePlanningStop() when catalog != null:
return catalog(_that.launch);case SnapRoutePlanningStop() when snap != null:
return snap(_that.id,_that.latitude,_that.longitude,_that.label,_that.reachId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LaunchPoint launch)  catalog,required TResult Function( String id,  double latitude,  double longitude,  String label,  String? reachId)  snap,}) {final _that = this;
switch (_that) {
case CatalogRoutePlanningStop():
return catalog(_that.launch);case SnapRoutePlanningStop():
return snap(_that.id,_that.latitude,_that.longitude,_that.label,_that.reachId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LaunchPoint launch)?  catalog,TResult? Function( String id,  double latitude,  double longitude,  String label,  String? reachId)?  snap,}) {final _that = this;
switch (_that) {
case CatalogRoutePlanningStop() when catalog != null:
return catalog(_that.launch);case SnapRoutePlanningStop() when snap != null:
return snap(_that.id,_that.latitude,_that.longitude,_that.label,_that.reachId);case _:
  return null;

}
}

}

/// @nodoc


class CatalogRoutePlanningStop extends RoutePlanningStop {
  const CatalogRoutePlanningStop(this.launch): super._();
  

 final  LaunchPoint launch;

/// Create a copy of RoutePlanningStop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogRoutePlanningStopCopyWith<CatalogRoutePlanningStop> get copyWith => _$CatalogRoutePlanningStopCopyWithImpl<CatalogRoutePlanningStop>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogRoutePlanningStop&&(identical(other.launch, launch) || other.launch == launch));
}


@override
int get hashCode => Object.hash(runtimeType,launch);

@override
String toString() {
  return 'RoutePlanningStop.catalog(launch: $launch)';
}


}

/// @nodoc
abstract mixin class $CatalogRoutePlanningStopCopyWith<$Res> implements $RoutePlanningStopCopyWith<$Res> {
  factory $CatalogRoutePlanningStopCopyWith(CatalogRoutePlanningStop value, $Res Function(CatalogRoutePlanningStop) _then) = _$CatalogRoutePlanningStopCopyWithImpl;
@useResult
$Res call({
 LaunchPoint launch
});


$LaunchPointCopyWith<$Res> get launch;

}
/// @nodoc
class _$CatalogRoutePlanningStopCopyWithImpl<$Res>
    implements $CatalogRoutePlanningStopCopyWith<$Res> {
  _$CatalogRoutePlanningStopCopyWithImpl(this._self, this._then);

  final CatalogRoutePlanningStop _self;
  final $Res Function(CatalogRoutePlanningStop) _then;

/// Create a copy of RoutePlanningStop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? launch = null,}) {
  return _then(CatalogRoutePlanningStop(
null == launch ? _self.launch : launch // ignore: cast_nullable_to_non_nullable
as LaunchPoint,
  ));
}

/// Create a copy of RoutePlanningStop
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchPointCopyWith<$Res> get launch {
  
  return $LaunchPointCopyWith<$Res>(_self.launch, (value) {
    return _then(_self.copyWith(launch: value));
  });
}
}

/// @nodoc


class SnapRoutePlanningStop extends RoutePlanningStop {
  const SnapRoutePlanningStop({required this.id, required this.latitude, required this.longitude, required this.label, this.reachId}): super._();
  

 final  String id;
 final  double latitude;
 final  double longitude;
 final  String label;
 final  String? reachId;

/// Create a copy of RoutePlanningStop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapRoutePlanningStopCopyWith<SnapRoutePlanningStop> get copyWith => _$SnapRoutePlanningStopCopyWithImpl<SnapRoutePlanningStop>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnapRoutePlanningStop&&(identical(other.id, id) || other.id == id)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.label, label) || other.label == label)&&(identical(other.reachId, reachId) || other.reachId == reachId));
}


@override
int get hashCode => Object.hash(runtimeType,id,latitude,longitude,label,reachId);

@override
String toString() {
  return 'RoutePlanningStop.snap(id: $id, latitude: $latitude, longitude: $longitude, label: $label, reachId: $reachId)';
}


}

/// @nodoc
abstract mixin class $SnapRoutePlanningStopCopyWith<$Res> implements $RoutePlanningStopCopyWith<$Res> {
  factory $SnapRoutePlanningStopCopyWith(SnapRoutePlanningStop value, $Res Function(SnapRoutePlanningStop) _then) = _$SnapRoutePlanningStopCopyWithImpl;
@useResult
$Res call({
 String id, double latitude, double longitude, String label, String? reachId
});




}
/// @nodoc
class _$SnapRoutePlanningStopCopyWithImpl<$Res>
    implements $SnapRoutePlanningStopCopyWith<$Res> {
  _$SnapRoutePlanningStopCopyWithImpl(this._self, this._then);

  final SnapRoutePlanningStop _self;
  final $Res Function(SnapRoutePlanningStop) _then;

/// Create a copy of RoutePlanningStop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? latitude = null,Object? longitude = null,Object? label = null,Object? reachId = freezed,}) {
  return _then(SnapRoutePlanningStop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,reachId: freezed == reachId ? _self.reachId : reachId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
