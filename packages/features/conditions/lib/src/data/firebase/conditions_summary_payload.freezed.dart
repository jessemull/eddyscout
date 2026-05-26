// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conditions_summary_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LaunchSummary {

 String get id; String get name; double get latitude; double get longitude; String get shortNote; RiverSystem get riverSystem; WindExposure get windExposure; TideRelevance get tideRelevance; GoNoGoProfile get skillProfile; String? get noaaTideStationId; String? get marineZoneId; String? get usgsSiteId; LaunchFlowBands? get flowBands;
/// Create a copy of LaunchSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchSummaryCopyWith<LaunchSummary> get copyWith => _$LaunchSummaryCopyWithImpl<LaunchSummary>(this as LaunchSummary, _$identity);

  /// Serializes this LaunchSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.shortNote, shortNote) || other.shortNote == shortNote)&&(identical(other.riverSystem, riverSystem) || other.riverSystem == riverSystem)&&(identical(other.windExposure, windExposure) || other.windExposure == windExposure)&&(identical(other.tideRelevance, tideRelevance) || other.tideRelevance == tideRelevance)&&(identical(other.skillProfile, skillProfile) || other.skillProfile == skillProfile)&&(identical(other.noaaTideStationId, noaaTideStationId) || other.noaaTideStationId == noaaTideStationId)&&(identical(other.marineZoneId, marineZoneId) || other.marineZoneId == marineZoneId)&&(identical(other.usgsSiteId, usgsSiteId) || other.usgsSiteId == usgsSiteId)&&(identical(other.flowBands, flowBands) || other.flowBands == flowBands));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latitude,longitude,shortNote,riverSystem,windExposure,tideRelevance,skillProfile,noaaTideStationId,marineZoneId,usgsSiteId,flowBands);

@override
String toString() {
  return 'LaunchSummary(id: $id, name: $name, latitude: $latitude, longitude: $longitude, shortNote: $shortNote, riverSystem: $riverSystem, windExposure: $windExposure, tideRelevance: $tideRelevance, skillProfile: $skillProfile, noaaTideStationId: $noaaTideStationId, marineZoneId: $marineZoneId, usgsSiteId: $usgsSiteId, flowBands: $flowBands)';
}


}

/// @nodoc
abstract mixin class $LaunchSummaryCopyWith<$Res>  {
  factory $LaunchSummaryCopyWith(LaunchSummary value, $Res Function(LaunchSummary) _then) = _$LaunchSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, double latitude, double longitude, String shortNote, RiverSystem riverSystem, WindExposure windExposure, TideRelevance tideRelevance, GoNoGoProfile skillProfile, String? noaaTideStationId, String? marineZoneId, String? usgsSiteId, LaunchFlowBands? flowBands
});


$LaunchFlowBandsCopyWith<$Res>? get flowBands;

}
/// @nodoc
class _$LaunchSummaryCopyWithImpl<$Res>
    implements $LaunchSummaryCopyWith<$Res> {
  _$LaunchSummaryCopyWithImpl(this._self, this._then);

  final LaunchSummary _self;
  final $Res Function(LaunchSummary) _then;

/// Create a copy of LaunchSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? shortNote = null,Object? riverSystem = null,Object? windExposure = null,Object? tideRelevance = null,Object? skillProfile = null,Object? noaaTideStationId = freezed,Object? marineZoneId = freezed,Object? usgsSiteId = freezed,Object? flowBands = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,shortNote: null == shortNote ? _self.shortNote : shortNote // ignore: cast_nullable_to_non_nullable
as String,riverSystem: null == riverSystem ? _self.riverSystem : riverSystem // ignore: cast_nullable_to_non_nullable
as RiverSystem,windExposure: null == windExposure ? _self.windExposure : windExposure // ignore: cast_nullable_to_non_nullable
as WindExposure,tideRelevance: null == tideRelevance ? _self.tideRelevance : tideRelevance // ignore: cast_nullable_to_non_nullable
as TideRelevance,skillProfile: null == skillProfile ? _self.skillProfile : skillProfile // ignore: cast_nullable_to_non_nullable
as GoNoGoProfile,noaaTideStationId: freezed == noaaTideStationId ? _self.noaaTideStationId : noaaTideStationId // ignore: cast_nullable_to_non_nullable
as String?,marineZoneId: freezed == marineZoneId ? _self.marineZoneId : marineZoneId // ignore: cast_nullable_to_non_nullable
as String?,usgsSiteId: freezed == usgsSiteId ? _self.usgsSiteId : usgsSiteId // ignore: cast_nullable_to_non_nullable
as String?,flowBands: freezed == flowBands ? _self.flowBands : flowBands // ignore: cast_nullable_to_non_nullable
as LaunchFlowBands?,
  ));
}
/// Create a copy of LaunchSummary
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


