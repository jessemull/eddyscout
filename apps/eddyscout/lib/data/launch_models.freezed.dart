// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launch_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LaunchFlowBands {

/// Below this cfs → marginal (low-water / strainer risk cue).
 double? get cfsMarginalBelow;/// At or above → marginal (high, pushy water for this stretch).
 double? get cfsComfortMax;/// At or above → no-go (planning hint).
 double? get cfsNoGoAbove;
/// Create a copy of LaunchFlowBands
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchFlowBandsCopyWith<LaunchFlowBands> get copyWith => _$LaunchFlowBandsCopyWithImpl<LaunchFlowBands>(this as LaunchFlowBands, _$identity);

  /// Serializes this LaunchFlowBands to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchFlowBands&&(identical(other.cfsMarginalBelow, cfsMarginalBelow) || other.cfsMarginalBelow == cfsMarginalBelow)&&(identical(other.cfsComfortMax, cfsComfortMax) || other.cfsComfortMax == cfsComfortMax)&&(identical(other.cfsNoGoAbove, cfsNoGoAbove) || other.cfsNoGoAbove == cfsNoGoAbove));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cfsMarginalBelow,cfsComfortMax,cfsNoGoAbove);

@override
String toString() {
  return 'LaunchFlowBands(cfsMarginalBelow: $cfsMarginalBelow, cfsComfortMax: $cfsComfortMax, cfsNoGoAbove: $cfsNoGoAbove)';
}


}

