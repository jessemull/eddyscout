// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_route_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
RouteWaypoint _$RouteWaypointFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'catalog':
          return CatalogRouteWaypoint.fromJson(
            json
          );
                case 'snap':
          return SnapRouteWaypoint.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'RouteWaypoint',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$RouteWaypoint {

 int get order;
/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteWaypointCopyWith<RouteWaypoint> get copyWith => _$RouteWaypointCopyWithImpl<RouteWaypoint>(this as RouteWaypoint, _$identity);

  /// Serializes this RouteWaypoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteWaypoint&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,order);

@override
String toString() {
  return 'RouteWaypoint(order: $order)';
}


}

/// @nodoc
abstract mixin class $RouteWaypointCopyWith<$Res>  {
  factory $RouteWaypointCopyWith(RouteWaypoint value, $Res Function(RouteWaypoint) _then) = _$RouteWaypointCopyWithImpl;
@useResult
$Res call({
 int order
});




}
/// @nodoc
class _$RouteWaypointCopyWithImpl<$Res>
    implements $RouteWaypointCopyWith<$Res> {
  _$RouteWaypointCopyWithImpl(this._self, this._then);

  final RouteWaypoint _self;
  final $Res Function(RouteWaypoint) _then;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,}) {
  return _then(_self.copyWith(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteWaypoint].
extension RouteWaypointPatterns on RouteWaypoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CatalogRouteWaypoint value)?  catalog,TResult Function( SnapRouteWaypoint value)?  snap,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CatalogRouteWaypoint() when catalog != null:
return catalog(_that);case SnapRouteWaypoint() when snap != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CatalogRouteWaypoint value)  catalog,required TResult Function( SnapRouteWaypoint value)  snap,}){
final _that = this;
switch (_that) {
case CatalogRouteWaypoint():
return catalog(_that);case SnapRouteWaypoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CatalogRouteWaypoint value)?  catalog,TResult? Function( SnapRouteWaypoint value)?  snap,}){
final _that = this;
switch (_that) {
case CatalogRouteWaypoint() when catalog != null:
return catalog(_that);case SnapRouteWaypoint() when snap != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String launchId,  int order)?  catalog,TResult Function( double latitude,  double longitude,  int order,  String? label)?  snap,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CatalogRouteWaypoint() when catalog != null:
return catalog(_that.launchId,_that.order);case SnapRouteWaypoint() when snap != null:
return snap(_that.latitude,_that.longitude,_that.order,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String launchId,  int order)  catalog,required TResult Function( double latitude,  double longitude,  int order,  String? label)  snap,}) {final _that = this;
switch (_that) {
case CatalogRouteWaypoint():
return catalog(_that.launchId,_that.order);case SnapRouteWaypoint():
return snap(_that.latitude,_that.longitude,_that.order,_that.label);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String launchId,  int order)?  catalog,TResult? Function( double latitude,  double longitude,  int order,  String? label)?  snap,}) {final _that = this;
switch (_that) {
case CatalogRouteWaypoint() when catalog != null:
return catalog(_that.launchId,_that.order);case SnapRouteWaypoint() when snap != null:
return snap(_that.latitude,_that.longitude,_that.order,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CatalogRouteWaypoint extends RouteWaypoint {
  const CatalogRouteWaypoint({required this.launchId, required this.order, final  String? $type}): $type = $type ?? 'catalog',super._();
  factory CatalogRouteWaypoint.fromJson(Map<String, dynamic> json) => _$CatalogRouteWaypointFromJson(json);

 final  String launchId;
@override final  int order;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogRouteWaypointCopyWith<CatalogRouteWaypoint> get copyWith => _$CatalogRouteWaypointCopyWithImpl<CatalogRouteWaypoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogRouteWaypointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogRouteWaypoint&&(identical(other.launchId, launchId) || other.launchId == launchId)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,launchId,order);

@override
String toString() {
  return 'RouteWaypoint.catalog(launchId: $launchId, order: $order)';
}


}

/// @nodoc
abstract mixin class $CatalogRouteWaypointCopyWith<$Res> implements $RouteWaypointCopyWith<$Res> {
  factory $CatalogRouteWaypointCopyWith(CatalogRouteWaypoint value, $Res Function(CatalogRouteWaypoint) _then) = _$CatalogRouteWaypointCopyWithImpl;
@override @useResult
$Res call({
 String launchId, int order
});




}
/// @nodoc
class _$CatalogRouteWaypointCopyWithImpl<$Res>
    implements $CatalogRouteWaypointCopyWith<$Res> {
  _$CatalogRouteWaypointCopyWithImpl(this._self, this._then);

  final CatalogRouteWaypoint _self;
  final $Res Function(CatalogRouteWaypoint) _then;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? launchId = null,Object? order = null,}) {
  return _then(CatalogRouteWaypoint(
launchId: null == launchId ? _self.launchId : launchId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SnapRouteWaypoint extends RouteWaypoint {
  const SnapRouteWaypoint({required this.latitude, required this.longitude, required this.order, this.label, final  String? $type}): $type = $type ?? 'snap',super._();
  factory SnapRouteWaypoint.fromJson(Map<String, dynamic> json) => _$SnapRouteWaypointFromJson(json);

 final  double latitude;
 final  double longitude;
@override final  int order;
 final  String? label;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapRouteWaypointCopyWith<SnapRouteWaypoint> get copyWith => _$SnapRouteWaypointCopyWithImpl<SnapRouteWaypoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnapRouteWaypointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnapRouteWaypoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.order, order) || other.order == order)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,order,label);

@override
String toString() {
  return 'RouteWaypoint.snap(latitude: $latitude, longitude: $longitude, order: $order, label: $label)';
}


}

/// @nodoc
abstract mixin class $SnapRouteWaypointCopyWith<$Res> implements $RouteWaypointCopyWith<$Res> {
  factory $SnapRouteWaypointCopyWith(SnapRouteWaypoint value, $Res Function(SnapRouteWaypoint) _then) = _$SnapRouteWaypointCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, int order, String? label
});




}
/// @nodoc
class _$SnapRouteWaypointCopyWithImpl<$Res>
    implements $SnapRouteWaypointCopyWith<$Res> {
  _$SnapRouteWaypointCopyWithImpl(this._self, this._then);

  final SnapRouteWaypoint _self;
  final $Res Function(SnapRouteWaypoint) _then;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? order = null,Object? label = freezed,}) {
  return _then(SnapRouteWaypoint(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RouteGeometrySnapshot {

/// Vertices along the river path in Mapbox `[lon, lat]` order.
 List<List<double>> get polylineLonLat;/// Total path length in meters.
 double get lengthMeters;/// When this geometry was computed.
 DateTime get computedAt;
/// Create a copy of RouteGeometrySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteGeometrySnapshotCopyWith<RouteGeometrySnapshot> get copyWith => _$RouteGeometrySnapshotCopyWithImpl<RouteGeometrySnapshot>(this as RouteGeometrySnapshot, _$identity);

  /// Serializes this RouteGeometrySnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteGeometrySnapshot&&const DeepCollectionEquality().equals(other.polylineLonLat, polylineLonLat)&&(identical(other.lengthMeters, lengthMeters) || other.lengthMeters == lengthMeters)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(polylineLonLat),lengthMeters,computedAt);

@override
String toString() {
  return 'RouteGeometrySnapshot(polylineLonLat: $polylineLonLat, lengthMeters: $lengthMeters, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class $RouteGeometrySnapshotCopyWith<$Res>  {
  factory $RouteGeometrySnapshotCopyWith(RouteGeometrySnapshot value, $Res Function(RouteGeometrySnapshot) _then) = _$RouteGeometrySnapshotCopyWithImpl;
@useResult
$Res call({
 List<List<double>> polylineLonLat, double lengthMeters, DateTime computedAt
});




}
/// @nodoc
class _$RouteGeometrySnapshotCopyWithImpl<$Res>
    implements $RouteGeometrySnapshotCopyWith<$Res> {
  _$RouteGeometrySnapshotCopyWithImpl(this._self, this._then);

  final RouteGeometrySnapshot _self;
  final $Res Function(RouteGeometrySnapshot) _then;

/// Create a copy of RouteGeometrySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? polylineLonLat = null,Object? lengthMeters = null,Object? computedAt = null,}) {
  return _then(_self.copyWith(
polylineLonLat: null == polylineLonLat ? _self.polylineLonLat : polylineLonLat // ignore: cast_nullable_to_non_nullable
as List<List<double>>,lengthMeters: null == lengthMeters ? _self.lengthMeters : lengthMeters // ignore: cast_nullable_to_non_nullable
as double,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteGeometrySnapshot].
extension RouteGeometrySnapshotPatterns on RouteGeometrySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteGeometrySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteGeometrySnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteGeometrySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RouteGeometrySnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteGeometrySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RouteGeometrySnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<List<double>> polylineLonLat,  double lengthMeters,  DateTime computedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteGeometrySnapshot() when $default != null:
return $default(_that.polylineLonLat,_that.lengthMeters,_that.computedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<List<double>> polylineLonLat,  double lengthMeters,  DateTime computedAt)  $default,) {final _that = this;
switch (_that) {
case _RouteGeometrySnapshot():
return $default(_that.polylineLonLat,_that.lengthMeters,_that.computedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<List<double>> polylineLonLat,  double lengthMeters,  DateTime computedAt)?  $default,) {final _that = this;
switch (_that) {
case _RouteGeometrySnapshot() when $default != null:
return $default(_that.polylineLonLat,_that.lengthMeters,_that.computedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteGeometrySnapshot implements RouteGeometrySnapshot {
  const _RouteGeometrySnapshot({required final  List<List<double>> polylineLonLat, required this.lengthMeters, required this.computedAt}): _polylineLonLat = polylineLonLat;
  factory _RouteGeometrySnapshot.fromJson(Map<String, dynamic> json) => _$RouteGeometrySnapshotFromJson(json);

/// Vertices along the river path in Mapbox `[lon, lat]` order.
 final  List<List<double>> _polylineLonLat;
/// Vertices along the river path in Mapbox `[lon, lat]` order.
@override List<List<double>> get polylineLonLat {
  if (_polylineLonLat is EqualUnmodifiableListView) return _polylineLonLat;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_polylineLonLat);
}

/// Total path length in meters.
@override final  double lengthMeters;
/// When this geometry was computed.
@override final  DateTime computedAt;

/// Create a copy of RouteGeometrySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteGeometrySnapshotCopyWith<_RouteGeometrySnapshot> get copyWith => __$RouteGeometrySnapshotCopyWithImpl<_RouteGeometrySnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteGeometrySnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteGeometrySnapshot&&const DeepCollectionEquality().equals(other._polylineLonLat, _polylineLonLat)&&(identical(other.lengthMeters, lengthMeters) || other.lengthMeters == lengthMeters)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_polylineLonLat),lengthMeters,computedAt);

@override
String toString() {
  return 'RouteGeometrySnapshot(polylineLonLat: $polylineLonLat, lengthMeters: $lengthMeters, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class _$RouteGeometrySnapshotCopyWith<$Res> implements $RouteGeometrySnapshotCopyWith<$Res> {
  factory _$RouteGeometrySnapshotCopyWith(_RouteGeometrySnapshot value, $Res Function(_RouteGeometrySnapshot) _then) = __$RouteGeometrySnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<List<double>> polylineLonLat, double lengthMeters, DateTime computedAt
});




}
/// @nodoc
class __$RouteGeometrySnapshotCopyWithImpl<$Res>
    implements _$RouteGeometrySnapshotCopyWith<$Res> {
  __$RouteGeometrySnapshotCopyWithImpl(this._self, this._then);

  final _RouteGeometrySnapshot _self;
  final $Res Function(_RouteGeometrySnapshot) _then;

/// Create a copy of RouteGeometrySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? polylineLonLat = null,Object? lengthMeters = null,Object? computedAt = null,}) {
  return _then(_RouteGeometrySnapshot(
polylineLonLat: null == polylineLonLat ? _self._polylineLonLat : polylineLonLat // ignore: cast_nullable_to_non_nullable
as List<List<double>>,lengthMeters: null == lengthMeters ? _self.lengthMeters : lengthMeters // ignore: cast_nullable_to_non_nullable
as double,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SavedRouteMetadata {

@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson) RouteDifficulty? get difficulty; double? get distanceMeters; int? get estimatedDurationMinutes;@JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson) WindExposure? get exposure;@JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson) TideRelevance? get tideDependency;@JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson) RecommendedSkillLevel? get recommendedSkillLevel; List<String> get categories;
/// Create a copy of SavedRouteMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedRouteMetadataCopyWith<SavedRouteMetadata> get copyWith => _$SavedRouteMetadataCopyWithImpl<SavedRouteMetadata>(this as SavedRouteMetadata, _$identity);

  /// Serializes this SavedRouteMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedRouteMetadata&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.exposure, exposure) || other.exposure == exposure)&&(identical(other.tideDependency, tideDependency) || other.tideDependency == tideDependency)&&(identical(other.recommendedSkillLevel, recommendedSkillLevel) || other.recommendedSkillLevel == recommendedSkillLevel)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,difficulty,distanceMeters,estimatedDurationMinutes,exposure,tideDependency,recommendedSkillLevel,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'SavedRouteMetadata(difficulty: $difficulty, distanceMeters: $distanceMeters, estimatedDurationMinutes: $estimatedDurationMinutes, exposure: $exposure, tideDependency: $tideDependency, recommendedSkillLevel: $recommendedSkillLevel, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $SavedRouteMetadataCopyWith<$Res>  {
  factory $SavedRouteMetadataCopyWith(SavedRouteMetadata value, $Res Function(SavedRouteMetadata) _then) = _$SavedRouteMetadataCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson) RouteDifficulty? difficulty, double? distanceMeters, int? estimatedDurationMinutes,@JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson) WindExposure? exposure,@JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson) TideRelevance? tideDependency,@JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson) RecommendedSkillLevel? recommendedSkillLevel, List<String> categories
});




}
/// @nodoc
class _$SavedRouteMetadataCopyWithImpl<$Res>
    implements $SavedRouteMetadataCopyWith<$Res> {
  _$SavedRouteMetadataCopyWithImpl(this._self, this._then);

  final SavedRouteMetadata _self;
  final $Res Function(SavedRouteMetadata) _then;

/// Create a copy of SavedRouteMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? difficulty = freezed,Object? distanceMeters = freezed,Object? estimatedDurationMinutes = freezed,Object? exposure = freezed,Object? tideDependency = freezed,Object? recommendedSkillLevel = freezed,Object? categories = null,}) {
  return _then(_self.copyWith(
difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as RouteDifficulty?,distanceMeters: freezed == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,exposure: freezed == exposure ? _self.exposure : exposure // ignore: cast_nullable_to_non_nullable
as WindExposure?,tideDependency: freezed == tideDependency ? _self.tideDependency : tideDependency // ignore: cast_nullable_to_non_nullable
as TideRelevance?,recommendedSkillLevel: freezed == recommendedSkillLevel ? _self.recommendedSkillLevel : recommendedSkillLevel // ignore: cast_nullable_to_non_nullable
as RecommendedSkillLevel?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedRouteMetadata].
extension SavedRouteMetadataPatterns on SavedRouteMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedRouteMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedRouteMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedRouteMetadata value)  $default,){
final _that = this;
switch (_that) {
case _SavedRouteMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedRouteMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _SavedRouteMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson)  RouteDifficulty? difficulty,  double? distanceMeters,  int? estimatedDurationMinutes, @JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson)  WindExposure? exposure, @JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson)  TideRelevance? tideDependency, @JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson)  RecommendedSkillLevel? recommendedSkillLevel,  List<String> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedRouteMetadata() when $default != null:
return $default(_that.difficulty,_that.distanceMeters,_that.estimatedDurationMinutes,_that.exposure,_that.tideDependency,_that.recommendedSkillLevel,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson)  RouteDifficulty? difficulty,  double? distanceMeters,  int? estimatedDurationMinutes, @JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson)  WindExposure? exposure, @JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson)  TideRelevance? tideDependency, @JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson)  RecommendedSkillLevel? recommendedSkillLevel,  List<String> categories)  $default,) {final _that = this;
switch (_that) {
case _SavedRouteMetadata():
return $default(_that.difficulty,_that.distanceMeters,_that.estimatedDurationMinutes,_that.exposure,_that.tideDependency,_that.recommendedSkillLevel,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson)  RouteDifficulty? difficulty,  double? distanceMeters,  int? estimatedDurationMinutes, @JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson)  WindExposure? exposure, @JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson)  TideRelevance? tideDependency, @JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson)  RecommendedSkillLevel? recommendedSkillLevel,  List<String> categories)?  $default,) {final _that = this;
switch (_that) {
case _SavedRouteMetadata() when $default != null:
return $default(_that.difficulty,_that.distanceMeters,_that.estimatedDurationMinutes,_that.exposure,_that.tideDependency,_that.recommendedSkillLevel,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedRouteMetadata implements SavedRouteMetadata {
  const _SavedRouteMetadata({@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson) this.difficulty, this.distanceMeters, this.estimatedDurationMinutes, @JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson) this.exposure, @JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson) this.tideDependency, @JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson) this.recommendedSkillLevel, final  List<String> categories = const <String>[]}): _categories = categories;
  factory _SavedRouteMetadata.fromJson(Map<String, dynamic> json) => _$SavedRouteMetadataFromJson(json);

