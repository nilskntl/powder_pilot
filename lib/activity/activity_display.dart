import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:ski_tracker/activity/activity.dart';
import 'package:ski_tracker/activity/activity_bar.dart';

import '../main.dart';
import '../utils.dart';
import 'activity_data_provider.dart';
import 'activity_map.dart';

class ActivityDisplay extends StatefulWidget {
  const ActivityDisplay({super.key});

  @override
  State<ActivityDisplay> createState() => _ActivityDisplayState();
}

class _ActivityDisplayState extends State<ActivityDisplay> {
  @override
  Widget build(BuildContext context) {
    ActivityDataProvider activityDataProvider =
        Provider.of<ActivityDataProvider>(context);
    SkiTracker.setActivityDataProvider(activityDataProvider);

    return Column(
      children: [
        const SizedBox(height: 32),
        ActivityInfo(activityDataProvider: activityDataProvider),
        const SizedBox(height: 16),
        ActivityBar(activityDataProvider: activityDataProvider),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ActivityInfo extends StatefulWidget {
  const ActivityInfo({super.key, required this.activityDataProvider});

  final ActivityDataProvider activityDataProvider;

  @override
  State<ActivityInfo> createState() => _ActivityInfoState();
}

class _ActivityInfoState extends State<ActivityInfo> {
  Location location = Location();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    SkiTracker.getActivity().infoMounted = true;
    _startTimer();
  }

  void _startTimer() {
    bool mapInitialized = false;
    bool addressInitialized = false;
    int id = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mapInitialized) {
          if (SkiTracker.getActivity().initializedMap) {
          setState(() {});
          mapInitialized = true;
        }
      }
      if (!addressInitialized) {
        if (SkiTracker.getActivity().areaName != 'Unknown') {
          setState(() {});
          addressInitialized = true;
        }
      }
      if (id != Activity.id) {
        id = Activity.id;
        mapInitialized = false;
        addressInitialized = false;
        setState(() {});
      }
    });
  }

  static const double horizontalSpaceMiddle = 8;
  static const double horizontalSpaceLeft = 16;
  static const double horizontalSpaceRight = 16;

  static const int animationDuration = 500;

  static const double verticalSpace = 8;

  static const String unitSpeed = 'km/h';
  static const String unitDistance = 'km';
  static const String unitAltitude = 'm';
  static const String unitSlope = '%';
  static const String unitTime = 's';

  static const double speedFactor = 3.6;