/// @nodoc
abstract mixin class $LaunchFlowBandsCopyWith<$Res>  {
  factory $LaunchFlowBandsCopyWith(LaunchFlowBands value, $Res Function(LaunchFlowBands) _then) = _$LaunchFlowBandsCopyWithImpl;
@useResult
$Res call({
 double? cfsMarginalBelow, double? cfsComfortMax, double? cfsNoGoAbove
});




}
/// @nodoc
class _$LaunchFlowBandsCopyWithImpl<$Res>
    implements $LaunchFlowBandsCopyWith<$Res> {
  _$LaunchFlowBandsCopyWithImpl(this._self, this._then);

  final LaunchFlowBands _self;
  final $Res Function(LaunchFlowBands) _then;

/// Create a copy of LaunchFlowBands
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cfsMarginalBelow = freezed,Object? cfsComfortMax = freezed,Object? cfsNoGoAbove = freezed,}) {
  return _then(_self.copyWith(
cfsMarginalBelow: freezed == cfsMarginalBelow ? _self.cfsMarginalBelow : cfsMarginalBelow // ignore: cast_nullable_to_non_nullable
as double?,cfsComfortMax: freezed == cfsComfortMax ? _self.cfsComfortMax : cfsComfortMax // ignore: cast_nullable_to_non_nullable
as double?,cfsNoGoAbove: freezed == cfsNoGoAbove ? _self.cfsNoGoAbove : cfsNoGoAbove // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [LaunchFlowBands].
extension LaunchFlowBandsPatterns on LaunchFlowBands {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchFlowBands value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchFlowBands() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchFlowBands value)  $default,){
final _that = this;
switch (_that) {
case _LaunchFlowBands():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchFlowBands value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchFlowBands() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? cfsMarginalBelow,  double? cfsComfortMax,  double? cfsNoGoAbove)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchFlowBands() when $default != null:
return $default(_that.cfsMarginalBelow,_that.cfsComfortMax,_that.cfsNoGoAbove);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? cfsMarginalBelow,  double? cfsComfortMax,  double? cfsNoGoAbove)  $default,) {final _that = this;
switch (_that) {
case _LaunchFlowBands():
return $default(_that.cfsMarginalBelow,_that.cfsComfortMax,_that.cfsNoGoAbove);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? cfsMarginalBelow,  double? cfsComfortMax,  double? cfsNoGoAbove)?  $default,) {final _that = this;
switch (_that) {
case _LaunchFlowBands() when $default != null:
return $default(_that.cfsMarginalBelow,_that.cfsComfortMax,_that.cfsNoGoAbove);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LaunchFlowBands implements LaunchFlowBands {
  const _LaunchFlowBands({this.cfsMarginalBelow, this.cfsComfortMax, this.cfsNoGoAbove});
  factory _LaunchFlowBands.fromJson(Map<String, dynamic> json) => _$LaunchFlowBandsFromJson(json);

/// Below this cfs → marginal (low-water / strainer risk cue).
@override final  double? cfsMarginalBelow;
/// At or above → marginal (high, pushy water for this stretch).
@override final  double? cfsComfortMax;
/// At or above → no-go (planning hint).
@override final  double? cfsNoGoAbove;

/// Create a copy of LaunchFlowBands
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchFlowBandsCopyWith<_LaunchFlowBands> get copyWith => __$LaunchFlowBandsCopyWithImpl<_LaunchFlowBands>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LaunchFlowBandsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchFlowBands&&(identical(other.cfsMarginalBelow, cfsMarginalBelow) || other.cfsMarginalBelow == cfsMarginalBelow)&&(identical(other.cfsComfortMax, cfsComfortMax) || other.cfsComfortMax == cfsComfortMax)&&(identical(other.cfsNoGoAbove, cfsNoGoAbove) || other.cfsNoGoAbove == cfsNoGoAbove));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cfsMarginalBelow,cfsComfortMax,cfsNoGoAbove);

@override
String toString() {
  return 'LaunchFlowBands(cfsMarginalBelow: $cfsMarginalBelow, cfsComfortMax: $cfsComfortMax, cfsNoGoAbove: $cfsNoGoAbove)';
}


}

/// @nodoc
abstract mixin class _$LaunchFlowBandsCopyWith<$Res> implements $LaunchFlowBandsCopyWith<$Res> {
  factory _$LaunchFlowBandsCopyWith(_LaunchFlowBands value, $Res Function(_LaunchFlowBands) _then) = __$LaunchFlowBandsCopyWithImpl;
@override @useResult
$Res call({
 double? cfsMarginalBelow, double? cfsComfortMax, double? cfsNoGoAbove
});




}
/// @nodoc
class __$LaunchFlowBandsCopyWithImpl<$Res>
    implements _$LaunchFlowBandsCopyWith<$Res> {
  __$LaunchFlowBandsCopyWithImpl(this._self, this._then);

  final _LaunchFlowBands _self;
  final $Res Function(_LaunchFlowBands) _then;

/// Create a copy of LaunchFlowBands
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cfsMarginalBelow = freezed,Object? cfsComfortMax = freezed,Object? cfsNoGoAbove = freezed,}) {
  return _then(_LaunchFlowBands(
cfsMarginalBelow: freezed == cfsMarginalBelow ? _self.cfsMarginalBelow : cfsMarginalBelow // ignore: cast_nullable_to_non_nullable
as double?,cfsComfortMax: freezed == cfsComfortMax ? _self.cfsComfortMax : cfsComfortMax // ignore: cast_nullable_to_non_nullable
as double?,cfsNoGoAbove: freezed == cfsNoGoAbove ? _self.cfsNoGoAbove : cfsNoGoAbove // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$LaunchPoint {

 String get id; String get name; double get latitude; double get longitude; String get shortNote; RiverSystem get riverSystem; WindExposure get windExposure; TideRelevance get tideRelevance;/// NOAA CO-OPS station id when [tideRelevance] is not [TideRelevance.none].
 String? get noaaTideStationId;/// NWS marine forecast zone (e.g. PZZ210); null when not applicable.
 String? get marineZoneId;/// USGS NWIS site number for discharge/stage when curated.
 String? get usgsSiteId;/// When set, flow rules use these bands instead of [RiverSystem] defaults.
 LaunchFlowBands? get flowBands;
/// Create a copy of LaunchPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchPointCopyWith<LaunchPoint> get copyWith => _$LaunchPointCopyWithImpl<LaunchPoint>(this as LaunchPoint, _$identity);

  /// Serializes this LaunchPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.shortNote, shortNote) || other.shortNote == shortNote)&&(identical(other.riverSystem, riverSystem) || other.riverSystem == riverSystem)&&(identical(other.windExposure, windExposure) || other.windExposure == windExposure)&&(identical(other.tideRelevance, tideRelevance) || other.tideRelevance == tideRelevance)&&(identical(other.noaaTideStationId, noaaTideStationId) || other.noaaTideStationId == noaaTideStationId)&&(identical(other.marineZoneId, marineZoneId) || other.marineZoneId == marineZoneId)&&(identical(other.usgsSiteId, usgsSiteId) || other.usgsSiteId == usgsSiteId)&&(identical(other.flowBands, flowBands) || other.flowBands == flowBands));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latitude,longitude,shortNote,riverSystem,windExposure,tideRelevance,noaaTideStationId,marineZoneId,usgsSiteId,flowBands);

@override
String toString() {
  return 'LaunchPoint(id: $id, name: $name, latitude: $latitude, longitude: $longitude, shortNote: $shortNote, riverSystem: $riverSystem, windExposure: $windExposure, tideRelevance: $tideRelevance, noaaTideStationId: $noaaTideStationId, marineZoneId: $marineZoneId, usgsSiteId: $usgsSiteId, flowBands: $flowBands)';
}


}

/// @nodoc
abstract mixin class $LaunchPointCopyWith<$Res>  {
  factory $LaunchPointCopyWith(LaunchPoint value, $Res Function(LaunchPoint) _then) = _$LaunchPointCopyWithImpl;
@useResult
$Res call({
 String id, String name, double latitude, double longitude, String shortNote, RiverSystem riverSystem, WindExposure windExposure, TideRelevance tideRelevance, String? noaaTideStationId, String? marineZoneId, String? usgsSiteId, LaunchFlowBands? flowBands
});


$LaunchFlowBandsCopyWith<$Res>? get flowBands;

}
/// @nodoc
class _$LaunchPointCopyWithImpl<$Res>
    implements $LaunchPointCopyWith<$Res> {
  _$LaunchPointCopyWithImpl(this._self, this._then);

  final LaunchPoint _self;
  final $Res Function(LaunchPoint) _then;

/// Create a copy of LaunchPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? shortNote = null,Object? riverSystem = null,Object? windExposure = null,Object? tideRelevance = null,Object? noaaTideStationId = freezed,Object? marineZoneId = freezed,Object? usgsSiteId = freezed,Object? flowBands = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,shortNote: null == shortNote ? _self.shortNote : shortNote // ignore: cast_nullable_to_non_nullable
as String,riverSystem: null == riverSystem ? _self.riverSystem : riverSystem // ignore: cast_nullable_to_non_nullable
as RiverSystem,windExposure: null == windExposure ? _self.windExposure : windExposure // ignore: cast_nullable_to_non_nullable
as WindExposure,tideRelevance: null == tideRelevance ? _self.tideRelevance : tideRelevance // ignore: cast_nullable_to_non_nullable
as TideRelevance,noaaTideStationId: freezed == noaaTideStationId ? _self.noaaTideStationId : noaaTideStationId // ignore: cast_nullable_to_non_nullable
as String?,marineZoneId: freezed == marineZoneId ? _self.marineZoneId : marineZoneId // ignore: cast_nullable_to_non_nullable
as String?,usgsSiteId: freezed == usgsSiteId ? _self.usgsSiteId : usgsSiteId // ignore: cast_nullable_to_non_nullable
as String?,flowBands: freezed == flowBands ? _self.flowBands : flowBands // ignore: cast_nullable_to_non_nullable
as LaunchFlowBands?,
  ));
}
/// Create a copy of LaunchPoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchFlowBandsCopyWith<$Res>? get flowBands {
    if (_self.flowBands == null) {
    return null;
  }

  return $LaunchFlowBandsCopyWith<$Res>(_self.flowBands!, (value) {
    return _then(_self.copyWith(flowBands: value));
  });
}
}


