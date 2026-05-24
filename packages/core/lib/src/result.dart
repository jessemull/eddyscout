import 'package:meta/meta.dart';

/// A discriminated union representing success or failure.
///
/// Prefer this over throwing exceptions for expected error cases.
/// Use [Result.success] and [Result.failure] constructors.
sealed class Result<T, E> {
  const Result._();

  /// Creates a successful [Result] containing [value].
  const factory Result.success(T value) = Success<T, E>;

  /// Creates a failed [Result] containing [error].
  const factory Result.failure(E error) = Failure<T, E>;

  /// Pattern-match on the result.
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  });

  /// Whether this result is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Whether this result is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// The success value, or null if this is a [Failure].
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// The failure error, or null if this is a [Success].
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };
}

/// Successful result containing a [value].
@immutable
final class Success<T, E> extends Result<T, E> {
  /// Creates a [Success] with the given [value].
  const Success(this.value) : super._();

  /// The successful value.
  final T value;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) => success(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T, E> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failed result containing an [error].
@immutable
final class Failure<T, E> extends Result<T, E> {
  /// Creates a [Failure] with the given [error].
  const Failure(this.error) : super._();

  /// The error value.
  final E error;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) => failure(error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failure<T, E> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
