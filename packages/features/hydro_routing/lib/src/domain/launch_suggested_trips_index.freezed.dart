// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launch_suggested_trips_index.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SuggestedTrip {

 String get destination; double get distanceKm; int get estimatedMinutes; List<String> get waypoints;
/// Create a copy of SuggestedTrip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedTripCopyWith<SuggestedTrip> get copyWith => _$SuggestedTripCopyWithImpl<SuggestedTrip>(this as SuggestedTrip, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedTrip&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&const DeepCollectionEquality().equals(other.waypoints, waypoints));
}


@override
int get hashCode => Object.hash(runtimeType,destination,distanceKm,estimatedMinutes,const DeepCollectionEquality().hash(waypoints));

@override
String toString() {
  return 'SuggestedTrip(destination: $destination, distanceKm: $distanceKm, estimatedMinutes: $estimatedMinutes, waypoints: $waypoints)';
}


}

/// @nodoc
abstract mixin class $SuggestedTripCopyWith<$Res>  {
  factory $SuggestedTripCopyWith(SuggestedTrip value, $Res Function(SuggestedTrip) _then) = _$SuggestedTripCopyWithImpl;
@useResult
$Res call({
 String destination, double distanceKm, int estimatedMinutes, List<String> waypoints
});




}
/// @nodoc
class _$SuggestedTripCopyWithImpl<$Res>
    implements $SuggestedTripCopyWith<$Res> {
  _$SuggestedTripCopyWithImpl(this._self, this._then);

  final SuggestedTrip _self;
  final $Res Function(SuggestedTrip) _then;

/// Create a copy of SuggestedTrip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? destination = null,Object? distanceKm = null,Object? estimatedMinutes = null,Object? waypoints = null,}) {
  return _then(_self.copyWith(
destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,waypoints: null == waypoints ? _self.waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestedTrip].
extension SuggestedTripPatterns on SuggestedTrip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedTrip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedTrip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedTrip value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedTrip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedTrip value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedTrip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String destination,  double distanceKm,  int estimatedMinutes,  List<String> waypoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedTrip() when $default != null:
return $default(_that.destination,_that.distanceKm,_that.estimatedMinutes,_that.waypoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String destination,  double distanceKm,  int estimatedMinutes,  List<String> waypoints)  $default,) {final _that = this;
switch (_that) {
case _SuggestedTrip():
return $default(_that.destination,_that.distanceKm,_that.estimatedMinutes,_that.waypoints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String destination,  double distanceKm,  int estimatedMinutes,  List<String> waypoints)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedTrip() when $default != null:
return $default(_that.destination,_that.distanceKm,_that.estimatedMinutes,_that.waypoints);case _:
  return null;

}
}

}

/// @nodoc


class _SuggestedTrip implements SuggestedTrip {
  const _SuggestedTrip({required this.destination, required this.distanceKm, required this.estimatedMinutes, required final  List<String> waypoints}): _waypoints = waypoints;
  

@override final  String destination;
@override final  double distanceKm;
@override final  int estimatedMinutes;
 final  List<String> _waypoints;
@override List<String> get waypoints {
  if (_waypoints is EqualUnmodifiableListView) return _waypoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypoints);
}


/// Create a copy of SuggestedTrip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedTripCopyWith<_SuggestedTrip> get copyWith => __$SuggestedTripCopyWithImpl<_SuggestedTrip>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedTrip&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.estimatedMinutes, estimatedMinutes) || other.estimatedMinutes == estimatedMinutes)&&const DeepCollectionEquality().equals(other._waypoints, _waypoints));
}


@override
int get hashCode => Object.hash(runtimeType,destination,distanceKm,estimatedMinutes,const DeepCollectionEquality().hash(_waypoints));

@override
String toString() {
  return 'SuggestedTrip(destination: $destination, distanceKm: $distanceKm, estimatedMinutes: $estimatedMinutes, waypoints: $waypoints)';
}


}

