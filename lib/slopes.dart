import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:ski_tracker/utils/general_utils.dart';

class SlopeMap {
  static final List<Slope> _slopes = [];

  static void addSlope(Slope slope) {
    if(_slopes.contains(slope)) {
      // Add coordinates to slope
      _slopes[_slopes.indexOf(slope)].coordinates.addAll(slope.coordinates);
      _slopes[_slopes.indexOf(slope)].removeDuplicates();
    } else {
      _slopes.add(slope);
    }
  }

  static List<Slope> getSlopesWithSameName(String slopeName) {
    List<Slope> slopesWithSameName = _slopes.where((slope) => slope.name == slopeName).toList();
    return slopesWithSameName;
  }

  static void clearSlopeMap() {
    _slopes.clear();
  }

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

  static List<Slope> get slopes => _slopes;
}

class Slope {

  late final String _name;
  late final String _difficulty;
  late final String _type;
  final List<List<double>> _coordinates = [];

  late final dynamic _slope;

  Slope({required dynamic slope}) {
    _slope = slope;
    _difficulty = slope['tags']['piste:difficulty'] ?? 'Unknown';
    _name = slope['tags']['ref'] ?? 'Unknown';
    _type = slope['tags']['piste:type'] ?? 'Unknown';
    _initData();
  }

  void addCoordinate({required double lat, required double lon}) {
    _coordinates.add([lat, lon]);
  }

  void _initData() {
    if (_slope['type'] == 'way') {
      for (final point in _slope['geometry']) {
        addCoordinate(lat: point['lat'], lon: point['lon']);
      }
    }
    if (_slope['type'] == 'relation') {
      for (final member in _slope['members']) {
        try {
          for (final point in member['geometry']) {
            addCoordinate(lat: point['lat'], lon: point['lon']);
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }
  }

  void removeDuplicates() {
    Set<List<double>> uniqueSet = {};
    List<List<double>> uniqueList = [];

    for (List<double> coord in _coordinates) {
      if (uniqueSet.add(coord)) {
        uniqueList.add(coord);
      }
    }
    _coordinates.clear();
    _coordinates.addAll(uniqueList);
  }

  /* Getter methods */
  String get name => _name;

  String get difficulty => _difficulty;

  String get pisteType => _type;

  List<List<double>> get coordinates => _coordinates;

  Map<String, dynamic> get slope => _slope;


  @override
  // TODO: implement hashCode
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Slope && hashCode == other.hashCode;
  }
}