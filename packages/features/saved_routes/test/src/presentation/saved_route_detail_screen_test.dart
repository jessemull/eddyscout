import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_screen.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_localized_app.dart';
import '../../helpers/test_saved_routes.dart';

class _MockSavedRouteRepository extends Mock implements SavedRouteRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSavedRouteRepository repository;

  setUpAll(() {
    registerFallbackValue(testSavedRoute());
  });

  setUp(() {
    repository = _MockSavedRouteRepository();
  });

  Future<void> tapScrollable(WidgetTester tester, Finder finder) async {
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      finder,
      800,
      scrollable: scrollable,
    );
    await tester.ensureVisible(finder);
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump();
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    required String routeId,
    required List<Object?> overrides,
    void Function(SavedRoute route)? onLoadOnMap,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClientProvider.overrideWithValue(
            const NoOpAnalyticsClient(),
          ),
          launchPointLookupProvider.overrideWithValue((_) => null),
          savedRouteRepositoryProvider.overrideWithValue(repository),
          ...overrides.cast(),
        ],
        child: testLocalizedApp(
          child: SavedRouteDetailScreen(
            routeId: routeId,
            onLoadOnMap: onLoadOnMap ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('shows not found when route is missing', (tester) async {
    when(() => repository.getById('missing')).thenAnswer(
      (_) async => const Result.success(null),
    );

    await pumpDetail(
      tester,
      routeId: 'missing',
      overrides: const [],
    );

    expect(find.text('Route not found.'), findsOneWidget);
  });

  testWidgets('shows route name and load on map action', (tester) async {
    final route = testSavedRoute(name: 'Willamette Shuttle');
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );

    expect(
      find.widgetWithText(TextField, 'Willamette Shuttle'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Load on map'),
      48,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Load on map'), findsOneWidget);
  });

  testWidgets('binds route fields when reopening with cached provider', (
    tester,
  ) async {
    final route = testSavedRoute(name: 'Cached Route');
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    final container = ProviderContainer(
      overrides: [
        analyticsClientProvider.overrideWithValue(
          const NoOpAnalyticsClient(),
        ),
        launchPointLookupProvider.overrideWithValue((_) => null),
        savedRouteRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    Future<void> pumpDetailHost() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: testLocalizedApp(
            child: SavedRouteDetailScreen(
              routeId: route.id,
              onLoadOnMap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpDetailHost();
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextField, 'Cached Route'),
      findsOneWidget,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(child: const SizedBox.shrink()),
      ),
    );
    await tester.pumpAndSettle();

    await pumpDetailHost();

    expect(
      find.widgetWithText(TextField, 'Cached Route'),
      findsOneWidget,
    );
  });

  testWidgets('invokes onLoadOnMap when load button pressed', (tester) async {
    final route = testSavedRoute();
    SavedRoute? loadedRoute;
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
      onLoadOnMap: (loaded) => loadedRoute = loaded,
    );

    await tapScrollable(tester, find.text('Load on map'));

    expect(loadedRoute, isNotNull);
    expect(loadedRoute!.id, route.id);
  });

  testWidgets('save changes shows success snackbar', (tester) async {
    final route = testSavedRoute(name: 'Original Name');
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );
    when(() => repository.upsert(any())).thenAnswer(
      (invocation) async => Result.success(
        invocation.positionalArguments.first as SavedRoute,
      ),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Original Name'),
      'Updated Name',
    );
    await tapScrollable(tester, find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Route saved.'), findsOneWidget);
    verify(() => repository.upsert(any(that: isA<SavedRoute>()))).called(1);
  });

  testWidgets('delete confirm removes route', (tester) async {
    final route = testSavedRoute();
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );
    when(() => repository.delete(route.id)).thenAnswer(
      (_) async => const Result.success(null),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );

    await tapScrollable(tester, find.text('Delete route'));
    await tester.pumpAndSettle();

    expect(find.text('Delete route?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete route'));
    await tester.pumpAndSettle();

    verify(() => repository.delete(route.id)).called(1);
  });

  testWidgets('save without edits preserves custom tags from metadata', (
    tester,
  ) async {
    final route = testSavedRoute().copyWith(
      metadata: const SavedRouteMetadata(
        distanceMeters: 5200,
        categories: ['scenic', 'summer paddle'],
      ),
    );
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );
    when(() => repository.upsert(any())).thenAnswer(
      (invocation) async => Result.success(
        invocation.positionalArguments.first as SavedRoute,
      ),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );

    await tapScrollable(tester, find.text('Save changes'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => repository.upsert(captureAny())).captured.single
            as SavedRoute;
    expect(captured.metadata.categories, contains('summer paddle'));
  });

  testWidgets('binds category chips and custom tags on first load', (
    tester,
  ) async {
    final route = testSavedRoute().copyWith(
      metadata: const SavedRouteMetadata(
        distanceMeters: 5200,
        categories: ['scenic', 'summer paddle'],
      ),
    );
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );
    await tester.scrollUntilVisible(
      find.text('Custom tags'),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    final scenicChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Scenic'),
    );
    expect(scenicChip.selected, isTrue);
    expect(find.byType(InputChip), findsOneWidget);
    expect(find.text('summer paddle'), findsOneWidget);
  });

  testWidgets('save persists custom tags with enum categories', (
    tester,
  ) async {
    final route = testSavedRoute(name: 'Tagged Route').copyWith(
      metadata: const SavedRouteMetadata(
        distanceMeters: 5200,
        categories: ['training'],
      ),
    );
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );
    when(() => repository.upsert(any())).thenAnswer(
      (invocation) async => Result.success(
        invocation.positionalArguments.first as SavedRoute,
      ),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );

    const tagField = Key('saved_route_custom_tag_field');
    await tester.scrollUntilVisible(
      find.byKey(tagField),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byKey(tagField), 'family');
    await tester.scrollUntilVisible(
      find.byIcon(Icons.add),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tapScrollable(tester, find.text('Save changes'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => repository.upsert(captureAny())).captured.single
            as SavedRoute;
    expect(
      captured.metadata.categories,
      containsAll(['training', 'family']),
    );
  });
}
