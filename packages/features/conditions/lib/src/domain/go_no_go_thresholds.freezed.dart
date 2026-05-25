// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'go_no_go_thresholds.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoNoGoThresholds {

 int get windMarginalShelteredMph; int get windNoGoShelteredMph; int get windMarginalModerateMph; int get windNoGoModerateMph; int get windMarginalExposedMph; int get windNoGoExposedMph;
/// Create a copy of GoNoGoThresholds
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoNoGoThresholdsCopyWith<GoNoGoThresholds> get copyWith => _$GoNoGoThresholdsCopyWithImpl<GoNoGoThresholds>(this as GoNoGoThresholds, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoNoGoThresholds&&(identical(other.windMarginalShelteredMph, windMarginalShelteredMph) || other.windMarginalShelteredMph == windMarginalShelteredMph)&&(identical(other.windNoGoShelteredMph, windNoGoShelteredMph) || other.windNoGoShelteredMph == windNoGoShelteredMph)&&(identical(other.windMarginalModerateMph, windMarginalModerateMph) || other.windMarginalModerateMph == windMarginalModerateMph)&&(identical(other.windNoGoModerateMph, windNoGoModerateMph) || other.windNoGoModerateMph == windNoGoModerateMph)&&(identical(other.windMarginalExposedMph, windMarginalExposedMph) || other.windMarginalExposedMph == windMarginalExposedMph)&&(identical(other.windNoGoExposedMph, windNoGoExposedMph) || other.windNoGoExposedMph == windNoGoExposedMph));
}


@override
int get hashCode => Object.hash(runtimeType,windMarginalShelteredMph,windNoGoShelteredMph,windMarginalModerateMph,windNoGoModerateMph,windMarginalExposedMph,windNoGoExposedMph);

@override
String toString() {
  return 'GoNoGoThresholds(windMarginalShelteredMph: $windMarginalShelteredMph, windNoGoShelteredMph: $windNoGoShelteredMph, windMarginalModerateMph: $windMarginalModerateMph, windNoGoModerateMph: $windNoGoModerateMph, windMarginalExposedMph: $windMarginalExposedMph, windNoGoExposedMph: $windNoGoExposedMph)';
}


}