/// @nodoc
abstract mixin class _$SuggestedTripCopyWith<$Res> implements $SuggestedTripCopyWith<$Res> {
  factory _$SuggestedTripCopyWith(_SuggestedTrip value, $Res Function(_SuggestedTrip) _then) = __$SuggestedTripCopyWithImpl;
@override @useResult
$Res call({
 String destination, double distanceKm, int estimatedMinutes, List<String> waypoints
});




}
/// @nodoc
class __$SuggestedTripCopyWithImpl<$Res>
    implements _$SuggestedTripCopyWith<$Res> {
  __$SuggestedTripCopyWithImpl(this._self, this._then);

  final _SuggestedTrip _self;
  final $Res Function(_SuggestedTrip) _then;

/// Create a copy of SuggestedTrip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? destination = null,Object? distanceKm = null,Object? estimatedMinutes = null,Object? waypoints = null,}) {
  return _then(_SuggestedTrip(
destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,estimatedMinutes: null == estimatedMinutes ? _self.estimatedMinutes : estimatedMinutes // ignore: cast_nullable_to_non_nullable
as int,waypoints: null == waypoints ? _self._waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$LaunchSuggestedTripsEntry {

 List<SuggestedTrip> get oneWay; List<SuggestedTrip> get roundTrips;
/// Create a copy of LaunchSuggestedTripsEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchSuggestedTripsEntryCopyWith<LaunchSuggestedTripsEntry> get copyWith => _$LaunchSuggestedTripsEntryCopyWithImpl<LaunchSuggestedTripsEntry>(this as LaunchSuggestedTripsEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchSuggestedTripsEntry&&const DeepCollectionEquality().equals(other.oneWay, oneWay)&&const DeepCollectionEquality().equals(other.roundTrips, roundTrips));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(oneWay),const DeepCollectionEquality().hash(roundTrips));

@override
String toString() {
  return 'LaunchSuggestedTripsEntry(oneWay: $oneWay, roundTrips: $roundTrips)';
}


}

/// @nodoc
abstract mixin class $LaunchSuggestedTripsEntryCopyWith<$Res>  {
  factory $LaunchSuggestedTripsEntryCopyWith(LaunchSuggestedTripsEntry value, $Res Function(LaunchSuggestedTripsEntry) _then) = _$LaunchSuggestedTripsEntryCopyWithImpl;
@useResult
$Res call({
 List<SuggestedTrip> oneWay, List<SuggestedTrip> roundTrips
});




}
/// @nodoc
class _$LaunchSuggestedTripsEntryCopyWithImpl<$Res>
    implements $LaunchSuggestedTripsEntryCopyWith<$Res> {
  _$LaunchSuggestedTripsEntryCopyWithImpl(this._self, this._then);

  final LaunchSuggestedTripsEntry _self;
  final $Res Function(LaunchSuggestedTripsEntry) _then;

/// Create a copy of LaunchSuggestedTripsEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oneWay = null,Object? roundTrips = null,}) {
  return _then(_self.copyWith(
oneWay: null == oneWay ? _self.oneWay : oneWay // ignore: cast_nullable_to_non_nullable
as List<SuggestedTrip>,roundTrips: null == roundTrips ? _self.roundTrips : roundTrips // ignore: cast_nullable_to_non_nullable
as List<SuggestedTrip>,
  ));
}

}


/// Adds pattern-matching-related methods to [LaunchSuggestedTripsEntry].
extension LaunchSuggestedTripsEntryPatterns on LaunchSuggestedTripsEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchSuggestedTripsEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchSuggestedTripsEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchSuggestedTripsEntry value)  $default,){
final _that = this;
switch (_that) {
case _LaunchSuggestedTripsEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchSuggestedTripsEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchSuggestedTripsEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SuggestedTrip> oneWay,  List<SuggestedTrip> roundTrips)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchSuggestedTripsEntry() when $default != null:
return $default(_that.oneWay,_that.roundTrips);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SuggestedTrip> oneWay,  List<SuggestedTrip> roundTrips)  $default,) {final _that = this;
switch (_that) {
case _LaunchSuggestedTripsEntry():
return $default(_that.oneWay,_that.roundTrips);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SuggestedTrip> oneWay,  List<SuggestedTrip> roundTrips)?  $default,) {final _that = this;
switch (_that) {
case _LaunchSuggestedTripsEntry() when $default != null:
return $default(_that.oneWay,_that.roundTrips);case _:
  return null;

}
}

}

