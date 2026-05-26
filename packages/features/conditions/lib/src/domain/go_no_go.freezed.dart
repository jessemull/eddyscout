// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'go_no_go.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoNoGoReason {

/// Machine-readable reason id for analytics and tests.
 String get code;/// Paddler-facing explanation.
 String get message;/// How this reason affects [GoNoGoVerdict].
 GoNoGoReasonSeverity get severity;
/// Create a copy of GoNoGoReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoNoGoReasonCopyWith<GoNoGoReason> get copyWith => _$GoNoGoReasonCopyWithImpl<GoNoGoReason>(this as GoNoGoReason, _$identity);

  /// Serializes this GoNoGoReason to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoNoGoReason&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.severity, severity) || other.severity == severity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,severity);

@override
String toString() {
  return 'GoNoGoReason(code: $code, message: $message, severity: $severity)';
}


}

/// @nodoc
abstract mixin class $GoNoGoReasonCopyWith<$Res>  {
  factory $GoNoGoReasonCopyWith(GoNoGoReason value, $Res Function(GoNoGoReason) _then) = _$GoNoGoReasonCopyWithImpl;
@useResult
$Res call({
 String code, String message, GoNoGoReasonSeverity severity
});




}
/// @nodoc
class _$GoNoGoReasonCopyWithImpl<$Res>
    implements $GoNoGoReasonCopyWith<$Res> {
  _$GoNoGoReasonCopyWithImpl(this._self, this._then);

  final GoNoGoReason _self;
  final $Res Function(GoNoGoReason) _then;

/// Create a copy of GoNoGoReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? severity = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as GoNoGoReasonSeverity,
  ));
}

}


