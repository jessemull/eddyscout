import 'package:eddyscout_core/src/result.dart';

/// Common type aliases used across the workspace.

/// JSON map shorthand.
typedef JsonMap = Map<String, dynamic>;

/// Async result returning either [T] on success or [E] on failure.
typedef FutureResult<T, E> = Future<Result<T, E>>;
