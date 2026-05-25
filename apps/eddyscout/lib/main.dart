import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'routing/app_router_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kUseFirebase && !kIsWeb) {
    FirebaseBootstrap.attempted = true;
    try {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e, st) {
      FirebaseBootstrap.lastError = e.toString();
      debugPrint(
        'Firebase init/sign-in failed (add native config or set USE_FIREBASE=false): $e\n$st',
      );
    }
  }

  MapboxOptions.setAccessToken(mapboxAccessToken);

  runApp(
    ProviderScope(
      overrides: [
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
      title: 'EddyScout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