/// @nodoc
abstract mixin class $GoNoGoThresholdsCopyWith<$Res>  {
  factory $GoNoGoThresholdsCopyWith(GoNoGoThresholds value, $Res Function(GoNoGoThresholds) _then) = _$GoNoGoThresholdsCopyWithImpl;
@useResult
$Res call({
 int windMarginalShelteredMph, int windNoGoShelteredMph, int windMarginalModerateMph, int windNoGoModerateMph, int windMarginalExposedMph, int windNoGoExposedMph
});




}
/// @nodoc
class _$GoNoGoThresholdsCopyWithImpl<$Res>
    implements $GoNoGoThresholdsCopyWith<$Res> {
  _$GoNoGoThresholdsCopyWithImpl(this._self, this._then);

  final GoNoGoThresholds _self;
  final $Res Function(GoNoGoThresholds) _then;

/// Create a copy of GoNoGoThresholds
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? windMarginalShelteredMph = null,Object? windNoGoShelteredMph = null,Object? windMarginalModerateMph = null,Object? windNoGoModerateMph = null,Object? windMarginalExposedMph = null,Object? windNoGoExposedMph = null,}) {
  return _then(_self.copyWith(
windMarginalShelteredMph: null == windMarginalShelteredMph ? _self.windMarginalShelteredMph : windMarginalShelteredMph // ignore: cast_nullable_to_non_nullable
as int,windNoGoShelteredMph: null == windNoGoShelteredMph ? _self.windNoGoShelteredMph : windNoGoShelteredMph // ignore: cast_nullable_to_non_nullable
as int,windMarginalModerateMph: null == windMarginalModerateMph ? _self.windMarginalModerateMph : windMarginalModerateMph // ignore: cast_nullable_to_non_nullable
as int,windNoGoModerateMph: null == windNoGoModerateMph ? _self.windNoGoModerateMph : windNoGoModerateMph // ignore: cast_nullable_to_non_nullable
as int,windMarginalExposedMph: null == windMarginalExposedMph ? _self.windMarginalExposedMph : windMarginalExposedMph // ignore: cast_nullable_to_non_nullable
as int,windNoGoExposedMph: null == windNoGoExposedMph ? _self.windNoGoExposedMph : windNoGoExposedMph // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GoNoGoThresholds].
extension GoNoGoThresholdsPatterns on GoNoGoThresholds {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoNoGoThresholds value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoNoGoThresholds() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoNoGoThresholds value)  $default,){
final _that = this;
switch (_that) {
case _GoNoGoThresholds():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoNoGoThresholds value)?  $default,){
final _that = this;
switch (_that) {
case _GoNoGoThresholds() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int windMarginalShelteredMph,  int windNoGoShelteredMph,  int windMarginalModerateMph,  int windNoGoModerateMph,  int windMarginalExposedMph,  int windNoGoExposedMph)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoNoGoThresholds() when $default != null:
return $default(_that.windMarginalShelteredMph,_that.windNoGoShelteredMph,_that.windMarginalModerateMph,_that.windNoGoModerateMph,_that.windMarginalExposedMph,_that.windNoGoExposedMph);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int windMarginalShelteredMph,  int windNoGoShelteredMph,  int windMarginalModerateMph,  int windNoGoModerateMph,  int windMarginalExposedMph,  int windNoGoExposedMph)  $default,) {final _that = this;
switch (_that) {
case _GoNoGoThresholds():
return $default(_that.windMarginalShelteredMph,_that.windNoGoShelteredMph,_that.windMarginalModerateMph,_that.windNoGoModerateMph,_that.windMarginalExposedMph,_that.windNoGoExposedMph);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int windMarginalShelteredMph,  int windNoGoShelteredMph,  int windMarginalModerateMph,  int windNoGoModerateMph,  int windMarginalExposedMph,  int windNoGoExposedMph)?  $default,) {final _that = this;
switch (_that) {
case _GoNoGoThresholds() when $default != null:
return $default(_that.windMarginalShelteredMph,_that.windNoGoShelteredMph,_that.windMarginalModerateMph,_that.windNoGoModerateMph,_that.windMarginalExposedMph,_that.windNoGoExposedMph);case _:
  return null;

}
}

}

/// @nodoc


class _GoNoGoThresholds implements GoNoGoThresholds {
  const _GoNoGoThresholds({required this.windMarginalShelteredMph, required this.windNoGoShelteredMph, required this.windMarginalModerateMph, required this.windNoGoModerateMph, required this.windMarginalExposedMph, required this.windNoGoExposedMph});
  

@override final  int windMarginalShelteredMph;
@override final  int windNoGoShelteredMph;
@override final  int windMarginalModerateMph;
@override final  int windNoGoModerateMph;
@override final  int windMarginalExposedMph;
@override final  int windNoGoExposedMph;

/// Create a copy of GoNoGoThresholds
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoNoGoThresholdsCopyWith<_GoNoGoThresholds> get copyWith => __$GoNoGoThresholdsCopyWithImpl<_GoNoGoThresholds>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoNoGoThresholds&&(identical(other.windMarginalShelteredMph, windMarginalShelteredMph) || other.windMarginalShelteredMph == windMarginalShelteredMph)&&(identical(other.windNoGoShelteredMph, windNoGoShelteredMph) || other.windNoGoShelteredMph == windNoGoShelteredMph)&&(identical(other.windMarginalModerateMph, windMarginalModerateMph) || other.windMarginalModerateMph == windMarginalModerateMph)&&(identical(other.windNoGoModerateMph, windNoGoModerateMph) || other.windNoGoModerateMph == windNoGoModerateMph)&&(identical(other.windMarginalExposedMph, windMarginalExposedMph) || other.windMarginalExposedMph == windMarginalExposedMph)&&(identical(other.windNoGoExposedMph, windNoGoExposedMph) || other.windNoGoExposedMph == windNoGoExposedMph));
}


