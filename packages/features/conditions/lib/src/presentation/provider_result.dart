import 'package:eddyscout_core/eddyscout_core.dart';

/// Unwraps [Result] for Riverpod async providers.
///
/// Throws [AppFailure] on failure so provider error state carries a typed
/// domain failure.
T unwrapResultForAsyncProvider<T>(Result<T, AppFailure> result) {
  return result.when(
    success: (value) => value,
    failure: (error) => throw error,
  );
}
