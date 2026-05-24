/// Abstraction over structured local storage (e.g. drift, isar).
///
/// Implementations provide type-safe queries, migrations, and
/// transactional writes for complex domain data.
abstract class StructuredStore {
  /// Initialize the store (run migrations, open database).
  Future<void> initialize();

  /// Close the store and release resources.
  Future<void> close();
}
