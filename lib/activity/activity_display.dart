import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ski_tracker/activity/activity.dart';

import '../main.dart';
import '../utils/general_utils.dart';
import 'activity_data_provider.dart';
import 'activity_map.dart';

class ActivityDisplay extends StatefulWidget {
  const ActivityDisplay({super.key});

  static const Duration animationDuration = Duration(milliseconds: 500);
  static const double expandedHeight = 200.0;

  @override
  State<ActivityDisplay> createState() => _ActivityDisplayState();
}

class _ActivityDisplayState extends State<ActivityDisplay> {
  late final ScrollController _scrollController;
  bool _scrollControllerInitialized = false;

  @override
  Widget build(BuildContext context) {
    ActivityDataProvider activityDataProvider =
        Provider.of<ActivityDataProvider>(context);
    SkiTracker.setActivityDataProvider(activityDataProvider);

    // Check if scroll controller is initialized
    if (!_scrollControllerInitialized) {
      // Check if activity is running
      _scrollController = activityDataProvider.status != ActivityStatus.inactive
          ? ScrollController(
              initialScrollOffset: MediaQuery.sizeOf(context).height - 420)
          : ScrollController();
      _scrollControllerInitialized = true;
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
            // Set color to transparent
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            collapsedHeight: MediaQuery.of(context).size.height - 235,
            forceMaterialTransparency: true,
            pinned: true,
            flexibleSpace: const Stack(
              children: [],
            )),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    height:
                        activityDataProvider.status != ActivityStatus.inactive
                            ? 650
                            : 0,
                    decoration: const BoxDecoration(
                      color: ColorTheme.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Status.heightBarContainer),
                        topRight: Radius.circular(Status.heightBarContainer),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Status(
                          activityDataProvider: activityDataProvider,
                          scrollController: _scrollController),
                      if (activityDataProvider.status ==
                              ActivityStatus.running ||
                          activityDataProvider.status == ActivityStatus.paused)
                        Info(activityDataProvider: activityDataProvider),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(color: ColorTheme.background),
        ),
      ],
    );
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    super.dispose();
  }
}

class BlinkingGps extends StatefulWidget {
  const BlinkingGps({super.key, required this.activityDataProvider});

  final ActivityDataProvider activityDataProvider;

  @override
  State<BlinkingGps> createState() => _BlinkingGpsState();
}

class _BlinkingGpsState extends State<BlinkingGps> {
  bool transparent = false;

