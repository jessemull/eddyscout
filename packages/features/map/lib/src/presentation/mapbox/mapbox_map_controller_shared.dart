import 'package:flutter/foundation.dart' show protected;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../map_ui_callbacks.dart';

/// Shared map session state for map controller mixins.
mixin MapboxMapControllerBase {
  /// Codegen notifiers extend `$Notifier`, not `Notifier`, so mixins cannot
  /// use `mixin on Notifier<void>`. The map controller implements this getter
  /// with `ref` and mixins read other providers through it.
  Ref get mapControllerRef;
  // Initialized with empty strings; the MapScreen binds localized values.
  MapUiCallbacks _ui = const MapUiCallbacks(
    pickDifferentTakeOutMessage: '',
    riverDataLoadingMessage: '',
    riverDataLoadFailedMessage: '',
  );

  /// Snackbar and navigation hooks from the map screen (set after first frame).
  // ignore: use_setters_to_change_properties -- setter triggers conflicting lints.
  void bindUiCallbacks(MapUiCallbacks callbacks) => _ui = callbacks;

  /// UI callbacks bound from the map screen.
  @protected
  MapUiCallbacks get ui => _ui;

  MapboxMap? _mapboxMap;
  Cancelable? _tapCancelable;
  Cancelable? _selectionTapCancelable;
  CircleAnnotationManager? _selectionManager;
  CircleAnnotation? _selectionAnnotation;
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
  Cancelable? get selectionTapCancelable => _selectionTapCancelable;

  @protected
  set selectionTapCancelable(Cancelable? value) =>
      _selectionTapCancelable = value;

  @protected
  CircleAnnotationManager? get selectionManager => _selectionManager;

  @protected
  set selectionManager(CircleAnnotationManager? value) =>
      _selectionManager = value;

  @protected
  CircleAnnotation? get selectionAnnotation => _selectionAnnotation;

  @protected
  set selectionAnnotation(CircleAnnotation? value) =>
      _selectionAnnotation = value;

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
}