/// Adds pattern-matching-related methods to [GoNoGoReason].
extension GoNoGoReasonPatterns on GoNoGoReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoNoGoReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoNoGoReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoNoGoReason value)  $default,){
final _that = this;
switch (_that) {
case _GoNoGoReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoNoGoReason value)?  $default,){
final _that = this;
switch (_that) {
case _GoNoGoReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String message,  GoNoGoReasonSeverity severity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoNoGoReason() when $default != null:
return $default(_that.code,_that.message,_that.severity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String message,  GoNoGoReasonSeverity severity)  $default,) {final _that = this;
switch (_that) {
case _GoNoGoReason():
return $default(_that.code,_that.message,_that.severity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String message,  GoNoGoReasonSeverity severity)?  $default,) {final _that = this;
switch (_that) {
case _GoNoGoReason() when $default != null:
return $default(_that.code,_that.message,_that.severity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoNoGoReason implements GoNoGoReason {
  const _GoNoGoReason({required this.code, required this.message, required this.severity});
  factory _GoNoGoReason.fromJson(Map<String, dynamic> json) => _$GoNoGoReasonFromJson(json);

/// Machine-readable reason id for analytics and tests.
@override final  String code;
/// Paddler-facing explanation.
@override final  String message;
/// How this reason affects [GoNoGoVerdict].
@override final  GoNoGoReasonSeverity severity;

/// Create a copy of GoNoGoReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoNoGoReasonCopyWith<_GoNoGoReason> get copyWith => __$GoNoGoReasonCopyWithImpl<_GoNoGoReason>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoNoGoReasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoNoGoReason&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.severity, severity) || other.severity == severity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,severity);

@override
String toString() {
  return 'GoNoGoReason(code: $code, message: $message, severity: $severity)';
}


}

/// @nodoc
abstract mixin class _$GoNoGoReasonCopyWith<$Res> implements $GoNoGoReasonCopyWith<$Res> {
  factory _$GoNoGoReasonCopyWith(_GoNoGoReason value, $Res Function(_GoNoGoReason) _then) = __$GoNoGoReasonCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, GoNoGoReasonSeverity severity
});




}
/// @nodoc
class __$GoNoGoReasonCopyWithImpl<$Res>
    implements _$GoNoGoReasonCopyWith<$Res> {
  __$GoNoGoReasonCopyWithImpl(this._self, this._then);

  final _GoNoGoReason _self;
  final $Res Function(_GoNoGoReason) _then;

/// Create a copy of GoNoGoReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? severity = null,}) {
  return _then(_GoNoGoReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as GoNoGoReasonSeverity,
  ));
}


}


/// @nodoc
mixin _$GoNoGoResult {

 GoNoGoVerdict get verdict; List<GoNoGoReason> get reasons; DateTime get computedAt;
/// Create a copy of GoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoNoGoResultCopyWith<GoNoGoResult> get copyWith => _$GoNoGoResultCopyWithImpl<GoNoGoResult>(this as GoNoGoResult, _$identity);

  /// Serializes this GoNoGoResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoNoGoResult&&(identical(other.verdict, verdict) || other.verdict == verdict)&&const DeepCollectionEquality().equals(other.reasons, reasons)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,verdict,const DeepCollectionEquality().hash(reasons),computedAt);

@override
String toString() {
  return 'GoNoGoResult(verdict: $verdict, reasons: $reasons, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class $GoNoGoResultCopyWith<$Res>  {
  factory $GoNoGoResultCopyWith(GoNoGoResult value, $Res Function(GoNoGoResult) _then) = _$GoNoGoResultCopyWithImpl;
@useResult
$Res call({
 GoNoGoVerdict verdict, List<GoNoGoReason> reasons, DateTime computedAt
});




}
/// @nodoc
class _$GoNoGoResultCopyWithImpl<$Res>
    implements $GoNoGoResultCopyWith<$Res> {
  _$GoNoGoResultCopyWithImpl(this._self, this._then);

  final GoNoGoResult _self;
  final $Res Function(GoNoGoResult) _then;

/// Create a copy of GoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verdict = null,Object? reasons = null,Object? computedAt = null,}) {
  return _then(_self.copyWith(
verdict: null == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as GoNoGoVerdict,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<GoNoGoReason>,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GoNoGoResult].
extension GoNoGoResultPatterns on GoNoGoResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoNoGoResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoNoGoResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoNoGoResult value)  $default,){
final _that = this;
switch (_that) {
case _GoNoGoResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoNoGoResult value)?  $default,){
final _that = this;
switch (_that) {
case _GoNoGoResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GoNoGoVerdict verdict,  List<GoNoGoReason> reasons,  DateTime computedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoNoGoResult() when $default != null:
return $default(_that.verdict,_that.reasons,_that.computedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GoNoGoVerdict verdict,  List<GoNoGoReason> reasons,  DateTime computedAt)  $default,) {final _that = this;
switch (_that) {
case _GoNoGoResult():
return $default(_that.verdict,_that.reasons,_that.computedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GoNoGoVerdict verdict,  List<GoNoGoReason> reasons,  DateTime computedAt)?  $default,) {final _that = this;
switch (_that) {
case _GoNoGoResult() when $default != null:
return $default(_that.verdict,_that.reasons,_that.computedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoNoGoResult implements GoNoGoResult {
  const _GoNoGoResult({required this.verdict, required final  List<GoNoGoReason> reasons, required this.computedAt}): _reasons = reasons;
  factory _GoNoGoResult.fromJson(Map<String, dynamic> json) => _$GoNoGoResultFromJson(json);

@override final  GoNoGoVerdict verdict;
 final  List<GoNoGoReason> _reasons;
@override List<GoNoGoReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

@override final  DateTime computedAt;

/// Create a copy of GoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoNoGoResultCopyWith<_GoNoGoResult> get copyWith => __$GoNoGoResultCopyWithImpl<_GoNoGoResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoNoGoResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoNoGoResult&&(identical(other.verdict, verdict) || other.verdict == verdict)&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,verdict,const DeepCollectionEquality().hash(_reasons),computedAt);

@override
String toString() {
  return 'GoNoGoResult(verdict: $verdict, reasons: $reasons, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class _$GoNoGoResultCopyWith<$Res> implements $GoNoGoResultCopyWith<$Res> {
  factory _$GoNoGoResultCopyWith(_GoNoGoResult value, $Res Function(_GoNoGoResult) _then) = __$GoNoGoResultCopyWithImpl;
@override @useResult
$Res call({
 GoNoGoVerdict verdict, List<GoNoGoReason> reasons, DateTime computedAt
});




}
/// @nodoc
class __$GoNoGoResultCopyWithImpl<$Res>
    implements _$GoNoGoResultCopyWith<$Res> {
  __$GoNoGoResultCopyWithImpl(this._self, this._then);

  final _GoNoGoResult _self;
  final $Res Function(_GoNoGoResult) _then;

/// Create a copy of GoNoGoResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verdict = null,Object? reasons = null,Object? computedAt = null,}) {
  return _then(_GoNoGoResult(
verdict: null == verdict ? _self.verdict : verdict // ignore: cast_nullable_to_non_nullable
as GoNoGoVerdict,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<GoNoGoReason>,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
