import 'package:eddyscout_core/eddyscout_core.dart';

/// Exception wrapper so [AppFailure] can be thrown from async providers.
final class HydroAppFailureException implements Exception {
  /// Creates an exception carrying [failure].
  const HydroAppFailureException(this.failure);

  /// Mapped hydro load/parse failure.
  final AppFailure failure;

  @override
  String toString() => failure.message;
}

/// Returns [AppFailure] when [error] is [HydroAppFailureException] or
/// [AppFailure].
AppFailure? hydroAppFailureFrom(Object? error) {
  if (error is HydroAppFailureException) {
    return error.failure;
  }
  if (error is AppFailure) {
    return error;
  }
  return null;
}