@override
int get hashCode => Object.hash(runtimeType,windMarginalShelteredMph,windNoGoShelteredMph,windMarginalModerateMph,windNoGoModerateMph,windMarginalExposedMph,windNoGoExposedMph);

@override
String toString() {
  return 'GoNoGoThresholds(windMarginalShelteredMph: $windMarginalShelteredMph, windNoGoShelteredMph: $windNoGoShelteredMph, windMarginalModerateMph: $windMarginalModerateMph, windNoGoModerateMph: $windNoGoModerateMph, windMarginalExposedMph: $windMarginalExposedMph, windNoGoExposedMph: $windNoGoExposedMph)';
}


}

/// @nodoc
abstract mixin class _$GoNoGoThresholdsCopyWith<$Res> implements $GoNoGoThresholdsCopyWith<$Res> {
  factory _$GoNoGoThresholdsCopyWith(_GoNoGoThresholds value, $Res Function(_GoNoGoThresholds) _then) = __$GoNoGoThresholdsCopyWithImpl;
@override @useResult
$Res call({
 int windMarginalShelteredMph, int windNoGoShelteredMph, int windMarginalModerateMph, int windNoGoModerateMph, int windMarginalExposedMph, int windNoGoExposedMph
});




}
/// @nodoc
class __$GoNoGoThresholdsCopyWithImpl<$Res>
    implements _$GoNoGoThresholdsCopyWith<$Res> {
  __$GoNoGoThresholdsCopyWithImpl(this._self, this._then);

  final _GoNoGoThresholds _self;
  final $Res Function(_GoNoGoThresholds) _then;

/// Create a copy of GoNoGoThresholds
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? windMarginalShelteredMph = null,Object? windNoGoShelteredMph = null,Object? windMarginalModerateMph = null,Object? windNoGoModerateMph = null,Object? windMarginalExposedMph = null,Object? windNoGoExposedMph = null,}) {
  return _then(_GoNoGoThresholds(
windMarginalShelteredMph: null == windMarginalShelteredMph ? _self.windMarginalShelteredMph : windMarginalShelteredMph // ignore: cast_nullable_to_non_nullable
as int,windNoGoShelteredMph: null == windNoGoShelteredMph ? _self.windNoGoShelteredMph : windNoGoShelteredMph // ignore: cast_nullable_to_non_nullable
as int,windMarginalModerateMph: null == windMarginalModerateMph ? _self.windMarginalModerateMph : windMarginalModerateMph // ignore: cast_nullable_to_non_nullable
as int,windNoGoModerateMph: null == windNoGoModerateMph ? _self.windNoGoModerateMph : windNoGoModerateMph // ignore: cast_nullable_to_non_nullable
as int,windMarginalExposedMph: null == windMarginalExposedMph ? _self.windMarginalExposedMph : windMarginalExposedMph // ignore: cast_nullable_to_non_nullable
as int,windNoGoExposedMph: null == windNoGoExposedMph ? _self.windNoGoExposedMph : windNoGoExposedMph // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RiverFlowThresholds {

 double? get marginalCfs; double? get noGoCfs;
/// Create a copy of RiverFlowThresholds
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiverFlowThresholdsCopyWith<RiverFlowThresholds> get copyWith => _$RiverFlowThresholdsCopyWithImpl<RiverFlowThresholds>(this as RiverFlowThresholds, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiverFlowThresholds&&(identical(other.marginalCfs, marginalCfs) || other.marginalCfs == marginalCfs)&&(identical(other.noGoCfs, noGoCfs) || other.noGoCfs == noGoCfs));
}


@override
int get hashCode => Object.hash(runtimeType,marginalCfs,noGoCfs);

@override
String toString() {
  return 'RiverFlowThresholds(marginalCfs: $marginalCfs, noGoCfs: $noGoCfs)';
}


}

/// @nodoc
abstract mixin class $RiverFlowThresholdsCopyWith<$Res>  {
  factory $RiverFlowThresholdsCopyWith(RiverFlowThresholds value, $Res Function(RiverFlowThresholds) _then) = _$RiverFlowThresholdsCopyWithImpl;
@useResult
$Res call({
 double? marginalCfs, double? noGoCfs
});




}
/// @nodoc
class _$RiverFlowThresholdsCopyWithImpl<$Res>
    implements $RiverFlowThresholdsCopyWith<$Res> {
  _$RiverFlowThresholdsCopyWithImpl(this._self, this._then);

  final RiverFlowThresholds _self;
  final $Res Function(RiverFlowThresholds) _then;

/// Create a copy of RiverFlowThresholds
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? marginalCfs = freezed,Object? noGoCfs = freezed,}) {
  return _then(_self.copyWith(
marginalCfs: freezed == marginalCfs ? _self.marginalCfs : marginalCfs // ignore: cast_nullable_to_non_nullable
as double?,noGoCfs: freezed == noGoCfs ? _self.noGoCfs : noGoCfs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [RiverFlowThresholds].
extension RiverFlowThresholdsPatterns on RiverFlowThresholds {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiverFlowThresholds value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiverFlowThresholds() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiverFlowThresholds value)  $default,){
final _that = this;
switch (_that) {
case _RiverFlowThresholds():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiverFlowThresholds value)?  $default,){
final _that = this;
switch (_that) {
case _RiverFlowThresholds() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? marginalCfs,  double? noGoCfs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiverFlowThresholds() when $default != null:
return $default(_that.marginalCfs,_that.noGoCfs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? marginalCfs,  double? noGoCfs)  $default,) {final _that = this;
switch (_that) {
case _RiverFlowThresholds():
return $default(_that.marginalCfs,_that.noGoCfs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? marginalCfs,  double? noGoCfs)?  $default,) {final _that = this;
switch (_that) {
case _RiverFlowThresholds() when $default != null:
return $default(_that.marginalCfs,_that.noGoCfs);case _:
  return null;

}
}

}

/// @nodoc


class _RiverFlowThresholds implements RiverFlowThresholds {
  const _RiverFlowThresholds({this.marginalCfs, this.noGoCfs});
  

@override final  double? marginalCfs;
@override final  double? noGoCfs;

/// Create a copy of RiverFlowThresholds
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiverFlowThresholdsCopyWith<_RiverFlowThresholds> get copyWith => __$RiverFlowThresholdsCopyWithImpl<_RiverFlowThresholds>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiverFlowThresholds&&(identical(other.marginalCfs, marginalCfs) || other.marginalCfs == marginalCfs)&&(identical(other.noGoCfs, noGoCfs) || other.noGoCfs == noGoCfs));
}


@override
int get hashCode => Object.hash(runtimeType,marginalCfs,noGoCfs);

@override
String toString() {
  return 'RiverFlowThresholds(marginalCfs: $marginalCfs, noGoCfs: $noGoCfs)';
}


}

/// @nodoc
abstract mixin class _$RiverFlowThresholdsCopyWith<$Res> implements $RiverFlowThresholdsCopyWith<$Res> {
  factory _$RiverFlowThresholdsCopyWith(_RiverFlowThresholds value, $Res Function(_RiverFlowThresholds) _then) = __$RiverFlowThresholdsCopyWithImpl;
@override @useResult
$Res call({
 double? marginalCfs, double? noGoCfs
});




}
/// @nodoc
class __$RiverFlowThresholdsCopyWithImpl<$Res>
    implements _$RiverFlowThresholdsCopyWith<$Res> {
  __$RiverFlowThresholdsCopyWithImpl(this._self, this._then);

  final _RiverFlowThresholds _self;
  final $Res Function(_RiverFlowThresholds) _then;

/// Create a copy of RiverFlowThresholds
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? marginalCfs = freezed,Object? noGoCfs = freezed,}) {
  return _then(_RiverFlowThresholds(
marginalCfs: freezed == marginalCfs ? _self.marginalCfs : marginalCfs // ignore: cast_nullable_to_non_nullable
as double?,noGoCfs: freezed == noGoCfs ? _self.noGoCfs : noGoCfs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
