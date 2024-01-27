import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../activity/data.dart';
import '../activity/database.dart';
import '../activity/map.dart';
import '../activity/route.dart';
import '../theme.dart';
import '../utils/app_bar.dart';
import '../utils/general_utils.dart';
import 'activity_page.dart';
import 'history.dart';

/// A stateful widget for displaying a summary dialog of an activity.
class SummaryDialog extends StatefulWidget {
  const SummaryDialog({super.key, required this.activityDatabase});

  final ActivityDatabase activityDatabase;

  @override
  State<SummaryDialog> createState() => _SummaryDialogState();
}

class _SummaryDialogState extends State<SummaryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CustomMaterialAppBar.appBar(title: 'Summary'),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: ColorTheme.background,
              ),
              child: ActivitySummary(
                activityDatabase: widget.activityDatabase,
                small: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A stateless widget for displaying a summary page of an activity.
class SummaryPage extends StatelessWidget {
  const SummaryPage({
    super.key,
    required this.activityDatabase,
    required this.historyState,
  });

  final HistoryState historyState;
  final ActivityDatabase activityDatabase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMaterialAppBar.appBar(
        title: 'Summary,',
        child: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                History.showDeleteConfirmationDialog(
                  context,
                  activityDatabase,
                  () {
                    Navigator.pop(context);
                    historyState.update();
                  },
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                height: 40,
                value: 'delete',
                child: Utils.buildText(text: 'Delete', caps: false),
              ),
              // Add more PopupMenuItems if needed
            ];
          },
        ),
      ),
      body: ActivitySummary(activityDatabase: activityDatabase),
    );
  }
}

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

  late final List<List<int>> dataAltitudes;
  late final List<List<double>> dataSpeeds;

  late final ActivityRoute route;

  late final ActivityMap _activityMap;

  late final double minus = widget.small ? 4 : 0;

  final double verticalPadding = 8.0;

  @override
  void initState() {
    super.initState();
    dataAltitudes = parseStringToListListInt(widget.activityDatabase.altitudes);
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
                  decoration: const BoxDecoration(
                    color: ColorTheme.secondary,
                    borderRadius: BorderRadius.only(
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
                            CurrentSlope(
                                slope: route.slopes[index], size: 32 - minus),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ActivityPage.buildSlopeName(route.slopes[index],
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
                          const Icon(LogoTheme.gps,
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
                                              '${widget.activityDatabase.elapsedTime.substring(0, 4)} ${Info.unitTime}',
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
                  title: 'Speed',
                  unit: Info.unitSpeed,
                  value1: (widget.activityDatabase.maxSpeed * Info.speedFactor)
                      .toStringAsFixed(1),
                  titleValue1: 'Max',
                  value2:
                      (widget.activityDatabase.averageSpeed * Info.speedFactor)
                          .toStringAsFixed(1),
                  titleValue2: 'Avg'),
              _buildActivityDisplay(
                  icon: LogoTheme.slope,
                  title: 'Slope',
                  unit: Info.unitSlope,
                  value1: widget.activityDatabase.maxSlope.toStringAsFixed(1),
                  titleValue1: 'Max',
                  value3: widget.activityDatabase.avgSlope.toStringAsFixed(1),
                  titleValue3: 'Avg'),
            ],
          ),
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          Row(
            children: [
              _buildActivityDisplay(
                  icon: LogoTheme.altitude,
                  title: 'Altitude',
                  unit: Info.unitAltitude,
                  value1: (widget.activityDatabase.maxAltitude *
                          Info.altitudeFactor)
                      .round()
                      .toString(),
                  titleValue1: 'Max',
                  value2: (widget.activityDatabase.minAltitude *
                          Info.altitudeFactor)
                      .round()
                      .toString(),
                  titleValue2: 'Min',
                  value3: (widget.activityDatabase.avgAltitude *
                          Info.altitudeFactor)
                      .round()
                      .toString(),
                  titleValue3: 'Avg'),
              _buildActivityDisplay(
                  icon: LogoTheme.distance,
                  title: 'Distance',
                  unit: Info.unitDistance,
                  value1: (widget.activityDatabase.distance *
                          Info.distanceFactor /
                          1000)
                      .toStringAsFixed(1),
                  titleValue1: 'Total',
                  value2: (widget.activityDatabase.distanceDownhill *
                          Info.distanceFactor /
                          1000)
                      .toStringAsFixed(1),
                  titleValue2: 'Downhill',
                  value3: (widget.activityDatabase.distanceUphill *
                          Info.distanceFactor /
                          1000)
                      .toStringAsFixed(1),
                  titleValue3: 'Uphill'),
            ],
          ),
          SizedBox(
            height: verticalPadding - minus / 2,
          ),
          Graph(dataAltitudes: dataAltitudes, dataSpeeds: dataSpeeds, small: true,),
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
          Utils.buildText(
              text: title,
              fontSize: FontTheme.size - minus,
              color: ColorTheme.grey),
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
                Utils.buildText(
                    text: title,
                    fontSize: FontTheme.sizeSubHeader - minus * 2,
                    color: ColorTheme.grey,
                    fontWeight: FontWeight.bold),
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

  Widget _buildContainer(
      {required Widget child, EdgeInsets padding = Info.padding}) {
    return Container(
      padding: padding / 2 - EdgeInsets.all(minus / 2),
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

class ImageFile extends StatefulWidget {
  const ImageFile({super.key, this.small = false});

  final bool small;

  @override
  State<ImageFile> createState() => _ImageFileState();
}

class _ImageFileState extends State<ImageFile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: widget.small ? 90 : 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorTheme.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_rounded,
                color: ColorTheme.secondary,
                size: widget.small ? 36 : 48,
              ),
              Utils.buildText(
                  text: 'Add a photo',
                  color: ColorTheme.secondary,
                  fontSize: FontTheme.size),
            ],
          ),
        ),
      ),
    );
  }
}
