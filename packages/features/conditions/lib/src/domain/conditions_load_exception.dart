import 'package:eddyscout_core/eddyscout_core.dart';

/// Thrown when conditions repository load fails (Riverpod async errors).
final class ConditionsLoadException implements Exception {
  /// Wraps the domain failure for async error handling.
  const ConditionsLoadException(this.failure);

  /// Mapped failure from the repository boundary.
  final AppFailure failure;

  @override
  String toString() => failure.message;
}
