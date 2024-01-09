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
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarDesign.appBar(title: 'Map'),
      body: SkiTracker.getActivity().activityMap,
    );
  }
}

class ActivityMap extends StatefulWidget {
  const ActivityMap({super.key});

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap>
    with TickerProviderStateMixin {
  static const double zoomLevel = 14.0;
  static const double maxZoom = 18.49;
  static const double minZoom = 4.0;
  static const Color backgroundColor = Color(0xFF777777);

  static const double markerSize = 32.0;

  late AnimatedMapController mapController;

  late Timer _timer;

  late final ActivityDataProvider activityDataProvider;
  bool _initializedDataProvider = false;

  bool _previewMode = true;

  List<Polyline> _fullRoute = [];
  List<Polyline> _currentRoute = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (!_initializedDataProvider) {
      activityDataProvider = SkiTracker.getActivityDataProvider();
      _initializedDataProvider = true;
    }
    super.initState();
    mapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isInPreviewMode();
    setState(() {
      if (!_previewMode) {
        _fullRoute = _buildFullPolylines(SkiTracker.getActivity().fullRoute);
        _currentRoute =
            _buildSinglePolyline(SkiTracker.getActivity().currentRoute);
      }
    });
  }

  void _isInPreviewMode() {
    final route = ModalRoute.of(context);
    _previewMode = route?.settings.name != '/fullscreen';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_previewMode) {
        mapController.animateTo(
          dest: LatLng(SkiTracker.getActivity().currentLatitude,
              SkiTracker.getActivity().currentLongitude),
        );
      }
    });
  }

  TileLayer _tileLayer() {
    return TileLayer(
      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
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

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
        mapController: mapController.mapController,
        options: MapOptions(
          backgroundColor: backgroundColor,
          initialCenter: LatLng(SkiTracker.getActivity().currentLatitude,
              SkiTracker.getActivity().currentLongitude),
          initialZoom: zoomLevel,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          maxZoom: maxZoom,
          minZoom: minZoom,
        ),
        // Layers are drawn in the order they are defined
        children: [
          _tileLayer(),
          _pisteLayer(),
          if (!_previewMode) _markerLayer(),
          if (!_previewMode) PolylineLayer(polylines: _fullRoute),
          if (!_previewMode) PolylineLayer(polylines: _currentRoute),
          // if(!_previewMode) PolylineLayer(polylines: SlopeMap.slopeMap),
        ],
      ),
      if (!_previewMode && activityDataProvider.status != ActivityStatus.inactive && SlopeMap.slopes.isNotEmpty)
        CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: true,
            collapsedHeight: MediaQuery.of(context).size.height -
                172 - MediaQuery.of(context).padding.bottom,
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
                            topLeft: Radius.circular(Status.heightBarContainer),
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
                                    CurrentSlope(
                                        slope:
                                            activityDataProvider.nearestSlope),
                                    const SizedBox(width: 16),
                                    if(activityDataProvider.nearestSlope.name != 'Unknown')
                                    Utils.buildText(
                                        text:
                                            'Slope: ${activityDataProvider.nearestSlope.name}',
                                        color: ColorTheme.contrast,
                                        fontSize: FontTheme.sizeSubHeader,
                                        caps: false,
                                        fontWeight: FontWeight.bold),
                                    if(activityDataProvider.nearestSlope.name == 'Unknown')
                                      Utils.buildText(
                                          text:
                                          'Free Ride',
                                          color: ColorTheme.contrast,
                                          fontSize: FontTheme.sizeSubHeader,
                                          caps: false,
                                          fontWeight: FontWeight.bold),
                                    const Spacer(),
                                    Container(
                                      height: 24,
                                      width: 96,
                                      decoration: BoxDecoration(
                                        color: ColorTheme.green,
                                        borderRadius: BorderRadius.circular(16),
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
                                itemCount: activityDataProvider
                                    .fullRoute.routes.length,
                                itemBuilder: (context, index) {
                                  if (index <
                                      activityDataProvider
                                              .fullRoute.routes.length -
                                          2) {
                                    return ListView.builder(
                                        itemBuilder: (context, index2) {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: ColorTheme.secondary,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            CurrentSlope(
                                                slope: activityDataProvider
                                                    .fullRoute
                                                    .routes[index]
                                                    .slopes[index2]),
                                            const SizedBox(width: 16),
                                            Utils.buildText(
                                                text:
                                                    'Slope: ${activityDataProvider.fullRoute.routes[index].slopes[index2].name}',
                                                color: ColorTheme.contrast,
                                                fontSize:
                                                    FontTheme.sizeSubHeader,
                                                caps: false,
                                                fontWeight: FontWeight.bold),
                                          ],
                                        ),
                                      );
                                    });
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
    ]);
  }

  List<Polyline> _buildFullPolylines(FullRoute fullRoute) {
    List<Polyline> polylines = [];

    for (SingleRoute singleRoute in fullRoute.routes) {
      List<LatLng> polylinePoints = [];

      for (List<double> coordinate in singleRoute.coordinates) {
        polylinePoints.add(LatLng(coordinate[1], coordinate[0]));
      }

      Color polylineColor = Colors.blue; // Default color for type='Downhill'

      if (singleRoute.type == 'Uphill') {
        polylineColor = Colors.red;
      }

      Polyline polyline = Polyline(
        points: polylinePoints,
        color: polylineColor,
        strokeWidth: 3.0, // Adjust this to your desired line width
      );

      polylines.add(polyline);
    }

    return polylines;
  }

  List<Polyline> _buildSinglePolyline(SingleRoute singleRoute) {
    List<Polyline> polylines = [];
    List<LatLng> polylinePoints = [];

    for (List<double> coordinate in singleRoute.coordinates) {
      polylinePoints.add(LatLng(coordinate[1], coordinate[0]));
    }

    Color polylineColor = Colors.blue; // Default color for type='Downhill'

    if (singleRoute.type == 'Uphill') {
      polylineColor = Colors.red;
    }

    if (singleRoute.type == 'Unknown') {
      polylineColor = Colors.black;
    }

    Polyline polyline = Polyline(
      points: polylinePoints,
      color: polylineColor,
      strokeWidth: 3.0, // Adjust this to your desired line width
    );

    polylines.add(polyline);

    return polylines;
  }

  @override
  void dispose() {
    _timer.cancel();
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
