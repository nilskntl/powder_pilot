import 'package:flutter/material.dart';

import '../../../../activity/data_provider.dart';
import '../../../map/map.dart';
import '../../../../activity/state.dart';
import '../../../../theme.dart';
import '../../../map/location_mark.dart';
import '../../../widgets/slope_circle.dart';

/// The map overview shows a small map overview of the current activity.
class MapOverview extends StatefulWidget {
  const MapOverview(
      {super.key, required this.dataProvider, this.height = 128.0});

  final ActivityMap activityMap = const ActivityMap(staticMap: false);
  final ActivityDataProvider dataProvider;

  final double height;

  @override
  State<MapOverview> createState() => _MapOverviewState();
}

class _MapOverviewState extends State<MapOverview> {
  /// Opens the map in full screen mode with more details
  void _openMapPage() {
    if (widget.dataProvider.latitude != 0.0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(
            dataProvider: widget.dataProvider,
            activityMap: widget.activityMap,
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
              if (widget.dataProvider.latitude != 0.0) widget.activityMap,
              _mapOverlay(),
              if (widget.dataProvider.latitude != 0.0) _drawLocationMark(),
              _clickIcon(),
              _currentSlope(),
            ],
          ),
        ),
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
    if (widget.dataProvider.latitude != 0.0 &&
        widget.dataProvider.status == ActivityStatus.running &&
        widget.dataProvider.route.slopes.isNotEmpty) {
      return Positioned(
        right: 4,
        bottom: 4,
        child: SlopeCircle(
            slope: widget.dataProvider.route.slopes.last, animated: true),
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