/// Adds pattern-matching-related methods to [LaunchPoint].
extension LaunchPointPatterns on LaunchPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchPoint value)  $default,){
final _that = this;
switch (_that) {
case _LaunchPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchPoint value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude,  String shortNote,  RiverSystem riverSystem,  WindExposure windExposure,  TideRelevance tideRelevance,  String? noaaTideStationId,  String? marineZoneId,  String? usgsSiteId,  LaunchFlowBands? flowBands)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchPoint() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.shortNote,_that.riverSystem,_that.windExposure,_that.tideRelevance,_that.noaaTideStationId,_that.marineZoneId,_that.usgsSiteId,_that.flowBands);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude,  String shortNote,  RiverSystem riverSystem,  WindExposure windExposure,  TideRelevance tideRelevance,  String? noaaTideStationId,  String? marineZoneId,  String? usgsSiteId,  LaunchFlowBands? flowBands)  $default,) {final _that = this;
switch (_that) {
case _LaunchPoint():
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.shortNote,_that.riverSystem,_that.windExposure,_that.tideRelevance,_that.noaaTideStationId,_that.marineZoneId,_that.usgsSiteId,_that.flowBands);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double latitude,  double longitude,  String shortNote,  RiverSystem riverSystem,  WindExposure windExposure,  TideRelevance tideRelevance,  String? noaaTideStationId,  String? marineZoneId,  String? usgsSiteId,  LaunchFlowBands? flowBands)?  $default,) {final _that = this;
switch (_that) {
case _LaunchPoint() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.shortNote,_that.riverSystem,_that.windExposure,_that.tideRelevance,_that.noaaTideStationId,_that.marineZoneId,_that.usgsSiteId,_that.flowBands);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LaunchPoint implements LaunchPoint {
  const _LaunchPoint({required this.id, required this.name, required this.latitude, required this.longitude, required this.shortNote, required this.riverSystem, required this.windExposure, required this.tideRelevance, this.noaaTideStationId, this.marineZoneId, this.usgsSiteId, this.flowBands});
  factory _LaunchPoint.fromJson(Map<String, dynamic> json) => _$LaunchPointFromJson(json);

@override final  String id;
@override final  String name;
@override final  double latitude;
@override final  double longitude;
@override final  String shortNote;
@override final  RiverSystem riverSystem;
@override final  WindExposure windExposure;
@override final  TideRelevance tideRelevance;
/// NOAA CO-OPS station id when [tideRelevance] is not [TideRelevance.none].
@override final  String? noaaTideStationId;
/// NWS marine forecast zone (e.g. PZZ210); null when not applicable.
@override final  String? marineZoneId;
/// USGS NWIS site number for discharge/stage when curated.
@override final  String? usgsSiteId;
/// When set, flow rules use these bands instead of [RiverSystem] defaults.
@override final  LaunchFlowBands? flowBands;

/// Create a copy of LaunchPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchPointCopyWith<_LaunchPoint> get copyWith => __$LaunchPointCopyWithImpl<_LaunchPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LaunchPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.shortNote, shortNote) || other.shortNote == shortNote)&&(identical(other.riverSystem, riverSystem) || other.riverSystem == riverSystem)&&(identical(other.windExposure, windExposure) || other.windExposure == windExposure)&&(identical(other.tideRelevance, tideRelevance) || other.tideRelevance == tideRelevance)&&(identical(other.noaaTideStationId, noaaTideStationId) || other.noaaTideStationId == noaaTideStationId)&&(identical(other.marineZoneId, marineZoneId) || other.marineZoneId == marineZoneId)&&(identical(other.usgsSiteId, usgsSiteId) || other.usgsSiteId == usgsSiteId)&&(identical(other.flowBands, flowBands) || other.flowBands == flowBands));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latitude,longitude,shortNote,riverSystem,windExposure,tideRelevance,noaaTideStationId,marineZoneId,usgsSiteId,flowBands);

@override
String toString() {
  return 'LaunchPoint(id: $id, name: $name, latitude: $latitude, longitude: $longitude, shortNote: $shortNote, riverSystem: $riverSystem, windExposure: $windExposure, tideRelevance: $tideRelevance, noaaTideStationId: $noaaTideStationId, marineZoneId: $marineZoneId, usgsSiteId: $usgsSiteId, flowBands: $flowBands)';
}


}

/// @nodoc
abstract mixin class _$LaunchPointCopyWith<$Res> implements $LaunchPointCopyWith<$Res> {
  factory _$LaunchPointCopyWith(_LaunchPoint value, $Res Function(_LaunchPoint) _then) = __$LaunchPointCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double latitude, double longitude, String shortNote, RiverSystem riverSystem, WindExposure windExposure, TideRelevance tideRelevance, String? noaaTideStationId, String? marineZoneId, String? usgsSiteId, LaunchFlowBands? flowBands
});


