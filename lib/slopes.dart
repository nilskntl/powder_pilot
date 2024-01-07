import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ski_tracker/utils/general_utils.dart';

class SlopeMap {
  static final List<Polyline> _slopePolygons = [];
  static final List<Slope> _slopes = [];

  static void addSlope(Slope slope) {
    if(_slopes.contains(slope) || slope.name == 'Unknown') {
      return;
    }
    _slopes.add(slope);
    List<Slope> slopesWithSameName = getSlopesWithSameName(slope.name);
    Slope maximumSlope = slopesWithSameName[0];
    for (slope in slopesWithSameName) {
      if (slope.coordinates.length > slope.coordinates.length) {
        maximumSlope = slope;
      }
    }
    for(slope in slopesWithSameName) {
      if(slope != maximumSlope) {
        slope.removeAllPolyline();
      }
    }
  }

  static List<Slope> getSlopesWithSameName(String slopeName) {
    List<Slope> slopesWithSameName = _slopes.where((slope) => slope.name == slopeName).toList();
    return slopesWithSameName;
  }

  static void addSlopePolylines() {
    for (Slope slope in _slopes) {
      _addPolylineList(slope.polylines);
    }
  }

  static void clearSlopeMap() {
    _slopePolygons.clear();
    _slopes.clear();
  }

  static void _addPolylineList(List<Polyline> polylines) {
    if(polylines.isEmpty) {
      return;
    }
    _slopePolygons.addAll(polylines);
  }

  //static void _clearPolylineList() {
  //  _slopeMap.clear();
  //}

  static String findNearestSlope(double latitude, double longitude) {
    if(_slopes.isEmpty) {
      return 'Unknown';
    } else {
      Slope nearestSlope = _slopes[0];
      double minDistance = double.infinity;

      for (Slope slope in _slopes) {
        double slopeDistance = calculateSlopeDistance(slope, longitude, latitude);
        if (slopeDistance < minDistance) {
          minDistance = slopeDistance;
          nearestSlope = slope;
        }
      }
      return nearestSlope.name;
    }
  }

  static double calculateSlopeDistance(Slope slope, double longitude, double latitude) {
    double minPointDistance = double.infinity;

    for (List<double> point in slope.coordinates) {
      double pointDistance = Utils.calculateHaversineDistance(
        LatLng(latitude, longitude),
        LatLng(point[0], point[1]),
      );
      if (pointDistance < minPointDistance) {
        minPointDistance = pointDistance;
      }
    }
    return minPointDistance;
  }

  static List<Polyline> get slopeMap => _slopePolygons;

  static List<Slope> get slopes => _slopes;
}

class Slope {
  static const _colorSlopeEasy = Color(0xFF0000FF);
  static const _colorSlopeIntermediate = Color(0xFFFF0000);
  static const _colorSlopeDifficult = Color(0xFF000000);
  static const _colorNordic = Color(0xFFFF00FF);
  static const _colorSkiTour = Color(0xFF00FF00);
  static const _colorHike = Color(0xFF00FF00);
  static const _colorSled = Color(0xFF00FF00);
  static const _colorConnection = Color(0xFF000000);
  static const _colorSnowPark = Color(0xFF00FF00);
  static const _colorUnknown = Color(0xFF000000);

  static const double _slopeWidth = 3.0;
  static const double _slopeOpacity = 0.5;
  static const double _restWidth = 3.0;
  static const double _restOpacity = 0.5;

  late final String _name;
  late final String _difficulty;
  late final String _type;
  final List<List<double>> _coordinates = [];
  late final int _id;
  final List<Polyline> _polylines = [];

  late final dynamic _slope;

  Slope({required dynamic slope}) {
    _slope = slope;
    _id = slope['id'] ?? -1;
    _difficulty = slope['tags']['piste:difficulty'] ?? 'Unknown';
    _name = slope['tags']['name'] ?? 'Unknown';
    _type = slope['tags']['piste:type'] ?? 'Unknown';
    _initData();
  }

  void addCoordinate({required double lat, required double lon}) {
    _coordinates.add([lat, lon]);
  }

  void _initData() {
    if (_slope['type'] == 'way') {
      List<List<double>> coordinateList = [];
      for (final point in _slope['geometry']) {
        addCoordinate(lat: point['lat'], lon: point['lon']);
        coordinateList.add([point['lat'], point['lon']]);
      }
      _buildPolyline(coordinateList);
    }
    if (_slope['type'] == 'relation') {
      for (final member in _slope['members']) {
        try {
          List<List<double>> coordinateList = [];
          for (final point in member['geometry']) {
            addCoordinate(lat: point['lat'], lon: point['lon']);
            coordinateList.add([point['lat'], point['lon']]);
          }
          _buildPolyline(coordinateList);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }
  }

  void removeAllPolyline() {
    _polylines.clear();
  }

  Polyline _buildPolyline(List<List<double>> coordinateList) {
    List<LatLng> polylinePoints = coordinateList
        .map((coordinate) => LatLng(coordinate[0], coordinate[1]))
        .toList();

    Color polylineColor = determinePolylineColor();

    double opacity = (_type == 'downhill' || _type == 'snow_park')
        ? _slopeOpacity
        : _restOpacity;
    double width = (_type == 'downhill') ? _slopeWidth : _restWidth;
    bool isDotted =
    (_type == 'downhill' || _type == 'snow_park') ? false : true;

    polylineColor = polylineColor.withOpacity(opacity);

    Polyline polyline = Polyline(
      points: polylinePoints,
      color: polylineColor,
      strokeWidth: width,
      isDotted: isDotted,
    );

    polylines.add(polyline);
    return polyline;
  }

  Color determinePolylineColor() {
    if (_type == 'downhill') {
      return determineDownhillColor();
    } else if (_type == 'nordic') {
      return _colorNordic;
    } else if (_type == 'skitour') {
      return _colorSkiTour;
    } else if (_type == 'hike') {
      return _colorHike;
    } else if (_type == 'sled') {
      return _colorSled;
    } else if (_type == 'connection') {
      return _colorConnection;
    } else if (_type == 'snow_park') {
      return _colorSnowPark;
    } else {
      return _colorUnknown;
    }
  }

  Color determineDownhillColor() {
    if (_difficulty == 'easy') {
      return _colorSlopeEasy;
    } else if (_difficulty == 'intermediate') {
      return _colorSlopeIntermediate;
    } else if (_difficulty == 'difficult') {
      return _colorSlopeDifficult;
    } else {
      return _colorUnknown;
    }
  }

  /* Getter methods */
  String get name => _name;

  String get difficulty => _difficulty;

  String get pisteType => _type;

  List<List<double>> get coordinates => _coordinates;

  int get id => _id;

  Map<String, dynamic> get slope => _slope;

  List<Polyline> get polylines => _polylines;


  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Slope && hashCode == other.hashCode;
  }
}