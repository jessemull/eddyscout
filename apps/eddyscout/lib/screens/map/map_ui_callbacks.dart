import 'package:eddyscout_map/eddyscout_map.dart';

/// UI actions the map controller cannot perform without widget context.
class MapUiCallbacks {
  const MapUiCallbacks({this.showSnackBar, this.openLaunchDetail});

  final void Function(String message)? showSnackBar;
  final void Function(LaunchPoint launch)? openLaunchDetail;
}
