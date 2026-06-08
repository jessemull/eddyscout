import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Relative import required: package src/data/ URIs are blocked in presentation/.
// ignore: always_use_package_imports
import '../../data/repositories/lazy_saved_route_repository.dart';

part 'saved_routes_providers.g.dart';

/// Resolves launch ids for saved route UI; overridden in the app shell.
@Riverpod(keepAlive: true)
LaunchPointLookup launchPointLookup(Ref ref) {
  throw UnimplementedError(
    'Override launchPointLookupProvider in ProviderScope '
    '(see apps/eddyscout/lib/main.dart).',
  );
}

/// Local [SavedRouteRepository] backed by Drift.
@Riverpod(keepAlive: true)
SavedRouteRepository savedRouteRepository(Ref ref) {
  return LazySavedRouteRepository(ref);
}

/// All saved routes from local storage.
@Riverpod(keepAlive: true)
class SavedRoutesList extends _$SavedRoutesList {
  @override
  Future<List<SavedRoute>> build() async {
    final result = await ref.read(savedRouteRepositoryProvider).listAll();
    return result.when(
      success: (routes) => routes,
      failure: (failure) => throw failure,
    );
  }

  /// Reloads the list from local storage.
  Future<void> refreshList() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Favorite saved routes only.
@Riverpod(keepAlive: true)
Future<List<SavedRoute>> savedRoutesFavorites(Ref ref) async {
  final result = await ref.read(savedRouteRepositoryProvider).listFavorites();
  return result.when(
    success: (routes) => routes,
    failure: (failure) => throw failure,
  );
}

/// Single saved route by id.
@Riverpod(keepAlive: true)
Future<SavedRoute?> savedRouteById(Ref ref, String id) async {
  final result = await ref.read(savedRouteRepositoryProvider).getById(id);
  return result.when(
    success: (route) => route,
    failure: (failure) => throw failure,
  );
}

/// Write operations for saved routes.
@Riverpod(keepAlive: true)
class SavedRoutesController extends _$SavedRoutesController {
  @override
  void build() {}

  /// Persists a new saved route.
  Future<Result<SavedRoute, AppFailure>> create(SavedRoute route) async {
    final result = await ref.read(savedRouteRepositoryProvider).upsert(route);
    if (result.isSuccess) {
      ref
        ..invalidate(savedRoutesListProvider)
        ..invalidate(savedRoutesFavoritesProvider)
        ..invalidate(savedRouteByIdProvider(route.id));
    }
    return result;
  }

  /// Updates an existing saved route.
  Future<Result<SavedRoute, AppFailure>> update(SavedRoute route) async {
    final result = await ref.read(savedRouteRepositoryProvider).upsert(route);
    if (result.isSuccess) {
      ref
        ..invalidate(savedRoutesListProvider)
        ..invalidate(savedRoutesFavoritesProvider)
        ..invalidate(savedRouteByIdProvider(route.id));
    }
    return result;
  }

  /// Deletes a saved route by id.
  Future<Result<void, AppFailure>> delete(String id) async {
    final result = await ref.read(savedRouteRepositoryProvider).delete(id);
    if (result.isSuccess) {
      ref
        ..invalidate(savedRoutesListProvider)
        ..invalidate(savedRoutesFavoritesProvider)
        ..invalidate(savedRouteByIdProvider(id));
    }
    return result;
  }

  /// Sets the favorite flag for a saved route.
  Future<Result<SavedRoute, AppFailure>> toggleFavorite(
    String id, {
    required bool isFavorite,
  }) async {
    final result = await ref
        .read(savedRouteRepositoryProvider)
        .setFavorite(id, isFavorite: isFavorite);
    if (result.isSuccess) {
      ref
        ..invalidate(savedRoutesListProvider)
        ..invalidate(savedRoutesFavoritesProvider)
        ..invalidate(savedRouteByIdProvider(id));
    }
    return result;
  }
}

/// Draft saved route to load on the map tab on next visit.
@Riverpod(keepAlive: true)
class PendingSavedRouteLoad extends _$PendingSavedRouteLoad {
  @override
  SavedRoute? build() => null;

  /// Draft awaiting map load, if any.
  SavedRoute? get draftRoute => state;

  /// Queues [route] (including unsaved edits) for load on the map tab.
  set draftRoute(SavedRoute route) => state = route;

  /// Returns and clears the pending route draft.
  SavedRoute? take() {
    final draft = state;
    state = null;
    return draft;
  }
}
