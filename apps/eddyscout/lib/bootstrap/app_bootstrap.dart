import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Dependencies resolved before the composition root calls `runApp`.
class AppBootstrapData {
  /// Creates bootstrap data for `ProviderScope` overrides.
  const AppBootstrapData({
    required this.keyValueStore,
    required this.firebaseBootstrapState,
  });

  /// Opened preference store for the app lifetime.
  final KeyValueStore keyValueStore;

  /// Firebase init outcome for launch-detail messaging.
  final FirebaseBootstrapState firebaseBootstrapState;
}

/// Initializes platform services and returns data for `ProviderScope`.
Future<AppBootstrapData> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyValueStore = await SharedPreferencesKeyValueStore.open();

  var firebaseBootstrapState = const FirebaseBootstrapState();
  if (kUseFirebase && !kIsWeb) {
    firebaseBootstrapState = const FirebaseBootstrapState(attempted: true);
    try {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.signInAnonymously();
    } on Exception catch (e, st) {
      firebaseBootstrapState = FirebaseBootstrapState(
        attempted: true,
        userFacingError: firebaseBootstrapUserFacingError(e),
      );
      if (kDebugMode) {
        debugPrint(
          'Firebase init/sign-in failed (add native config or set USE_FIREBASE=false): $e\n$st',
        );
      }
    }
  }

  if (mapboxAccessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(mapboxAccessToken);
  }

  return AppBootstrapData(
    keyValueStore: keyValueStore,
    firebaseBootstrapState: firebaseBootstrapState,
  );
}
