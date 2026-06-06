/// Disables Riverpod automatic retry for future providers.
///
/// Use as `@Riverpod(retry: disableProviderRetry)` — inline lambdas are invalid
/// because `@Riverpod` is a const constructor.
Duration? disableProviderRetry(int retryCount, Object error) => null;
