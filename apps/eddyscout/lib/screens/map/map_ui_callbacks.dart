import 'package:eddyscout_map/eddyscout_map.dart';

/// UI actions the map controller cannot perform without widget context.
class MapUiCallbacks {
  const MapUiCallbacks({
    required this.pickDifferentTakeOutMessage,
    required this.riverDataLoadingMessage,
    this.showSnackBar,
    this.openLaunchDetail,
  });

  /// Either a localized `String` or a typed domain object
  /// (e.g. `RouteFailure`).
  /// Widgets should localize domain objects via `AppLocalizations`.
  final void Function(Object message)? showSnackBar;
  final void Function(LaunchPoint launch)? openLaunchDetail;

  /// Localized snack bar when take-out equals put-in.
  final String pickDifferentTakeOutMessage;

  /// Localized snack bar when hydro data is not ready.
  final String riverDataLoadingMessage;
}
