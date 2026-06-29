import 'package:eddyscout_core/eddyscout_core.dart';

/// UI actions the map controller cannot perform without widget context.
class MapUiCallbacks {
  const MapUiCallbacks({
    required this.pickDifferentTakeOutMessage,
    required this.pickStopLaunchBlockedMessage,
    required this.riverDataLoadingMessage,
    required this.riverDataLoadFailedMessage,
    this.customStopLabel,
    this.showSnackBar,
    this.openLaunchDetail,
    this.onLaunchPlaceSelected,
  });

  /// Either a localized `String` or a typed domain object
  /// (e.g. `RouteFailure`).
  /// Widgets should localize domain objects via `AppLocalizations`.
  final void Function(Object message)? showSnackBar;
  final void Function(LaunchPoint launch)? openLaunchDetail;

  /// Place-first flow: user tapped a launch pin while browsing the map.
  final void Function(LaunchPoint launch)? onLaunchPlaceSelected;

  /// Localized label for a custom snap stop (one-based display index).
  final String Function(int index)? customStopLabel;

  /// Localized snack bar when take-out equals put-in.
  final String pickDifferentTakeOutMessage;

  /// Localized snack bar when pick-on-map mode taps a catalog launch pin.
  final String pickStopLaunchBlockedMessage;

  /// Localized snack bar when hydro data is not ready.
  final String riverDataLoadingMessage;

  /// Localized snack bar when hydro data failed to load or parse.
  final String riverDataLoadFailedMessage;
}
