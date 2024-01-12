import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:ski_tracker/utils/general_utils.dart';
import 'dart:math' as math;

class SlopeMap {
  static final List<Slope> _slopes = [];

  static void addSlope(Slope slope) {
    if (_slopes.contains(slope)) {
      // Add coordinates to slope
      _slopes[_slopes.indexOf(slope)].coordinates.addAll(slope.coordinates);
      _slopes[_slopes.indexOf(slope)].removeDuplicates();
    } else {
      _slopes.add(slope);
    }
  }

  static void clearSlopeMap() {
    _slopes.clear();
  }

  // Get a list of possible near Slopes
  static double distanceBuffer = 60;

  static Slope findNearestSlope({required double latitude, required double longitude, bool lift = false}) {
    if (_slopes.isEmpty) {
      return Slope(empty: true);
    }

    double calculateDistanceToLine(double latitude, double longitude,
        double x1, double y1, double x2, double y2) {

      double segmentLengthSquared = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);

      if (segmentLengthSquared == 0) {
        // Handle case where the line segment is just a point
        return math.sqrt((longitude - x1) * (longitude - x1) + (latitude - y1) * (latitude - y1));
      }

      double t = math.max(0, math.min(1, ((longitude - x1) * (x2 - x1) + (latitude - y1) * (y2 - y1)) / segmentLengthSquared));
      double projectedX = x1 + t * (x2 - x1);
      double projectedY = y1 + t * (y2 - y1);

      const double degreesToKilometers = 111.0;
      const double metersConversionFactor = degreesToKilometers * 1000.0;

      return math.sqrt((longitude - projectedX) * (longitude - projectedX) + (latitude - projectedY) * (latitude - projectedY)) * metersConversionFactor;
    }

    Slope nearestSlope = _slopes[0];
    double minDistance = double.infinity;

    Slope nearestSlopeAfterPoint = _slopes[0];
    double minDistanceAfterPoint = double.infinity;

    double betterDistance = double.infinity;

    double getDistanceByIndex(
        {required Slope slope,
        required int firstIndex,
        required int secondIndex, required double distanceToPoint}) {
      if(distanceToPoint > 200) {
        return distanceToPoint;
      }
      double x1 = slope.coordinates[firstIndex][1];
      double y1 = slope.coordinates[firstIndex][0];
      double x2 = slope.coordinates[secondIndex][1];
      double y2 = slope.coordinates[secondIndex][0];

      double distanceToLine =
          calculateDistanceToLine(latitude, longitude, x1, y1, x2, y2);

      if (distanceToLine < minDistance) {
        minDistance = distanceToLine;
        betterDistance = distanceToPoint;
        nearestSlope = slope;
      }

      return distanceToLine;
    }

    for (Slope slope in _slopes) {
      if (((!slope.lift && !lift) || (slope.lift && lift)) && slope.coordinates.isNotEmpty) {
        List<double> distanceToSlope =
            calculateSlopeDistance(slope, longitude, latitude);
        int indexOfNearestPoint = distanceToSlope[1].toInt();
        double slopeDistanceToPoint = distanceToSlope[0];

        if(slopeDistanceToPoint < minDistanceAfterPoint) {
          minDistanceAfterPoint = slopeDistanceToPoint;
          nearestSlopeAfterPoint = slope;
        }

        if (slope.coordinates.length > 1) {
          // Check if the nearest point is the first or last point in the slope
          if (indexOfNearestPoint != 0) {
            getDistanceByIndex(
                slope: slope,
                firstIndex: indexOfNearestPoint - 1,
                secondIndex: indexOfNearestPoint, distanceToPoint: slopeDistanceToPoint);
          }
          if (indexOfNearestPoint != slope.coordinates.length - 1) {
            getDistanceByIndex(
                slope: slope,
                firstIndex: indexOfNearestPoint,
                secondIndex: indexOfNearestPoint + 1, distanceToPoint: slopeDistanceToPoint);
          }
        } else {
          // Only one point in the slope, calculate distance directly
          if (slopeDistanceToPoint < minDistance) {
            minDistance = slopeDistanceToPoint;
            nearestSlope = slope;
          }
        }
      }
    }

    if(!lift) {
      if (minDistance > distanceBuffer) {
        return Slope(empty: true);
      }
    }

    return nearestSlope;
  }

  static List<double> calculateSlopeDistance(
      Slope slope, double longitude, double latitude) {
    double minPointDistance = double.infinity;
    int index = 0;

    for (List<double> point in slope.coordinates) {
      double pointDistance = Utils.calculateHaversineDistance(
        LatLng(latitude, longitude),
        LatLng(point[0], point[1]),
      );
      if (pointDistance < minPointDistance) {
        minPointDistance = pointDistance;
        index = slope.coordinates.indexOf(point);
      }
    }
    return [minPointDistance, index.toDouble()];
  }

  static List<Slope> get slopes => _slopes;
}

class Slope {
  late final String _ref;
  late final String _type;
  final List<List<double>> _coordinates = [];

  late final bool _lift;

  late final Map<String, dynamic> _slope;

  late final bool _empty;

  Slope(
      {Map<String, dynamic> slope = const {},
      bool lift = false,
      bool empty = false}) {
    _empty = empty;
    _lift = lift;
    if (lift && !empty) {
      _slope = slope;
      _type = slope['tags']['aerialway'] ?? 'Unknown';
      String name = slope['tags']['name'] ?? 'Unknown';
      _ref = name != 'Unknown'
          ? '$name '
          : '' + (slope['tags']['ref'] ?? 'Unknown');
      _initData();
    }
    if (!empty && !lift) {
      _slope = slope;
      _type = slope['tags']['piste:difficulty'] ?? 'Unknown';
      _ref = slope['tags']['ref'] ?? slope['tags']['name'] ?? 'Unknown';
      _initData();
    }
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
  String get ref => !_empty ? _ref : 'Unknown';

  String get type => !_empty ? _type : 'Unknown';

  String get pisteType => !_empty ? _type : 'Unknown';

  List<List<double>> get coordinates => !_empty ? _coordinates : [];

  Map<String, dynamic> get slope => !_empty ? _slope : {};

  bool get lift => _lift;

  @override
  int get hashCode => ref.hashCode + type.hashCode + lift.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Slope && hashCode == other.hashCode;
  }
}