  void update() {
    setState(() {
      widget.activityDataProvider.status != ActivityStatus.inactive
          ? transparent = !transparent
          : transparent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    GpsAccuracy accuracy = widget.activityDataProvider.gpsAccuracy;

    return Stack(
      children: [
        Positioned(
          // Position in center
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Icon(
            accuracy == GpsAccuracy.medium
                ? Icons.signal_cellular_alt_2_bar_rounded
                : accuracy == GpsAccuracy.low
                    ? Icons.signal_cellular_alt_1_bar_rounded
                    : Icons.signal_cellular_alt_rounded,
            size: Info.iconSize + 8,
            color: accuracy == GpsAccuracy.medium
                ? ColorTheme.yellow
                : accuracy == GpsAccuracy.low
                    ? ColorTheme.red
                    : accuracy == GpsAccuracy.high
                        ? ColorTheme.green
                        : Colors.grey,
          ),
        ),
        AnimatedContainer(
            duration: const Duration(milliseconds: 2000),
            width: Info.iconSize + 16,
            height: Info.iconSize + 16,
            decoration: BoxDecoration(
              color: transparent
                  ? ColorTheme.secondary.withOpacity(0.3)
                  : ColorTheme.secondary,
              borderRadius: BorderRadius.circular(8.0),
            ),
            onEnd: () {
              update();
            },
            alignment: Alignment.center,
            child: Stack(
              children: [
                const Icon(
                  Icons.signal_cellular_alt_rounded,
                  size: Info.iconSize,
                  color: Colors.grey,
                ),
                if (accuracy != GpsAccuracy.none)
                  Icon(
                      accuracy == GpsAccuracy.medium
                          ? Icons.signal_cellular_alt_2_bar_rounded
                          : accuracy == GpsAccuracy.low
                              ? Icons.signal_cellular_alt_1_bar_rounded
                              : Icons.signal_cellular_alt_rounded,
                      size: Info.iconSize,
                      color: accuracy == GpsAccuracy.medium
                          ? ColorTheme.yellow
                          : accuracy == GpsAccuracy.low
                              ? ColorTheme.red
                              : ColorTheme.green),
              ],
            )),
      ],
    );
  }
}

class BlinkingDot extends StatefulWidget {
  const BlinkingDot({super.key, required this.activityDataProvider});

  final ActivityDataProvider activityDataProvider;

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot> {
  bool transparent = false;

  void update() {
    setState(() {
      widget.activityDataProvider.status != ActivityStatus.inactive
          ? transparent = !transparent
          : transparent = false;
    });
  }

  double size = 24.0;
  double borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.activityDataProvider.status != ActivityStatus.inactive) {
          SkiTracker.getActivity().stopActivity();
        }
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOut,
            width: size,
            height: size,
            decoration: transparent
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: widget.activityDataProvider.status !=
                            ActivityStatus.inactive
                        ? ColorTheme.red.withOpacity(0.1)
                        : ColorTheme.grey.withOpacity(0.5),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: widget.activityDataProvider.status !=
                            ActivityStatus.inactive
                        ? ColorTheme.red.withOpacity(0.5)
                        : ColorTheme.grey.withOpacity(0.5),
                  ),
            onEnd: () {
              update();
            },
          ),
          Positioned(
            top: 3,
            left: 3,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              width: size - 6,
              height: size - 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: widget.activityDataProvider.status !=
                        ActivityStatus.inactive
                    ? ColorTheme.red
                    : ColorTheme.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Status extends StatefulWidget {
  const Status(
      {super.key,
      required this.activityDataProvider,
      required this.scrollController});

  final ActivityDataProvider activityDataProvider;
  final ScrollController scrollController;

  static const double height = 132.0;
  static const double heightBarContainer = 12.0;
  static const double heightBar = 4.0;
  static const double widthBar = 80.0;
  static const double padding = 8.0;

  static const String idle = 'Idle';
  static const String running = 'Running';
  static const String paused = 'Paused';
  static const String finished = 'Finished';
  static const String inactive = 'Inactive';

  @override
  State<StatefulWidget> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: Status.heightBarContainer,
          decoration: const BoxDecoration(
            color: ColorTheme.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Status.heightBarContainer),
              topRight: Radius.circular(Status.heightBarContainer),
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            height: Status.heightBar,
            width: Status.widthBar,
            decoration: BoxDecoration(
              color: ColorTheme.grey,
              borderRadius: BorderRadius.circular(Status.heightBar / 2),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: ColorTheme.background,
            // Linear gradient
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [_left(), _right()],
          ),
        ),
      ],
    );
  }

  Widget _right() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.activityDataProvider.initializedMap) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MapPage(),
                settings: const RouteSettings(
                    name:
                        '/fullscreen'), // Setzen Sie hier den gewünschten Routennamen
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.fromLTRB(
              Status.padding, Status.padding, Status.padding, Status.padding),
          height: Status.height - Status.heightBarContainer,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Stack(
              children: [
                if (widget.activityDataProvider.initializedMap)
                  SkiTracker.getActivity().activityMap,
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
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        ColorTheme.secondary.withOpacity(0.9)
                      ],
                      center: Alignment.center,
                      radius: 1.5, // Radius steuert die Größe des Gradients
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _left() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            Status.padding, Status.padding, Status.padding, Status.padding),
        height: Status.height - Status.heightBarContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildCurrentLocation(),
            const Spacer(),
            _buildElapsedTime(),
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    _buildStatus(),
                  ],
                )),
                Expanded(
                  child: _buildButtons(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return Row(
      children: [
        const SizedBox(width: 4),
        Icon(
          !widget.activityDataProvider.internetStatus
              ? Icons.signal_cellular_connected_no_internet_0_bar_rounded
              : Icons.location_on_rounded,
          size: FontTheme.sizeSubHeader,
          color: widget.activityDataProvider.area != ''
              ? ColorTheme.primary
              : ColorTheme.grey,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Utils.buildText(
              text: widget.activityDataProvider.area != ''
                  ? widget.activityDataProvider.area
                  : 'Unknown',
              fontSize: widget.activityDataProvider.area != ''
                  ? FontTheme.size
                  : FontTheme.size - 4,
              color: widget.activityDataProvider.area != ''
                  ? ColorTheme.primary
                  : ColorTheme.grey,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildElapsedTime() {
    return Row(
      children: [
        const SizedBox(width: 4),
        Utils.buildText(
            text:
                '${widget.activityDataProvider.elapsedTime.toString().substring(0, 7)}s',
            fontSize: FontTheme.sizeSubHeader,
            color: widget.activityDataProvider.status ==
                        ActivityStatus.running ||
                    widget.activityDataProvider.status == ActivityStatus.paused
                ? ColorTheme.primary
                : ColorTheme.grey,
            fontWeight: FontWeight.bold,
            caps: false),
      ],
    );
  }

  Widget _buildStatus() {
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        color: ColorTheme.primary,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      alignment: Alignment.center,
      child: Utils.buildText(
          text: widget.activityDataProvider.status == ActivityStatus.inactive
              ? Status.inactive
              : widget.activityDataProvider.status == ActivityStatus.running
                  ? Status.running
                  : widget.activityDataProvider.status == ActivityStatus.paused
                      ? Status.paused
                      : '',
          fontWeight: FontWeight.bold,
          color: ColorTheme.secondary),
    );
  }

  Widget _buildButtons() {
    Widget buildIconButton(IconData icon, Color color, Function() onPressed) {
      return Container(
        padding: const EdgeInsets.all(0.0),
        height: 32,
        width: 32,
        child: IconButton(
          iconSize: 24,
          padding: const EdgeInsets.all(0.0),
          onPressed: onPressed,
          icon: Icon(
            icon,
          ),
          color: color,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BlinkingDot(activityDataProvider: widget.activityDataProvider),
        buildIconButton(
            widget.activityDataProvider.status == ActivityStatus.running
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            ColorTheme.contrast, () {
          if (widget.activityDataProvider.status == ActivityStatus.inactive) {
            SkiTracker.getActivity().startActivity();
            double targetPosition = MediaQuery.of(context).size.height - 420;
            widget.scrollController.animateTo(
              targetPosition,
              curve: Curves.easeOut,
              duration: ActivityDisplay.animationDuration,
            );
          } else if (widget.activityDataProvider.status ==
              ActivityStatus.paused) {
            SkiTracker.getActivity().resumeActivity();
          } else if (widget.activityDataProvider.status ==
              ActivityStatus.running) {
            SkiTracker.getActivity().pauseActivity();
          }
        }),
      ],
    );
  }
}

class Info extends StatefulWidget {
  const Info({super.key, required this.activityDataProvider});

  final ActivityDataProvider activityDataProvider;

  static const double height = 120.0;

  static const String unitSpeed = 'km/h';
  static const String unitDistance = 'km';
  static const String unitAltitude = 'm';
  static const String unitSlope = '%';
  static const String unitTime = 's';

  static const double speedFactor = 3.6;

  static const EdgeInsets padding = EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0);
  static const double iconSize = 40.0;

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorTheme.background,
        // Linear gradient
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.0, 0.5, 1.0],
          colors: [
            ColorTheme.background,
            ColorTheme.background,
            ColorTheme.background,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: Info.padding / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BlinkingGps(activityDataProvider: widget.activityDataProvider),
                const SizedBox(width: 8),
                ElapsedTime(activityDataProvider: widget.activityDataProvider),
              ],
            ),
          ),
          _buildActivityDisplay(
              icon: Icons.speed_rounded,
              title: 'Speed',
              unit: Info.unitSpeed,
              value1: (widget.activityDataProvider.speed * Info.speedFactor)
                  .toStringAsFixed(1),
              value2: (widget.activityDataProvider.maxSpeed * Info.speedFactor)
                  .toStringAsFixed(1),
              value3: (widget.activityDataProvider.avgSpeed * Info.speedFactor)
                  .toStringAsFixed(1),
              titleValue1: 'Current',
              titleValue2: 'Max',
              titleValue3: 'Avg'),
          _buildActivityDisplay(
              icon: Icons.map_rounded,
              title: 'Distance',
              unit: Info.unitDistance,
              value1: (widget.activityDataProvider.distance / 1000)
                  .toStringAsFixed(1),
              value2: (widget.activityDataProvider.distanceDownhill / 1000)
                  .toStringAsFixed(1),
              value3: (widget.activityDataProvider.distanceUphill / 1000)
                  .toStringAsFixed(1),
              titleValue1: 'Total',
              titleValue2: 'Downhill',
              titleValue3: 'Uphill'),
          Container(
            color: ColorTheme.secondary,
            child: Column(
              children: [
                _buildActivityDisplay(
                    icon: Icons.terrain_rounded,
                    title: 'Altitude',
                    unit: Info.unitAltitude,
                    value1:
                        widget.activityDataProvider.altitude.round().toString(),
                    value2: widget.activityDataProvider.maxAltitude
                        .round()
                        .toString(),
                    value3: widget.activityDataProvider.minAltitude
                        .round()
                        .toString(),
                    titleValue1: 'Current',
                    titleValue2: 'Max',
                    titleValue3: 'Min'),
                SizedBox(
                  height: 100,
                  child: CustomPaint(
                    painter:
                        GraphPainter(widget.activityDataProvider.altitudes),
                  ),
                )
              ],
            ),
          ),
          _buildActivityDisplay(
              icon: Icons.line_axis_rounded,
              title: 'Slope',
              unit: Info.unitSlope,
              value1: widget.activityDataProvider.slope.round().toString(),
              value2: widget.activityDataProvider.maxSlope.round().toString(),
              value3: widget.activityDataProvider.avgSlope.round().toString(),
              titleValue1: 'Current',
              titleValue2: 'Max',
              titleValue3: 'Avg'),
          /*_buildActivityDisplay(
              icon: Icons.timer_rounded,
              title: 'Time',
              unit: Info.unitTime,
              value1: widget.activityDataProvider.elapsedTime
                  .toString()
                  .substring(0, 7),
              value2: widget.activityDataProvider.elapsedDownhillTime
                  .toString()
                  .substring(0, 7),
              value3: widget.activityDataProvider.elapsedUphillTime
                  .toString()
                  .substring(0, 7),
              titleValue1: 'Total',
              titleValue2: 'Downhill',
              titleValue3: 'Uphill'),*/
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
      mirrored = false}) {
    Widget buildValue({required String value, required String title}) {
      return Row(
        children: [
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
          const SizedBox(width: 4),
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            child: Utils.buildText(
                text: title, fontSize: FontTheme.size, color: ColorTheme.grey),
          )
        ],
      );
    }

    Widget buildMirroredValue({required String value, required String title}) {
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

    Widget activityContainer() {
      return Container(
        padding: Info.padding / 2,
        child: Container(
          color: ColorTheme.secondary,
          padding: Info.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Info.iconSize + 16,
                    height: Info.iconSize + 16,
                    decoration: BoxDecoration(
                      color: ColorTheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      icon,
                      size: Info.iconSize,
                      color: ColorTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: Info.iconSize + 16,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils.buildText(
                            text: title,
                            fontSize: FontTheme.size,
                            color: ColorTheme.grey,
                            fontWeight: FontWeight.bold),
                        if (value1 != '')
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Utils.buildText(
                                  text: value1,
                                  fontSize: FontTheme.sizeSubHeader,
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
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  if (value2 != '')
                    buildValue(value: value2, title: titleValue2),
                  if (value3 != '')
                    buildValue(value: value3, title: titleValue3),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget mirroredActivityContainer() {
      return Container(
        padding: Info.padding / 2,
        child: Container(
          color: ColorTheme.secondary,
          padding: Info.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  if (value2 != '')
                    buildMirroredValue(value: value2, title: titleValue2),
                  if (value3 != '')
                    buildMirroredValue(value: value3, title: titleValue3),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Info.iconSize + 16,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Utils.buildText(
                            text: title,
                            fontSize: FontTheme.size,
                            color: ColorTheme.grey,
                            fontWeight: FontWeight.bold),
                        if (value1 != '')
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Utils.buildText(
                                  text: value1,
                                  fontSize: FontTheme.sizeSubHeader,
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
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: Info.iconSize + 16,
                    height: Info.iconSize + 16,
                    decoration: BoxDecoration(
                      color: ColorTheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      icon,
                      size: Info.iconSize,
                      color: ColorTheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (mirrored) {
      return mirroredActivityContainer();
    } else {
      return activityContainer();
    }
  }
}

class GraphPainter extends CustomPainter {
  final List<int> data;

  GraphPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ColorTheme.primary
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    int maxData =
        data.reduce((value, element) => value > element ? value : element);
    int minData =
        data.reduce((value, element) => value < element ? value : element);

    double width = size.width / (data.length - 1);

    for (int i = 0; i < data.length - 1; i++) {
      double x1 = i * width;
      if (maxData - minData == 0) {
        maxData = 1;
      }
      double y1 = size.height -
          (size.height * (data[i] - minData) / (maxData - minData));
      double x2 = (i + 1) * width;
      double y2 = size.height -
          (size.height * (data[i + 1] - minData) / (maxData - minData));

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ElapsedTime extends StatefulWidget {
  const ElapsedTime({super.key, required this.activityDataProvider});

  final ActivityDataProvider activityDataProvider;

  @override
  State<ElapsedTime> createState() => _ElapsedTimeState();
}

class _ElapsedTimeState extends State<ElapsedTime> {
  Widget _buildTimeBar(Duration downhill, Duration uphill) {
    int flexDownhill =
        downhill.inSeconds;
    int flexUphill = uphill.inSeconds;

    return Row(
      children: [
        Expanded(
            flex: flexDownhill,
            child: Container(
              height: 16,
              decoration: const BoxDecoration(
                color: ColorTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
              ),
            )),
        Expanded(
            flex: flexUphill,
            child: Container(
              height: 16,
              decoration: const BoxDecoration(
                color: ColorTheme.contrast,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        height: Info.iconSize + 16,
        decoration: const BoxDecoration(
          color: ColorTheme.secondary,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Utils.buildText(
                        text: 'Downhill',
                        fontSize: FontTheme.size,
                        color: ColorTheme.contrast,
                        caps: false,
                        fontWeight: FontWeight.bold),
                  ],
                ),
                Row(
                  children: [
                    Utils.buildText(
                        text: 'Uphill',
                        fontSize: FontTheme.size,
                        color: ColorTheme.contrast,
                        fontWeight: FontWeight.bold,
                        caps: false),
                    const SizedBox(width: 4),
                  ],
                )
              ],
            ),
            const SizedBox(height: 4),
            _buildTimeBar(widget.activityDataProvider.elapsedDownhillTime,
                widget.activityDataProvider.elapsedUphillTime),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Utils.buildText(
                        text:
                            '${widget.activityDataProvider.elapsedDownhillTime.toString().substring(0, 7)} ${Info.unitTime}',
                        fontSize: FontTheme.size,
                        color: ColorTheme.contrast,
                        caps: false,
                        fontWeight: FontWeight.bold),
                  ],
                ),
                Row(
                  children: [
                    Utils.buildText(
                        text:
                            '${widget.activityDataProvider.elapsedUphillTime.toString().substring(0, 7)} ${Info.unitTime}',
                        fontSize: FontTheme.size,
                        color: ColorTheme.contrast,
                        fontWeight: FontWeight.bold,
                        caps: false),
                    const SizedBox(width: 4),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
