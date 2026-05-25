// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RouteResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RouteResult()';
}


}

/// @nodoc
class $RouteResultCopyWith<$Res>  {
$RouteResultCopyWith(RouteResult _, $Res Function(RouteResult) __);
}


/// Adds pattern-matching-related methods to [RouteResult].
extension RouteResultPatterns on RouteResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RouteSuccess value)?  success,TResult Function( RouteFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RouteSuccess() when success != null:
return success(_that);case RouteFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RouteSuccess value)  success,required TResult Function( RouteFailure value)  failure,}){
final _that = this;
switch (_that) {
case RouteSuccess():
return success(_that);case RouteFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RouteSuccess value)?  success,TResult? Function( RouteFailure value)?  failure,}){
final _that = this;
switch (_that) {
case RouteSuccess() when success != null:
return success(_that);case RouteFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<List<double>> polylineLonLat,  double lengthMeters)?  success,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RouteSuccess() when success != null:
return success(_that.polylineLonLat,_that.lengthMeters);case RouteFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<List<double>> polylineLonLat,  double lengthMeters)  success,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case RouteSuccess():
return success(_that.polylineLonLat,_that.lengthMeters);case RouteFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<List<double>> polylineLonLat,  double lengthMeters)?  success,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case RouteSuccess() when success != null:
return success(_that.polylineLonLat,_that.lengthMeters);case RouteFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class RouteSuccess extends RouteResult {
  const RouteSuccess({required final  List<List<double>> polylineLonLat, required this.lengthMeters}): _polylineLonLat = polylineLonLat,super._();
  

/// Outer list is vertices along the river path.
///
/// Mapbox order: each pair is `[longitude, latitude]`.
 final  List<List<double>> _polylineLonLat;
/// Outer list is vertices along the river path.
///
/// Mapbox order: each pair is `[longitude, latitude]`.
 List<List<double>> get polylineLonLat {
  if (_polylineLonLat is EqualUnmodifiableListView) return _polylineLonLat;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_polylineLonLat);
}

 final  double lengthMeters;

/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteSuccessCopyWith<RouteSuccess> get copyWith => _$RouteSuccessCopyWithImpl<RouteSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteSuccess&&const DeepCollectionEquality().equals(other._polylineLonLat, _polylineLonLat)&&(identical(other.lengthMeters, lengthMeters) || other.lengthMeters == lengthMeters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_polylineLonLat),lengthMeters);

@override
String toString() {
  return 'RouteResult.success(polylineLonLat: $polylineLonLat, lengthMeters: $lengthMeters)';
}


}

/// @nodoc
abstract mixin class $RouteSuccessCopyWith<$Res> implements $RouteResultCopyWith<$Res> {
  factory $RouteSuccessCopyWith(RouteSuccess value, $Res Function(RouteSuccess) _then) = _$RouteSuccessCopyWithImpl;
@useResult
$Res call({
 List<List<double>> polylineLonLat, double lengthMeters
});




}
/// @nodoc
class _$RouteSuccessCopyWithImpl<$Res>
    implements $RouteSuccessCopyWith<$Res> {
  _$RouteSuccessCopyWithImpl(this._self, this._then);

  final RouteSuccess _self;
  final $Res Function(RouteSuccess) _then;

/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? polylineLonLat = null,Object? lengthMeters = null,}) {
  return _then(RouteSuccess(
polylineLonLat: null == polylineLonLat ? _self._polylineLonLat : polylineLonLat // ignore: cast_nullable_to_non_nullable
as List<List<double>>,lengthMeters: null == lengthMeters ? _self.lengthMeters : lengthMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class RouteFailure extends RouteResult {
  const RouteFailure(this.message): super._();
  

 final  String message;

/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteFailureCopyWith<RouteFailure> get copyWith => _$RouteFailureCopyWithImpl<RouteFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RouteResult.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $RouteFailureCopyWith<$Res> implements $RouteResultCopyWith<$Res> {
  factory $RouteFailureCopyWith(RouteFailure value, $Res Function(RouteFailure) _then) = _$RouteFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$RouteFailureCopyWithImpl<$Res>
    implements $RouteFailureCopyWith<$Res> {
  _$RouteFailureCopyWithImpl(this._self, this._then);

  final RouteFailure _self;
  final $Res Function(RouteFailure) _then;

/// Create a copy of RouteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(RouteFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
