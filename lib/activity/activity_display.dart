import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ski_tracker/activity/activity.dart';
import 'package:ski_tracker/activity/activity_bar.dart';

import '../main.dart';
import '../utils.dart';
import 'activity_data_provider.dart';

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
  @override
  void initState() {
    super.initState();
  }

  static const double horizontalSpaceMiddle = 8;
  static const double horizontalSpaceLeft = 16;
  static const double horizontalSpaceRight = 16;

  static const double verticalSpace = 8;

  static const String unitSpeed = 'km/h';
  static const String unitDistance = 'km';
  static const String unitAltitude = 'm';
  static const String unitSlope = '%';
  static const String unitTime = 's';

  static const double speedFactor = 3.6;

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
    return Expanded(
      child: _buildActivityContainer(
        height: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildActivityHeader(
                text: 'GPS', iconData: Icons.gps_fixed_rounded),
            const SizedBox(height: 12),
            Stack(
              children: [
                const Icon(
                  Icons.signal_cellular_alt_rounded,
                  size: 48,
                  color: Colors.grey,
                ),
                if (activityData.gpsAccuracy == GpsAccuracy.high)
                  const Icon(
                    Icons.signal_cellular_alt_rounded,
                    size: 48,
                    color: Colors.green,
                  ),
                if (activityData.gpsAccuracy == GpsAccuracy.medium)
                  const Icon(
                    Icons.signal_cellular_alt_2_bar_rounded,
                    size: 48,
                    color: Colors.yellow,
                  ),
                if (activityData.gpsAccuracy == GpsAccuracy.low)
                  const Icon(
                    Icons.signal_cellular_alt_1_bar_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _time(ActivityDataProvider activityData) {
    return Expanded(
      child: _buildActivityContainer(
        height: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(text: 'Time', iconData: Icons.timer_rounded),
            const SizedBox(height: 8),
            _buildActivitySubItem(
                text: 'Pause',
                fontSize: 12.0,
                value: activityData.elapsedPauseTime.toString().substring(0, 7),
                unit: unitTime),
            _buildActivitySubItem(
                text: 'Uphill',
                fontSize: 12.0,
                value:
                    activityData.elapsedUphillTime.toString().substring(0, 7),
                unit: unitTime),
            _buildActivitySubItem(
                text: 'Downhill',
                fontSize: 12.0,
                value:
                    activityData.elapsedDownhillTime.toString().substring(0, 7),
                unit: unitTime),
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
                value: (activityData.totalDistance / 1000).toStringAsFixed(1),
                unit: unitDistance),
            _buildActivitySubItem(
                text: 'Downhill',
                value:
                    (activityData.downhillDistance / 1000).toStringAsFixed(1),
                unit: unitDistance),
            _buildActivitySubItem(
                text: 'Uphill',
                value: (activityData.uphillDistance / 1000).toStringAsFixed(1),
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

  Widget _buildActivityContainer({required Widget child, double height = 140}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: SkiTracker.getActivity().isActive ? height : 56,
      padding: const EdgeInsets.all(8.0),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          child,
        ],
      ),
    );
  }

  Widget _buildActivityHeader(
      {required String text, required IconData iconData}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Utils.buildText(text: text),
        Icon(
          iconData,
          size: 28,
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
            Utils.buildText(text: unit, fontWeight: FontWeight.bold),
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
            Utils.buildText(text: unit, fontWeight: FontWeight.bold),
          const SizedBox(width: 4),
        ],
      );
    } else {
      return Container();
    }
  }
}
