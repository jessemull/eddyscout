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
  MapUiCallbacks _ui = const MapUiCallbacks(
    pickDifferentTakeOutMessage: '',
    pickStopLaunchBlockedMessage: '',
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
  Cancelable? _longTapCancelable;
  Cancelable? _waterEntryTapCancelable;
  Cancelable? _selectionTapCancelable;
  CircleAnnotationManager? _launchCircleManager;
  CircleAnnotationManager? _planningSnapManager;
  CircleAnnotationManager? _waterEntryCircleManager;
  PolylineAnnotationManager? _waterEntryConnectorManager;
  CircleAnnotationManager? _selectionManager;
  CircleAnnotation? _selectionAnnotation;
  CircleAnnotation? _selectionWaterEntryAnnotation;
  bool _markersInstalled = false;
  bool _mapDiagnosticsLogged = false;

  double? _debugLastLoggedCameraZoom;
  int _debugLastCameraChangeLogMs = 0;
  bool _alive = true;
  int _routeLineGeneration = 0;

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
  Cancelable? get longTapCancelable => _longTapCancelable;

  @protected
  set longTapCancelable(Cancelable? value) => _longTapCancelable = value;

  @protected
  Cancelable? get waterEntryTapCancelable => _waterEntryTapCancelable;

  @protected
  set waterEntryTapCancelable(Cancelable? value) =>
      _waterEntryTapCancelable = value;

  @protected
  CircleAnnotationManager? get waterEntryCircleManager =>
      _waterEntryCircleManager;

  @protected
  set waterEntryCircleManager(CircleAnnotationManager? value) =>
      _waterEntryCircleManager = value;

  @protected
  PolylineAnnotationManager? get waterEntryConnectorManager =>
      _waterEntryConnectorManager;

  @protected
  set waterEntryConnectorManager(PolylineAnnotationManager? value) =>
      _waterEntryConnectorManager = value;

  @protected
  Cancelable? get selectionTapCancelable => _selectionTapCancelable;

  @protected
  set selectionTapCancelable(Cancelable? value) =>
      _selectionTapCancelable = value;

  @protected
  CircleAnnotationManager? get launchCircleManager => _launchCircleManager;

  @protected
  set launchCircleManager(CircleAnnotationManager? value) =>
      _launchCircleManager = value;

  @protected
  CircleAnnotationManager? get planningSnapManager => _planningSnapManager;

  @protected
  set planningSnapManager(CircleAnnotationManager? value) =>
      _planningSnapManager = value;

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
  CircleAnnotation? get selectionWaterEntryAnnotation =>
      _selectionWaterEntryAnnotation;

  @protected
  set selectionWaterEntryAnnotation(CircleAnnotation? value) =>
      _selectionWaterEntryAnnotation = value;

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

  /// Bumped when route drawing should be abandoned (back from planning).
  @protected
  int get routeLineGeneration => _routeLineGeneration;

  @protected
  int bumpRouteLineGeneration() => ++_routeLineGeneration;

  @protected
  bool isRouteLineGenerationCurrent(int generation) =>
      generation == _routeLineGeneration;
}
