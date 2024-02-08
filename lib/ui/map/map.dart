import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:powder_pilot/ui/activity/status/status.dart';
import 'package:powder_pilot/ui/widgets/slope_circle.dart';

import '../../activity/data.dart';
import '../../activity/data_provider.dart';
import '../../activity/route.dart';
import '../../activity/slopes.dart';
import '../../activity/state.dart';
import '../../main.dart';
import '../../theme/color.dart';
import '../../theme/font.dart';
import '../../theme/icon.dart';
import '../../utils/general_utils.dart';
import '../widgets/app_bar.dart';
import 'location_mark.dart';

class MapPage extends StatefulWidget {
  const MapPage(
      {super.key, required this.dataProvider, required this.activityMap});

  final ActivityDataProvider dataProvider;

  final ActivityMap activityMap;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMaterialAppBar.appBar(title: 'Map'),
      body: Stack(
        children: [
          if (widget.dataProvider.status == ActivityStatus.inactive ||
              SlopeMap.slopes.isEmpty ||
              widget.dataProvider.route.slopes.isEmpty)
            widget.activityMap,
          if (widget.dataProvider.status != ActivityStatus.inactive &&
              SlopeMap.slopes.isNotEmpty &&
              widget.dataProvider.route.slopes.isNotEmpty)
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
                            decoration: BoxDecoration(
                              color: ColorTheme.background,
                              borderRadius: const BorderRadius.only(
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
                              decoration: BoxDecoration(
                                color: ColorTheme.background,
                              ),

                              /// Make an entry for every route in the full route of widget.activityDataProvider.route except the last one
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
                                        if (widget.dataProvider.route.slopes
                                            .isNotEmpty)
                                          SlopeCircle(
                                            slope: widget
                                                .dataProvider.route.slopes.last,
                                            animated: true,
                                          ),
                                        const SizedBox(width: 16),
                                        if (widget.dataProvider.route.slopes
                                            .isNotEmpty)
                                          SlopeCircle.buildSlopeName(
                                              slope: widget.dataProvider.route
                                                  .slopes.last),
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
                                    itemCount:
                                        widget.dataProvider.route.slopes.length,
                                    itemBuilder: (context, index) {
                                      if (index !=
                                          widget.dataProvider.route.slopes
                                                  .length -
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
                                              SlopeCircle(
                                                  slope: widget.dataProvider
                                                      .route.slopes[index]),
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
                                                              .dataProvider
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
                                                  SlopeCircle.buildSlopeName(
                                                      slope: widget.dataProvider
                                                          .route.slopes[index]),
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
                                                                  .dataProvider
                                                                  .route
                                                                  .slopes[index]
                                                                  .endTime
                                                                  .difference(widget
                                                                      .dataProvider
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
      {super.key, required this.route, required this.activityMap});

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
      appBar: CustomMaterialAppBar.appBar(title: 'Map'),
      body: Stack(
        children: [
          if (widget.route.slopes.isEmpty) widget.activityMap,
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
                            decoration: BoxDecoration(
                              color: ColorTheme.background,
                              borderRadius: const BorderRadius.only(
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
                              decoration: BoxDecoration(
                                color: ColorTheme.background,
                              ),

                              /// Make an entry for every route in the full route of widget.activityDataProvider.route except the last one
                              child: Column(
                                children: [
                                  ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: widget.route.slopes.length,
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
                                            SlopeCircle(
                                                slope:
                                                    widget.route.slopes[index]),
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
                                                            FontTheme.size - 4,
                                                        color: ColorTheme.grey,
                                                        caps: false),
                                                    const SizedBox(width: 4),
                                                    Utils.buildText(
                                                        text: Utils
                                                            .durationStringToString(widget
                                                                .route
                                                                .slopes[index]
                                                                .startTime
                                                                .toString())[1],
                                                        caps: false,
                                                        fontSize:
                                                            FontTheme.size - 4,
                                                        color: ColorTheme
                                                            .contrast),
                                                  ],
                                                ),
                                                SlopeCircle.buildSlopeName(
                                                    slope: widget
                                                        .route.slopes[index]),
                                                Row(
                                                  children: [
                                                    Utils.buildText(
                                                        text: 'Duration: ',
                                                        fontSize:
                                                            FontTheme.size - 4,
                                                        color: ColorTheme.grey,
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
                                                            FontTheme.size - 4,
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
      this.route = const ActivityRoute(coordinates: [], slopes: []),
      this.activityLocations = const ActivityLocations()});

  final bool staticMap;
  final ActivityRoute route;
  final ActivityLocations activityLocations;

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap>
    with TickerProviderStateMixin {
  static const double zoomLevel = 14.0;
  static const double zoomOverview = 14.0;
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
    if (widget.route.coordinates.isNotEmpty) {
      if (widget.staticMap) {
        _middlePoint = _calculateMiddlePoint(widget.route.coordinates);
        _route = _buildPolyline(widget.route);
      } else {
        _activityLocations = PowderPilot.activity.activityLocations;
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
          _activityLocations = PowderPilot.activity.activityLocations;
          _route = _buildPolyline(PowderPilot.activity.route);
        }
      }
    });
  }

  void _isInPreviewMode() {
    final route = ModalRoute.of(context);
    _previewMode = route?.settings.name != '/fullscreen' &&
        route?.settings.name != '/fullscreenSummary';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_previewMode && PowderPilot.activity.latitude != 0.0) {
        mapController.animateTo(
          dest: LatLng(PowderPilot.locationService.latitude,
              PowderPilot.locationService.longitude),
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
          point: LatLng(PowderPilot.locationService.latitude,
              PowderPilot.locationService.longitude),
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
        additionalOptions: const {
          'referer': 'com.lumino.powder_pilot',
        });
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
    return _buildMarker(
        point: LatLng(_activityLocations.fastestLocation[1],
            _activityLocations.fastestLocation[0]),
        icon: LogoTheme.speed);
  }

  Widget _startPosition() {
    return _buildMarker(
        point: LatLng(_activityLocations.startLocation[1],
            _activityLocations.startLocation[0]),
        icon: LogoTheme.start);
  }

  Widget _endPosition() {
    return _buildMarker(
        point: LatLng(_activityLocations.endLocation[1],
            _activityLocations.endLocation[0]),
        icon: LogoTheme.end);
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
              : LatLng(PowderPilot.locationService.latitude,
                  PowderPilot.locationService.longitude),
          initialZoom: widget.staticMap ? zoomOverview : zoomLevel,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          maxZoom: maxZoom,
          minZoom: minZoom,
        ),

        /// Layers are drawn in the order they are defined
        children: [
          _tileLayer(),
          if (!widget.staticMap || (!_previewMode && widget.staticMap))
            _pisteLayer(),
          if (!_previewMode || widget.staticMap)
            PolylineLayer(polylines: _route),
          if ((!_previewMode || widget.staticMap) &&
              _activityLocations.startLocation[0] != 0.0)
            _startPosition(),
          if ((!_previewMode || widget.staticMap) &&
              _activityLocations.endLocation[0] != 0.0)
            _endPosition(),
          if ((!_previewMode || widget.staticMap) &&
              _activityLocations.fastestLocation[0] != 0.0)
            _fastestPosition(),
          if (!_previewMode && !widget.staticMap) _markerLayer(),
        ],
      ),
      if (!_previewMode)
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () {
              _showCreditsDialog(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Utils.buildText(
                      text: 'opensnowmap.org',
                      caps: false,
                      color: ColorTheme.contrast,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  const SizedBox(width: 8),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: ColorTheme.contrast.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Utils.buildText(
                        text: 'c',
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.grey,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
    ]);
  }

  /// Shows the credits dialog
  ///
  /// @param context The context
  void _showCreditsDialog(BuildContext context) {
    String credit =
        "Map data provided by opensnowmap.org. Ski resort slopes used with kind permission. Data (c) www.openstreetmap.org & contributors ODBL and www.opensnowmap.org CC-BY-SA.";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorTheme.background,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Utils.buildText(
                  text: credit,
                  caps: false,
                  color: ColorTheme.contrast,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  align: TextAlign.left),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Utils.buildText(
                  text: 'OK',
                  caps: false,
                  color: ColorTheme.contrast,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  /// Build the polyline
  ///
  /// @param route The route
  List<Polyline> _buildPolyline(ActivityRoute route) {
    List<Polyline> polylines = [];
    List<LatLng> polylinePoints = [];

    for (List<double> coordinate in route.coordinates) {
      polylinePoints.add(LatLng(coordinate[1], coordinate[0]));
    }

    Color polylineColor = ColorTheme.primary;

    /// Design of the polyline
    Polyline polyline = Polyline(
      points: polylinePoints,
      color: polylineColor,
      strokeWidth: 5.0,
    );

    polylines.add(polyline);

    return polylines;
  }

  @override
  void dispose() {
    try {
      if (!widget.staticMap) {
        _timer.cancel();
      }
      mapController.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error in dispose: $e');
      }
    }
    super.dispose();
  }
}
