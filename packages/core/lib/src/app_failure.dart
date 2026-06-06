/// Base class for domain-level failures.
///
/// Prefer sealed subtypes per feature over catch-all error strings.
sealed class AppFailure implements Exception {
  /// Creates an [AppFailure] with a human-readable [message].
  const AppFailure({required this.message, this.stackTrace});

  /// Human-readable failure description.
  final String message;

  /// Optional stack trace captured at the failure site.
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

/// A network-related failure (timeout, no connectivity, server error).
final class NetworkFailure extends AppFailure {
  /// Creates a [NetworkFailure] with optional HTTP [statusCode].
  const NetworkFailure({
    required super.message,
    super.stackTrace,
    this.statusCode,
  });

  /// HTTP status code when available.
  final int? statusCode;
}

/// A failure from local storage operations.
final class StorageFailure extends AppFailure {
  /// Creates a [StorageFailure].
  const StorageFailure({required super.message, super.stackTrace});
}

/// Structured local or bundled data could not be parsed.
final class ParseFailure extends AppFailure {
  /// Creates a [ParseFailure].
  const ParseFailure({super.stackTrace}) : super(message: 'parse_failure');
}

/// A bundled or local asset failed to load.
final class AssetLoadFailure extends AppFailure {
  /// Creates an [AssetLoadFailure].
  const AssetLoadFailure({super.stackTrace})
    : super(message: 'asset_load_failure');
}

/// A requested resource was not found (e.g. unknown launch id).
final class NotFoundFailure extends AppFailure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure({required super.message, super.stackTrace});
}

/// An unexpected failure that does not fit known categories.
final class UnexpectedFailure extends AppFailure {
  /// Creates an [UnexpectedFailure].
  const UnexpectedFailure({required super.message, super.stackTrace});
}