@override $LaunchFlowBandsCopyWith<$Res>? get flowBands;

}
/// @nodoc
class __$LaunchPointCopyWithImpl<$Res>
    implements _$LaunchPointCopyWith<$Res> {
  __$LaunchPointCopyWithImpl(this._self, this._then);

  final _LaunchPoint _self;
  final $Res Function(_LaunchPoint) _then;

/// Create a copy of LaunchPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? shortNote = null,Object? riverSystem = null,Object? windExposure = null,Object? tideRelevance = null,Object? noaaTideStationId = freezed,Object? marineZoneId = freezed,Object? usgsSiteId = freezed,Object? flowBands = freezed,}) {
  return _then(_LaunchPoint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,shortNote: null == shortNote ? _self.shortNote : shortNote // ignore: cast_nullable_to_non_nullable
as String,riverSystem: null == riverSystem ? _self.riverSystem : riverSystem // ignore: cast_nullable_to_non_nullable
as RiverSystem,windExposure: null == windExposure ? _self.windExposure : windExposure // ignore: cast_nullable_to_non_nullable
as WindExposure,tideRelevance: null == tideRelevance ? _self.tideRelevance : tideRelevance // ignore: cast_nullable_to_non_nullable
as TideRelevance,noaaTideStationId: freezed == noaaTideStationId ? _self.noaaTideStationId : noaaTideStationId // ignore: cast_nullable_to_non_nullable
as String?,marineZoneId: freezed == marineZoneId ? _self.marineZoneId : marineZoneId // ignore: cast_nullable_to_non_nullable
as String?,usgsSiteId: freezed == usgsSiteId ? _self.usgsSiteId : usgsSiteId // ignore: cast_nullable_to_non_nullable
as String?,flowBands: freezed == flowBands ? _self.flowBands : flowBands // ignore: cast_nullable_to_non_nullable
as LaunchFlowBands?,
  ));
}

/// Create a copy of LaunchPoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchFlowBandsCopyWith<$Res>? get flowBands {
    if (_self.flowBands == null) {
    return null;
  }

  return $LaunchFlowBandsCopyWith<$Res>(_self.flowBands!, (value) {
    return _then(_self.copyWith(flowBands: value));
  });
}
}

// dart format on
