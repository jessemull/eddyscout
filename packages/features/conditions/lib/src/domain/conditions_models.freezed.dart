// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conditions_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherConditions {

/// Data source used for this card.
 WeatherDataSource get source;/// Air temperature in °F when available.
 int? get temperatureF;/// Sustained wind in mph when available.
 int? get windSpeedMph;/// Wind gust in mph when available.
 int? get windGustMph;/// Compass or cardinal wind direction label.
 String? get windDirection;/// Short NWS phrase or Open-Meteo summary line.
 String? get shortForecast;/// Start of the forecast period used for wind (local time).
 DateTime? get periodStart;
/// Create a copy of WeatherConditions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherConditionsCopyWith<WeatherConditions> get copyWith => _$WeatherConditionsCopyWithImpl<WeatherConditions>(this as WeatherConditions, _$identity);

  /// Serializes this WeatherConditions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherConditions&&(identical(other.source, source) || other.source == source)&&(identical(other.temperatureF, temperatureF) || other.temperatureF == temperatureF)&&(identical(other.windSpeedMph, windSpeedMph) || other.windSpeedMph == windSpeedMph)&&(identical(other.windGustMph, windGustMph) || other.windGustMph == windGustMph)&&(identical(other.windDirection, windDirection) || other.windDirection == windDirection)&&(identical(other.shortForecast, shortForecast) || other.shortForecast == shortForecast)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,temperatureF,windSpeedMph,windGustMph,windDirection,shortForecast,periodStart);

@override
String toString() {
  return 'WeatherConditions(source: $source, temperatureF: $temperatureF, windSpeedMph: $windSpeedMph, windGustMph: $windGustMph, windDirection: $windDirection, shortForecast: $shortForecast, periodStart: $periodStart)';
}


}

