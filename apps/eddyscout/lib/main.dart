import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kUseFirebase && !kIsWeb) {
    FirebaseBootstrap.attempted = true;
    try {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.signInAnonymously();
    } on Exception catch (e, st) {
      FirebaseBootstrap.lastError = e.toString();
      if (kDebugMode) {
        debugPrint(
          'Firebase init/sign-in failed (add native config or set USE_FIREBASE=false): $e\n$st',
        );
      }
    }
  }

  MapboxOptions.setAccessToken(mapboxAccessToken);

  runApp(
    ProviderScope(
      overrides: [
        routesProvider.overrideWithValue($appRoutes),
        conditionReportsRepositoryProvider.overrideWithValue(
          const ConditionReportsRepositoryImpl(),
        ),
        hydroGeoJsonLoaderProvider.overrideWithValue(
          () =>
              rootBundle.loadString('assets/hydro/willamette_waterway.geojson'),
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
