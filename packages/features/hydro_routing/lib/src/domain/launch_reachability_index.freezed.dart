// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launch_reachability_index.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LaunchReachabilityEntry {

 List<String> get within5Mi; List<String> get within10Mi; List<String> get within20Mi;
/// Create a copy of LaunchReachabilityEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchReachabilityEntryCopyWith<LaunchReachabilityEntry> get copyWith => _$LaunchReachabilityEntryCopyWithImpl<LaunchReachabilityEntry>(this as LaunchReachabilityEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchReachabilityEntry&&const DeepCollectionEquality().equals(other.within5Mi, within5Mi)&&const DeepCollectionEquality().equals(other.within10Mi, within10Mi)&&const DeepCollectionEquality().equals(other.within20Mi, within20Mi));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(within5Mi),const DeepCollectionEquality().hash(within10Mi),const DeepCollectionEquality().hash(within20Mi));

@override
String toString() {
  return 'LaunchReachabilityEntry(within5Mi: $within5Mi, within10Mi: $within10Mi, within20Mi: $within20Mi)';
}


}

/// @nodoc
abstract mixin class $LaunchReachabilityEntryCopyWith<$Res>  {
  factory $LaunchReachabilityEntryCopyWith(LaunchReachabilityEntry value, $Res Function(LaunchReachabilityEntry) _then) = _$LaunchReachabilityEntryCopyWithImpl;
@useResult
$Res call({
 List<String> within5Mi, List<String> within10Mi, List<String> within20Mi
});




}
/// @nodoc
class _$LaunchReachabilityEntryCopyWithImpl<$Res>
    implements $LaunchReachabilityEntryCopyWith<$Res> {
  _$LaunchReachabilityEntryCopyWithImpl(this._self, this._then);

  final LaunchReachabilityEntry _self;
  final $Res Function(LaunchReachabilityEntry) _then;

/// Create a copy of LaunchReachabilityEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? within5Mi = null,Object? within10Mi = null,Object? within20Mi = null,}) {
  return _then(_self.copyWith(
within5Mi: null == within5Mi ? _self.within5Mi : within5Mi // ignore: cast_nullable_to_non_nullable
as List<String>,within10Mi: null == within10Mi ? _self.within10Mi : within10Mi // ignore: cast_nullable_to_non_nullable
as List<String>,within20Mi: null == within20Mi ? _self.within20Mi : within20Mi // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [LaunchReachabilityEntry].
extension LaunchReachabilityEntryPatterns on LaunchReachabilityEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchReachabilityEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchReachabilityEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchReachabilityEntry value)  $default,){
final _that = this;
switch (_that) {
case _LaunchReachabilityEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchReachabilityEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchReachabilityEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> within5Mi,  List<String> within10Mi,  List<String> within20Mi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchReachabilityEntry() when $default != null:
return $default(_that.within5Mi,_that.within10Mi,_that.within20Mi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> within5Mi,  List<String> within10Mi,  List<String> within20Mi)  $default,) {final _that = this;
switch (_that) {
case _LaunchReachabilityEntry():
return $default(_that.within5Mi,_that.within10Mi,_that.within20Mi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> within5Mi,  List<String> within10Mi,  List<String> within20Mi)?  $default,) {final _that = this;
switch (_that) {
case _LaunchReachabilityEntry() when $default != null:
return $default(_that.within5Mi,_that.within10Mi,_that.within20Mi);case _:
  return null;

}
}

}

/// @nodoc


class _LaunchReachabilityEntry extends LaunchReachabilityEntry {
  const _LaunchReachabilityEntry({final  List<String> within5Mi = const [], final  List<String> within10Mi = const [], final  List<String> within20Mi = const []}): _within5Mi = within5Mi,_within10Mi = within10Mi,_within20Mi = within20Mi,super._();
  

 final  List<String> _within5Mi;
@override@JsonKey() List<String> get within5Mi {
  if (_within5Mi is EqualUnmodifiableListView) return _within5Mi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_within5Mi);
}

 final  List<String> _within10Mi;
@override@JsonKey() List<String> get within10Mi {
  if (_within10Mi is EqualUnmodifiableListView) return _within10Mi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_within10Mi);
}

 final  List<String> _within20Mi;
@override@JsonKey() List<String> get within20Mi {
  if (_within20Mi is EqualUnmodifiableListView) return _within20Mi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_within20Mi);
}


/// Create a copy of LaunchReachabilityEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchReachabilityEntryCopyWith<_LaunchReachabilityEntry> get copyWith => __$LaunchReachabilityEntryCopyWithImpl<_LaunchReachabilityEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchReachabilityEntry&&const DeepCollectionEquality().equals(other._within5Mi, _within5Mi)&&const DeepCollectionEquality().equals(other._within10Mi, _within10Mi)&&const DeepCollectionEquality().equals(other._within20Mi, _within20Mi));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_within5Mi),const DeepCollectionEquality().hash(_within10Mi),const DeepCollectionEquality().hash(_within20Mi));