/// @nodoc
abstract mixin class $WeatherConditionsCopyWith<$Res>  {
  factory $WeatherConditionsCopyWith(WeatherConditions value, $Res Function(WeatherConditions) _then) = _$WeatherConditionsCopyWithImpl;
@useResult
$Res call({
 WeatherDataSource source, int? temperatureF, int? windSpeedMph, int? windGustMph, String? windDirection, String? shortForecast, DateTime? periodStart
});




}
/// @nodoc
class _$WeatherConditionsCopyWithImpl<$Res>
    implements $WeatherConditionsCopyWith<$Res> {
  _$WeatherConditionsCopyWithImpl(this._self, this._then);

  final WeatherConditions _self;
  final $Res Function(WeatherConditions) _then;

/// Create a copy of WeatherConditions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? temperatureF = freezed,Object? windSpeedMph = freezed,Object? windGustMph = freezed,Object? windDirection = freezed,Object? shortForecast = freezed,Object? periodStart = freezed,}) {
  return _then(_self.copyWith(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WeatherDataSource,temperatureF: freezed == temperatureF ? _self.temperatureF : temperatureF // ignore: cast_nullable_to_non_nullable
as int?,windSpeedMph: freezed == windSpeedMph ? _self.windSpeedMph : windSpeedMph // ignore: cast_nullable_to_non_nullable
as int?,windGustMph: freezed == windGustMph ? _self.windGustMph : windGustMph // ignore: cast_nullable_to_non_nullable
as int?,windDirection: freezed == windDirection ? _self.windDirection : windDirection // ignore: cast_nullable_to_non_nullable
as String?,shortForecast: freezed == shortForecast ? _self.shortForecast : shortForecast // ignore: cast_nullable_to_non_nullable
as String?,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherConditions].
extension WeatherConditionsPatterns on WeatherConditions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherConditions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherConditions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherConditions value)  $default,){
final _that = this;
switch (_that) {
case _WeatherConditions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherConditions value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherConditions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WeatherDataSource source,  int? temperatureF,  int? windSpeedMph,  int? windGustMph,  String? windDirection,  String? shortForecast,  DateTime? periodStart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherConditions() when $default != null:
return $default(_that.source,_that.temperatureF,_that.windSpeedMph,_that.windGustMph,_that.windDirection,_that.shortForecast,_that.periodStart);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WeatherDataSource source,  int? temperatureF,  int? windSpeedMph,  int? windGustMph,  String? windDirection,  String? shortForecast,  DateTime? periodStart)  $default,) {final _that = this;
switch (_that) {
case _WeatherConditions():
return $default(_that.source,_that.temperatureF,_that.windSpeedMph,_that.windGustMph,_that.windDirection,_that.shortForecast,_that.periodStart);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WeatherDataSource source,  int? temperatureF,  int? windSpeedMph,  int? windGustMph,  String? windDirection,  String? shortForecast,  DateTime? periodStart)?  $default,) {final _that = this;
switch (_that) {
case _WeatherConditions() when $default != null:
return $default(_that.source,_that.temperatureF,_that.windSpeedMph,_that.windGustMph,_that.windDirection,_that.shortForecast,_that.periodStart);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherConditions implements WeatherConditions {
  const _WeatherConditions({required this.source, this.temperatureF, this.windSpeedMph, this.windGustMph, this.windDirection, this.shortForecast, this.periodStart});
  factory _WeatherConditions.fromJson(Map<String, dynamic> json) => _$WeatherConditionsFromJson(json);

/// Data source used for this card.
@override final  WeatherDataSource source;
/// Air temperature in °F when available.
@override final  int? temperatureF;
/// Sustained wind in mph when available.
@override final  int? windSpeedMph;
/// Wind gust in mph when available.
@override final  int? windGustMph;
/// Compass or cardinal wind direction label.
@override final  String? windDirection;
/// Short NWS phrase or Open-Meteo summary line.
@override final  String? shortForecast;
/// Start of the forecast period used for wind (local time).
@override final  DateTime? periodStart;

/// Create a copy of WeatherConditions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherConditionsCopyWith<_WeatherConditions> get copyWith => __$WeatherConditionsCopyWithImpl<_WeatherConditions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherConditionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherConditions&&(identical(other.source, source) || other.source == source)&&(identical(other.temperatureF, temperatureF) || other.temperatureF == temperatureF)&&(identical(other.windSpeedMph, windSpeedMph) || other.windSpeedMph == windSpeedMph)&&(identical(other.windGustMph, windGustMph) || other.windGustMph == windGustMph)&&(identical(other.windDirection, windDirection) || other.windDirection == windDirection)&&(identical(other.shortForecast, shortForecast) || other.shortForecast == shortForecast)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,temperatureF,windSpeedMph,windGustMph,windDirection,shortForecast,periodStart);

@override
String toString() {
  return 'WeatherConditions(source: $source, temperatureF: $temperatureF, windSpeedMph: $windSpeedMph, windGustMph: $windGustMph, windDirection: $windDirection, shortForecast: $shortForecast, periodStart: $periodStart)';
}


}

/// @nodoc
abstract mixin class _$WeatherConditionsCopyWith<$Res> implements $WeatherConditionsCopyWith<$Res> {
  factory _$WeatherConditionsCopyWith(_WeatherConditions value, $Res Function(_WeatherConditions) _then) = __$WeatherConditionsCopyWithImpl;
@override @useResult
$Res call({
 WeatherDataSource source, int? temperatureF, int? windSpeedMph, int? windGustMph, String? windDirection, String? shortForecast, DateTime? periodStart
});




}
/// @nodoc
class __$WeatherConditionsCopyWithImpl<$Res>
    implements _$WeatherConditionsCopyWith<$Res> {
  __$WeatherConditionsCopyWithImpl(this._self, this._then);

  final _WeatherConditions _self;
  final $Res Function(_WeatherConditions) _then;

/// Create a copy of WeatherConditions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? temperatureF = freezed,Object? windSpeedMph = freezed,Object? windGustMph = freezed,Object? windDirection = freezed,Object? shortForecast = freezed,Object? periodStart = freezed,}) {
  return _then(_WeatherConditions(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WeatherDataSource,temperatureF: freezed == temperatureF ? _self.temperatureF : temperatureF // ignore: cast_nullable_to_non_nullable
as int?,windSpeedMph: freezed == windSpeedMph ? _self.windSpeedMph : windSpeedMph // ignore: cast_nullable_to_non_nullable
as int?,windGustMph: freezed == windGustMph ? _self.windGustMph : windGustMph // ignore: cast_nullable_to_non_nullable
as int?,windDirection: freezed == windDirection ? _self.windDirection : windDirection // ignore: cast_nullable_to_non_nullable
as String?,shortForecast: freezed == shortForecast ? _self.shortForecast : shortForecast // ignore: cast_nullable_to_non_nullable
as String?,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TideEvent {

/// NOAA event type (e.g. H, L).
 String get type;/// Local or station time for the event.
 DateTime get time;/// Predicted height in feet when present.
 double? get heightFt;
/// Create a copy of TideEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TideEventCopyWith<TideEvent> get copyWith => _$TideEventCopyWithImpl<TideEvent>(this as TideEvent, _$identity);

  /// Serializes this TideEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TideEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.time, time) || other.time == time)&&(identical(other.heightFt, heightFt) || other.heightFt == heightFt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,time,heightFt);

@override
String toString() {
  return 'TideEvent(type: $type, time: $time, heightFt: $heightFt)';
}


}

/// @nodoc
abstract mixin class $TideEventCopyWith<$Res>  {
  factory $TideEventCopyWith(TideEvent value, $Res Function(TideEvent) _then) = _$TideEventCopyWithImpl;
@useResult
$Res call({
 String type, DateTime time, double? heightFt
});




}
/// @nodoc
class _$TideEventCopyWithImpl<$Res>
    implements $TideEventCopyWith<$Res> {
  _$TideEventCopyWithImpl(this._self, this._then);

  final TideEvent _self;
  final $Res Function(TideEvent) _then;

/// Create a copy of TideEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? time = null,Object? heightFt = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,heightFt: freezed == heightFt ? _self.heightFt : heightFt // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TideEvent].
extension TideEventPatterns on TideEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TideEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TideEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TideEvent value)  $default,){
final _that = this;
switch (_that) {
case _TideEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TideEvent value)?  $default,){
final _that = this;
switch (_that) {
case _TideEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  DateTime time,  double? heightFt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TideEvent() when $default != null:
return $default(_that.type,_that.time,_that.heightFt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  DateTime time,  double? heightFt)  $default,) {final _that = this;
switch (_that) {
case _TideEvent():
return $default(_that.type,_that.time,_that.heightFt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  DateTime time,  double? heightFt)?  $default,) {final _that = this;
switch (_that) {
case _TideEvent() when $default != null:
return $default(_that.type,_that.time,_that.heightFt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TideEvent implements TideEvent {
  const _TideEvent({required this.type, required this.time, this.heightFt});
  factory _TideEvent.fromJson(Map<String, dynamic> json) => _$TideEventFromJson(json);

/// NOAA event type (e.g. H, L).
@override final  String type;
/// Local or station time for the event.
@override final  DateTime time;
/// Predicted height in feet when present.
@override final  double? heightFt;

/// Create a copy of TideEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TideEventCopyWith<_TideEvent> get copyWith => __$TideEventCopyWithImpl<_TideEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TideEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TideEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.time, time) || other.time == time)&&(identical(other.heightFt, heightFt) || other.heightFt == heightFt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,time,heightFt);

@override
String toString() {
  return 'TideEvent(type: $type, time: $time, heightFt: $heightFt)';
}


}

/// @nodoc
abstract mixin class _$TideEventCopyWith<$Res> implements $TideEventCopyWith<$Res> {
  factory _$TideEventCopyWith(_TideEvent value, $Res Function(_TideEvent) _then) = __$TideEventCopyWithImpl;
@override @useResult
$Res call({
 String type, DateTime time, double? heightFt
});




}
/// @nodoc
class __$TideEventCopyWithImpl<$Res>
    implements _$TideEventCopyWith<$Res> {
  __$TideEventCopyWithImpl(this._self, this._then);

  final _TideEvent _self;
  final $Res Function(_TideEvent) _then;

/// Create a copy of TideEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? time = null,Object? heightFt = freezed,}) {
  return _then(_TideEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,heightFt: freezed == heightFt ? _self.heightFt : heightFt // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$TideSummary {

/// NOAA station identifier.
 String get stationId;/// Datum label (e.g. CRD, MLLW).
 String get datumLabel;/// Upcoming high/low events in the fetch window.
 List<TideEvent> get events;/// Optional caveat for pool / lagged stage launches.
 String? get referenceNote;
/// Create a copy of TideSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TideSummaryCopyWith<TideSummary> get copyWith => _$TideSummaryCopyWithImpl<TideSummary>(this as TideSummary, _$identity);

  /// Serializes this TideSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TideSummary&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.datumLabel, datumLabel) || other.datumLabel == datumLabel)&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.referenceNote, referenceNote) || other.referenceNote == referenceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stationId,datumLabel,const DeepCollectionEquality().hash(events),referenceNote);

@override
String toString() {
  return 'TideSummary(stationId: $stationId, datumLabel: $datumLabel, events: $events, referenceNote: $referenceNote)';
}


}

/// @nodoc
abstract mixin class $TideSummaryCopyWith<$Res>  {
  factory $TideSummaryCopyWith(TideSummary value, $Res Function(TideSummary) _then) = _$TideSummaryCopyWithImpl;
@useResult
$Res call({
 String stationId, String datumLabel, List<TideEvent> events, String? referenceNote
});




}
/// @nodoc
class _$TideSummaryCopyWithImpl<$Res>
    implements $TideSummaryCopyWith<$Res> {
  _$TideSummaryCopyWithImpl(this._self, this._then);

  final TideSummary _self;
  final $Res Function(TideSummary) _then;

/// Create a copy of TideSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stationId = null,Object? datumLabel = null,Object? events = null,Object? referenceNote = freezed,}) {
  return _then(_self.copyWith(
stationId: null == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String,datumLabel: null == datumLabel ? _self.datumLabel : datumLabel // ignore: cast_nullable_to_non_nullable
as String,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<TideEvent>,referenceNote: freezed == referenceNote ? _self.referenceNote : referenceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TideSummary].
extension TideSummaryPatterns on TideSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TideSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TideSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TideSummary value)  $default,){
final _that = this;
switch (_that) {
case _TideSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TideSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TideSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stationId,  String datumLabel,  List<TideEvent> events,  String? referenceNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TideSummary() when $default != null:
return $default(_that.stationId,_that.datumLabel,_that.events,_that.referenceNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stationId,  String datumLabel,  List<TideEvent> events,  String? referenceNote)  $default,) {final _that = this;
switch (_that) {
case _TideSummary():
return $default(_that.stationId,_that.datumLabel,_that.events,_that.referenceNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stationId,  String datumLabel,  List<TideEvent> events,  String? referenceNote)?  $default,) {final _that = this;
switch (_that) {
case _TideSummary() when $default != null:
return $default(_that.stationId,_that.datumLabel,_that.events,_that.referenceNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TideSummary implements TideSummary {
  const _TideSummary({required this.stationId, required this.datumLabel, required final  List<TideEvent> events, this.referenceNote}): _events = events;
  factory _TideSummary.fromJson(Map<String, dynamic> json) => _$TideSummaryFromJson(json);

/// NOAA station identifier.
@override final  String stationId;
/// Datum label (e.g. CRD, MLLW).
@override final  String datumLabel;
/// Upcoming high/low events in the fetch window.
 final  List<TideEvent> _events;
/// Upcoming high/low events in the fetch window.
@override List<TideEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

/// Optional caveat for pool / lagged stage launches.
@override final  String? referenceNote;

/// Create a copy of TideSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TideSummaryCopyWith<_TideSummary> get copyWith => __$TideSummaryCopyWithImpl<_TideSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TideSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TideSummary&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.datumLabel, datumLabel) || other.datumLabel == datumLabel)&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.referenceNote, referenceNote) || other.referenceNote == referenceNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stationId,datumLabel,const DeepCollectionEquality().hash(_events),referenceNote);

@override
String toString() {
  return 'TideSummary(stationId: $stationId, datumLabel: $datumLabel, events: $events, referenceNote: $referenceNote)';
}


}

/// @nodoc
abstract mixin class _$TideSummaryCopyWith<$Res> implements $TideSummaryCopyWith<$Res> {
  factory _$TideSummaryCopyWith(_TideSummary value, $Res Function(_TideSummary) _then) = __$TideSummaryCopyWithImpl;
@override @useResult
$Res call({
 String stationId, String datumLabel, List<TideEvent> events, String? referenceNote
});




}
/// @nodoc
class __$TideSummaryCopyWithImpl<$Res>
    implements _$TideSummaryCopyWith<$Res> {
  __$TideSummaryCopyWithImpl(this._self, this._then);

  final _TideSummary _self;
  final $Res Function(_TideSummary) _then;

/// Create a copy of TideSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stationId = null,Object? datumLabel = null,Object? events = null,Object? referenceNote = freezed,}) {
  return _then(_TideSummary(
stationId: null == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String,datumLabel: null == datumLabel ? _self.datumLabel : datumLabel // ignore: cast_nullable_to_non_nullable
as String,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<TideEvent>,referenceNote: freezed == referenceNote ? _self.referenceNote : referenceNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MarinePeriod {

/// Period name from NWS JSON or CWF section title.
 String get name;/// Full text used for keyword go/no-go scanning.
 String get detailedForecast;
/// Create a copy of MarinePeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarinePeriodCopyWith<MarinePeriod> get copyWith => _$MarinePeriodCopyWithImpl<MarinePeriod>(this as MarinePeriod, _$identity);

  /// Serializes this MarinePeriod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarinePeriod&&(identical(other.name, name) || other.name == name)&&(identical(other.detailedForecast, detailedForecast) || other.detailedForecast == detailedForecast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,detailedForecast);

@override
String toString() {
  return 'MarinePeriod(name: $name, detailedForecast: $detailedForecast)';
}


}

/// @nodoc
abstract mixin class $MarinePeriodCopyWith<$Res>  {
  factory $MarinePeriodCopyWith(MarinePeriod value, $Res Function(MarinePeriod) _then) = _$MarinePeriodCopyWithImpl;
@useResult
$Res call({
 String name, String detailedForecast
});




}
/// @nodoc
class _$MarinePeriodCopyWithImpl<$Res>
    implements $MarinePeriodCopyWith<$Res> {
  _$MarinePeriodCopyWithImpl(this._self, this._then);

  final MarinePeriod _self;
  final $Res Function(MarinePeriod) _then;

/// Create a copy of MarinePeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? detailedForecast = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,detailedForecast: null == detailedForecast ? _self.detailedForecast : detailedForecast // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MarinePeriod].
extension MarinePeriodPatterns on MarinePeriod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarinePeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarinePeriod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarinePeriod value)  $default,){
final _that = this;
switch (_that) {
case _MarinePeriod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarinePeriod value)?  $default,){
final _that = this;
switch (_that) {
case _MarinePeriod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String detailedForecast)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarinePeriod() when $default != null:
return $default(_that.name,_that.detailedForecast);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String detailedForecast)  $default,) {final _that = this;
switch (_that) {
case _MarinePeriod():
return $default(_that.name,_that.detailedForecast);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String detailedForecast)?  $default,) {final _that = this;
switch (_that) {
case _MarinePeriod() when $default != null:
return $default(_that.name,_that.detailedForecast);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarinePeriod implements MarinePeriod {
  const _MarinePeriod({required this.name, required this.detailedForecast});
  factory _MarinePeriod.fromJson(Map<String, dynamic> json) => _$MarinePeriodFromJson(json);

/// Period name from NWS JSON or CWF section title.
@override final  String name;
/// Full text used for keyword go/no-go scanning.
@override final  String detailedForecast;

/// Create a copy of MarinePeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarinePeriodCopyWith<_MarinePeriod> get copyWith => __$MarinePeriodCopyWithImpl<_MarinePeriod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarinePeriodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarinePeriod&&(identical(other.name, name) || other.name == name)&&(identical(other.detailedForecast, detailedForecast) || other.detailedForecast == detailedForecast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,detailedForecast);

@override
String toString() {
  return 'MarinePeriod(name: $name, detailedForecast: $detailedForecast)';
}


}

/// @nodoc
abstract mixin class _$MarinePeriodCopyWith<$Res> implements $MarinePeriodCopyWith<$Res> {
  factory _$MarinePeriodCopyWith(_MarinePeriod value, $Res Function(_MarinePeriod) _then) = __$MarinePeriodCopyWithImpl;
@override @useResult
$Res call({
 String name, String detailedForecast
});




}
/// @nodoc
class __$MarinePeriodCopyWithImpl<$Res>
    implements _$MarinePeriodCopyWith<$Res> {
  __$MarinePeriodCopyWithImpl(this._self, this._then);

  final _MarinePeriod _self;
  final $Res Function(_MarinePeriod) _then;

/// Create a copy of MarinePeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? detailedForecast = null,}) {
  return _then(_MarinePeriod(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,detailedForecast: null == detailedForecast ? _self.detailedForecast : detailedForecast // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MarineSummary {

/// NWS marine zone id (e.g. PZZ210).
 String get zoneId;/// One or more forecast periods for display and rules.
 List<MarinePeriod> get periods;
/// Create a copy of MarineSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarineSummaryCopyWith<MarineSummary> get copyWith => _$MarineSummaryCopyWithImpl<MarineSummary>(this as MarineSummary, _$identity);

  /// Serializes this MarineSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarineSummary&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&const DeepCollectionEquality().equals(other.periods, periods));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zoneId,const DeepCollectionEquality().hash(periods));

@override
String toString() {
  return 'MarineSummary(zoneId: $zoneId, periods: $periods)';
}


}

/// @nodoc
abstract mixin class $MarineSummaryCopyWith<$Res>  {
  factory $MarineSummaryCopyWith(MarineSummary value, $Res Function(MarineSummary) _then) = _$MarineSummaryCopyWithImpl;
@useResult
$Res call({
 String zoneId, List<MarinePeriod> periods
});




}
/// @nodoc
class _$MarineSummaryCopyWithImpl<$Res>
    implements $MarineSummaryCopyWith<$Res> {
  _$MarineSummaryCopyWithImpl(this._self, this._then);

  final MarineSummary _self;
  final $Res Function(MarineSummary) _then;

/// Create a copy of MarineSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zoneId = null,Object? periods = null,}) {
  return _then(_self.copyWith(
zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,periods: null == periods ? _self.periods : periods // ignore: cast_nullable_to_non_nullable
as List<MarinePeriod>,
  ));
}

}


/// Adds pattern-matching-related methods to [MarineSummary].
extension MarineSummaryPatterns on MarineSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarineSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarineSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarineSummary value)  $default,){
final _that = this;
switch (_that) {
case _MarineSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarineSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MarineSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String zoneId,  List<MarinePeriod> periods)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarineSummary() when $default != null:
return $default(_that.zoneId,_that.periods);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String zoneId,  List<MarinePeriod> periods)  $default,) {final _that = this;
switch (_that) {
case _MarineSummary():
return $default(_that.zoneId,_that.periods);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String zoneId,  List<MarinePeriod> periods)?  $default,) {final _that = this;
switch (_that) {
case _MarineSummary() when $default != null:
return $default(_that.zoneId,_that.periods);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarineSummary implements MarineSummary {
  const _MarineSummary({required this.zoneId, required final  List<MarinePeriod> periods}): _periods = periods;
  factory _MarineSummary.fromJson(Map<String, dynamic> json) => _$MarineSummaryFromJson(json);

/// NWS marine zone id (e.g. PZZ210).
@override final  String zoneId;
/// One or more forecast periods for display and rules.
 final  List<MarinePeriod> _periods;
/// One or more forecast periods for display and rules.
@override List<MarinePeriod> get periods {
  if (_periods is EqualUnmodifiableListView) return _periods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_periods);
}


/// Create a copy of MarineSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarineSummaryCopyWith<_MarineSummary> get copyWith => __$MarineSummaryCopyWithImpl<_MarineSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarineSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarineSummary&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&const DeepCollectionEquality().equals(other._periods, _periods));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zoneId,const DeepCollectionEquality().hash(_periods));

@override
String toString() {
  return 'MarineSummary(zoneId: $zoneId, periods: $periods)';
}


}

/// @nodoc
abstract mixin class _$MarineSummaryCopyWith<$Res> implements $MarineSummaryCopyWith<$Res> {
  factory _$MarineSummaryCopyWith(_MarineSummary value, $Res Function(_MarineSummary) _then) = __$MarineSummaryCopyWithImpl;
@override @useResult
$Res call({
 String zoneId, List<MarinePeriod> periods
});




}
/// @nodoc
class __$MarineSummaryCopyWithImpl<$Res>
    implements _$MarineSummaryCopyWith<$Res> {
  __$MarineSummaryCopyWithImpl(this._self, this._then);

  final _MarineSummary _self;
  final $Res Function(_MarineSummary) _then;

/// Create a copy of MarineSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zoneId = null,Object? periods = null,}) {
  return _then(_MarineSummary(
zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,periods: null == periods ? _self._periods : periods // ignore: cast_nullable_to_non_nullable
as List<MarinePeriod>,
  ));
}


}


/// @nodoc
mixin _$RiverFlowReading {

/// USGS site id (parameter 00060).
 String get siteId;/// Discharge in cubic feet per second.
 double get cfs;/// Observation timestamp from USGS IV JSON.
 DateTime get observedAt;
/// Create a copy of RiverFlowReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiverFlowReadingCopyWith<RiverFlowReading> get copyWith => _$RiverFlowReadingCopyWithImpl<RiverFlowReading>(this as RiverFlowReading, _$identity);

  /// Serializes this RiverFlowReading to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiverFlowReading&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.cfs, cfs) || other.cfs == cfs)&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteId,cfs,observedAt);

@override
String toString() {
  return 'RiverFlowReading(siteId: $siteId, cfs: $cfs, observedAt: $observedAt)';
}


}

/// @nodoc
abstract mixin class $RiverFlowReadingCopyWith<$Res>  {
  factory $RiverFlowReadingCopyWith(RiverFlowReading value, $Res Function(RiverFlowReading) _then) = _$RiverFlowReadingCopyWithImpl;
@useResult
$Res call({
 String siteId, double cfs, DateTime observedAt
});




}
/// @nodoc
class _$RiverFlowReadingCopyWithImpl<$Res>
    implements $RiverFlowReadingCopyWith<$Res> {
  _$RiverFlowReadingCopyWithImpl(this._self, this._then);

  final RiverFlowReading _self;
  final $Res Function(RiverFlowReading) _then;

/// Create a copy of RiverFlowReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteId = null,Object? cfs = null,Object? observedAt = null,}) {
  return _then(_self.copyWith(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,cfs: null == cfs ? _self.cfs : cfs // ignore: cast_nullable_to_non_nullable
as double,observedAt: null == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RiverFlowReading].
extension RiverFlowReadingPatterns on RiverFlowReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiverFlowReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiverFlowReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiverFlowReading value)  $default,){
final _that = this;
switch (_that) {
case _RiverFlowReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiverFlowReading value)?  $default,){
final _that = this;
switch (_that) {
case _RiverFlowReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String siteId,  double cfs,  DateTime observedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiverFlowReading() when $default != null:
return $default(_that.siteId,_that.cfs,_that.observedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String siteId,  double cfs,  DateTime observedAt)  $default,) {final _that = this;
switch (_that) {
case _RiverFlowReading():
return $default(_that.siteId,_that.cfs,_that.observedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String siteId,  double cfs,  DateTime observedAt)?  $default,) {final _that = this;
switch (_that) {
case _RiverFlowReading() when $default != null:
return $default(_that.siteId,_that.cfs,_that.observedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiverFlowReading implements RiverFlowReading {
  const _RiverFlowReading({required this.siteId, required this.cfs, required this.observedAt});
  factory _RiverFlowReading.fromJson(Map<String, dynamic> json) => _$RiverFlowReadingFromJson(json);

/// USGS site id (parameter 00060).
@override final  String siteId;
/// Discharge in cubic feet per second.
@override final  double cfs;
/// Observation timestamp from USGS IV JSON.
@override final  DateTime observedAt;

/// Create a copy of RiverFlowReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiverFlowReadingCopyWith<_RiverFlowReading> get copyWith => __$RiverFlowReadingCopyWithImpl<_RiverFlowReading>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiverFlowReadingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiverFlowReading&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.cfs, cfs) || other.cfs == cfs)&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,siteId,cfs,observedAt);

@override
String toString() {
  return 'RiverFlowReading(siteId: $siteId, cfs: $cfs, observedAt: $observedAt)';
}


}

/// @nodoc
abstract mixin class _$RiverFlowReadingCopyWith<$Res> implements $RiverFlowReadingCopyWith<$Res> {
  factory _$RiverFlowReadingCopyWith(_RiverFlowReading value, $Res Function(_RiverFlowReading) _then) = __$RiverFlowReadingCopyWithImpl;
@override @useResult
$Res call({
 String siteId, double cfs, DateTime observedAt
});




}
/// @nodoc
class __$RiverFlowReadingCopyWithImpl<$Res>
    implements _$RiverFlowReadingCopyWith<$Res> {
  __$RiverFlowReadingCopyWithImpl(this._self, this._then);

  final _RiverFlowReading _self;
  final $Res Function(_RiverFlowReading) _then;

/// Create a copy of RiverFlowReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteId = null,Object? cfs = null,Object? observedAt = null,}) {
  return _then(_RiverFlowReading(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,cfs: null == cfs ? _self.cfs : cfs // ignore: cast_nullable_to_non_nullable
as double,observedAt: null == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ConditionsSnapshot {

/// When this snapshot was assembled on device.
 DateTime get fetchedAt;/// Parsed weather, if the weather pipeline succeeded.
 WeatherConditions? get weather;/// User-facing weather error when [weather] is null.
 String? get weatherError;/// Parsed tides when the launch uses a NOAA station.
 TideSummary? get tides;/// User-facing tide error when tides were expected but failed.
 String? get tideError;/// Parsed marine summary when a marine zone is configured.
 MarineSummary? get marine;/// User-facing marine error when a zone was configured but failed.
 String? get marineError;/// Parsed USGS discharge when a site id is configured.
 RiverFlowReading? get riverFlow;/// User-facing river error when USGS was expected but failed.
 String? get riverError;
/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionsSnapshotCopyWith<ConditionsSnapshot> get copyWith => _$ConditionsSnapshotCopyWithImpl<ConditionsSnapshot>(this as ConditionsSnapshot, _$identity);

  /// Serializes this ConditionsSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionsSnapshot&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.weatherError, weatherError) || other.weatherError == weatherError)&&(identical(other.tides, tides) || other.tides == tides)&&(identical(other.tideError, tideError) || other.tideError == tideError)&&(identical(other.marine, marine) || other.marine == marine)&&(identical(other.marineError, marineError) || other.marineError == marineError)&&(identical(other.riverFlow, riverFlow) || other.riverFlow == riverFlow)&&(identical(other.riverError, riverError) || other.riverError == riverError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fetchedAt,weather,weatherError,tides,tideError,marine,marineError,riverFlow,riverError);

@override
String toString() {
  return 'ConditionsSnapshot(fetchedAt: $fetchedAt, weather: $weather, weatherError: $weatherError, tides: $tides, tideError: $tideError, marine: $marine, marineError: $marineError, riverFlow: $riverFlow, riverError: $riverError)';
}


}

/// @nodoc
abstract mixin class $ConditionsSnapshotCopyWith<$Res>  {
  factory $ConditionsSnapshotCopyWith(ConditionsSnapshot value, $Res Function(ConditionsSnapshot) _then) = _$ConditionsSnapshotCopyWithImpl;
@useResult
$Res call({
 DateTime fetchedAt, WeatherConditions? weather, String? weatherError, TideSummary? tides, String? tideError, MarineSummary? marine, String? marineError, RiverFlowReading? riverFlow, String? riverError
});


$WeatherConditionsCopyWith<$Res>? get weather;$TideSummaryCopyWith<$Res>? get tides;$MarineSummaryCopyWith<$Res>? get marine;$RiverFlowReadingCopyWith<$Res>? get riverFlow;

}
/// @nodoc
class _$ConditionsSnapshotCopyWithImpl<$Res>
    implements $ConditionsSnapshotCopyWith<$Res> {
  _$ConditionsSnapshotCopyWithImpl(this._self, this._then);

  final ConditionsSnapshot _self;
  final $Res Function(ConditionsSnapshot) _then;

/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fetchedAt = null,Object? weather = freezed,Object? weatherError = freezed,Object? tides = freezed,Object? tideError = freezed,Object? marine = freezed,Object? marineError = freezed,Object? riverFlow = freezed,Object? riverError = freezed,}) {
  return _then(_self.copyWith(
fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as WeatherConditions?,weatherError: freezed == weatherError ? _self.weatherError : weatherError // ignore: cast_nullable_to_non_nullable
as String?,tides: freezed == tides ? _self.tides : tides // ignore: cast_nullable_to_non_nullable
as TideSummary?,tideError: freezed == tideError ? _self.tideError : tideError // ignore: cast_nullable_to_non_nullable
as String?,marine: freezed == marine ? _self.marine : marine // ignore: cast_nullable_to_non_nullable
as MarineSummary?,marineError: freezed == marineError ? _self.marineError : marineError // ignore: cast_nullable_to_non_nullable
as String?,riverFlow: freezed == riverFlow ? _self.riverFlow : riverFlow // ignore: cast_nullable_to_non_nullable
as RiverFlowReading?,riverError: freezed == riverError ? _self.riverError : riverError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherConditionsCopyWith<$Res>? get weather {
    if (_self.weather == null) {
    return null;
  }

  return $WeatherConditionsCopyWith<$Res>(_self.weather!, (value) {
    return _then(_self.copyWith(weather: value));
  });
}/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TideSummaryCopyWith<$Res>? get tides {
    if (_self.tides == null) {
    return null;
  }

  return $TideSummaryCopyWith<$Res>(_self.tides!, (value) {
    return _then(_self.copyWith(tides: value));
  });
}/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarineSummaryCopyWith<$Res>? get marine {
    if (_self.marine == null) {
    return null;
  }

  return $MarineSummaryCopyWith<$Res>(_self.marine!, (value) {
    return _then(_self.copyWith(marine: value));
  });
}/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RiverFlowReadingCopyWith<$Res>? get riverFlow {
    if (_self.riverFlow == null) {
    return null;
  }

  return $RiverFlowReadingCopyWith<$Res>(_self.riverFlow!, (value) {
    return _then(_self.copyWith(riverFlow: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConditionsSnapshot].
extension ConditionsSnapshotPatterns on ConditionsSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConditionsSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConditionsSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConditionsSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ConditionsSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConditionsSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ConditionsSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime fetchedAt,  WeatherConditions? weather,  String? weatherError,  TideSummary? tides,  String? tideError,  MarineSummary? marine,  String? marineError,  RiverFlowReading? riverFlow,  String? riverError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConditionsSnapshot() when $default != null:
return $default(_that.fetchedAt,_that.weather,_that.weatherError,_that.tides,_that.tideError,_that.marine,_that.marineError,_that.riverFlow,_that.riverError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime fetchedAt,  WeatherConditions? weather,  String? weatherError,  TideSummary? tides,  String? tideError,  MarineSummary? marine,  String? marineError,  RiverFlowReading? riverFlow,  String? riverError)  $default,) {final _that = this;
switch (_that) {
case _ConditionsSnapshot():
return $default(_that.fetchedAt,_that.weather,_that.weatherError,_that.tides,_that.tideError,_that.marine,_that.marineError,_that.riverFlow,_that.riverError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime fetchedAt,  WeatherConditions? weather,  String? weatherError,  TideSummary? tides,  String? tideError,  MarineSummary? marine,  String? marineError,  RiverFlowReading? riverFlow,  String? riverError)?  $default,) {final _that = this;
switch (_that) {
case _ConditionsSnapshot() when $default != null:
return $default(_that.fetchedAt,_that.weather,_that.weatherError,_that.tides,_that.tideError,_that.marine,_that.marineError,_that.riverFlow,_that.riverError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConditionsSnapshot implements ConditionsSnapshot {
  const _ConditionsSnapshot({required this.fetchedAt, this.weather, this.weatherError, this.tides, this.tideError, this.marine, this.marineError, this.riverFlow, this.riverError});
  factory _ConditionsSnapshot.fromJson(Map<String, dynamic> json) => _$ConditionsSnapshotFromJson(json);

/// When this snapshot was assembled on device.
@override final  DateTime fetchedAt;
/// Parsed weather, if the weather pipeline succeeded.
@override final  WeatherConditions? weather;
/// User-facing weather error when [weather] is null.
@override final  String? weatherError;
/// Parsed tides when the launch uses a NOAA station.
@override final  TideSummary? tides;
/// User-facing tide error when tides were expected but failed.
@override final  String? tideError;
/// Parsed marine summary when a marine zone is configured.
@override final  MarineSummary? marine;
/// User-facing marine error when a zone was configured but failed.
@override final  String? marineError;
/// Parsed USGS discharge when a site id is configured.
@override final  RiverFlowReading? riverFlow;
/// User-facing river error when USGS was expected but failed.
@override final  String? riverError;

/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConditionsSnapshotCopyWith<_ConditionsSnapshot> get copyWith => __$ConditionsSnapshotCopyWithImpl<_ConditionsSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConditionsSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConditionsSnapshot&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.weatherError, weatherError) || other.weatherError == weatherError)&&(identical(other.tides, tides) || other.tides == tides)&&(identical(other.tideError, tideError) || other.tideError == tideError)&&(identical(other.marine, marine) || other.marine == marine)&&(identical(other.marineError, marineError) || other.marineError == marineError)&&(identical(other.riverFlow, riverFlow) || other.riverFlow == riverFlow)&&(identical(other.riverError, riverError) || other.riverError == riverError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fetchedAt,weather,weatherError,tides,tideError,marine,marineError,riverFlow,riverError);

@override
String toString() {
  return 'ConditionsSnapshot(fetchedAt: $fetchedAt, weather: $weather, weatherError: $weatherError, tides: $tides, tideError: $tideError, marine: $marine, marineError: $marineError, riverFlow: $riverFlow, riverError: $riverError)';
}


}

/// @nodoc
abstract mixin class _$ConditionsSnapshotCopyWith<$Res> implements $ConditionsSnapshotCopyWith<$Res> {
  factory _$ConditionsSnapshotCopyWith(_ConditionsSnapshot value, $Res Function(_ConditionsSnapshot) _then) = __$ConditionsSnapshotCopyWithImpl;
@override @useResult
$Res call({
 DateTime fetchedAt, WeatherConditions? weather, String? weatherError, TideSummary? tides, String? tideError, MarineSummary? marine, String? marineError, RiverFlowReading? riverFlow, String? riverError
});


@override $WeatherConditionsCopyWith<$Res>? get weather;@override $TideSummaryCopyWith<$Res>? get tides;@override $MarineSummaryCopyWith<$Res>? get marine;@override $RiverFlowReadingCopyWith<$Res>? get riverFlow;

}
/// @nodoc
class __$ConditionsSnapshotCopyWithImpl<$Res>
    implements _$ConditionsSnapshotCopyWith<$Res> {
  __$ConditionsSnapshotCopyWithImpl(this._self, this._then);

  final _ConditionsSnapshot _self;
  final $Res Function(_ConditionsSnapshot) _then;

/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fetchedAt = null,Object? weather = freezed,Object? weatherError = freezed,Object? tides = freezed,Object? tideError = freezed,Object? marine = freezed,Object? marineError = freezed,Object? riverFlow = freezed,Object? riverError = freezed,}) {
  return _then(_ConditionsSnapshot(
fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as WeatherConditions?,weatherError: freezed == weatherError ? _self.weatherError : weatherError // ignore: cast_nullable_to_non_nullable
as String?,tides: freezed == tides ? _self.tides : tides // ignore: cast_nullable_to_non_nullable
as TideSummary?,tideError: freezed == tideError ? _self.tideError : tideError // ignore: cast_nullable_to_non_nullable
as String?,marine: freezed == marine ? _self.marine : marine // ignore: cast_nullable_to_non_nullable
as MarineSummary?,marineError: freezed == marineError ? _self.marineError : marineError // ignore: cast_nullable_to_non_nullable
as String?,riverFlow: freezed == riverFlow ? _self.riverFlow : riverFlow // ignore: cast_nullable_to_non_nullable
as RiverFlowReading?,riverError: freezed == riverError ? _self.riverError : riverError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherConditionsCopyWith<$Res>? get weather {
    if (_self.weather == null) {
    return null;
  }

  return $WeatherConditionsCopyWith<$Res>(_self.weather!, (value) {
    return _then(_self.copyWith(weather: value));
  });
}/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TideSummaryCopyWith<$Res>? get tides {
    if (_self.tides == null) {
    return null;
  }

  return $TideSummaryCopyWith<$Res>(_self.tides!, (value) {
    return _then(_self.copyWith(tides: value));
  });
}/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarineSummaryCopyWith<$Res>? get marine {
    if (_self.marine == null) {
    return null;
  }

  return $MarineSummaryCopyWith<$Res>(_self.marine!, (value) {
    return _then(_self.copyWith(marine: value));
  });
}/// Create a copy of ConditionsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RiverFlowReadingCopyWith<$Res>? get riverFlow {
    if (_self.riverFlow == null) {
    return null;
  }

  return $RiverFlowReadingCopyWith<$Res>(_self.riverFlow!, (value) {
    return _then(_self.copyWith(riverFlow: value));
  });
}
}

// dart format on