/// @nodoc


class _LaunchSuggestedTripsEntry extends LaunchSuggestedTripsEntry {
  const _LaunchSuggestedTripsEntry({final  List<SuggestedTrip> oneWay = const [], final  List<SuggestedTrip> roundTrips = const []}): _oneWay = oneWay,_roundTrips = roundTrips,super._();
  

 final  List<SuggestedTrip> _oneWay;
@override@JsonKey() List<SuggestedTrip> get oneWay {
  if (_oneWay is EqualUnmodifiableListView) return _oneWay;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_oneWay);
}

 final  List<SuggestedTrip> _roundTrips;
@override@JsonKey() List<SuggestedTrip> get roundTrips {
  if (_roundTrips is EqualUnmodifiableListView) return _roundTrips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roundTrips);
}


/// Create a copy of LaunchSuggestedTripsEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchSuggestedTripsEntryCopyWith<_LaunchSuggestedTripsEntry> get copyWith => __$LaunchSuggestedTripsEntryCopyWithImpl<_LaunchSuggestedTripsEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchSuggestedTripsEntry&&const DeepCollectionEquality().equals(other._oneWay, _oneWay)&&const DeepCollectionEquality().equals(other._roundTrips, _roundTrips));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_oneWay),const DeepCollectionEquality().hash(_roundTrips));

@override
String toString() {
  return 'LaunchSuggestedTripsEntry(oneWay: $oneWay, roundTrips: $roundTrips)';
}


}

/// @nodoc
abstract mixin class _$LaunchSuggestedTripsEntryCopyWith<$Res> implements $LaunchSuggestedTripsEntryCopyWith<$Res> {
  factory _$LaunchSuggestedTripsEntryCopyWith(_LaunchSuggestedTripsEntry value, $Res Function(_LaunchSuggestedTripsEntry) _then) = __$LaunchSuggestedTripsEntryCopyWithImpl;
@override @useResult
$Res call({
 List<SuggestedTrip> oneWay, List<SuggestedTrip> roundTrips
});




}
/// @nodoc
class __$LaunchSuggestedTripsEntryCopyWithImpl<$Res>
    implements _$LaunchSuggestedTripsEntryCopyWith<$Res> {
  __$LaunchSuggestedTripsEntryCopyWithImpl(this._self, this._then);

  final _LaunchSuggestedTripsEntry _self;
  final $Res Function(_LaunchSuggestedTripsEntry) _then;

/// Create a copy of LaunchSuggestedTripsEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oneWay = null,Object? roundTrips = null,}) {
  return _then(_LaunchSuggestedTripsEntry(
oneWay: null == oneWay ? _self._oneWay : oneWay // ignore: cast_nullable_to_non_nullable
as List<SuggestedTrip>,roundTrips: null == roundTrips ? _self._roundTrips : roundTrips // ignore: cast_nullable_to_non_nullable
as List<SuggestedTrip>,
  ));
}


}

