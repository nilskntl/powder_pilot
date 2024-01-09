import 'package:flutter/material.dart';
import 'package:ski_tracker/main.dart';
import 'package:ski_tracker/utils/custom_app_bar.dart';

import '../utils/activity_database.dart';
import '../utils/general_utils.dart';
import 'activity_display.dart';

class ActivitySummaryPage extends StatelessWidget {
  const ActivitySummaryPage({super.key, required this.activityDatabase});

  final ActivityDatabase activityDatabase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarDesign.appBar(title: 'Summary'),
      body: ActivitySummary(activityDatabase: activityDatabase),
    );
  }
}

class ActivitySummary extends StatefulWidget {
  const ActivitySummary({super.key, required this.activityDatabase});

  static const iconSize = 32.0;

  final ActivityDatabase activityDatabase;

  @override
  State<ActivitySummary> createState() => _ActivitySummaryState();
}

class _ActivitySummaryState extends State<ActivitySummary> {
  late List<String> uphillParts =
      widget.activityDatabase.elapsedUphillTime.split(':');
  late List<String> downhillParts =
      widget.activityDatabase.elapsedDownhillTime.split(':');
  late List<String> pauseParts =
      widget.activityDatabase.elapsedPauseTime.split(':');

  late final List<List<int>> dataAltitudes;
  late final List<List<double>> dataSpeeds;

  @override
  void initState() {
    super.initState();
    dataAltitudes = parseStringToListListInt(widget.activityDatabase.altitudes);
    dataSpeeds = parseStringToListListDouble(widget.activityDatabase.speeds);
  }

  List<List<int>> parseStringToListListInt(String stringRepresentation) {
    // Remove square brackets at the beginning and end of the string
    String cleanedString = stringRepresentation.substring(2, stringRepresentation.length - 2);

    // Split the string by '], [' to get individual lists
    List<String> listStrings = cleanedString.split('], [');

    // Convert each string representation of a list to a List<int>
    List<List<int>> resultList = listStrings.map((listString) {
      List<String> values = listString.split(', ');
      return values.map((value) => int.parse(value)).toList();
    }).toList();

    return resultList;
  }

