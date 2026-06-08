import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/data/repositories/saved_route_repository_impl.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Defers Drift open until the first repository call.
///
/// The saved route repository provider is synchronous, but the database
/// provider is async. Calling requireValue during cold start throws before
/// upsert completes.
class LazySavedRouteRepository implements SavedRouteRepository {
  /// Creates a repository that waits for the saved routes database provider.
  const LazySavedRouteRepository(this._ref);

  final Ref _ref;

  Future<SavedRouteRepositoryImpl> _delegate() async {
    final db = await _ref.read(savedRoutesDatabaseProvider.future);
    return SavedRouteRepositoryImpl(db);
  }

  @override
  FutureResult<List<SavedRoute>, AppFailure> listAll() async {
    return (await _delegate()).listAll();
  }

  @override
  FutureResult<List<SavedRoute>, AppFailure> listFavorites() async {
    return (await _delegate()).listFavorites();
  }

  @override
  FutureResult<SavedRoute?, AppFailure> getById(String id) async {
    return (await _delegate()).getById(id);
  }

  @override
  FutureResult<SavedRoute, AppFailure> upsert(SavedRoute route) async {
    return (await _delegate()).upsert(route);
  }

  @override
  FutureResult<void, AppFailure> delete(String id) async {
    return (await _delegate()).delete(id);
  }

  @override
  FutureResult<SavedRoute, AppFailure> setFavorite(
    String id, {
    required bool isFavorite,
  }) async {
    return (await _delegate()).setFavorite(id, isFavorite: isFavorite);
  }
}
