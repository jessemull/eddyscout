import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'firebase/firebase_bootstrap.dart';
import 'firebase/firebase_flags.dart';
import 'screens/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kUseFirebase && !kIsWeb) {
    FirebaseBootstrap.attempted = true;
    try {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e, st) {
      FirebaseBootstrap.lastError = e.toString();
      debugPrint('Firebase init/sign-in failed (add native config or set USE_FIREBASE=false): $e\n$st');
    }
  }

  const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
  MapboxOptions.setAccessToken(mapboxAccessToken);

  runApp(const EddyScoutApp(mapboxAccessToken: mapboxAccessToken));
}

class EddyScoutApp extends StatelessWidget {
  const EddyScoutApp({super.key, required this.mapboxAccessToken});

  final String mapboxAccessToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EddyScout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: _homeForToken(),
    );
  }

  Widget _homeForToken() {
    if (kIsWeb) {
      return const WebMapPlaceholderScreen();
    }
    if (mapboxAccessToken.isEmpty) {
      return const MissingMapboxTokenScreen();
    }
    return const MapScreen();
  }
}

class MissingMapboxTokenScreen extends StatelessWidget {
  const MissingMapboxTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EddyScout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.key_off_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mapbox token required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Local dev: create .local.env from the template and run via the script:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'cp env.example .local.env\n'
                  '# edit MAPBOX_ACCESS_TOKEN=pk....\n'
                  './scripts/run_android.sh',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Or pass at compile time:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'flutter run --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_PUBLIC_TOKEN',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Never commit .local.env. Use a restricted public token in Mapbox.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebMapPlaceholderScreen extends StatelessWidget {
  const WebMapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EddyScout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'The Mapbox map runs on Android and iOS. '
            'Use a device or emulator to see launch points.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