/// Adds pattern-matching-related methods to [LaunchSummary].
extension LaunchSummaryPatterns on LaunchSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchSummary value)  $default,){
final _that = this;
switch (_that) {
case _LaunchSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchSummary value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude,  String shortNote,  RiverSystem riverSystem,  WindExposure windExposure,  TideRelevance tideRelevance,  GoNoGoProfile skillProfile,  String? noaaTideStationId,  String? marineZoneId,  String? usgsSiteId,  LaunchFlowBands? flowBands)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchSummary() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.shortNote,_that.riverSystem,_that.windExposure,_that.tideRelevance,_that.skillProfile,_that.noaaTideStationId,_that.marineZoneId,_that.usgsSiteId,_that.flowBands);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude,  String shortNote,  RiverSystem riverSystem,  WindExposure windExposure,  TideRelevance tideRelevance,  GoNoGoProfile skillProfile,  String? noaaTideStationId,  String? marineZoneId,  String? usgsSiteId,  LaunchFlowBands? flowBands)  $default,) {final _that = this;
switch (_that) {
case _LaunchSummary():
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.shortNote,_that.riverSystem,_that.windExposure,_that.tideRelevance,_that.skillProfile,_that.noaaTideStationId,_that.marineZoneId,_that.usgsSiteId,_that.flowBands);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double latitude,  double longitude,  String shortNote,  RiverSystem riverSystem,  WindExposure windExposure,  TideRelevance tideRelevance,  GoNoGoProfile skillProfile,  String? noaaTideStationId,  String? marineZoneId,  String? usgsSiteId,  LaunchFlowBands? flowBands)?  $default,) {final _that = this;
switch (_that) {
case _LaunchSummary() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.shortNote,_that.riverSystem,_that.windExposure,_that.tideRelevance,_that.skillProfile,_that.noaaTideStationId,_that.marineZoneId,_that.usgsSiteId,_that.flowBands);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LaunchSummary implements LaunchSummary {
  const _LaunchSummary({required this.id, required this.name, required this.latitude, required this.longitude, required this.shortNote, required this.riverSystem, required this.windExposure, required this.tideRelevance, required this.skillProfile, this.noaaTideStationId, this.marineZoneId, this.usgsSiteId, this.flowBands});
  factory _LaunchSummary.fromJson(Map<String, dynamic> json) => _$LaunchSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  double latitude;
@override final  double longitude;
@override final  String shortNote;
@override final  RiverSystem riverSystem;
@override final  WindExposure windExposure;
@override final  TideRelevance tideRelevance;
@override final  GoNoGoProfile skillProfile;
@override final  String? noaaTideStationId;
@override final  String? marineZoneId;
@override final  String? usgsSiteId;
@override final  LaunchFlowBands? flowBands;

/// Create a copy of LaunchSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchSummaryCopyWith<_LaunchSummary> get copyWith => __$LaunchSummaryCopyWithImpl<_LaunchSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LaunchSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.shortNote, shortNote) || other.shortNote == shortNote)&&(identical(other.riverSystem, riverSystem) || other.riverSystem == riverSystem)&&(identical(other.windExposure, windExposure) || other.windExposure == windExposure)&&(identical(other.tideRelevance, tideRelevance) || other.tideRelevance == tideRelevance)&&(identical(other.skillProfile, skillProfile) || other.skillProfile == skillProfile)&&(identical(other.noaaTideStationId, noaaTideStationId) || other.noaaTideStationId == noaaTideStationId)&&(identical(other.marineZoneId, marineZoneId) || other.marineZoneId == marineZoneId)&&(identical(other.usgsSiteId, usgsSiteId) || other.usgsSiteId == usgsSiteId)&&(identical(other.flowBands, flowBands) || other.flowBands == flowBands));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latitude,longitude,shortNote,riverSystem,windExposure,tideRelevance,skillProfile,noaaTideStationId,marineZoneId,usgsSiteId,flowBands);

@override
String toString() {
  return 'LaunchSummary(id: $id, name: $name, latitude: $latitude, longitude: $longitude, shortNote: $shortNote, riverSystem: $riverSystem, windExposure: $windExposure, tideRelevance: $tideRelevance, skillProfile: $skillProfile, noaaTideStationId: $noaaTideStationId, marineZoneId: $marineZoneId, usgsSiteId: $usgsSiteId, flowBands: $flowBands)';
}


}

/// @nodoc
abstract mixin class _$LaunchSummaryCopyWith<$Res> implements $LaunchSummaryCopyWith<$Res> {
  factory _$LaunchSummaryCopyWith(_LaunchSummary value, $Res Function(_LaunchSummary) _then) = __$LaunchSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double latitude, double longitude, String shortNote, RiverSystem riverSystem, WindExposure windExposure, TideRelevance tideRelevance, GoNoGoProfile skillProfile, String? noaaTideStationId, String? marineZoneId, String? usgsSiteId, LaunchFlowBands? flowBands
});