@override@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson) final  RouteDifficulty? difficulty;
@override final  double? distanceMeters;
@override final  int? estimatedDurationMinutes;
@override@JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson) final  WindExposure? exposure;
@override@JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson) final  TideRelevance? tideDependency;
@override@JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson) final  RecommendedSkillLevel? recommendedSkillLevel;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of SavedRouteMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedRouteMetadataCopyWith<_SavedRouteMetadata> get copyWith => __$SavedRouteMetadataCopyWithImpl<_SavedRouteMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedRouteMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedRouteMetadata&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.exposure, exposure) || other.exposure == exposure)&&(identical(other.tideDependency, tideDependency) || other.tideDependency == tideDependency)&&(identical(other.recommendedSkillLevel, recommendedSkillLevel) || other.recommendedSkillLevel == recommendedSkillLevel)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,difficulty,distanceMeters,estimatedDurationMinutes,exposure,tideDependency,recommendedSkillLevel,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'SavedRouteMetadata(difficulty: $difficulty, distanceMeters: $distanceMeters, estimatedDurationMinutes: $estimatedDurationMinutes, exposure: $exposure, tideDependency: $tideDependency, recommendedSkillLevel: $recommendedSkillLevel, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$SavedRouteMetadataCopyWith<$Res> implements $SavedRouteMetadataCopyWith<$Res> {
  factory _$SavedRouteMetadataCopyWith(_SavedRouteMetadata value, $Res Function(_SavedRouteMetadata) _then) = __$SavedRouteMetadataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson) RouteDifficulty? difficulty, double? distanceMeters, int? estimatedDurationMinutes,@JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson) WindExposure? exposure,@JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson) TideRelevance? tideDependency,@JsonKey(fromJson: _recommendedSkillLevelFromJson, toJson: _recommendedSkillLevelToJson) RecommendedSkillLevel? recommendedSkillLevel, List<String> categories
});




}
/// @nodoc
class __$SavedRouteMetadataCopyWithImpl<$Res>
    implements _$SavedRouteMetadataCopyWith<$Res> {
  __$SavedRouteMetadataCopyWithImpl(this._self, this._then);

  final _SavedRouteMetadata _self;
  final $Res Function(_SavedRouteMetadata) _then;

/// Create a copy of SavedRouteMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? difficulty = freezed,Object? distanceMeters = freezed,Object? estimatedDurationMinutes = freezed,Object? exposure = freezed,Object? tideDependency = freezed,Object? recommendedSkillLevel = freezed,Object? categories = null,}) {
  return _then(_SavedRouteMetadata(
difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as RouteDifficulty?,distanceMeters: freezed == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,exposure: freezed == exposure ? _self.exposure : exposure // ignore: cast_nullable_to_non_nullable
as WindExposure?,tideDependency: freezed == tideDependency ? _self.tideDependency : tideDependency // ignore: cast_nullable_to_non_nullable
as TideRelevance?,recommendedSkillLevel: freezed == recommendedSkillLevel ? _self.recommendedSkillLevel : recommendedSkillLevel // ignore: cast_nullable_to_non_nullable
as RecommendedSkillLevel?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$SavedRoute {

 String get id; String get name; List<RouteWaypoint> get waypoints; SavedRouteMetadata get metadata; DateTime get createdAt; DateTime get updatedAt; String? get description; String get notes; bool get isFavorite; bool get isPrivate; RouteGeometrySnapshot? get geometrySnapshot;
/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedRouteCopyWith<SavedRoute> get copyWith => _$SavedRouteCopyWithImpl<SavedRoute>(this as SavedRoute, _$identity);

  /// Serializes this SavedRoute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.waypoints, waypoints)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.geometrySnapshot, geometrySnapshot) || other.geometrySnapshot == geometrySnapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(waypoints),metadata,createdAt,updatedAt,description,notes,isFavorite,isPrivate,geometrySnapshot);

@override
String toString() {
  return 'SavedRoute(id: $id, name: $name, waypoints: $waypoints, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, notes: $notes, isFavorite: $isFavorite, isPrivate: $isPrivate, geometrySnapshot: $geometrySnapshot)';
}


}

/// @nodoc
abstract mixin class $SavedRouteCopyWith<$Res>  {
  factory $SavedRouteCopyWith(SavedRoute value, $Res Function(SavedRoute) _then) = _$SavedRouteCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<RouteWaypoint> waypoints, SavedRouteMetadata metadata, DateTime createdAt, DateTime updatedAt, String? description, String notes, bool isFavorite, bool isPrivate, RouteGeometrySnapshot? geometrySnapshot
});


$SavedRouteMetadataCopyWith<$Res> get metadata;$RouteGeometrySnapshotCopyWith<$Res>? get geometrySnapshot;

}
/// @nodoc
class _$SavedRouteCopyWithImpl<$Res>
    implements $SavedRouteCopyWith<$Res> {
  _$SavedRouteCopyWithImpl(this._self, this._then);

  final SavedRoute _self;
  final $Res Function(SavedRoute) _then;

/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? waypoints = null,Object? metadata = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? notes = null,Object? isFavorite = null,Object? isPrivate = null,Object? geometrySnapshot = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,waypoints: null == waypoints ? _self.waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<RouteWaypoint>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as SavedRouteMetadata,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,geometrySnapshot: freezed == geometrySnapshot ? _self.geometrySnapshot : geometrySnapshot // ignore: cast_nullable_to_non_nullable
as RouteGeometrySnapshot?,
  ));
}
/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedRouteMetadataCopyWith<$Res> get metadata {
  
  return $SavedRouteMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteGeometrySnapshotCopyWith<$Res>? get geometrySnapshot {
    if (_self.geometrySnapshot == null) {
    return null;
  }

  return $RouteGeometrySnapshotCopyWith<$Res>(_self.geometrySnapshot!, (value) {
    return _then(_self.copyWith(geometrySnapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [SavedRoute].
extension SavedRoutePatterns on SavedRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedRoute value)  $default,){
final _that = this;
switch (_that) {
case _SavedRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedRoute value)?  $default,){
final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<RouteWaypoint> waypoints,  SavedRouteMetadata metadata,  DateTime createdAt,  DateTime updatedAt,  String? description,  String notes,  bool isFavorite,  bool isPrivate,  RouteGeometrySnapshot? geometrySnapshot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
return $default(_that.id,_that.name,_that.waypoints,_that.metadata,_that.createdAt,_that.updatedAt,_that.description,_that.notes,_that.isFavorite,_that.isPrivate,_that.geometrySnapshot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<RouteWaypoint> waypoints,  SavedRouteMetadata metadata,  DateTime createdAt,  DateTime updatedAt,  String? description,  String notes,  bool isFavorite,  bool isPrivate,  RouteGeometrySnapshot? geometrySnapshot)  $default,) {final _that = this;
switch (_that) {
case _SavedRoute():
return $default(_that.id,_that.name,_that.waypoints,_that.metadata,_that.createdAt,_that.updatedAt,_that.description,_that.notes,_that.isFavorite,_that.isPrivate,_that.geometrySnapshot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<RouteWaypoint> waypoints,  SavedRouteMetadata metadata,  DateTime createdAt,  DateTime updatedAt,  String? description,  String notes,  bool isFavorite,  bool isPrivate,  RouteGeometrySnapshot? geometrySnapshot)?  $default,) {final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
return $default(_that.id,_that.name,_that.waypoints,_that.metadata,_that.createdAt,_that.updatedAt,_that.description,_that.notes,_that.isFavorite,_that.isPrivate,_that.geometrySnapshot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedRoute implements SavedRoute {
  const _SavedRoute({required this.id, required this.name, required final  List<RouteWaypoint> waypoints, required this.metadata, required this.createdAt, required this.updatedAt, this.description, this.notes = '', this.isFavorite = false, this.isPrivate = true, this.geometrySnapshot}): _waypoints = waypoints;
  factory _SavedRoute.fromJson(Map<String, dynamic> json) => _$SavedRouteFromJson(json);

@override final  String id;
@override final  String name;
 final  List<RouteWaypoint> _waypoints;
@override List<RouteWaypoint> get waypoints {
  if (_waypoints is EqualUnmodifiableListView) return _waypoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypoints);
}

@override final  SavedRouteMetadata metadata;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? description;
@override@JsonKey() final  String notes;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool isPrivate;
@override final  RouteGeometrySnapshot? geometrySnapshot;

/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedRouteCopyWith<_SavedRoute> get copyWith => __$SavedRouteCopyWithImpl<_SavedRoute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedRouteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._waypoints, _waypoints)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.geometrySnapshot, geometrySnapshot) || other.geometrySnapshot == geometrySnapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_waypoints),metadata,createdAt,updatedAt,description,notes,isFavorite,isPrivate,geometrySnapshot);

@override
String toString() {
  return 'SavedRoute(id: $id, name: $name, waypoints: $waypoints, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, notes: $notes, isFavorite: $isFavorite, isPrivate: $isPrivate, geometrySnapshot: $geometrySnapshot)';
}


}

/// @nodoc
abstract mixin class _$SavedRouteCopyWith<$Res> implements $SavedRouteCopyWith<$Res> {
  factory _$SavedRouteCopyWith(_SavedRoute value, $Res Function(_SavedRoute) _then) = __$SavedRouteCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<RouteWaypoint> waypoints, SavedRouteMetadata metadata, DateTime createdAt, DateTime updatedAt, String? description, String notes, bool isFavorite, bool isPrivate, RouteGeometrySnapshot? geometrySnapshot
});


@override $SavedRouteMetadataCopyWith<$Res> get metadata;@override $RouteGeometrySnapshotCopyWith<$Res>? get geometrySnapshot;

}
/// @nodoc
class __$SavedRouteCopyWithImpl<$Res>
    implements _$SavedRouteCopyWith<$Res> {
  __$SavedRouteCopyWithImpl(this._self, this._then);

  final _SavedRoute _self;
  final $Res Function(_SavedRoute) _then;

/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? waypoints = null,Object? metadata = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? notes = null,Object? isFavorite = null,Object? isPrivate = null,Object? geometrySnapshot = freezed,}) {
  return _then(_SavedRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,waypoints: null == waypoints ? _self._waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<RouteWaypoint>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as SavedRouteMetadata,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,geometrySnapshot: freezed == geometrySnapshot ? _self.geometrySnapshot : geometrySnapshot // ignore: cast_nullable_to_non_nullable
as RouteGeometrySnapshot?,
  ));
}

/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SavedRouteMetadataCopyWith<$Res> get metadata {
  
  return $SavedRouteMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RouteGeometrySnapshotCopyWith<$Res>? get geometrySnapshot {
    if (_self.geometrySnapshot == null) {
    return null;
  }

  return $RouteGeometrySnapshotCopyWith<$Res>(_self.geometrySnapshot!, (value) {
    return _then(_self.copyWith(geometrySnapshot: value));
  });
}
}

// dart format on
