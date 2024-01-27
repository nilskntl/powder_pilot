import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../activity/data.dart';
import '../activity/data_provider.dart';
import '../activity/map.dart';
import '../activity/slopes.dart';
import '../activity/state.dart';
import '../main.dart';
import '../theme.dart';
import '../utils/general_utils.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  static const Duration animationDuration = Duration(milliseconds: 500);
  static const double expandedHeight = 200.0;

  static Widget buildSlopeName(SlopeInfo slope,
      {double size = FontTheme.sizeSubHeader}) {
    if (slope.type == 'gondola' ||
        slope.type == 'chair_lift' ||
        slope.type == 'drag_lift' ||
        slope.type == 'platter' ||
        slope.type == 't-bar') {
      return Utils.buildText(
          text: slope.name,
          color: ColorTheme.contrast,
          fontSize: size,
          caps: false,
          fontWeight: FontWeight.bold);
    } else if (slope.name != 'Unknown' && slope.name != '') {
      return Utils.buildText(
          text: 'Slope: ${slope.name}',
          color: ColorTheme.contrast,
          fontSize: size,
          caps: false,
          fontWeight: FontWeight.bold);
    } else {
      return Utils.buildText(
          text: 'Free Ride',
          color: ColorTheme.contrast,
          fontSize: size,
          caps: false,
          fontWeight: FontWeight.bold);
    }
  }

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late final ScrollController _scrollController;
  bool _scrollControllerInitialized = false;

  late ActivityDataProvider activityDataProvider =
      Provider.of<ActivityDataProvider>(context);

  @override
  Widget build(BuildContext context) {
    PowderPilot.setActivityDataProvider(activityDataProvider);
    // Check if scroll controller is initialized
    if (!_scrollControllerInitialized) {
      // Check if activity is running
      _scrollController = activityDataProvider.status != ActivityStatus.inactive
          ? ScrollController(
              initialScrollOffset: MediaQuery.sizeOf(context).height - 420)
          : ScrollController(initialScrollOffset: 1);
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
            collapsedHeight: MediaQuery.of(context).size.height -
                255 -
                MediaQuery.of(context).padding.bottom,
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

class CurrentSlope extends StatefulWidget {
  const CurrentSlope(
      {super.key, required this.slope, this.size = 48, this.animated = false});

  final double size;

  final bool animated;

  final SlopeInfo slope;

  @override
  State<CurrentSlope> createState() => _CurrentSlopeState();
}

class _CurrentSlopeState extends State<CurrentSlope> {
  Color _getColor(String difficulty) {
    if (widget.slope.name == 'Unknown') {
      return ColorTheme.black;
    }
    if (difficulty == 'easy') {
      return ColorTheme.blue;
    } else if (difficulty == 'intermediate') {
      return ColorTheme.red;
    } else if (difficulty == 'advanced') {
      return ColorTheme.black;
    } else {
      return ColorTheme.darkGrey;
    }
  }

  @override
  void initState() {
    super.initState();
    // Schedule a callback after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized && widget.animated) {
        setState(() {
          transparent = !transparent;
          _initialized = true;
        });
      }
    });
  }

  bool transparent = true;

  bool _initialized = false;

  String getIconString(String type) {
    if (type == 'gondola') {
      return 'assets/images/lift/gondola.png';
    } else {
      return 'assets/images/lift/chair_lift.png';
    }
  }

  Widget _buildInside() {
    if (widget.slope.type == 'intermediate' ||
        widget.slope.type == 'easy' ||
        widget.slope.type == 'advanced') {
      return Utils.buildText(
          text: widget.slope.name,
          fontSize: widget.size / 3,
          color: ColorTheme.secondary,
          fontWeight: FontWeight.bold,
          caps: false);
    } else if (widget.slope.type == 'gondola' ||
        widget.slope.type == 'chair_lift' ||
        widget.slope.type == 'drag_lift' ||
        widget.slope.type == 'platter' ||
        widget.slope.type == 't-bar') {
      return Image.asset(getIconString(widget.slope.type),
          width: widget.size / 3 * 2, height: widget.size / 3 * 2);
    } else {
      return Icon(
        LogoTheme.activity,
        color: ColorTheme.secondary,
        size: widget.size / 3 * 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = _getColor(widget.slope.type);

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 2000),
          width: widget.size + 8,
          height: widget.size + 8,
          decoration: transparent
              ? BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular((widget.size + 8) / 2),
                )
              : BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular((widget.size + 8) / 2),
                ),
          onEnd: () {
            if (widget.animated) {
              setState(() {
                transparent = !transparent;
              });
            }
          },
        ),
        // Position Container in the center
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2000),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(widget.size / 2),
              ),
              alignment: Alignment.center,
              child: _buildInside(),
            ),
          ),
        ),
      ],
    );
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
      transparent = !transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    GpsAccuracy accuracy = widget.activityDataProvider.gpsAccuracy;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ColorTheme.secondary,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Stack(
            children: [
              Positioned(
                // Position in center
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Icon(
                  accuracy == GpsAccuracy.medium
                      ? LogoTheme.gpsMedium
                      : accuracy == GpsAccuracy.low
                          ? LogoTheme.gpsLow
                          : LogoTheme.gpsHigh,
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
                  curve: Curves.easeInOut,
                  decoration: transparent
                      ? BoxDecoration(
                          color: ColorTheme.secondary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.0),
                        )
                      : BoxDecoration(
                          color: ColorTheme.secondary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                  onEnd: () {
                    update();
                  },
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      const Icon(
                        LogoTheme.gpsHigh,
                        size: Info.iconSize,
                        color: ColorTheme.grey,
                      ),
                      if (accuracy != GpsAccuracy.none)
                        Icon(
                            accuracy == GpsAccuracy.medium
                                ? LogoTheme.gpsMedium
                                : accuracy == GpsAccuracy.low
                                    ? LogoTheme.gpsLow
                                    : LogoTheme.gpsHigh,
                            size: Info.iconSize,
                            color: accuracy == GpsAccuracy.medium
                                ? ColorTheme.yellow
                                : accuracy == GpsAccuracy.low
                                    ? ColorTheme.red
                                    : ColorTheme.green),
                    ],
                  )),
            ],
          ),
        ))
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

  double size = 32.0;
  double borderRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.activityDataProvider.status != ActivityStatus.inactive) {
          PowderPilot.activity.stopActivity(context);
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

  final ActivityMap activityMap = const ActivityMap(staticMap: false);

  @override
  State<StatefulWidget> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  void initState() {
    super.initState();
  }

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
      flex: 4,
      child: GestureDetector(
        onTap: () {
          if (widget.activityDataProvider.latitude != 0.0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPage(
                  activityDataProvider: widget.activityDataProvider,
                  activityMap: widget.activityMap,
                ),
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
                if (widget.activityDataProvider.latitude != 0.0)
                  widget.activityMap,
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
                        ColorTheme.secondary.withOpacity(0.6),
                        ColorTheme.secondary.withOpacity(0.9)
                      ],
                      stops: const [0.0, 0.8, 1.0],
                      center: Alignment.center,
                      radius: 1.2, // Radius steuert die Größe des Gradients
                    ),
                  ),
                ),
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    LogoTheme.click,
                    color: ColorTheme.contrast,
                  ),
                ),
                if (widget.activityDataProvider.latitude != 0.0 &&
                    widget.activityDataProvider.status ==
                        ActivityStatus.running &&
                    SlopeMap.slopes.isNotEmpty)
                  if (widget.activityDataProvider.route.slopes.isNotEmpty)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: CurrentSlope(
                          slope: widget.activityDataProvider.route.slopes.last,
                          animated: true),
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
      flex: 5,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Column(
                  children: [
                    _buildElapsedTime(),
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
              ? LogoTheme.noInternet
              : LogoTheme.gps,
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
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildElapsedTime() {
    return Row(
      children: [
        const SizedBox(width: 4),
        Utils.buildText(
            text: widget.activityDataProvider.duration.total
                .toString()
                .substring(0, 7),
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
      height: 20,
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
          color: ColorTheme.secondary,
          fontSize: FontTheme.size - 4),
    );
  }

  Widget _buildButtons() {
    Widget buildIconButton(IconData icon, Color color, Function() onPressed) {
      return Container(
        padding: const EdgeInsets.all(0.0),
        height: 48,
        width: 48,
        child: IconButton(
          iconSize: 48,
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
                ? LogoTheme.pause
                : LogoTheme.start,
            ColorTheme.contrast, () {
          if (widget.activityDataProvider.status == ActivityStatus.inactive) {
            PowderPilot.activity.startActivity();
            double targetPosition = MediaQuery.of(context).size.height - 200;
            widget.scrollController.animateTo(
              targetPosition,
              curve: Curves.easeOut,
              duration: ActivityPage.animationDuration,
            );
          } else if (widget.activityDataProvider.status ==
              ActivityStatus.paused) {
            PowderPilot.activity.resumeActivity();
          } else if (widget.activityDataProvider.status ==
              ActivityStatus.running) {
            PowderPilot.activity.pauseActivity();
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

  static String unitSpeed = 'km/h';
  static String unitDistance = 'km';
  static String unitAltitude = 'm';
  static String unitSlope = '%';
  static String unitTime = 'h';

  static double speedFactor = 3.6;
  static double distanceFactor = 1;
  static double altitudeFactor = 1;

  static const EdgeInsets padding = EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0);
  static const double iconSize = 40.0;

  @override
  State<Info> createState() => _InfoState();

  static void setUnits(String units) {
    if (units == 'imperial') {
      unitSpeed = 'mph';
      unitDistance = 'mi';
      unitAltitude = 'ft';
      speedFactor = 2.236936;
      distanceFactor = 0.621371;
      altitudeFactor = 3.28084;
    } else {
      unitSpeed = 'km/h';
      unitDistance = 'km';
      unitAltitude = 'm';
      speedFactor = 3.6;
      distanceFactor = 1;
      altitudeFactor = 1;
    }
  }
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
            height: Info.iconSize + 32 + Info.padding.top + Info.padding.bottom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BlinkingGps(activityDataProvider: widget.activityDataProvider),
                const SizedBox(width: 8),
                ElapsedTime(
                  downhillTime: widget.activityDataProvider.duration.downhill,
                  uphillTime: widget.activityDataProvider.duration.uphill,
                  pauseTime: widget.activityDataProvider.duration.pause,
                ),
              ],
            ),
          ),
          _buildActivityDisplay(
              icon: LogoTheme.speed,
              title: 'Speed',
              unit: Info.unitSpeed,
              value1: (widget.activityDataProvider.speed.currentSpeed *
                      Info.speedFactor)
                  .toStringAsFixed(1),
              value2: (widget.activityDataProvider.speed.maxSpeed *
                      Info.speedFactor)
                  .toStringAsFixed(1),
              value3: (widget.activityDataProvider.speed.avgSpeed *
                      Info.speedFactor)
                  .toStringAsFixed(1),
              titleValue1: 'Current',
              titleValue2: 'Max',
              titleValue3: 'Avg'),
          _buildActivityDisplay(
            icon: LogoTheme.altitude,
            title: 'Altitude',
            unit: Info.unitAltitude,
            value1: (widget.activityDataProvider.altitude.currentAltitude *
                    Info.altitudeFactor)
                .round()
                .toString(),
            value2: (widget.activityDataProvider.altitude.maxAltitude *
                    Info.altitudeFactor)
                .round()
                .toString(),
            value3: (widget.activityDataProvider.altitude.minAltitude *
                    Info.altitudeFactor)
                .round()
                .toString(),
            titleValue1: 'Current',
            titleValue2: 'Max',
            titleValue3: 'Min',
          ),
          _buildActivityDisplay(
            icon: LogoTheme.distance,
            title: 'Distance',
            unit: Info.unitDistance,
            value1: (widget.activityDataProvider.distance.totalDistance *
                    Info.distanceFactor /
                    1000)
                .toStringAsFixed(1),
            value2: (widget.activityDataProvider.distance.distanceDownhill *
                    Info.distanceFactor /
                    1000)
                .toStringAsFixed(1),
            value3: (widget.activityDataProvider.distance.distanceUphill *
                    Info.distanceFactor /
                    1000)
                .toStringAsFixed(1),
            titleValue1: 'Total',
            titleValue2: 'Downhill',
            titleValue3: 'Uphill',
          ),
          _buildActivityDisplay(
              icon: LogoTheme.slope,
              title: 'Slope',
              unit: Info.unitSlope,
              value1: widget.activityDataProvider.slope.currentSlope
                  .round()
                  .toString(),
              value2:
                  widget.activityDataProvider.slope.maxSlope.round().toString(),
              value3:
                  widget.activityDataProvider.slope.avgSlope.round().toString(),
              titleValue1: 'Current',
              titleValue2: 'Max',
              titleValue3: 'Avg'),
          Graph(
            dataAltitudes: widget.activityDataProvider.altitude.altitudes,
            dataSpeeds: widget.activityDataProvider.speed.speeds,
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
      mirrored = false,
      EdgeInsets padding = Info.padding}) {
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
        padding: padding / 2,
        child: Container(
          padding: Info.padding,
          decoration: const BoxDecoration(
            color: ColorTheme.secondary,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
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

/// Widget to display the Graph of altitude and speed
class Graph extends StatefulWidget {
  const Graph(
      {super.key,
      required this.dataAltitudes,
      required this.dataSpeeds,
      this.small = false});

  /// The data of the altitude
  final List<List<int>> dataAltitudes;

  /// The data of the speed
  final List<List<double>> dataSpeeds;

  /// Flag to display a small graph
  final bool small;

  @override
  State<Graph> createState() => _GraphState();
}

/// State of the Graph widget
class _GraphState extends State<Graph> {
  @override
  void initState() {
    super.initState();
    if (!_differentEntries) {
      hasDifferentEntry(widget.dataAltitudes);
      hasDifferentEntry(widget.dataSpeeds);
    }
  }

  /// Convert a list of generic lists to FlSpots
  ///
  /// @param dataList The list of generic lists (T can be int or double)
  /// @param factor The factor to multiply the values with
  List<FlSpot> _convertToFlSpots<T>(
      {required List<List<T>> list, double factor = 1.0}) {
    if (!_differentEntries) {
      hasDifferentEntry(list);
    }

    List<FlSpot> flSpots = [];

    /// Iterate through the list of T
    for (List<T> data in list) {
      /// Only add the FlSpot if the list has two elements
      if (data.length == 2) {
        /// Get the values of the list (x, y)
        double x =
            data[0] is int ? (data[0] as int).toDouble() : data[0] as double;
        double y =
            data[1] is int ? (data[1] as int).toDouble() : data[1] as double;

        /// Try to add the FlSpot to the list of FlSpots
        /// If the value is not a double, the value is not added
        /// If the value is a double, the value is rounded to one decimal place
        try {
          flSpots.add(FlSpot(x, double.parse((y * factor).toStringAsFixed(1))));
        } catch (e) {
          if (kDebugMode) {
            print('Cant add FlSpot: $e');
          }
        }
      }
    }

    return flSpots;
  }

  /// Flag to check if the list has different entries at position 2
  bool _differentEntries = false;

  /// Check if one of the list has different entries at position 2 to
  /// change the size of the graph dynamically
  ///
  /// @param list The list of lists
  bool hasDifferentEntry<T>(List<List<T>> list) {
    /// Check if the list has at least one element
    if (list.isEmpty) {
      return false;
    }

    /// Get the value at position 2 of the first list
    T referenceValue = list[0][1];

    /// Iterate through the rest of the lists and check if the value at position 2 is different
    for (int i = 1; i < list.length; i++) {
      if (list[i][1] != referenceValue) {
        /// Found a different entry at position 2
        _differentEntries = true;
        return true;
      }
    }

    /// All entries at position 2 are the same
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: Info.padding / 2,
        child: Column(
          children: [
            Container(
              padding: Info.padding,
              decoration: const BoxDecoration(
                color: ColorTheme.secondary,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    topLeft: Radius.circular(16.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeader(
                      title: 'Altitude',
                      icon: LogoTheme.altitude,
                      color: ColorTheme.primary),
                  _buildHeader(
                      title: 'Speed',
                      icon: LogoTheme.speed,
                      color: ColorTheme.contrast,
                      mirrored: true),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: const BoxDecoration(
                color: ColorTheme.secondary,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0)),
              ),
              height: widget.dataSpeeds.isEmpty
                  ? 16
                  : _differentEntries == false
                      ? 32
                      : 150,
              padding: Info.padding * 2,
              child: Stack(
                children: [
                  _buildLineChart(
                    color: ColorTheme.primary,
                    list: widget.dataAltitudes,
                    factor: Info.altitudeFactor,
                  ),
                  _buildLineChart(
                    color: ColorTheme.contrast,
                    list: widget.dataSpeeds,
                    factor: Info.speedFactor,
                  ),
                ],
              ),
            ),
          ],
        ));
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
          color: color,
          fontWeight: FontWeight.normal,
        ),
        if (mirrored) const SizedBox(width: 8),
        if (mirrored) buildIcon(),
      ],
    );
  }

  /// Build the line chart
  ///
  /// @param color The color of the line
  /// @param list The list of lists with the data (T can be int or double)
  /// @param factor The factor to multiply the values with
  Widget _buildLineChart<T>(
      {required Color color,
      required List<List<T>> list,
      double factor = 1.0}) {
    /// Convert the list to FlSpots
    List<FlSpot> flSpots = _convertToFlSpots(list: list, factor: factor);

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData:
                BarAreaData(show: true, color: color.withOpacity(0.4)),
            spots: flSpots,
            curveSmoothness: 0.01,
          ),
        ],
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }
}

class ElapsedTime extends StatefulWidget {
  const ElapsedTime(
      {super.key,
      required this.downhillTime,
      required this.uphillTime,
      required this.pauseTime});

  final Duration downhillTime;
  final Duration uphillTime;
  final Duration pauseTime;

  @override
  State<ElapsedTime> createState() => _ElapsedTimeState();
}

class _ElapsedTimeState extends State<ElapsedTime> {
  Widget _buildTimeBar(Duration downhill, Duration uphill, Duration pause) {
    int flexDownhill = downhill.inSeconds;
    int flexUphill = uphill.inSeconds;
    int flexPause = pause.inSeconds;

    if (flexPause == 0 && flexDownhill == 0 && flexUphill == 0) {
      flexPause = 1;
      flexDownhill = 0;
      flexUphill = 0;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: flexDownhill,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: ColorTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(4.0),
                  bottomLeft: const Radius.circular(4.0),
                  topRight: (flexPause == 0 && flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  bottomRight: (flexPause == 0 && flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                ),
              ),
            )),
        Expanded(
            flex: flexPause,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: ColorTheme.grey,
                borderRadius: BorderRadius.only(
                  topRight: (flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  bottomRight: (flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  topLeft: (flexDownhill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  bottomLeft: (flexDownhill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                ),
              ),
            )),
        Expanded(
          flex: flexUphill,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: ColorTheme.contrast,
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(4.0),
                bottomRight: const Radius.circular(4.0),
                topLeft: (flexPause == 0 && flexDownhill == 0)
                    ? const Radius.circular(4.0)
                    : const Radius.circular(0.0),
                bottomLeft: (flexPause == 0 && flexDownhill == 0)
                    ? const Radius.circular(4.0)
                    : const Radius.circular(0.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
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
                Utils.buildText(
                    text: 'Pause',
                    fontSize: FontTheme.size,
                    color: ColorTheme.contrast,
                    fontWeight: FontWeight.bold,
                    caps: false),
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
            _buildTimeBar(
                widget.downhillTime, widget.uphillTime, widget.pauseTime),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Utils.buildText(
                        text: widget.downhillTime.toString().substring(0, 7),
                        fontSize: FontTheme.size,
                        color: ColorTheme.contrast,
                        caps: false,
                        fontWeight: FontWeight.bold),
                  ],
                ),
                Utils.buildText(
                    text: widget.pauseTime.toString().substring(0, 7),
                    fontSize: FontTheme.size,
                    color: ColorTheme.contrast,
                    fontWeight: FontWeight.bold,
                    caps: false),
                Row(
                  children: [
                    Utils.buildText(
                        text: widget.uphillTime.toString().substring(0, 7),
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
