import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../utils/general_utils.dart';

/// A class that manages slopes, including adding slopes, finding the nearest slope, and clearing the slope map.
class SlopeMap {
  /// List of slopes.
  static final List<Slope> _slopes = [];

  /// Adds a slope to the slope map. If the slope already exists, coordinates are added, and duplicates are removed.
  static void addSlope(Slope slope) {
    if (_slopes.contains(slope)) {
      _slopes[_slopes.indexOf(slope)].coordinates.addAll(slope.coordinates);
      _slopes[_slopes.indexOf(slope)].removeDuplicates();
    } else {
      _slopes.add(slope);
    }
  }

  /// Clears all slopes from the slope map.
  static void clearSlopeMap() {
    _slopes.clear();
  }

  /// Distance buffer for finding near slopes.
  static double distanceBuffer = 60;

  /// Finds the nearest slope to a given location.
  ///
  /// @param latitude Latitude of the location.
  /// @param longitude Longitude of the location.
  /// @param lift Indicates if the slope is a lift.
  /// @return Nearest slope to the location.
  static Slope findNearestSlope({
    required double latitude,
    required double longitude,
    bool lift = false,
  }) {
    if (_slopes.isEmpty) {
      return Slope(empty: true);
    }

    /// Calculates the distance from a point to a line segment.
    ///
    /// @param latitude Latitude of the point.
    /// @param longitude Longitude of the point.
    /// @param x1 Longitude of the first point in the line segment.
    /// @param y1 Latitude of the first point in the line segment.
    /// @param x2 Longitude of the second point in the line segment.
    /// @param y2 Latitude of the second point in the line segment.
    /// @return The distance from the point to the line segment.
    double calculateDistanceToLine(double latitude, double longitude, double x1,
        double y1, double x2, double y2) {
      double segmentLengthSquared =
          (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);

      if (segmentLengthSquared == 0) {
        /// Handle case where the line segment is just a point
        return math.sqrt((longitude - x1) * (longitude - x1) +
            (latitude - y1) * (latitude - y1));
      }

      /// Calculate the distance from the point to the line segment
      double t = math.max(
          0,
          math.min(
              1,
              ((longitude - x1) * (x2 - x1) + (latitude - y1) * (y2 - y1)) /
                  segmentLengthSquared));
      double projectedX = x1 + t * (x2 - x1);
      double projectedY = y1 + t * (y2 - y1);

      /// Convert the distance from degrees to meters
      const double degreesToKilometers = 111.0;
      const double metersConversionFactor = degreesToKilometers * 1000.0;

      return math.sqrt((longitude - projectedX) * (longitude - projectedX) +
          (latitude - projectedY) * (latitude - projectedY)) *
          metersConversionFactor;
    }

    Slope nearestSlope = _slopes[0];
    double minDistance = double.infinity;

    /// Calculates the distance from a point to a line segment.
    ///
    /// @param slope The slope for which to calculate the distance.
    /// @param firstIndex The index of the first point in the line segment.
    /// @param secondIndex The index of the second point in the line segment.
    /// @param distanceToPoint The distance from the point to the slope.
    /// @return The distance from the point to the line segment.
    double getDistanceByIndex({
      required Slope slope,
      required int firstIndex,
      required int secondIndex,
      required double distanceToPoint,
    }) {
      if (distanceToPoint > 200) {
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
        nearestSlope = slope;
      }

      return distanceToLine;
    }

    /// Iterate through slopes to find the nearest one
    for (Slope slope in _slopes) {
      if (((!slope.lift && !lift) || (slope.lift && lift)) &&
          slope.coordinates.isNotEmpty) {
        List<double> distanceToSlope =
        calculateSlopeDistance(slope, longitude, latitude);
        int indexOfNearestPoint = distanceToSlope[1].toInt();
        double slopeDistanceToPoint = distanceToSlope[0];

        if (slope.coordinates.length > 1) {
          /// Check if the nearest point is the first or last point in the slope
          if (indexOfNearestPoint != 0) {
            getDistanceByIndex(
                slope: slope,
                firstIndex: indexOfNearestPoint - 1,
                secondIndex: indexOfNearestPoint,
                distanceToPoint: slopeDistanceToPoint);
          }
          if (indexOfNearestPoint != slope.coordinates.length - 1) {
            getDistanceByIndex(
                slope: slope,
                firstIndex: indexOfNearestPoint,
                secondIndex: indexOfNearestPoint + 1,
                distanceToPoint: slopeDistanceToPoint);
          }
        } else {
          /// Only one point in the slope, calculate distance directly
          if (slopeDistanceToPoint < minDistance) {
            minDistance = slopeDistanceToPoint;
            nearestSlope = slope;
          }
        }
      }
    }

    /// Check if the nearest slope is within the distance buffer
    if (!lift) {
      if (minDistance > distanceBuffer) {
        return Slope(empty: true);
      }
    }

    return nearestSlope;
  }

