import 'package:flutter/material.dart';

/// Web platform placeholder when Mapbox map is unavailable.
class WebMapPlaceholderScreen extends StatelessWidget {
  const WebMapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