@override $LaunchFlowBandsCopyWith<$Res>? get flowBands;

}
/// @nodoc
class __$LaunchSummaryCopyWithImpl<$Res>
    implements _$LaunchSummaryCopyWith<$Res> {
  __$LaunchSummaryCopyWithImpl(this._self, this._then);

  final _LaunchSummary _self;
  final $Res Function(_LaunchSummary) _then;

/// Create a copy of LaunchSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? shortNote = null,Object? riverSystem = null,Object? windExposure = null,Object? tideRelevance = null,Object? skillProfile = null,Object? noaaTideStationId = freezed,Object? marineZoneId = freezed,Object? usgsSiteId = freezed,Object? flowBands = freezed,}) {
  return _then(_LaunchSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,shortNote: null == shortNote ? _self.shortNote : shortNote // ignore: cast_nullable_to_non_nullable
as String,riverSystem: null == riverSystem ? _self.riverSystem : riverSystem // ignore: cast_nullable_to_non_nullable
as RiverSystem,windExposure: null == windExposure ? _self.windExposure : windExposure // ignore: cast_nullable_to_non_nullable
as WindExposure,tideRelevance: null == tideRelevance ? _self.tideRelevance : tideRelevance // ignore: cast_nullable_to_non_nullable
as TideRelevance,skillProfile: null == skillProfile ? _self.skillProfile : skillProfile // ignore: cast_nullable_to_non_nullable
as GoNoGoProfile,noaaTideStationId: freezed == noaaTideStationId ? _self.noaaTideStationId : noaaTideStationId // ignore: cast_nullable_to_non_nullable
as String?,marineZoneId: freezed == marineZoneId ? _self.marineZoneId : marineZoneId // ignore: cast_nullable_to_non_nullable
as String?,usgsSiteId: freezed == usgsSiteId ? _self.usgsSiteId : usgsSiteId // ignore: cast_nullable_to_non_nullable
as String?,flowBands: freezed == flowBands ? _self.flowBands : flowBands // ignore: cast_nullable_to_non_nullable
as LaunchFlowBands?,
  ));
}

/// Create a copy of LaunchSummary
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


/// @nodoc
mixin _$ConditionsSummaryPayload {

 LaunchSummary get launch; ConditionsSnapshot get snapshot; GoNoGoResult get goNoGo;
/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionsSummaryPayloadCopyWith<ConditionsSummaryPayload> get copyWith => _$ConditionsSummaryPayloadCopyWithImpl<ConditionsSummaryPayload>(this as ConditionsSummaryPayload, _$identity);

  /// Serializes this ConditionsSummaryPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionsSummaryPayload&&(identical(other.launch, launch) || other.launch == launch)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.goNoGo, goNoGo) || other.goNoGo == goNoGo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,launch,snapshot,goNoGo);

@override
String toString() {
  return 'ConditionsSummaryPayload(launch: $launch, snapshot: $snapshot, goNoGo: $goNoGo)';
}


}

