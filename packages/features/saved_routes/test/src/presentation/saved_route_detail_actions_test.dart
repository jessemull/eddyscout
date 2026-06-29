import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_actions.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_saved_routes.dart';

class _MockSavedRouteRepository extends Mock implements SavedRouteRepository {}

void main() {
  late _MockSavedRouteRepository repository;

  setUp(() {
    repository = _MockSavedRouteRepository();
    registerFallbackValue(testSavedRoute());
  });

  Future<AppLocalizations> pumpSaveButton(
    WidgetTester tester, {
    required SavedRoute route,
    required String name,
    VoidCallback? onSaved,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClientProvider.overrideWithValue(RecordingAnalyticsClient()),
          savedRouteRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () => SavedRouteDetailActions.save(
                    context: context,
                    ref: ref,
                    existing: route,
                    updated: route.copyWith(name: name),
                    name: name,
                    onSaved: onSaved ?? () {},
                  ),
                  child: const Text('Save'),
                ),
              );
            },
          ),
        ),
      ),
    );
    return AppLocalizations.of(tester.element(find.byType(Scaffold)));
  }

  testWidgets('save shows validation snackbar when name is empty', (
    tester,
  ) async {
    final route = testSavedRoute();
    final l10n = await pumpSaveButton(tester, route: route, name: '');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.savedRoutesNameRequired), findsOneWidget);
  });

  testWidgets('save shows success snackbar when update succeeds', (
    tester,
  ) async {
    final route = testSavedRoute();
    when(() => repository.upsert(any())).thenAnswer(
      (_) async => Result.success(route.copyWith(name: 'Updated route')),
    );
    when(() => repository.listAll()).thenAnswer(
      (_) async => Result.success([route]),
    );
    when(() => repository.listFavorites()).thenAnswer(
      (_) async => const Result.success([]),
    );
    when(() => repository.getById(route.id)).thenAnswer(
      (_) async => Result.success(route),
    );

    final l10n = await pumpSaveButton(
      tester,
      route: route,
      name: 'Updated route',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.savedRoutesSaveSuccess), findsOneWidget);
  });

  testWidgets('save shows error snackbar when update fails', (tester) async {
    final route = testSavedRoute();
    when(() => repository.upsert(any())).thenAnswer(
      (_) async => const Result.failure(
        StorageFailure(message: 'disk full'),
      ),
    );

    final l10n = await pumpSaveButton(
      tester,
      route: route,
      name: 'Updated route',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.savedRoutesSaveError), findsOneWidget);
  });
}
