import 'package:flutter/material.dart';
import 'package:powder_pilot/activity/data.dart';
import 'package:powder_pilot/main.dart';

import '../../activity/data_provider.dart';
import '../../activity/route.dart';
import '../../activity/state.dart';
import '../../theme/color.dart';
import '../../theme/icon.dart';
import 'location_mark.dart';
import 'map.dart';
import 'map_page.dart';
import '../widgets/slope_circle.dart';

/// The map overview shows a small map overview of the current activity.
class MapOverview extends StatefulWidget {
  const MapOverview(
      {super.key,
      this.dataProvider,
      this.static = false,
      this.route,
      this.locations,
      this.height = 128.0});

  final ActivityDataProvider? dataProvider;
  final ActivityRoute? route;
  final ActivityLocations? locations;

  /// If static is true the dataProvider MUST be != null
  final bool static;

  final double height;

  @override
  State<MapOverview> createState() => _MapOverviewState();
}

class _MapOverviewState extends State<MapOverview> {
  late final ActivityMap _map = ActivityMap(
    staticMap: widget.static,
    route: _getRoute(),
    activityLocations: _getLocations(),
  );

  ActivityLocations _getLocations() {
    if (widget.dataProvider != null &&
        !widget.static &&
        widget.dataProvider!.activityLocations != null) {
      return widget.dataProvider!.activityLocations!;
    } else if (widget.locations != null) {
      return widget.locations!;
    } else {
      return const ActivityLocations();
    }
  }

  ActivityRoute _getRoute() {
    if (widget.dataProvider != null && !widget.static) {
      return widget.dataProvider!.route;
    } else if (widget.route != null) {
      return widget.route!;
    } else {
      return const ActivityRoute(coordinates: [], slopes: []);
    }
  }

  /// Opens the map in full screen mode with more details
  void _openMapPage() {
    ActivityStatus getStatus() {
      if (!widget.static) {
        return ActivityStatus.running;
      } else if (widget.dataProvider != null) {
        return widget.dataProvider!.status;
      } else {
        return ActivityStatus.inactive;
      }
    }

    if (!widget.static
        ? widget.dataProvider!.internetStatus == true
        : PowderPilot.connectivityController.status == true &&
            (widget.static || widget.dataProvider!.latitude != 0.0)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(
            static: widget.static,
            route: _getRoute(),
            status: getStatus(),
            activityMap: _map,
          ),
          settings: const RouteSettings(
              name:
                  '/fullscreen'), // Setzen Sie hier den gewünschten Routennamen
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onTap: () {
          _openMapPage();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              if (!widget.static
                  ? widget.dataProvider!.internetStatus == true
                  : PowderPilot.connectivityController.status == true &&
                      (widget.static || widget.dataProvider!.latitude != 0.0))
                _map,
              _mapOverlay(),
              if (!widget.static && !widget.static
                  ? widget.dataProvider!.internetStatus == true
                  : PowderPilot.connectivityController.status == true &&
                      !widget.static &&
                      widget.dataProvider!.latitude != 0.0)
                _drawLocationMark(),
              if (!widget.static
                  ? widget.dataProvider!.internetStatus == true
                  : PowderPilot.connectivityController.status == true)
                _clickIcon(),
              if (!widget.static) _currentSlope(),
              if (!widget.static
                  ? widget.dataProvider!.internetStatus == false
                  : PowderPilot.connectivityController.status == false)
                _noInternet(),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a message if the user is offline
  Widget _noInternet() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Icon(
        size: 48.0,
        LogoTheme.noInternet,
        color: ColorTheme.contrast,
      ),
    );
  }

  /// Draws a gradient overlay over the map
  Widget _mapOverlay() {
    final List<Color> colors = [
      Colors.transparent,
      ColorTheme.secondary.withOpacity(0.2),
      ColorTheme.secondary.withOpacity(0.8)
    ];
    const List<double> stops = [0.0, 0.8, 1.0];
    Widget container(
        {required AlignmentGeometry begin, required AlignmentGeometry end}) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: colors,
            stops: stops,
          ),
        ),
      );
    }

    return Stack(
      children: [
        container(begin: Alignment.bottomCenter, end: Alignment.topCenter),
        container(begin: Alignment.topCenter, end: Alignment.bottomCenter),
        container(begin: Alignment.centerRight, end: Alignment.centerLeft),
        container(begin: Alignment.centerLeft, end: Alignment.centerRight),
      ],
    );
  }

  /// Shows an Icon to indicate that the map can be clicked
  Widget _clickIcon() {
    return Positioned(
      top: 4,
      right: 4,
      child: Icon(
        LogoTheme.click,
        color: ColorTheme.contrast,
      ),
    );
  }

  /// Shows the current slope or lift the user is on
  Widget _currentSlope() {
    if (widget.dataProvider!.latitude != 0.0 &&
        widget.dataProvider!.status == ActivityStatus.running &&
        widget.dataProvider!.route.slopes.isNotEmpty) {
      return Positioned(
        right: 4,
        bottom: 4,
        child: SlopeCircle(
            slope: widget.dataProvider!.route.slopes.last, animated: true),
      );
    } else {
      return const SizedBox();
    }
  }

  /// Draws the location mark in the center of the map
  Widget _drawLocationMark() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: CustomPaint(
          size: const Size(24, 24),
          painter: LocationMark(),
        ),
      ),
    );
  }
}