/// @nodoc
mixin _$LaunchSuggestedTripsIndex {

 int get schemaVersion; DateTime get generatedAt; String get distanceModel; double get snapMaxMeters; int get maxDistanceMi; double get paddleSpeedKmh; int get maxOneWaySuggestions; int get maxRoundTripSuggestions; bool get crossSystemReachability; Map<String, LaunchSuggestedTripsEntry> get entries;
/// Create a copy of LaunchSuggestedTripsIndex
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchSuggestedTripsIndexCopyWith<LaunchSuggestedTripsIndex> get copyWith => _$LaunchSuggestedTripsIndexCopyWithImpl<LaunchSuggestedTripsIndex>(this as LaunchSuggestedTripsIndex, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchSuggestedTripsIndex&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.distanceModel, distanceModel) || other.distanceModel == distanceModel)&&(identical(other.snapMaxMeters, snapMaxMeters) || other.snapMaxMeters == snapMaxMeters)&&(identical(other.maxDistanceMi, maxDistanceMi) || other.maxDistanceMi == maxDistanceMi)&&(identical(other.paddleSpeedKmh, paddleSpeedKmh) || other.paddleSpeedKmh == paddleSpeedKmh)&&(identical(other.maxOneWaySuggestions, maxOneWaySuggestions) || other.maxOneWaySuggestions == maxOneWaySuggestions)&&(identical(other.maxRoundTripSuggestions, maxRoundTripSuggestions) || other.maxRoundTripSuggestions == maxRoundTripSuggestions)&&(identical(other.crossSystemReachability, crossSystemReachability) || other.crossSystemReachability == crossSystemReachability)&&const DeepCollectionEquality().equals(other.entries, entries));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,distanceModel,snapMaxMeters,maxDistanceMi,paddleSpeedKmh,maxOneWaySuggestions,maxRoundTripSuggestions,crossSystemReachability,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'LaunchSuggestedTripsIndex(schemaVersion: $schemaVersion, generatedAt: $generatedAt, distanceModel: $distanceModel, snapMaxMeters: $snapMaxMeters, maxDistanceMi: $maxDistanceMi, paddleSpeedKmh: $paddleSpeedKmh, maxOneWaySuggestions: $maxOneWaySuggestions, maxRoundTripSuggestions: $maxRoundTripSuggestions, crossSystemReachability: $crossSystemReachability, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $LaunchSuggestedTripsIndexCopyWith<$Res>  {
  factory $LaunchSuggestedTripsIndexCopyWith(LaunchSuggestedTripsIndex value, $Res Function(LaunchSuggestedTripsIndex) _then) = _$LaunchSuggestedTripsIndexCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, DateTime generatedAt, String distanceModel, double snapMaxMeters, int maxDistanceMi, double paddleSpeedKmh, int maxOneWaySuggestions, int maxRoundTripSuggestions, bool crossSystemReachability, Map<String, LaunchSuggestedTripsEntry> entries
});




}
/// @nodoc
class _$LaunchSuggestedTripsIndexCopyWithImpl<$Res>
    implements $LaunchSuggestedTripsIndexCopyWith<$Res> {
  _$LaunchSuggestedTripsIndexCopyWithImpl(this._self, this._then);

  final LaunchSuggestedTripsIndex _self;
  final $Res Function(LaunchSuggestedTripsIndex) _then;

/// Create a copy of LaunchSuggestedTripsIndex
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? distanceModel = null,Object? snapMaxMeters = null,Object? maxDistanceMi = null,Object? paddleSpeedKmh = null,Object? maxOneWaySuggestions = null,Object? maxRoundTripSuggestions = null,Object? crossSystemReachability = null,Object? entries = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceModel: null == distanceModel ? _self.distanceModel : distanceModel // ignore: cast_nullable_to_non_nullable
as String,snapMaxMeters: null == snapMaxMeters ? _self.snapMaxMeters : snapMaxMeters // ignore: cast_nullable_to_non_nullable
as double,maxDistanceMi: null == maxDistanceMi ? _self.maxDistanceMi : maxDistanceMi // ignore: cast_nullable_to_non_nullable
as int,paddleSpeedKmh: null == paddleSpeedKmh ? _self.paddleSpeedKmh : paddleSpeedKmh // ignore: cast_nullable_to_non_nullable
as double,maxOneWaySuggestions: null == maxOneWaySuggestions ? _self.maxOneWaySuggestions : maxOneWaySuggestions // ignore: cast_nullable_to_non_nullable
as int,maxRoundTripSuggestions: null == maxRoundTripSuggestions ? _self.maxRoundTripSuggestions : maxRoundTripSuggestions // ignore: cast_nullable_to_non_nullable
as int,crossSystemReachability: null == crossSystemReachability ? _self.crossSystemReachability : crossSystemReachability // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, LaunchSuggestedTripsEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [LaunchSuggestedTripsIndex].
extension LaunchSuggestedTripsIndexPatterns on LaunchSuggestedTripsIndex {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchSuggestedTripsIndex value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchSuggestedTripsIndex() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchSuggestedTripsIndex value)  $default,){
final _that = this;
switch (_that) {
case _LaunchSuggestedTripsIndex():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchSuggestedTripsIndex value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchSuggestedTripsIndex() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime generatedAt,  String distanceModel,  double snapMaxMeters,  int maxDistanceMi,  double paddleSpeedKmh,  int maxOneWaySuggestions,  int maxRoundTripSuggestions,  bool crossSystemReachability,  Map<String, LaunchSuggestedTripsEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchSuggestedTripsIndex() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.distanceModel,_that.snapMaxMeters,_that.maxDistanceMi,_that.paddleSpeedKmh,_that.maxOneWaySuggestions,_that.maxRoundTripSuggestions,_that.crossSystemReachability,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime generatedAt,  String distanceModel,  double snapMaxMeters,  int maxDistanceMi,  double paddleSpeedKmh,  int maxOneWaySuggestions,  int maxRoundTripSuggestions,  bool crossSystemReachability,  Map<String, LaunchSuggestedTripsEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _LaunchSuggestedTripsIndex():
return $default(_that.schemaVersion,_that.generatedAt,_that.distanceModel,_that.snapMaxMeters,_that.maxDistanceMi,_that.paddleSpeedKmh,_that.maxOneWaySuggestions,_that.maxRoundTripSuggestions,_that.crossSystemReachability,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  DateTime generatedAt,  String distanceModel,  double snapMaxMeters,  int maxDistanceMi,  double paddleSpeedKmh,  int maxOneWaySuggestions,  int maxRoundTripSuggestions,  bool crossSystemReachability,  Map<String, LaunchSuggestedTripsEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _LaunchSuggestedTripsIndex() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.distanceModel,_that.snapMaxMeters,_that.maxDistanceMi,_that.paddleSpeedKmh,_that.maxOneWaySuggestions,_that.maxRoundTripSuggestions,_that.crossSystemReachability,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _LaunchSuggestedTripsIndex extends LaunchSuggestedTripsIndex {
  const _LaunchSuggestedTripsIndex({required this.schemaVersion, required this.generatedAt, required this.distanceModel, required this.snapMaxMeters, required this.maxDistanceMi, required this.paddleSpeedKmh, required this.maxOneWaySuggestions, required this.maxRoundTripSuggestions, required this.crossSystemReachability, required final  Map<String, LaunchSuggestedTripsEntry> entries}): _entries = entries,super._();
  

@override final  int schemaVersion;
@override final  DateTime generatedAt;
@override final  String distanceModel;
@override final  double snapMaxMeters;
@override final  int maxDistanceMi;
@override final  double paddleSpeedKmh;
@override final  int maxOneWaySuggestions;
@override final  int maxRoundTripSuggestions;
@override final  bool crossSystemReachability;
 final  Map<String, LaunchSuggestedTripsEntry> _entries;
@override Map<String, LaunchSuggestedTripsEntry> get entries {
  if (_entries is EqualUnmodifiableMapView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entries);
}


/// Create a copy of LaunchSuggestedTripsIndex
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchSuggestedTripsIndexCopyWith<_LaunchSuggestedTripsIndex> get copyWith => __$LaunchSuggestedTripsIndexCopyWithImpl<_LaunchSuggestedTripsIndex>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchSuggestedTripsIndex&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.distanceModel, distanceModel) || other.distanceModel == distanceModel)&&(identical(other.snapMaxMeters, snapMaxMeters) || other.snapMaxMeters == snapMaxMeters)&&(identical(other.maxDistanceMi, maxDistanceMi) || other.maxDistanceMi == maxDistanceMi)&&(identical(other.paddleSpeedKmh, paddleSpeedKmh) || other.paddleSpeedKmh == paddleSpeedKmh)&&(identical(other.maxOneWaySuggestions, maxOneWaySuggestions) || other.maxOneWaySuggestions == maxOneWaySuggestions)&&(identical(other.maxRoundTripSuggestions, maxRoundTripSuggestions) || other.maxRoundTripSuggestions == maxRoundTripSuggestions)&&(identical(other.crossSystemReachability, crossSystemReachability) || other.crossSystemReachability == crossSystemReachability)&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,distanceModel,snapMaxMeters,maxDistanceMi,paddleSpeedKmh,maxOneWaySuggestions,maxRoundTripSuggestions,crossSystemReachability,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'LaunchSuggestedTripsIndex(schemaVersion: $schemaVersion, generatedAt: $generatedAt, distanceModel: $distanceModel, snapMaxMeters: $snapMaxMeters, maxDistanceMi: $maxDistanceMi, paddleSpeedKmh: $paddleSpeedKmh, maxOneWaySuggestions: $maxOneWaySuggestions, maxRoundTripSuggestions: $maxRoundTripSuggestions, crossSystemReachability: $crossSystemReachability, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$LaunchSuggestedTripsIndexCopyWith<$Res> implements $LaunchSuggestedTripsIndexCopyWith<$Res> {
  factory _$LaunchSuggestedTripsIndexCopyWith(_LaunchSuggestedTripsIndex value, $Res Function(_LaunchSuggestedTripsIndex) _then) = __$LaunchSuggestedTripsIndexCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, DateTime generatedAt, String distanceModel, double snapMaxMeters, int maxDistanceMi, double paddleSpeedKmh, int maxOneWaySuggestions, int maxRoundTripSuggestions, bool crossSystemReachability, Map<String, LaunchSuggestedTripsEntry> entries
});




}
/// @nodoc
class __$LaunchSuggestedTripsIndexCopyWithImpl<$Res>
    implements _$LaunchSuggestedTripsIndexCopyWith<$Res> {
  __$LaunchSuggestedTripsIndexCopyWithImpl(this._self, this._then);

  final _LaunchSuggestedTripsIndex _self;
  final $Res Function(_LaunchSuggestedTripsIndex) _then;

/// Create a copy of LaunchSuggestedTripsIndex
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? distanceModel = null,Object? snapMaxMeters = null,Object? maxDistanceMi = null,Object? paddleSpeedKmh = null,Object? maxOneWaySuggestions = null,Object? maxRoundTripSuggestions = null,Object? crossSystemReachability = null,Object? entries = null,}) {
  return _then(_LaunchSuggestedTripsIndex(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceModel: null == distanceModel ? _self.distanceModel : distanceModel // ignore: cast_nullable_to_non_nullable
as String,snapMaxMeters: null == snapMaxMeters ? _self.snapMaxMeters : snapMaxMeters // ignore: cast_nullable_to_non_nullable
as double,maxDistanceMi: null == maxDistanceMi ? _self.maxDistanceMi : maxDistanceMi // ignore: cast_nullable_to_non_nullable
as int,paddleSpeedKmh: null == paddleSpeedKmh ? _self.paddleSpeedKmh : paddleSpeedKmh // ignore: cast_nullable_to_non_nullable
as double,maxOneWaySuggestions: null == maxOneWaySuggestions ? _self.maxOneWaySuggestions : maxOneWaySuggestions // ignore: cast_nullable_to_non_nullable
as int,maxRoundTripSuggestions: null == maxRoundTripSuggestions ? _self.maxRoundTripSuggestions : maxRoundTripSuggestions // ignore: cast_nullable_to_non_nullable
as int,crossSystemReachability: null == crossSystemReachability ? _self.crossSystemReachability : crossSystemReachability // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, LaunchSuggestedTripsEntry>,
  ));
}


}

// dart format on
