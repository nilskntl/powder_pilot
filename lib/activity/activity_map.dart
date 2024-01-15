import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:ski_tracker/activity/activity.dart';
import 'package:ski_tracker/main.dart';

import '../route.dart';
import '../slopes.dart';
import '../utils/custom_app_bar.dart';
import '../utils/general_utils.dart';
import 'activity_data_provider.dart';
import 'activity_display.dart';

class MapPage extends StatefulWidget {
  const MapPage(
      {super.key,
      required this.activityDataProvider,
      required this.activityMap});

  final ActivityDataProvider activityDataProvider;

  final ActivityMap activityMap;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarDesign.appBar(title: 'Map'),
      body: Stack(
        children: [
          if (widget.activityDataProvider.status == ActivityStatus.inactive ||
              SlopeMap.slopes.isEmpty || widget.activityDataProvider.route.slopes.isEmpty)
            widget.activityMap,
          if (widget.activityDataProvider.status != ActivityStatus.inactive &&
              SlopeMap.slopes.isNotEmpty && widget.activityDataProvider.route.slopes.isNotEmpty)
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  forceMaterialTransparency: true,
                  flexibleSpace: widget.activityMap,
                  toolbarHeight: 125,
                  expandedHeight: MediaQuery.of(context).size.height -
                      172 -
                      MediaQuery.of(context).padding.bottom,
                  pinned: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        children: [
                          Container(
                            height: Status.heightBarContainer,
                            decoration: const BoxDecoration(
                              color: ColorTheme.background,
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(Status.heightBarContainer),
                                topRight:
                                    Radius.circular(Status.heightBarContainer),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              height: Status.heightBar,
                              width: Status.widthBar,
                              decoration: BoxDecoration(
                                color: ColorTheme.grey,
                                borderRadius:
                                    BorderRadius.circular(Status.heightBar / 2),
                              ),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: ColorTheme.background,
                              ),
                              // Make an entry for every route in the full route of widget.activityDataProvider.route except the last one
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorTheme.secondary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        if (widget.activityDataProvider.route
                                            .slopes.isNotEmpty)
                                          CurrentSlope(
                                              slope: widget.activityDataProvider
                                                  .route.slopes.last, animated: true,),
                                        const SizedBox(width: 16),
                                        if (widget.activityDataProvider.route
                                            .slopes.isNotEmpty)
                                          ActivityDisplay.buildSlopeName(widget
                                              .activityDataProvider
                                              .route
                                              .slopes
                                              .last),
                                        const Spacer(),
                                        Container(
                                          height: 24,
                                          width: 96,
                                          decoration: BoxDecoration(
                                            color: ColorTheme.green,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          alignment: Alignment.center,
                                          child: Utils.buildText(
                                              text: 'Current',
                                              fontSize: FontTheme.size - 4,
                                              color: ColorTheme.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: widget.activityDataProvider.route
                                        .slopes.length,
                                    itemBuilder: (context, index) {
                                      if (index !=
                                          widget.activityDataProvider.route
                                                  .slopes.length -
                                              1) {
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.secondary,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CurrentSlope(
                                                  slope: widget
                                                      .activityDataProvider
                                                      .route
                                                      .slopes[index]),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Utils.buildText(
                                                          text: 'Start: ',
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color:
                                                              ColorTheme.grey,
                                                          caps: false),
                                                      const SizedBox(width: 4),
                                                      Utils.buildText(
                                                          text: Utils.durationStringToString(widget
                                                              .activityDataProvider
                                                              .route
                                                              .slopes[index]
                                                              .startTime
                                                              .toString())[1],
                                                          caps: false,
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color: ColorTheme
                                                              .contrast),
                                                    ],
                                                  ),
                                                  ActivityDisplay.buildSlopeName(widget
                                                      .activityDataProvider
                                                      .route
                                                      .slopes[index]),
                                                  Row(
                                                    children: [
                                                      Utils.buildText(
                                                          text: 'Duration: ',
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color:
                                                              ColorTheme.grey,
                                                          caps: false),
                                                      const SizedBox(width: 4),
                                                      Utils.buildText(
                                                          text: Utils.formatDuration(widget
                                                                  .activityDataProvider
                                                                  .route
                                                                  .slopes[index]
                                                                  .endTime
                                                                  .difference(widget
                                                                      .activityDataProvider
                                                                      .route
                                                                      .slopes[
                                                                          index]
                                                                      .startTime)) +
                                                              ' min',
                                                          caps: false,
                                                          fontSize:
                                                              FontTheme.size -
                                                                  4,
                                                          color: ColorTheme
                                                              .contrast),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: ColorTheme.background,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class MapPageSummary extends StatefulWidget {
  const MapPageSummary(
      {super.key,
        required this.route,
        required this.activityMap});

  final ActivityRoute route;

  final ActivityMap activityMap;

  @override
  State<MapPageSummary> createState() => _MapPageSummaryState();
}

class _MapPageSummaryState extends State<MapPageSummary> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarDesign.appBar(title: 'Map'),
      body: Stack(
        children: [
          if (widget.route.slopes.isEmpty)
            widget.activityMap,
          if (widget.route.slopes.isNotEmpty)
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  forceMaterialTransparency: true,
                  flexibleSpace: widget.activityMap,
                  toolbarHeight: 125,
                  expandedHeight: MediaQuery.of(context).size.height -
                      172 -
                      MediaQuery.of(context).padding.bottom,
                  pinned: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        children: [
                          Container(
                            height: Status.heightBarContainer,
                            decoration: const BoxDecoration(
                              color: ColorTheme.background,
                              borderRadius: BorderRadius.only(
                                topLeft:
                                Radius.circular(Status.heightBarContainer),
                                topRight:
                                Radius.circular(Status.heightBarContainer),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              height: Status.heightBar,
                              width: Status.widthBar,
                              decoration: BoxDecoration(
                                color: ColorTheme.grey,
                                borderRadius:
                                BorderRadius.circular(Status.heightBar / 2),
                              ),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: ColorTheme.background,
                              ),
                              // Make an entry for every route in the full route of widget.activityDataProvider.route except the last one
                              child: Column(
                                children: [
                                  ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: widget.route
                                        .slopes.length,
                                    itemBuilder: (context, index) {
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.secondary,
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              CurrentSlope(
                                                  slope: widget
                                                      .route
                                                      .slopes[index]),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Utils.buildText(
                                                          text: 'Start: ',
                                                          fontSize:
                                                          FontTheme.size -
                                                              4,
                                                          color:
                                                          ColorTheme.grey,
                                                          caps: false),
                                                      const SizedBox(width: 4),
                                                      Utils.buildText(
                                                          text: Utils.durationStringToString(widget
                                                              .route
                                                              .slopes[index]
                                                              .startTime
                                                              .toString())[1],
                                                          caps: false,
                                                          fontSize:
                                                          FontTheme.size -
                                                              4,
                                                          color: ColorTheme
                                                              .contrast),
                                                    ],
                                                  ),
                                                  ActivityDisplay.buildSlopeName(widget
                                                      .route
                                                      .slopes[index]),
                                                  Row(
                                                    children: [
                                                      Utils.buildText(
                                                          text: 'Duration: ',
                                                          fontSize:
                                                          FontTheme.size -
                                                              4,
                                                          color:
                                                          ColorTheme.grey,
                                                          caps: false),
                                                      const SizedBox(width: 4),
                                                      Utils.buildText(
                                                          text: Utils.formatDuration(widget
                                                              .route
                                                              .slopes[index]
                                                              .endTime
                                                              .difference(widget
                                                              .route
                                                              .slopes[
                                                          index]
                                                              .startTime)) +
                                                              ' min',
                                                          caps: false,
                                                          fontSize:
                                                          FontTheme.size -
                                                              4,
                                                          color: ColorTheme
                                                              .contrast),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: ColorTheme.background,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class ActivityMap extends StatefulWidget {
  const ActivityMap(
      {super.key,
      this.staticMap = false,
      this.route = const ActivityRoute(coordinates: [], slopes: []), this.activityLocations = const ActivityLocations()});

  final bool staticMap;
  final ActivityRoute route;
  final ActivityLocations activityLocations;

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap>
    with TickerProviderStateMixin {
  static const double zoomLevel = 14.0;
  static const double zoomOverview = 12.0;
  static const double maxZoom = 18.49;
  static const double minZoom = 4.0;
  static const Color backgroundColor = Color(0xFF777777);

  static const double markerSize = 32.0;

  late AnimatedMapController mapController;

  late Timer _timer;

  bool _previewMode = true;

  List<Polyline> _route = [];

  late ActivityLocations _activityLocations = widget.activityLocations;

  LatLng _middlePoint = const LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    if(widget.route.coordinates.isNotEmpty) {
      if(widget.staticMap) {
        _middlePoint = _calculateMiddlePoint(widget.route.coordinates);
        _route = _buildPolyline(widget.route);
      } else {
        _activityLocations = SkiTracker.getActivity().activityLocations;
      }
    }
    mapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (!widget.staticMap) {
      _startTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isInPreviewMode();
    setState(() {
      if (!_previewMode) {
        if (!widget.staticMap) {
          _activityLocations = SkiTracker.getActivity().activityLocations;
          _route = _buildPolyline(SkiTracker.getActivity().route);
        }
      }
    });
  }

  void _isInPreviewMode() {
    final route = ModalRoute.of(context);
    _previewMode = route?.settings.name != '/fullscreen' && route?.settings.name != '/fullscreenSummary';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_previewMode && SkiTracker.getActivity().currentLatitude != 0.0) {
        mapController.animateTo(
          dest: LatLng(SkiTracker.getActivity().currentLatitude,
              SkiTracker.getActivity().currentLongitude),
        );
      }
    });
  }

  LatLng _calculateMiddlePoint(List<List<double>> coordinates) {
  double minLatitude = double.infinity;
  double maxLatitude = -double.infinity;
  double minLongitude = double.infinity;
  double maxLongitude = -double.infinity;

// Find the minimum and maximum latitude and longitude
  for (List<double> coordinate in coordinates) {
  double latitude = coordinate[0];
  double longitude = coordinate[1];

  minLatitude = latitude < minLatitude ? latitude : minLatitude;
  maxLatitude = latitude > maxLatitude ? latitude : maxLatitude;
  minLongitude = longitude < minLongitude ? longitude : minLongitude;
  maxLongitude = longitude > maxLongitude ? longitude : maxLongitude;
  }

// Calculate the middle point
  double middleLatitude = (maxLatitude + minLatitude) / 2;
  double middleLongitude = (maxLongitude + minLongitude) / 2;

// The middle point
  return LatLng(middleLongitude, middleLatitude);
  }

  TileLayer _tileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
  }

  MarkerLayer _markerLayer() {
    return MarkerLayer(
      markers: [
        Marker(
          width: markerSize,
          height: markerSize,
          point: LatLng(SkiTracker.getActivity().currentLatitude,
              SkiTracker.getActivity().currentLongitude),
          child: CustomPaint(
            painter: LocationMark(),
          ),
        ),
      ],
    );
  }

  TileLayer _pisteLayer() {
    String pistesOnlyOverlayUrl = "https://tiles.opensnowmap.org/pistes/";
    return TileLayer(
      urlTemplate: '$pistesOnlyOverlayUrl{z}/{x}/{y}.png',
    );
  }

  Widget _buildMarker({required LatLng point, required IconData icon}) {
    return MarkerLayer(
      markers: [
        Marker(
          width: markerSize,
          height: markerSize,
          point: point,
          child: Container(
            width: markerSize,
            height: markerSize,
            decoration: BoxDecoration(
              color: ColorTheme.primary,
              borderRadius: BorderRadius.circular(markerSize / 2),
            ),
            child: Icon(
              icon,
              color: ColorTheme.secondary,
              size: markerSize - 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fastestPosition() {
    return _buildMarker(point: LatLng(_activityLocations.fastestLocation[1], _activityLocations.fastestLocation[0]), icon: Icons.speed_rounded);
  }

  Widget _startPosition() {
    return _buildMarker(point: LatLng(_activityLocations.startLocation[1], _activityLocations.startLocation[0]), icon: Icons.play_arrow_rounded);
  }

  Widget _endPosition() {
    return _buildMarker(point: LatLng(_activityLocations.endLocation[1], _activityLocations.endLocation[0]), icon: Icons.flag_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
        mapController: mapController.mapController,
        options: MapOptions(
          backgroundColor: backgroundColor,
          initialCenter: widget.staticMap
              ? _middlePoint
              : LatLng(SkiTracker.getActivity().currentLatitude,
                  SkiTracker.getActivity().currentLongitude),
          initialZoom: widget.staticMap ? zoomOverview : zoomLevel,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          maxZoom: maxZoom,
          minZoom: minZoom,
        ),
        // Layers are drawn in the order they are defined
        children: [
          _tileLayer(),
          if(!widget.staticMap || (!_previewMode && widget.staticMap)) _pisteLayer(),
          if (!_previewMode  || widget.staticMap) PolylineLayer(polylines: _route),
          if((!_previewMode || widget.staticMap) && _activityLocations.startLocation[0] != 0.0) _startPosition(),
          if((!_previewMode || widget.staticMap) && _activityLocations.endLocation[0] != 0.0) _endPosition(),
          if((!_previewMode || widget.staticMap) && _activityLocations.fastestLocation[0] != 0.0) _fastestPosition(),
          if (!_previewMode && !widget.staticMap) _markerLayer(),
        ],
      ),
    ]);
  }

  List<Polyline> _buildPolyline(ActivityRoute route) {
    List<Polyline> polylines = [];
    List<LatLng> polylinePoints = [];

    for (List<double> coordinate in route.coordinates) {
      polylinePoints.add(LatLng(coordinate[1], coordinate[0]));
    }

    Color polylineColor = ColorTheme.primary;

    Polyline polyline = Polyline(
      points: polylinePoints,
      color: polylineColor,
      strokeWidth: 5.0, // Adjust this to your desired line width
    );

    polylines.add(polyline);

    return polylines;
  }

  @override
  void dispose() {
    if(!widget.staticMap) {
      _timer.cancel();
    }
    mapController.dispose();
    super.dispose();
  }
}

const double markerSize = 32.0;
const int markerBorderWidth = 4;
const double interpolationFactorLocationMark = 0.02;
Color locationMark = const Color(0xFF007aff);
Color locationMarkBorder = Colors.white;
Color locationMarkArrow = locationMark;

class LocationMark extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    drawCircle(canvas, size, locationMarkBorder, size.width / 2);
    drawCircle(canvas, size, locationMark, size.width / 2 - markerBorderWidth);
  }

  void drawArrow(Canvas canvas, Size size) {
    var arrow = Paint()
      ..color = locationMarkArrow
      ..style = PaintingStyle.fill;

    double arrowAngle = 270 * (pi / 180);
    double arrowLength = size.width;

    Offset arrowTip = Offset(size.width / 2 + arrowLength * cos(arrowAngle),
        size.height / 2 + arrowLength * sin(arrowAngle));
    Offset arrowBase1 = calculateOffset(size, arrowAngle - pi / 2);
    Offset arrowBase2 = calculateOffset(size, arrowAngle + pi / 2);

    ui.Path path = ui.Path();
    path.moveTo(arrowBase1.dx, arrowBase1.dy);
    path.lineTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(arrowBase2.dx, arrowBase2.dy);
    path.arcTo(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2),
        arrowAngle + pi / 2,
        pi,
        false);
    path.close();

    canvas.drawPath(path, arrow);
  }

  Offset calculateOffset(Size size, double angle) {
    return Offset(size.width / 2 + (size.width / 2 * cos(angle)),
        size.height / 2 + (size.width / 2 * sin(angle)));
  }

  void drawCircle(Canvas canvas, Size size, Color color, double radius) {
    var circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), radius, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint whenever the compass heading changes
  }
}
