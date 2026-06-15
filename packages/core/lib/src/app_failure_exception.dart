import 'package:eddyscout_core/src/app_failure.dart';

/// Wraps [AppFailure] for Riverpod async throw semantics and
/// `only_throw_errors`.
final class AppFailureException implements Exception {
  /// Creates an exception carrying [failure].
  const AppFailureException(this.failure);

  /// Mapped load/parse failure.
  final AppFailure failure;

  @override
  String toString() => failure.message;
}

/// Returns [AppFailure] when [error] is [AppFailureException] or
/// [AppFailure].
AppFailure? appFailureFrom(Object? error) {
  if (error is AppFailureException) {
    return error.failure;
  }
  if (error is AppFailure) {
    return error;
  }
  return null;
}