  /// Calculates the distance from a point to the slope and returns the nearest point's distance and index.
  ///
  /// @param slope The slope for which to calculate the distance.
  /// @param longitude Longitude of the point.
  /// @param latitude Latitude of the point.
  /// @return List containing the distance and index of the nearest point.
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

  /// Gets the list of slopes.
  static List<Slope> get slopes => _slopes;
}

/// A class representing a slope with coordinates, type, and reference information.
class Slope {
  late final String _ref;
  late final String _type;
  final List<List<double>> _coordinates = [];

  late final bool _lift;

  late final Map<String, dynamic> _slope;

  late final bool _empty;

  /// Constructs a Slope object based on slope information, lift status, and empty status.
  Slope({
    Map<String, dynamic> slope = const {},
    bool lift = false,
    bool empty = false,
  }) {
    _empty = empty;
    _lift = lift;
    if (lift && !empty) {
      _slope = slope;
      _type = slope['tags']['aerialway'] ?? 'Unknown';
      String name = slope['tags']['name'] ?? 'Unknown';
      _ref = name != 'Unknown' ? '$name ' : (slope['tags']['ref'] ?? 'Unknown');
      _initData();
    }
    if (!empty && !lift) {
      _slope = slope;
      _type = slope['tags']['piste:difficulty'] ?? 'Unknown';
      _ref = slope['tags']['ref'] ?? slope['tags']['name'] ?? 'Unknown';
      _initData();
    }
  }

  /// Adds a coordinate to the slope.
  ///
  /// @param lat Latitude of the coordinate.
  /// @param lon Longitude of the coordinate.
  void addCoordinate({required double lat, required double lon}) {
    _coordinates.add([lat, lon]);
  }

  /// Initializes slope data from the provided slope information.
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
    }  }

  /// Removes duplicate coordinates from the slope.
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

  /// Gets the reference of the slope.
  String get ref => !_empty ? _ref : 'Unknown';

  /// Gets the type of the slope.
  String get type => !_empty ? _type : 'Unknown';

  /// Gets the piste type of the slope.
  String get pisteType => !_empty ? _type : 'Unknown';

  /// Gets the list of coordinates of the slope.
  List<List<double>> get coordinates => !_empty ? _coordinates : [];

  /// Gets the slope information as a map.
  Map<String, dynamic> get slope => !_empty ? _slope : {};

  /// Checks if the slope is a lift.
  bool get lift => _lift;

  @override
  /// Gets the hash code of the slope.
  int get hashCode => ref.hashCode + type.hashCode + lift.hashCode;

  @override
  /// Checks if the slope is equal to another object.
  bool operator ==(Object other) {
    return other is Slope && hashCode == other.hashCode;
  }

}

/// A class representing additional information about a slope, including name, type, start time, and end time.
class SlopeInfo {
  late String _name;
  late String _type;
  late DateTime _startTime;
  late DateTime endTime;

  /// Constructs a SlopeInfo object with the provided name, type, and start time.
  SlopeInfo({
    required String name,
    required String type,
    required DateTime startTime,
  }) {
    _name = name;
    _type = type;
    _startTime = startTime;
  }

  /// Gets the name of the slope.
  String get name => _name;

  /// Gets the type of the slope.
  String get type => _type;

  /// Gets the start time of the slope.
  DateTime get startTime => _startTime;

  /// Sets the start time of the slope.
  ///
  /// @param startTime The start time of the slope.
  /// @return The start time of the slope.
  factory SlopeInfo.fromString(String jsonString) {
    return SlopeInfo.fromJson(jsonDecode(jsonString));
  }

  /// Converts the SlopeInfo object to a Map.
  ///
  /// @param json A Map representation of the SlopeInfo object.
  /// @return A Map representation of the SlopeInfo object.
  factory SlopeInfo.fromJson(Map<String, dynamic> json) {
    SlopeInfo slopeInfo = SlopeInfo(
      name: json['name'],
      type: json['type'],
      startTime: DateTime.parse(json['endTime']),
    );
    slopeInfo.endTime = DateTime.parse(json['endTime']);
    return slopeInfo;
  }

  /// Converts the SlopeInfo object to a Map.
  ///
  /// @return A Map representation of the SlopeInfo object.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
    };
  }

  /// Converts a list of SlopeInfo objects to a String.
  ///
  /// @param list A list of SlopeInfo objects.
  /// @return A String representation of the list of SlopeInfo objects.
  static String listToString(List<SlopeInfo> list) {
    return jsonEncode(list.map((slopeInfo) => slopeInfo.toJson()).toList());
  }

  /// Converts a Slope object to a SlopeInfo object.
  ///
  /// @param slope A Slope object.
  /// @return A SlopeInfo object.
  static SlopeInfo slopeToSlopeInfo(Slope slope) {
    return SlopeInfo(
      name: slope.ref,
      type: slope.type,
      startTime: DateTime.now(),
    );
  }

  /// Converts the SlopeInfo object to a String.
  ///
  /// @return A String representation of the SlopeInfo object.
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

