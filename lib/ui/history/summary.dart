import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:powder_pilot/activity/data_provider.dart';
import 'package:powder_pilot/ui/widgets/single_graph.dart';

import '../../activity/data.dart';
import '../../activity/database.dart';
import '../../activity/route.dart';
import '../../string_pool.dart';
import '../../theme/color.dart';
import '../../theme/font.dart';
import '../../theme/icon.dart';
import '../../theme/measurement.dart';
import '../../theme/widget.dart';
import '../../utils/general_utils.dart';
import '../activity/info/info.dart';
import '../activity/info/widgets/category.dart';
import '../activity/info/widgets/elapsed_time.dart';
import '../activity/info/widgets/run.dart';
import '../map/map.dart';
import '../widgets/slope_circle.dart';

/// A stateful widget for displaying the summary of an activity.
class ActivitySummary extends StatefulWidget {
  const ActivitySummary({
    super.key,
    required this.activityDatabase,
    this.small = false,
  });

  static const iconSize = 32.0;

  final bool small;
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
  late List<String> totalParts = widget.activityDatabase.elapsedTime.split(':');

  late final List<List<double>> dataAltitudes;
  late final List<List<double>> dataSpeeds;

  late final ActivityRoute route;

  late final ActivityMap _activityMap;

  late final double minus = widget.small ? 4 : 0;

  final double verticalPadding = 8.0;

  final ActivityDataProvider runs = ActivityDataProvider();

  @override
  void initState() {
    super.initState();
    dataAltitudes =
        parseStringToListListDouble(widget.activityDatabase.altitudes);
    dataSpeeds = parseStringToListListDouble(widget.activityDatabase.speeds);
    route = ActivityRoute.stringToRoute(widget.activityDatabase.route);
    List<double> startLocation =
        parseStringToDoubleList(widget.activityDatabase.startLocation);
    List<double> endLocation =
        parseStringToDoubleList(widget.activityDatabase.endLocation);
    final List<double> fastestLocation =
        parseStringToDoubleList(widget.activityDatabase.speedLocation);
    _activityMap = ActivityMap(
      route: route,
      staticMap: true,
      activityLocations: ActivityLocations(
        fastestLocation: fastestLocation,
        startLocation: startLocation,
        endLocation: endLocation,
      ),
    );
    ActivityDistance activityDistance = ActivityDistance();
    if (widget.activityDatabase.distances != null) {
      activityDistance.setDistances(
          parseStringToListListDouble(widget.activityDatabase.distances!));
    }
    runs.updateSummary(
        newRuns: ActivityRun(
          longestRun: widget.activityDatabase.longestRun,
          totalRuns: widget.activityDatabase.totalRuns,
        ),
        newDistance: activityDistance);
  }

  List<double> parseStringToDoubleList(String doubleListString) {
    // Remove square brackets and split the string into individual double strings
    List<String> doubleStrings =
        doubleListString.replaceAll('[', '').replaceAll(']', '').split(', ');

    // Parse each string into a double and create a list of doubles
    List<double> doubleList =
        doubleStrings.map((string) => double.parse(string)).toList();

    return doubleList;
  }

  LatLng parseStringToLatLng(String coordinateString) {
    // Remove square brackets and split the string into longitude and latitude
    List<String> coordinates =
        coordinateString.replaceAll('[', '').replaceAll(']', '').split(', ');

    // Parse the strings into doubles
    double longitude = double.parse(coordinates[0]);
    double latitude = double.parse(coordinates[1]);

    // Create a LatLng object
    LatLng latLng = LatLng(latitude, longitude);

    return latLng;
  }

  List<List<int>> parseStringToListListInt(String stringRepresentation) {
    // Remove square brackets at the beginning and end of the string
    if (stringRepresentation.length < 6) {
      return [];
    }
    String cleanedString =
        stringRepresentation.substring(2, stringRepresentation.length - 2);

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
    if (stringRepresentation.length < 6) {
      return [];
    }
    String cleanedString =
        stringRepresentation.substring(2, stringRepresentation.length - 2);

    // Split the string by '], [' to get individual lists
    List<String> listStrings = cleanedString.split('], [');

    // Convert each string representation of a list to a List<double>
    List<List<double>> resultList = listStrings.map((listString) {
      List<String> values = listString.split(', ');
      return values.map((value) => double.parse(value)).toList();
    }).toList();

    return resultList;
  }