/// @nodoc
abstract mixin class $ConditionsSummaryPayloadCopyWith<$Res>  {
  factory $ConditionsSummaryPayloadCopyWith(ConditionsSummaryPayload value, $Res Function(ConditionsSummaryPayload) _then) = _$ConditionsSummaryPayloadCopyWithImpl;
@useResult
$Res call({
 LaunchSummary launch, ConditionsSnapshot snapshot, GoNoGoResult goNoGo
});


$LaunchSummaryCopyWith<$Res> get launch;$ConditionsSnapshotCopyWith<$Res> get snapshot;$GoNoGoResultCopyWith<$Res> get goNoGo;

}
/// @nodoc
class _$ConditionsSummaryPayloadCopyWithImpl<$Res>
    implements $ConditionsSummaryPayloadCopyWith<$Res> {
  _$ConditionsSummaryPayloadCopyWithImpl(this._self, this._then);

  final ConditionsSummaryPayload _self;
  final $Res Function(ConditionsSummaryPayload) _then;

/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? launch = null,Object? snapshot = null,Object? goNoGo = null,}) {
  return _then(_self.copyWith(
launch: null == launch ? _self.launch : launch // ignore: cast_nullable_to_non_nullable
as LaunchSummary,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as ConditionsSnapshot,goNoGo: null == goNoGo ? _self.goNoGo : goNoGo // ignore: cast_nullable_to_non_nullable
as GoNoGoResult,
  ));
}
/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchSummaryCopyWith<$Res> get launch {
  
  return $LaunchSummaryCopyWith<$Res>(_self.launch, (value) {
    return _then(_self.copyWith(launch: value));
  });
}/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionsSnapshotCopyWith<$Res> get snapshot {
  
  return $ConditionsSnapshotCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoNoGoResultCopyWith<$Res> get goNoGo {
  
  return $GoNoGoResultCopyWith<$Res>(_self.goNoGo, (value) {
    return _then(_self.copyWith(goNoGo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConditionsSummaryPayload].
extension ConditionsSummaryPayloadPatterns on ConditionsSummaryPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConditionsSummaryPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConditionsSummaryPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConditionsSummaryPayload value)  $default,){
final _that = this;
switch (_that) {
case _ConditionsSummaryPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConditionsSummaryPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ConditionsSummaryPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LaunchSummary launch,  ConditionsSnapshot snapshot,  GoNoGoResult goNoGo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConditionsSummaryPayload() when $default != null:
return $default(_that.launch,_that.snapshot,_that.goNoGo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LaunchSummary launch,  ConditionsSnapshot snapshot,  GoNoGoResult goNoGo)  $default,) {final _that = this;
switch (_that) {
case _ConditionsSummaryPayload():
return $default(_that.launch,_that.snapshot,_that.goNoGo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LaunchSummary launch,  ConditionsSnapshot snapshot,  GoNoGoResult goNoGo)?  $default,) {final _that = this;
switch (_that) {
case _ConditionsSummaryPayload() when $default != null:
return $default(_that.launch,_that.snapshot,_that.goNoGo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConditionsSummaryPayload implements ConditionsSummaryPayload {
  const _ConditionsSummaryPayload({required this.launch, required this.snapshot, required this.goNoGo});
  factory _ConditionsSummaryPayload.fromJson(Map<String, dynamic> json) => _$ConditionsSummaryPayloadFromJson(json);

@override final  LaunchSummary launch;
@override final  ConditionsSnapshot snapshot;
@override final  GoNoGoResult goNoGo;

/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConditionsSummaryPayloadCopyWith<_ConditionsSummaryPayload> get copyWith => __$ConditionsSummaryPayloadCopyWithImpl<_ConditionsSummaryPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConditionsSummaryPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConditionsSummaryPayload&&(identical(other.launch, launch) || other.launch == launch)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.goNoGo, goNoGo) || other.goNoGo == goNoGo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,launch,snapshot,goNoGo);

@override
String toString() {
  return 'ConditionsSummaryPayload(launch: $launch, snapshot: $snapshot, goNoGo: $goNoGo)';
}


}

/// @nodoc
abstract mixin class _$ConditionsSummaryPayloadCopyWith<$Res> implements $ConditionsSummaryPayloadCopyWith<$Res> {
  factory _$ConditionsSummaryPayloadCopyWith(_ConditionsSummaryPayload value, $Res Function(_ConditionsSummaryPayload) _then) = __$ConditionsSummaryPayloadCopyWithImpl;
@override @useResult
$Res call({
 LaunchSummary launch, ConditionsSnapshot snapshot, GoNoGoResult goNoGo
});


@override $LaunchSummaryCopyWith<$Res> get launch;@override $ConditionsSnapshotCopyWith<$Res> get snapshot;@override $GoNoGoResultCopyWith<$Res> get goNoGo;

}
/// @nodoc
class __$ConditionsSummaryPayloadCopyWithImpl<$Res>
    implements _$ConditionsSummaryPayloadCopyWith<$Res> {
  __$ConditionsSummaryPayloadCopyWithImpl(this._self, this._then);

  final _ConditionsSummaryPayload _self;
  final $Res Function(_ConditionsSummaryPayload) _then;

/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? launch = null,Object? snapshot = null,Object? goNoGo = null,}) {
  return _then(_ConditionsSummaryPayload(
launch: null == launch ? _self.launch : launch // ignore: cast_nullable_to_non_nullable
as LaunchSummary,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as ConditionsSnapshot,goNoGo: null == goNoGo ? _self.goNoGo : goNoGo // ignore: cast_nullable_to_non_nullable
as GoNoGoResult,
  ));
}

/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LaunchSummaryCopyWith<$Res> get launch {
  
  return $LaunchSummaryCopyWith<$Res>(_self.launch, (value) {
    return _then(_self.copyWith(launch: value));
  });
}/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionsSnapshotCopyWith<$Res> get snapshot {
  
  return $ConditionsSnapshotCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}/// Create a copy of ConditionsSummaryPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoNoGoResultCopyWith<$Res> get goNoGo {
  
  return $GoNoGoResultCopyWith<$Res>(_self.goNoGo, (value) {
    return _then(_self.copyWith(goNoGo: value));
  });
}
}

// dart format on
