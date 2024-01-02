import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:ski_tracker/main.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  late AnimatedMapController mapController;

  late Timer _timer;

  bool _previewMode = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('Map init state');
    }
    mapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode) {
      print('Map dependencies changed');
    }
    _isInPreviewMode();
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

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
      ],
    );
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('Map dispose');
    }
    _timer.cancel();
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