  Widget _map() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPageSummary(
              route: route,
              activityMap: _activityMap,
            ),
            settings: const RouteSettings(
                name:
                    '/fullscreenSummary'), // Setzen Sie hier den gewünschten Routennamen
          ),
        );
      },
      child: Container(
        height: widget.small ? 120 : 160,
        padding: Info.padding / 2,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorTheme.secondary,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16.0),
                      bottomLeft: const Radius.circular(16.0),
                      topRight:
                          Radius.circular(route.slopes.isEmpty ? 16.0 : 0.0),
                      bottomRight:
                          Radius.circular(route.slopes.isEmpty ? 16.0 : 0.0)),
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16.0),
                      bottomLeft: const Radius.circular(16.0),
                      topRight:
                          Radius.circular(route.slopes.isEmpty ? 16.0 : 0.0),
                      bottomRight:
                          Radius.circular(route.slopes.isEmpty ? 16.0 : 0.0)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _activityMap,
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              ColorTheme.secondary.withOpacity(0.6),
                              ColorTheme.secondary.withOpacity(0.9)
                            ],
                            stops: const [0.0, 0.8, 1.0],
                            center: Alignment.center,
                            radius: route.slopes.isEmpty
                                ? 1.5
                                : 1.2, // Radius steuert die Größe des Gradients
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (route.slopes.isNotEmpty)
              Expanded(
                flex: 1,
                child: Container(
                  height: widget.small ? 120 : 160,
                  decoration: BoxDecoration(
                    color: ColorTheme.secondary,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0)),
                  ),
                  alignment: Alignment.topLeft,
                  child: ListView.builder(
                    controller: ScrollController(),
                    shrinkWrap: true,
                    itemCount: route.slopes.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorTheme.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SlopeCircle(
                                slope: route.slopes[index], size: 32 - minus),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SlopeCircle.buildSlopeName(
                                    slope: route.slopes[index],
                                    size: FontTheme.size - minus),
                                Utils.buildText(
                                    text: Utils.durationStringToString(route
                                        .slopes[index].startTime
                                        .toString())[1],
                                    caps: false,
                                    fontSize: FontTheme.size - 4 - minus / 2,
                                    color: ColorTheme.grey),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
                          Icon(LogoTheme.gps,
                              color: ColorTheme.primary,
                              size: ActivitySummary.iconSize),
                          const SizedBox(width: 4.0),
                          Utils.buildText(
                              text: widget.activityDatabase.areaName == ''
                                  ? StringPool.UNKNOWN_AREA
                                  : widget.activityDatabase.areaName,
                              fontSize: FontTheme.size,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.primary),
                        ],
                      ),
                      SizedBox(
                        height: verticalPadding - minus * 2,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Utils.buildText(
                                          text: Utils.durationStringToString(
                                              widget.activityDatabase
                                                  .startTime)[0],
                                          fontSize:
                                              FontTheme.sizeSubHeader - minus,
                                          fontWeight: FontWeight.bold),
                                      Utils.buildText(
                                          text: ' / ',
                                          fontSize:
                                              FontTheme.sizeSubHeader - minus,
                                          fontWeight: FontWeight.bold),
                                      Utils.buildText(
                                          text:
                                              '${widget.activityDatabase.elapsedTime.substring(0, 4)} ${Measurement.unitTime}',
                                          fontSize: FontTheme.size - minus,
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
                                      fontSize: FontTheme.size - minus,
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
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          _map(),
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          Row(
            children: [
              _buildActivityDisplay(
                icon: LogoTheme.speed,
                title: StringPool.SPEED,
                unit: Measurement.unitSpeed,
                value1:
                    (widget.activityDatabase.maxSpeed * Measurement.speedFactor)
                        .toStringAsFixed(1),
                titleValue1: StringPool.MAX,
                value2: (widget.activityDatabase.averageSpeed *
                        Measurement.speedFactor)
                    .toStringAsFixed(1),
                titleValue2: StringPool.AVERAGE,
              ),
              _buildActivityDisplay(
                icon: LogoTheme.slope,
                title: StringPool.DOWNWARD_SLOPE,
                unit: Measurement.unitSlope,
                value1: widget.activityDatabase.maxSlope.toStringAsFixed(1),
                titleValue1: StringPool.MAX,
                value3: widget.activityDatabase.avgSlope.toStringAsFixed(1),
                titleValue3: StringPool.AVERAGE,
              ),
            ],
          ),
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          Row(
            children: [
              _buildActivityDisplay(
                icon: LogoTheme.altitude,
                title: StringPool.ALTITUDE,
                unit: Measurement.unitAltitude,
                value1: (widget.activityDatabase.maxAltitude *
                        Measurement.altitudeFactor)
                    .round()
                    .toString(),
                titleValue1: StringPool.MAX,
                value2: (widget.activityDatabase.minAltitude *
                        Measurement.altitudeFactor)
                    .round()
                    .toString(),
                titleValue2: StringPool.MIN,
                value3: (widget.activityDatabase.avgAltitude *
                        Measurement.altitudeFactor)
                    .round()
                    .toString(),
                titleValue3: StringPool.AVERAGE,
              ),
              _buildActivityDisplay(
                icon: LogoTheme.distance,
                title: StringPool.DISTANCE,
                unit: Measurement.unitDistance,
                value1: (widget.activityDatabase.distance *
                        Measurement.distanceFactor /
                        1000)
                    .toStringAsFixed(1),
                titleValue1: StringPool.TOTAL,
                value2: (widget.activityDatabase.distanceDownhill *
                        Measurement.distanceFactor /
                        1000)
                    .toStringAsFixed(1),
                titleValue2: StringPool.DOWNHILL,
                value3: (widget.activityDatabase.distanceUphill *
                        Measurement.distanceFactor /
                        1000)
                    .toStringAsFixed(1),
                titleValue3: StringPool.UPHILL,
              ),
            ],
          ),
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          Padding(
            padding: Category.paddingOutside / 2 - EdgeInsets.all(minus / 2),
            child: WidgetTheme.container(
                child: Column(
              children: [
                _buildHeader(
                  title: StringPool.SPEED,
                  icon: LogoTheme.speed,
                  color: ColorTheme.primary,
                ),
                SingleGraph(
                  data: dataSpeeds,
                  factor: Measurement.speedFactor,
                  unit: Measurement.unitSpeed,
                  color: ColorTheme.primary,
                ),
                SizedBox(
                  height: verticalPadding * 2 - minus / 2,
                ),
                _buildHeader(
                  title: StringPool.ALTITUDE,
                  icon: LogoTheme.altitude,
                  color: ColorTheme.contrast,
                ),
                SingleGraph(
                  data: dataAltitudes,
                  factor: Measurement.altitudeFactor,
                  unit: Measurement.unitAltitude,
                  color: ColorTheme.contrast,
                ),
                SizedBox(
                  height: verticalPadding - minus / 2,
                ),
              ],
            )),
          ),
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          Container(
            color: ColorTheme.background,
            padding: Category.paddingOutside / 2 - EdgeInsets.all(minus / 2),
            height: 264,
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
                  totalTime: Duration(
                      hours: int.parse(totalParts[0]),
                      minutes: int.parse(totalParts[1]),
                      seconds: double.parse(totalParts[2]).toInt()),
                  summary: true,
                ),
                SizedBox(width: 16.0 - minus / 2),
                Expanded(
                  child: Run(
                    dataProvider: runs,
                    summary: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: verticalPadding - minus / 2,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Utils.buildText(
              text: title,
              fontSize: FontTheme.size - minus,
              color: ColorTheme.grey,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Utils.buildText(
                  text: value,
                  fontSize: FontTheme.size - minus,
                  color: ColorTheme.contrast,
                  fontWeight: FontWeight.bold),
              const SizedBox(width: 4),
              Utils.buildText(
                  text: unit,
                  fontSize: FontTheme.size - minus,
                  color: ColorTheme.contrast,
                  fontWeight: FontWeight.bold,
                  caps: false),
            ],
          )
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
                  width: Info.iconSize - 8 - minus * 2,
                  height: Info.iconSize - 8 - minus * 2,
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
                Flexible(
                  child: Utils.buildText(
                    text: title,
                    fontSize: widget.small
                        ? FontTheme.sizeSubHeader - minus * 2
                        : FontTheme.sizeSubHeader - 4,
                    color: ColorTheme.grey,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: verticalPadding - minus / 2,
            ),
            if (value1 != '') const SizedBox(height: 8),
            if (value1 != '') buildValue(value: value1, title: titleValue1),
            if (value2 != '') const SizedBox(height: 8),
            if (value2 != '') buildValue(value: value2, title: titleValue2),
            if (value3 != '') const SizedBox(height: 8),
            if (value3 != '') buildValue(value: value3, title: titleValue3),
            SizedBox(
              height: verticalPadding - minus / 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Build the header of the graph
  ///
  /// @param title The title of the header
  /// @param icon The icon of the header
  /// @param color The color of the header
  /// @param mirrored Flag to mirror the elements of the row
  Widget _buildHeader(
      {required String title,
      required IconData icon,
      required Color color,
      bool mirrored = false}) {
    Widget buildIcon() {
      return Icon(
        icon,
        size: widget.small ? Info.iconSize - 12 : Info.iconSize - 8,
        color: color,
      );
    }

    return Row(
      children: [
        if (!mirrored) buildIcon(),
        if (!mirrored) const SizedBox(width: 8),
        Utils.buildText(
          text: title,
          fontSize: widget.small ? FontTheme.size - 2 : FontTheme.size,
          color: ColorTheme.grey,
          fontWeight: FontWeight.bold,
        ),
        if (mirrored) const SizedBox(width: 8),
        if (mirrored) buildIcon(),
      ],
    );
  }

  Widget _buildContainer(
      {required Widget child, EdgeInsets padding = Info.padding}) {
    return Container(
      padding: padding / 2 - EdgeInsets.all(minus / 2),
      child: WidgetTheme.container(
        child: child,
      ),
    );
  }
}