  static const double standardContainerHeight = 140;
  static const double standardContainerHeightFolded = 56;
  static const double mapPreviewHeight = 100;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: horizontalSpaceLeft),
                _speed(widget.activityDataProvider),
                const SizedBox(width: horizontalSpaceMiddle),
                _distance(widget.activityDataProvider),
                const SizedBox(width: horizontalSpaceRight),
              ],
            ),
            const SizedBox(height: verticalSpace),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: horizontalSpaceLeft),
                _altitude(widget.activityDataProvider),
                const SizedBox(width: horizontalSpaceMiddle),
                _slope(widget.activityDataProvider),
                // _vertical(activityDataProvider),
                const SizedBox(width: horizontalSpaceRight),
              ],
            ),
            const SizedBox(height: verticalSpace),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapPage(),
                    settings: const RouteSettings(
                        name:
                            '/fullscreen'), // Setzen Sie hier den gewünschten Routennamen
                  ),
                );
              },
              child: _buildActivityContainer(
                height: SkiTracker.getActivity().initializedMap &&
                        SkiTracker.getActivity().areaName != 'Unknown'
                    ? mapPreviewHeight + FontTheme.size + 24
                    : SkiTracker.getActivity().initializedMap
                        ? mapPreviewHeight
                        : SkiTracker.getActivity().areaName != 'Unknown'
                            ? FontTheme.size + 24
                            : 0,
                alwaysSameHeight: true,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (SkiTracker.getActivity().initializedMap)
                      Stack(children: [
                        SizedBox(
                          height: mapPreviewHeight,
                          child: SkiTracker.getActivity().activityMap,
                        ),
                        Positioned(
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
                        ),
                        Container(
                          height: mapPreviewHeight,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF505050).withOpacity(0.9)
                              ],
                              center: Alignment.center,
                              radius:
                                  2.5, // Radius steuert die Größe des Gradients
                            ),
                          ),
                        ),
                      ]),
                    if (SkiTracker.getActivity().areaName != 'Unknown')
                      Container(
                          height: FontTheme.size + 24,
                          padding: const EdgeInsets.all(8.0),
                          child: Utils.buildText(
                            text: SkiTracker.getActivity().areaName == 'Unknown'
                                ? 'No location data available'
                                : '${SkiTracker.getActivity().areaName}, ${SkiTracker.getActivity().areaName}',
                            fontSize: FontTheme.size,
                          )),
                  ],
                ),
              ),
            ),
            if(SkiTracker.getActivity().initializedMap || SkiTracker.getActivity().areaName != 'Unknown')const SizedBox(height: verticalSpace),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: horizontalSpaceLeft),
                _gps(widget.activityDataProvider),
                const SizedBox(width: horizontalSpaceMiddle),
                _time(widget.activityDataProvider),
                const SizedBox(width: horizontalSpaceRight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gps(ActivityDataProvider activityData) {
    Widget buildGpsIcon(IconData icon, Color color) {
      return Icon(
        icon,
        size: 48,
        color: color,
      );
    }

    return Expanded(
      flex: 1,
      child: _buildActivityContainer(
        height: 72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!SkiTracker.getActivity().isActive)
              _buildActivityHeader(
                  text: 'GPS', iconData: Icons.gps_fixed_rounded),
            if (SkiTracker.getActivity().isActive)
              Stack(
                children: [
                  buildGpsIcon(Icons.signal_cellular_alt_rounded, Colors.grey),
                  if (activityData.gpsAccuracy == GpsAccuracy.high)
                    buildGpsIcon(
                        Icons.signal_cellular_alt_rounded, Colors.green),
                  if (activityData.gpsAccuracy == GpsAccuracy.medium)
                    buildGpsIcon(
                        Icons.signal_cellular_alt_2_bar_rounded, Colors.yellow),
                  if (activityData.gpsAccuracy == GpsAccuracy.low)
                    buildGpsIcon(
                        Icons.signal_cellular_alt_1_bar_rounded, Colors.red),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _time(ActivityDataProvider activityData) {
    int downhillFlex = 1;
    int uphillFlex = 1;
    if (activityData.elapsedDownhillTime.inSeconds > 0) {
      downhillFlex = ((activityData.elapsedDownhillTime.inSeconds /
                  (activityData.elapsedUphillTime.inSeconds +
                      activityData.elapsedDownhillTime.inSeconds)) *
              100)
          .round();
      if (activityData.elapsedUphillTime.inSeconds == 0) {
        uphillFlex = 1;
      }
    }
    if (activityData.elapsedUphillTime.inSeconds > 0) {
      uphillFlex = ((activityData.elapsedUphillTime.inSeconds /
                  (activityData.elapsedUphillTime.inSeconds +
                      activityData.elapsedDownhillTime.inSeconds)) *
              100)
          .round();
      if (activityData.elapsedDownhillTime.inSeconds == 0) {
        downhillFlex = 1;
      }
    }

    Widget buildTimeBar(Color color, bool left) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: left
              ? const BorderRadius.only(
                  topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))
              : const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4)),
        ),
      );
    }

    return Expanded(
      flex: 2,
      child: _buildActivityContainer(
        height: 72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!SkiTracker.getActivity().isActive)
              _buildActivityHeader(text: 'Time', iconData: Icons.timer_rounded),
            if (SkiTracker.getActivity().isActive)
              const SizedBox(height: 4),
            if (SkiTracker.getActivity().isActive)

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Utils.buildText(text: 'Downhill'),
                    ],
                  ),
                  Row(
                    children: [
                      Utils.buildText(text: 'Uphill'),
                      const SizedBox(width: 4),
                    ],
                  ),
                ],
              ),
            if (SkiTracker.getActivity().isActive)
              const SizedBox(height: 2),
            if (SkiTracker.getActivity().isActive)
              Row(
                children: [
                  Expanded(
                    flex: downhillFlex,
                    child: buildTimeBar(Colors.red, true),
                  ),
                  Expanded(
                    flex: uphillFlex,
                    child: buildTimeBar(Colors.green, false),
                  ),
                ],
              ),
            if (SkiTracker.getActivity().isActive)
              const SizedBox(height: 2),
            if (SkiTracker.getActivity().isActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Utils.buildText(
                          text:
                          '${activityData.elapsedDownhillTime.toString().substring(0, 7)} $unitTime'),
                    ],
                  ),
                  Row(
                    children: [
                      Utils.buildText(
                          text:
                          '${activityData.elapsedUphillTime.toString().substring(0, 7)} $unitTime'),
                      const SizedBox(width: 4),],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _speed(ActivityDataProvider activityData) {
    return Expanded(
      child: _buildActivityContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(text: 'Speed', iconData: Icons.speed_rounded),
            const SizedBox(height: 8),
            _buildActivityItem(
                value: (activityData.speed * speedFactor).toStringAsFixed(1),
                unit: unitSpeed),
            _buildActivitySubItem(
                text: 'Max',
                value: (activityData.maxSpeed * speedFactor).toStringAsFixed(1),
                unit: unitSpeed),
            _buildActivitySubItem(
                text: 'Avg',
                value: (activityData.avgSpeed * speedFactor).toStringAsFixed(1),
                unit: unitSpeed),
          ],
        ),
      ),
    );
  }

  Widget _distance(ActivityDataProvider activityData) {
    return Expanded(
      child: _buildActivityContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(text: 'Distance', iconData: Icons.map_rounded),
            const SizedBox(height: 8),
            _buildActivityItem(
                value: (activityData.distance / 1000).toStringAsFixed(1),
                unit: unitDistance),
            _buildActivitySubItem(
                text: 'Downhill',
                value:
                    (activityData.distanceDownhill / 1000).toStringAsFixed(1),
                unit: unitDistance),
            _buildActivitySubItem(
                text: 'Uphill',
                value: (activityData.distanceUphill / 1000).toStringAsFixed(1),
                unit: unitDistance),
          ],
        ),
      ),
    );
  }

  Widget _altitude(ActivityDataProvider activityData) {
    return Expanded(
      child: _buildActivityContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(
                text: 'Altitude', iconData: Icons.terrain_rounded),
            const SizedBox(height: 8),
            _buildActivityItem(
                value: activityData.altitude.round().toString(),
                unit: unitAltitude),
            _buildActivitySubItem(
                text: 'Max',
                value: activityData.maxAltitude.round().toString(),
                unit: unitAltitude),
            _buildActivitySubItem(
                text: 'Avg',
                value: activityData.avgAltitude.round().toString(),
                unit: unitAltitude),
          ],
        ),
      ),
    );
  }

  /*
  Widget _vertical(ActivityDataProvider activityData) {
    return Expanded(
      child: _buildActivityContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(
                text: 'Vertical', iconData: Icons.height_rounded),
            const SizedBox(height: 8),
            _buildActivityItem(
                value: activityData.vertical.round().toString(),
                unit: unitVertical),
            _buildActivitySubItem(
                text: 'Downhill',
                value: activityData.downhillVertical.round().toString(),
                unit: unitVertical),
            _buildActivitySubItem(
                text: 'Uphill',
                value: activityData.uphillVertical.round().toString(),
                unit: unitVertical),
          ],
        ),
      ),
    );
  }
   */

  Widget _slope(ActivityDataProvider activityData) {
    return Expanded(
      child: _buildActivityContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(
                text: 'Slope', iconData: Icons.line_axis_rounded),
            const SizedBox(height: 8),
            _buildActivityItem(
                value: (activityData.slope * 100).toStringAsFixed(1),
                unit: unitSlope),
            _buildActivitySubItem(
                text: 'Max',
                value: (activityData.maxSlope * 100).toStringAsFixed(1),
                unit: unitSlope),
            _buildActivitySubItem(
                text: 'Avg',
                value: (activityData.avgSlope * 100).toStringAsFixed(1),
                unit: unitSlope),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityContainer(
      {required Widget child,
      double height = standardContainerHeight,
      bool alwaysSameHeight = false,
      double padding = 8.0,
      EdgeInsets margin = const EdgeInsets.all(0.0)}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: animationDuration),
      height: alwaysSameHeight
          ? height
          : SkiTracker.getActivity().isActive
              ? height
              : standardContainerHeightFolded,
      padding: EdgeInsets.all(padding),
      margin: margin,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            child,
          ],
        ),
      ),
    );
  }

  static const double headerIconSize = 28.0;

  Widget _buildActivityHeader(
      {required String text, required IconData iconData}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Utils.buildText(text: text),
        Icon(
          iconData,
          size: headerIconSize,
          color: ColorTheme.contrastColor,
        ),
      ],
    );
  }

  Widget _buildActivityItem({required String value, String unit = ''}) {
    if (SkiTracker.getActivity().isActive) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Utils.buildText(
              text: value,
              fontSize: FontTheme.sizeSubHeader,
              fontWeight: FontWeight.bold),
          if (SkiTracker.getActivity().isActive) const SizedBox(width: 4),
          if (SkiTracker.getActivity().isActive)
            Utils.buildText(
                text: unit, fontWeight: FontWeight.bold, caps: false),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildActivitySubItem(
      {required String text,
      required String value,
      String unit = '',
      fontSize = FontTheme.size}) {
    if (SkiTracker.getActivity().isActive) {
      return Row(
        children: [
          Utils.buildText(text: text, fontSize: fontSize),
          const Spacer(),
          Utils.buildText(
              text: value, fontSize: fontSize, fontWeight: FontWeight.bold),
          if (SkiTracker.getActivity().isActive) const SizedBox(width: 2),
          if (SkiTracker.getActivity().isActive)
            Utils.buildText(
                text: unit, fontWeight: FontWeight.bold, caps: false),
          const SizedBox(width: 4),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    SkiTracker.getActivity().infoMounted = false;
    _timer.cancel();
    super.dispose();
  }
}
