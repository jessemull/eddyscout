import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_routes_list_screen.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_localized_app.dart';
import '../../helpers/test_saved_routes.dart';

class _MockSavedRouteRepository extends Mock implements SavedRouteRepository {}

class _EmptySavedRoutesList extends SavedRoutesList {
  @override
  Future<List<SavedRoute>> build() async => [];
}

class _FixedSavedRoutesList extends SavedRoutesList {
  _FixedSavedRoutesList(this.routes);

  final List<SavedRoute> routes;

  @override
  Future<List<SavedRoute>> build() async => routes;
}

class _ErrorSavedRoutesList extends SavedRoutesList {
  @override
  Future<List<SavedRoute>> build() async {
    throw const StorageFailure(message: 'test storage failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSavedRouteRepository repository;

  setUp(() {
    repository = _MockSavedRouteRepository();
  });

  Future<void> pumpList(
    WidgetTester tester, {
    required List<Object?> overrides,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: testLocalizedApp(
          child: SavedRoutesListScreen(
            onOpenRouteDetail: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state when no routes', (tester) async {
    await pumpList(
      tester,
      overrides: [
        savedRoutesListProvider.overrideWith(_EmptySavedRoutesList.new),
      ],
    );

    expect(
      find.text(
        'No saved routes yet. Plan a route on the Map tab and tap Save.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows route name when routes exist', (tester) async {
    await pumpList(
      tester,
      overrides: [
        savedRoutesListProvider.overrideWith(
          () => _FixedSavedRoutesList([testSavedRoute(name: 'Columbia Loop')]),
        ),
      ],
    );

    expect(find.text('Columbia Loop'), findsOneWidget);
  });

  testWidgets('shows imperial distance when units preference is imperial', (
    tester,
  ) async {
    await pumpList(
      tester,
      overrides: [
        effectiveDisplayUnitSystemProvider.overrideWithValue(
          DisplayUnitSystem.imperial,
        ),
        savedRoutesListProvider.overrideWith(
          () => _FixedSavedRoutesList([testSavedRoute()]),
        ),
      ],
    );

    expect(find.textContaining('3.2 mi'), findsOneWidget);
  });

  testWidgets('shows error with retry when list fails', (tester) async {
    await pumpList(
      tester,
      overrides: [
        savedRoutesListProvider.overrideWith(_ErrorSavedRoutesList.new),
      ],
    );

    await tester.pumpAndSettle();

    expect(find.text('Could not load saved routes.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows favorites empty state on favorites tab', (tester) async {
    await pumpList(
      tester,
      overrides: [
        savedRoutesListProvider.overrideWith(_EmptySavedRoutesList.new),
        savedRoutesFavoritesProvider.overrideWith((ref) async => []),
      ],
    );

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('No favorite routes yet.'), findsOneWidget);
  });

  testWidgets('shows snackbar when favorite toggle fails', (tester) async {
    final route = testSavedRoute();
    when(
      () => repository.setFavorite(route.id, isFavorite: true),
    ).thenAnswer(
      (_) async => const Result.failure(
        StorageFailure(message: 'favorite failure'),
      ),
    );

    await pumpList(
      tester,
      overrides: [
        savedRouteRepositoryProvider.overrideWithValue(repository),
        savedRoutesListProvider.overrideWith(
          () => _FixedSavedRoutesList([route]),
        ),
      ],
    );

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    expect(find.text('Could not update favorite.'), findsOneWidget);
    verify(
      () => repository.setFavorite(route.id, isFavorite: true),
    ).called(1);
  });
}