  List<List<double>> parseStringToListListDouble(String stringRepresentation) {
    // Remove square brackets at the beginning and end of the string
    String cleanedString = stringRepresentation.substring(2, stringRepresentation.length - 2);

    // Split the string by '], [' to get individual lists
    List<String> listStrings = cleanedString.split('], [');

    // Convert each string representation of a list to a List<double>
    List<List<double>> resultList = listStrings.map((listString) {
      List<String> values = listString.split(', ');
      return values.map((value) => double.parse(value)).toList();
    }).toList();

    return resultList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorTheme.background,
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: Info.padding / 2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: ColorTheme.primary,
                              size: ActivitySummary.iconSize),
                          const SizedBox(width: 4.0),
                          Utils.buildText(
                              text: widget.activityDatabase.areaName == ''
                                  ? 'Unknown'
                                  : widget.activityDatabase.areaName,
                              fontSize: FontTheme.size,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.primary),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ColorTheme.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                /*
                        child: Image.asset(
                          'assets/images/background.png',
                          fit: BoxFit.cover,
                        ),

                         */
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt_rounded,
                                      color: ColorTheme.secondary,
                                      size: 64,
                                    ),
                                    Utils.buildText(
                                        text: 'Add a photo',
                                        color: ColorTheme.secondary,
                                        fontSize: FontTheme.size),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Utils.buildText(
                                          text: Utils.durationStringToString(
                                              widget.activityDatabase
                                                  .startTime)[0],
                                          fontSize: FontTheme.sizeSubHeader,
                                          fontWeight: FontWeight.bold),
                                      Utils.buildText(
                                          text: ' / ',
                                          fontSize: FontTheme.sizeSubHeader,
                                          fontWeight: FontWeight.bold),
                                      Utils.buildText(
                                          text:
                                              '${widget.activityDatabase.elapsedTime.substring(0, 4)} ${Info.unitTime}',
                                          fontSize: FontTheme.size,
                                          fontWeight: FontWeight.bold,
                                          caps: false),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  Utils.buildText(
                                      text:
                                          '${Utils.durationStringToString(widget.activityDatabase.startTime)[1]}-${Utils.durationStringToString(widget.activityDatabase.endTime)[1]}',
                                      color: ColorTheme.grey,
                                      caps: false),
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          Container(
            padding: Info.padding / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElapsedTime(
                  uphillTime: Duration(
                      hours: int.parse(uphillParts[0]),
                      minutes: int.parse(uphillParts[1]),
                      seconds: double.parse(uphillParts[2]).toInt()),
                  downhillTime: Duration(
                      hours: int.parse(downhillParts[0]),
                      minutes: int.parse(downhillParts[1]),
                      seconds: double.parse(downhillParts[2]).toInt()),
                  pauseTime: Duration(
                      hours: int.parse(pauseParts[0]),
                      minutes: int.parse(pauseParts[1]),
                      seconds: double.parse(pauseParts[2]).toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              _buildActivityDisplay(
                  icon: Icons.speed_rounded,
                  title: 'Speed',
                  unit: Info.unitSpeed,
                  value1: widget.activityDatabase.maxSpeed.toStringAsFixed(1),
                  titleValue1: 'Max',
                  value2:
                      widget.activityDatabase.averageSpeed.toStringAsFixed(1),
                  titleValue2: 'Avg'),
              _buildActivityDisplay(
                  icon: Icons.line_axis_rounded,
                  title: 'Slope',
                  unit: Info.unitSlope,
                  value1: widget.activityDatabase.maxSlope.toStringAsFixed(1),
                  titleValue1: 'Max',
                  value3: widget.activityDatabase.avgSlope.toStringAsFixed(1),
                  titleValue3: 'Avg'),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              _buildActivityDisplay(
                  icon: Icons.height_rounded,
                  title: 'Altitude',
                  unit: Info.unitAltitude,
                  value1:
                      widget.activityDatabase.maxAltitude.round().toString(),
                  titleValue1: 'Max',
                  value2:
                      widget.activityDatabase.minAltitude.round().toString(),
                  titleValue2: 'Min',
                  value3:
                      widget.activityDatabase.avgAltitude.round().toString(),
                  titleValue3: 'Avg'),
              _buildActivityDisplay(
                  icon: Icons.directions_walk_rounded,
                  title: 'Distance',
                  unit: Info.unitDistance,
                  value1: widget.activityDatabase.distance.toStringAsFixed(1),
                  titleValue1: 'Total',
                  value2: widget.activityDatabase.distanceDownhill
                      .toStringAsFixed(1),
                  titleValue2: 'Downhill',
                  value3:
                      widget.activityDatabase.distanceUphill.toStringAsFixed(1),
                  titleValue3: 'Uphill'),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          Graph(dataAltitudes: dataAltitudes, dataSpeeds: dataSpeeds),
          const SizedBox(
            height: 8.0,
          ),
          const SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDisplay(
      {required IconData icon,
      required String title,
      required String unit,
      String value1 = '',
      String value2 = '',
      String value3 = '',
      String titleValue1 = '',
      String titleValue2 = '',
      String titleValue3 = '',
      EdgeInsets padding = Info.padding}) {
    Widget buildValue({required String value, required String title}) {
      return Row(
        children: [
          Container(
            width: 80,
            alignment: Alignment.centerLeft,
            child: Utils.buildText(
                text: title, fontSize: FontTheme.size, color: ColorTheme.grey),
          ),
          const SizedBox(width: 4),
          Utils.buildText(
              text: value,
              fontSize: FontTheme.size,
              color: ColorTheme.contrast,
              fontWeight: FontWeight.bold),
          const SizedBox(width: 4),
          Utils.buildText(
              text: unit,
              fontSize: FontTheme.size,
              color: ColorTheme.contrast,
              fontWeight: FontWeight.bold,
              caps: false),
        ],
      );
    }

    return Expanded(
      child: _buildContainer(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: Info.iconSize - 8,
                  height: Info.iconSize - 8,
                  decoration: BoxDecoration(
                    color: ColorTheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    size: Info.iconSize - 24,
                    color: ColorTheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Utils.buildText(
                    text: title,
                    fontSize: FontTheme.sizeSubHeader,
                    color: ColorTheme.grey,
                    fontWeight: FontWeight.bold),
              ],
            ),
            const SizedBox(height: 8),
            if (value1 != '') const SizedBox(height: 8),
            if (value1 != '') buildValue(value: value1, title: titleValue1),
            if (value2 != '') const SizedBox(height: 8),
            if (value2 != '') buildValue(value: value2, title: titleValue2),
            if (value3 != '') const SizedBox(height: 8),
            if (value3 != '') buildValue(value: value3, title: titleValue3),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(
      {required Widget child, EdgeInsets padding = Info.padding}) {
    return Container(
      padding: padding / 2,
      child: Container(
        padding: Info.padding,
        decoration: const BoxDecoration(
          color: ColorTheme.secondary,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: child,
      ),
    );
  }
}
