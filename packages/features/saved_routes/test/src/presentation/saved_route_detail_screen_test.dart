import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_form_helpers.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_screen.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_waypoints_section.dart';
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
    DisplayUnitSystem displayUnits = DisplayUnitSystem.metric,
    void Function(SavedRoute route)? onLoadOnMap,
    Widget? goNoGoSection,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClientProvider.overrideWithValue(
            const NoOpAnalyticsClient(),
          ),
          effectiveDisplayUnitSystemProvider.overrideWithValue(displayUnits),
          launchPointLookupProvider.overrideWithValue((_) => null),
          savedRouteRepositoryProvider.overrideWithValue(repository),
          ...overrides.cast(),
        ],
        child: testLocalizedApp(
          child: SavedRouteDetailScreen(
            routeId: routeId,
            onLoadOnMap: onLoadOnMap ?? (_) {},
            goNoGoSection: goNoGoSection,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('shows go/no-go section slot when provided', (tester) async {
    final route = testSavedRoute(name: 'Willamette Shuttle');
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
      goNoGoSection: const Text('Route go-no-go slot'),
    );

    expect(find.text('Route go-no-go slot'), findsOneWidget);
  });

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

  testWidgets('shows metric distance for route with distance metadata', (
    tester,
  ) async {
    final route = testSavedRoute();
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );

    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('5.2 km'), findsOneWidget);
  });

  testWidgets('shows imperial distance when units preference is imperial', (
    tester,
  ) async {
    final route = testSavedRoute();
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
      displayUnits: DisplayUnitSystem.imperial,
    );

    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('3.2 mi'), findsOneWidget);
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

  testWidgets('toggle favorite persists immediately via repository', (
    tester,
  ) async {
    final route = testSavedRoute(name: 'Favorite Route');
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );
    when(
      () => repository.setFavorite(route.id, isFavorite: true),
    ).thenAnswer(
      (_) async => Result.success(route.copyWith(isFavorite: true)),
    );

    await pumpDetail(
      tester,
      routeId: route.id,
      overrides: const [],
    );

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    verify(
      () => repository.setFavorite(route.id, isFavorite: true),
    ).called(1);
    verifyNever(() => repository.upsert(any()));
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('save clears geometry when a waypoint is removed', (
    tester,
  ) async {
    final route = testSavedRoute(name: 'Edit me').copyWith(
      waypoints: const [
        RouteWaypoint.catalog(launchId: 'a', order: 0),
        RouteWaypoint.catalog(launchId: 'b', order: 1),
        RouteWaypoint.catalog(launchId: 'c', order: 2),
      ],
      geometrySnapshot: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.6, 45.5],
          [-122.5, 45.6],
        ],
        lengthMeters: 1200,
        computedAt: DateTime.utc(2026),
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
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Waypoints'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsNWidgets(3));
    await tester.tap(deleteButtons.at(1));
    await tester.pumpAndSettle();

    await tapScrollable(tester, find.text('Save changes'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => repository.upsert(captureAny())).captured.single
            as SavedRoute;
    expect(captured.geometrySnapshot, isNull);
    expect(captured.waypoints, hasLength(2));
  });

  testWidgets('save clears geometry when waypoints are reordered', (
    tester,
  ) async {
    final existing = testSavedRoute(name: 'Reorder me').copyWith(
      waypoints: const [
        RouteWaypoint.catalog(launchId: 'a', order: 0),
        RouteWaypoint.catalog(launchId: 'b', order: 1),
        RouteWaypoint.catalog(launchId: 'c', order: 2),
      ],
      geometrySnapshot: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.6, 45.5],
          [-122.5, 45.6],
        ],
        lengthMeters: 1200,
        computedAt: DateTime.utc(2026),
      ),
    );
    SavedRoute? captured;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchPointLookupProvider.overrideWithValue((_) => null),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: _WaypointReorderHarness(
              existing: existing,
              onSaved: (route) => captured = route,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester
        .state<_WaypointReorderHarnessState>(
          find.byType(_WaypointReorderHarness),
        )
        .applyReorder(1, 0);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.geometrySnapshot, isNull);
    expect(captured!.waypoints.map((wp) => wp.launchId), ['b', 'a', 'c']);
  });
}

class _WaypointReorderHarness extends StatefulWidget {
  const _WaypointReorderHarness({
    required this.existing,
    required this.onSaved,
  });

  final SavedRoute existing;
  final ValueChanged<SavedRoute> onSaved;

  @override
  State<_WaypointReorderHarness> createState() =>
      _WaypointReorderHarnessState();
}

class _WaypointReorderHarnessState extends State<_WaypointReorderHarness> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  late List<RouteWaypoint> _waypoints;

  void applyReorder(int oldIndex, int newIndex) {
    setState(() {
      var targetIndex = newIndex;
      if (targetIndex > oldIndex) {
        targetIndex -= 1;
      }
      final item = _waypoints.removeAt(oldIndex);
      _waypoints.insert(targetIndex, item);
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existing.name;
    _waypoints = List.of(widget.existing.waypoints);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        SavedRouteDetailWaypointsSection(
          waypoints: _waypoints,
          onReorder: applyReorder,
          onDeleteWaypoint: (_) {},
        ),
        FilledButton(
          onPressed: () => widget.onSaved(
            buildSavedRouteDetailUpdate(
              existing: widget.existing,
              nameController: _nameController,
              descriptionController: _descriptionController,
              notesController: _notesController,
              durationController: _durationController,
              waypoints: _waypoints,
              difficulty: widget.existing.metadata.difficulty,
              skillLevel: widget.existing.metadata.recommendedSkillLevel,
              selectedCategories: const {},
              customTags: const [],
              isFavorite: widget.existing.isFavorite,
            ),
          ),
          child: Text(l10n.savedRoutesSaveButton),
        ),
      ],
    );
  }
}
