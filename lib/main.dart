import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'screens/map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const accessToken = String.fromEnvironment('ACCESS_TOKEN');
  MapboxOptions.setAccessToken(accessToken);

  runApp(EddyScoutApp(accessToken: accessToken));
}

class EddyScoutApp extends StatelessWidget {
  const EddyScoutApp({super.key, required this.accessToken});

  final String accessToken;

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
    if (accessToken.isEmpty) {
      return const MissingAccessTokenScreen();
    }
    return const MapScreen();
  }
}

class MissingAccessTokenScreen extends StatelessWidget {
  const MissingAccessTokenScreen({super.key});

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
                  'Mapbox access token required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Create a public token in your Mapbox account, then run the app with:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SelectableText(
                  'flutter run --dart-define=ACCESS_TOKEN=YOUR_PUBLIC_TOKEN',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'For release builds, pass the same --dart-define to flutter build. '
                  'Do not commit tokens to the repository.',
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
