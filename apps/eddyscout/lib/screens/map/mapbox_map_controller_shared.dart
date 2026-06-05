import 'package:eddyscout/screens/map/map_ui_callbacks.dart';
import 'package:flutter/foundation.dart' show protected;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Shared map session state for map controller mixins.
abstract class MapboxMapControllerBase extends Notifier<void> {
  // Initialized with empty strings; the MapScreen binds localized values.
  MapUiCallbacks _ui = const MapUiCallbacks(
    pickDifferentTakeOutMessage: '',
    riverDataLoadingMessage: '',
  );

  /// Snackbar and navigation hooks from the map screen (set after first frame).
  // ignore: use_setters_to_change_properties -- setter triggers conflicting lints.
  void bindUiCallbacks(MapUiCallbacks callbacks) => _ui = callbacks;

  /// UI callbacks bound from the map screen.
  @protected
  MapUiCallbacks get ui => _ui;

  MapboxMap? _mapboxMap;
  Cancelable? _tapCancelable;
  bool _markersInstalled = false;
  bool _mapDiagnosticsLogged = false;

  double? _debugLastLoggedCameraZoom;
  int _debugLastCameraChangeLogMs = 0;
  bool _alive = true;

  /// Active Mapbox map instance, if created.
  @protected
  MapboxMap? get mapboxMap => _mapboxMap;

  @protected
  set mapboxMap(MapboxMap? value) => _mapboxMap = value;

  @protected
  Cancelable? get tapCancelable => _tapCancelable;

  @protected
  set tapCancelable(Cancelable? value) => _tapCancelable = value;

  @protected
  bool get markersInstalled => _markersInstalled;

  @protected
  set markersInstalled(bool value) => _markersInstalled = value;

  @protected
  bool get mapDiagnosticsLogged => _mapDiagnosticsLogged;

  @protected
  set mapDiagnosticsLogged(bool value) => _mapDiagnosticsLogged = value;

  @protected
  bool get alive => _alive;

  @protected
  set alive(bool value) => _alive = value;

  @protected
  double? get debugLastLoggedCameraZoom => _debugLastLoggedCameraZoom;

  @protected
  set debugLastLoggedCameraZoom(double? value) =>
      _debugLastLoggedCameraZoom = value;

  @protected
  int get debugLastCameraChangeLogMs => _debugLastCameraChangeLogMs;

  @protected
  set debugLastCameraChangeLogMs(int value) =>
      _debugLastCameraChangeLogMs = value;

  @override
  void build() {
    alive = true;
    ref.onDispose(() {
      alive = false;
      tapCancelable?.cancel();
    });
  }
}
