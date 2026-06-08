import 'package:eddyscout/analytics/analytics_navigator_observer.dart';
import 'package:eddyscout/bootstrap/app_bootstrap.dart';
import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/routing/saved_routes_database_override.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  final bootstrap = await bootstrapApp();

  runApp(
    ProviderScope(
      overrides: [
        ...buildAppProviderOverrides(keyValueStore: bootstrap.keyValueStore),
        firebaseBootstrapProvider.overrideWithValue(
          bootstrap.firebaseBootstrapState,
        ),
        ...savedRoutesProductionOverrides(),
        launchPointLookupProvider.overrideWithValue(findLaunchPointById),
        navigatorObserversProvider.overrideWith(
          (ref) => [
            AnalyticsNavigatorObserver(ref.watch(analyticsClientProvider)),
          ],
        ),
      ],
      child: const EddyScoutApp(),
    ),
  );
}

class EddyScoutApp extends ConsumerWidget {
  const EddyScoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(savedRoutesDatabaseProvider);

    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
