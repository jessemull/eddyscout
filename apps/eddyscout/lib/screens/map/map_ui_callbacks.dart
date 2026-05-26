import 'package:eddyscout_map/eddyscout_map.dart';

/// UI actions the map controller cannot perform without widget context.
class MapUiCallbacks {
  const MapUiCallbacks({
    this.showSnackBar,
    this.openLaunchDetail,
    this.pickDifferentTakeOutMessage = 'Pick a different launch for take-out.',
    this.riverDataLoadingMessage = 'Still loading river data… try again.',
  });

  final void Function(String message)? showSnackBar;
  final void Function(LaunchPoint launch)? openLaunchDetail;

  /// Localized snack bar when take-out equals put-in.
  final String pickDifferentTakeOutMessage;

  /// Localized snack bar when hydro data is not ready.
  final String riverDataLoadingMessage;
}
