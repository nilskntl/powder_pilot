import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utils.dart';
import 'activity.dart';

class ActivityInfo extends StatefulWidget {
  const ActivityInfo({super.key});

  @override
  State<ActivityInfo> createState() => ActivityInfoState();
}

class ActivityInfoState extends State<ActivityInfo> {
  @override
  void initState() {
    super.initState();
  }

  static const double horizontalSpaceMiddle = 8;
  static const double horizontalSpaceLeft = 16;
  static const double horizontalSpaceRight = 16;

  static const double verticalSpace = 8;

  static const String placeholder = '-.-';

  static const String unitSpeed = 'km/h';
  static const String unitDistance = 'km';
  static const String unitAltitude = 'm';
  static const String unitVertical = 'm';
  static const String unitSlope = '%';

  @override
  Widget build(BuildContext context) {
    ActivityData activityData = Provider.of<ActivityData>(context);
    SkiTracker.setActivityData(activityData);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: horizontalSpaceLeft),
            _speed(activityData),
            const SizedBox(width: horizontalSpaceMiddle),
            _distance(activityData),
            const SizedBox(width: horizontalSpaceRight),
          ],
        ),
        const SizedBox(height: verticalSpace),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: horizontalSpaceLeft),
            _altitude(activityData),
            const SizedBox(width: horizontalSpaceMiddle),
            _vertical(activityData),
            const SizedBox(width: horizontalSpaceRight),
          ],
        ),
        const SizedBox(height: verticalSpace),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: horizontalSpaceLeft),
            _slope(activityData),
            const SizedBox(width: horizontalSpaceMiddle),
            Expanded(child: Container(height: 12)),
            const SizedBox(width: horizontalSpaceRight),
          ],
        ),
      ],
    );
  }

  Widget _speed(ActivityData activityData) {
    return Expanded(
      child: _buildActivityContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(text: 'Speed', iconData: Icons.speed_rounded),
            const SizedBox(height: 8),
            _buildActivityItem(
                value: (activityData.speed).toStringAsFixed(1),
                unit: unitSpeed),
            _buildActivitySubItem(
                text: 'Max',
                value: activityData.maxSpeed.toStringAsFixed(1),
                unit: unitSpeed),
            _buildActivitySubItem(
                text: 'Avg',
                value: activityData.avgSpeed.toStringAsFixed(1),
                unit: unitSpeed),
          ],
        ),
      ),
    );
  }

  Widget _distance(ActivityData activityData) {
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

  Widget _altitude(ActivityData activityData) {
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

  Widget _vertical(ActivityData activityData) {
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

  Widget _slope(ActivityData activityData) {
    return Expanded(
      child: _buildActivityContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(
                text: 'Slope', iconData: Icons.line_axis_rounded),
            const SizedBox(height: 8),
            _buildActivityItem(
                value: activityData.slope.toStringAsFixed(1), unit: unitSlope),
            _buildActivitySubItem(
                text: 'Max',
                value: activityData.maxSlope.toStringAsFixed(1),
                unit: unitSlope),
            _buildActivitySubItem(
                text: 'Avg',
                value: activityData.avgSlope.toStringAsFixed(1),
                unit: unitSlope),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: child,
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
          size: 32,
          color: ColorTheme.contrastColor,
        ),
      ],
    );
  }

  Widget _buildActivityItem({required String value, String unit = ''}) {
    ActivityData activityData = SkiTracker.getActivityData();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Utils.buildText(
            text: activityData.running ? value : placeholder,
            fontSize: FontTheme.sizeSubHeader,
            fontWeight: FontWeight.bold),
        if (activityData.running) const SizedBox(width: 4),
        if (activityData.running)
          Utils.buildText(text: unit, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildActivitySubItem(
      {required String text, required String value, String unit = ''}) {
    ActivityData activityData = SkiTracker.getActivityData();
    return Row(
      children: [
        Utils.buildText(text: text),
        const Spacer(),
        Utils.buildText(
            text: activityData.running ? value : placeholder,
            fontWeight: FontWeight.bold),
        if (activityData.running) const SizedBox(width: 2),
        if (activityData.running)
          Utils.buildText(text: unit, fontWeight: FontWeight.bold),
        const SizedBox(width: 4),
      ],
    );
  }
}