@override
String toString() {
  return 'LaunchReachabilityEntry(within5Mi: $within5Mi, within10Mi: $within10Mi, within20Mi: $within20Mi)';
}


}

/// @nodoc
abstract mixin class _$LaunchReachabilityEntryCopyWith<$Res> implements $LaunchReachabilityEntryCopyWith<$Res> {
  factory _$LaunchReachabilityEntryCopyWith(_LaunchReachabilityEntry value, $Res Function(_LaunchReachabilityEntry) _then) = __$LaunchReachabilityEntryCopyWithImpl;
@override @useResult
$Res call({
 List<String> within5Mi, List<String> within10Mi, List<String> within20Mi
});




}
/// @nodoc
class __$LaunchReachabilityEntryCopyWithImpl<$Res>
    implements _$LaunchReachabilityEntryCopyWith<$Res> {
  __$LaunchReachabilityEntryCopyWithImpl(this._self, this._then);

  final _LaunchReachabilityEntry _self;
  final $Res Function(_LaunchReachabilityEntry) _then;

/// Create a copy of LaunchReachabilityEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? within5Mi = null,Object? within10Mi = null,Object? within20Mi = null,}) {
  return _then(_LaunchReachabilityEntry(
within5Mi: null == within5Mi ? _self._within5Mi : within5Mi // ignore: cast_nullable_to_non_nullable
as List<String>,within10Mi: null == within10Mi ? _self._within10Mi : within10Mi // ignore: cast_nullable_to_non_nullable
as List<String>,within20Mi: null == within20Mi ? _self._within20Mi : within20Mi // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$LaunchReachabilityIndex {

 int get schemaVersion; DateTime get generatedAt; String get distanceModel; double get snapMaxMeters; List<int> get thresholdsMi; bool get crossSystemReachability; Map<String, LaunchReachabilityEntry> get entries;
/// Create a copy of LaunchReachabilityIndex
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchReachabilityIndexCopyWith<LaunchReachabilityIndex> get copyWith => _$LaunchReachabilityIndexCopyWithImpl<LaunchReachabilityIndex>(this as LaunchReachabilityIndex, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchReachabilityIndex&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.distanceModel, distanceModel) || other.distanceModel == distanceModel)&&(identical(other.snapMaxMeters, snapMaxMeters) || other.snapMaxMeters == snapMaxMeters)&&const DeepCollectionEquality().equals(other.thresholdsMi, thresholdsMi)&&(identical(other.crossSystemReachability, crossSystemReachability) || other.crossSystemReachability == crossSystemReachability)&&const DeepCollectionEquality().equals(other.entries, entries));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,distanceModel,snapMaxMeters,const DeepCollectionEquality().hash(thresholdsMi),crossSystemReachability,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'LaunchReachabilityIndex(schemaVersion: $schemaVersion, generatedAt: $generatedAt, distanceModel: $distanceModel, snapMaxMeters: $snapMaxMeters, thresholdsMi: $thresholdsMi, crossSystemReachability: $crossSystemReachability, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $LaunchReachabilityIndexCopyWith<$Res>  {
  factory $LaunchReachabilityIndexCopyWith(LaunchReachabilityIndex value, $Res Function(LaunchReachabilityIndex) _then) = _$LaunchReachabilityIndexCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, DateTime generatedAt, String distanceModel, double snapMaxMeters, List<int> thresholdsMi, bool crossSystemReachability, Map<String, LaunchReachabilityEntry> entries
});




}
/// @nodoc
class _$LaunchReachabilityIndexCopyWithImpl<$Res>
    implements $LaunchReachabilityIndexCopyWith<$Res> {
  _$LaunchReachabilityIndexCopyWithImpl(this._self, this._then);

  final LaunchReachabilityIndex _self;
  final $Res Function(LaunchReachabilityIndex) _then;

/// Create a copy of LaunchReachabilityIndex
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? distanceModel = null,Object? snapMaxMeters = null,Object? thresholdsMi = null,Object? crossSystemReachability = null,Object? entries = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceModel: null == distanceModel ? _self.distanceModel : distanceModel // ignore: cast_nullable_to_non_nullable
as String,snapMaxMeters: null == snapMaxMeters ? _self.snapMaxMeters : snapMaxMeters // ignore: cast_nullable_to_non_nullable
as double,thresholdsMi: null == thresholdsMi ? _self.thresholdsMi : thresholdsMi // ignore: cast_nullable_to_non_nullable
as List<int>,crossSystemReachability: null == crossSystemReachability ? _self.crossSystemReachability : crossSystemReachability // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, LaunchReachabilityEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [LaunchReachabilityIndex].
extension LaunchReachabilityIndexPatterns on LaunchReachabilityIndex {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaunchReachabilityIndex value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaunchReachabilityIndex() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaunchReachabilityIndex value)  $default,){
final _that = this;
switch (_that) {
case _LaunchReachabilityIndex():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaunchReachabilityIndex value)?  $default,){
final _that = this;
switch (_that) {
case _LaunchReachabilityIndex() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime generatedAt,  String distanceModel,  double snapMaxMeters,  List<int> thresholdsMi,  bool crossSystemReachability,  Map<String, LaunchReachabilityEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaunchReachabilityIndex() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.distanceModel,_that.snapMaxMeters,_that.thresholdsMi,_that.crossSystemReachability,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime generatedAt,  String distanceModel,  double snapMaxMeters,  List<int> thresholdsMi,  bool crossSystemReachability,  Map<String, LaunchReachabilityEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _LaunchReachabilityIndex():
return $default(_that.schemaVersion,_that.generatedAt,_that.distanceModel,_that.snapMaxMeters,_that.thresholdsMi,_that.crossSystemReachability,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  DateTime generatedAt,  String distanceModel,  double snapMaxMeters,  List<int> thresholdsMi,  bool crossSystemReachability,  Map<String, LaunchReachabilityEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _LaunchReachabilityIndex() when $default != null:
return $default(_that.schemaVersion,_that.generatedAt,_that.distanceModel,_that.snapMaxMeters,_that.thresholdsMi,_that.crossSystemReachability,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _LaunchReachabilityIndex extends LaunchReachabilityIndex {
  const _LaunchReachabilityIndex({required this.schemaVersion, required this.generatedAt, required this.distanceModel, required this.snapMaxMeters, required final  List<int> thresholdsMi, required this.crossSystemReachability, required final  Map<String, LaunchReachabilityEntry> entries}): _thresholdsMi = thresholdsMi,_entries = entries,super._();
  

@override final  int schemaVersion;
@override final  DateTime generatedAt;
@override final  String distanceModel;
@override final  double snapMaxMeters;
 final  List<int> _thresholdsMi;
@override List<int> get thresholdsMi {
  if (_thresholdsMi is EqualUnmodifiableListView) return _thresholdsMi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_thresholdsMi);
}

@override final  bool crossSystemReachability;
 final  Map<String, LaunchReachabilityEntry> _entries;
@override Map<String, LaunchReachabilityEntry> get entries {
  if (_entries is EqualUnmodifiableMapView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entries);
}


/// Create a copy of LaunchReachabilityIndex
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaunchReachabilityIndexCopyWith<_LaunchReachabilityIndex> get copyWith => __$LaunchReachabilityIndexCopyWithImpl<_LaunchReachabilityIndex>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaunchReachabilityIndex&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.distanceModel, distanceModel) || other.distanceModel == distanceModel)&&(identical(other.snapMaxMeters, snapMaxMeters) || other.snapMaxMeters == snapMaxMeters)&&const DeepCollectionEquality().equals(other._thresholdsMi, _thresholdsMi)&&(identical(other.crossSystemReachability, crossSystemReachability) || other.crossSystemReachability == crossSystemReachability)&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,generatedAt,distanceModel,snapMaxMeters,const DeepCollectionEquality().hash(_thresholdsMi),crossSystemReachability,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'LaunchReachabilityIndex(schemaVersion: $schemaVersion, generatedAt: $generatedAt, distanceModel: $distanceModel, snapMaxMeters: $snapMaxMeters, thresholdsMi: $thresholdsMi, crossSystemReachability: $crossSystemReachability, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$LaunchReachabilityIndexCopyWith<$Res> implements $LaunchReachabilityIndexCopyWith<$Res> {
  factory _$LaunchReachabilityIndexCopyWith(_LaunchReachabilityIndex value, $Res Function(_LaunchReachabilityIndex) _then) = __$LaunchReachabilityIndexCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, DateTime generatedAt, String distanceModel, double snapMaxMeters, List<int> thresholdsMi, bool crossSystemReachability, Map<String, LaunchReachabilityEntry> entries
});




}
/// @nodoc
class __$LaunchReachabilityIndexCopyWithImpl<$Res>
    implements _$LaunchReachabilityIndexCopyWith<$Res> {
  __$LaunchReachabilityIndexCopyWithImpl(this._self, this._then);

  final _LaunchReachabilityIndex _self;
  final $Res Function(_LaunchReachabilityIndex) _then;

/// Create a copy of LaunchReachabilityIndex
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? generatedAt = null,Object? distanceModel = null,Object? snapMaxMeters = null,Object? thresholdsMi = null,Object? crossSystemReachability = null,Object? entries = null,}) {
  return _then(_LaunchReachabilityIndex(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceModel: null == distanceModel ? _self.distanceModel : distanceModel // ignore: cast_nullable_to_non_nullable
as String,snapMaxMeters: null == snapMaxMeters ? _self.snapMaxMeters : snapMaxMeters // ignore: cast_nullable_to_non_nullable
as double,thresholdsMi: null == thresholdsMi ? _self._thresholdsMi : thresholdsMi // ignore: cast_nullable_to_non_nullable
as List<int>,crossSystemReachability: null == crossSystemReachability ? _self.crossSystemReachability : crossSystemReachability // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as Map<String, LaunchReachabilityEntry>,
  ));
}


}

// dart format on
