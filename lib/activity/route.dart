import 'dart:convert';

import 'package:powder_pilot/activity/slopes.dart';

/// A class representing an activity route with coordinates and associated slopes.
class ActivityRoute {
  /// List of coordinates representing the route.
  final List<List<double>> coordinates;

  /// List of SlopeInfo objects associated with the route.
  final List<SlopeInfo> slopes;

  /// Constructs an ActivityRoute object with the given coordinates and slopes.
  const ActivityRoute({
    required this.coordinates,
    required this.slopes,
  });

  /// Constructs an ActivityRoute object from a JSON string.
  ///
  /// @param jsonString A JSON string representing the ActivityRoute.
  factory ActivityRoute.fromString(String jsonString) {
    return ActivityRoute.fromJson(jsonDecode(jsonString));
  }

  /// Constructs an ActivityRoute object from a JSON map.
  ///
  /// @param json A JSON map representing the ActivityRoute.
  factory ActivityRoute.fromJson(Map<String, dynamic> json) {
    return ActivityRoute(
      coordinates: List<List<double>>.from(
        json['coordinates'].map((coord) => List<double>.from(coord)),
      ),
      slopes: List<SlopeInfo>.from(
        json['slopes'].map((slope) => SlopeInfo.fromJson(slope)),
      ),
    );
  }

  /// Converts the ActivityRoute object to a JSON map.
  ///
  /// @return A JSON map representing the ActivityRoute.
  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates.map((coord) => coord.toList()).toList(),
      'slopes': slopes.map((slope) => slope.toJson()).toList(),
    };
  }

  /// Converts a list of ActivityRoute objects to a JSON string.
  ///
  /// @param list A list of ActivityRoute objects.
  /// @return A JSON string representing the list of ActivityRoute objects.
  static String listToString(List<ActivityRoute> list) {
    return jsonEncode(list.map((route) => route.toJson()).toList());
  }

  /// Converts the ActivityRoute object to a JSON string.
  ///
  /// @return A JSON string representing the ActivityRoute object.
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  /// Converts a JSON string to an ActivityRoute object.
  ///
  /// @param jsonString A JSON string representing the ActivityRoute.
  /// @return An ActivityRoute object.
  static ActivityRoute stringToRoute(String jsonString) {
    return ActivityRoute.fromJson(jsonDecode(jsonString));
  }

  /// Adds a slope to the list of slopes associated with the route.
  ///
  /// @param nearestSlope The nearest slope to add.
  void addSlope(Slope nearestSlope) {
    if (slopes.isEmpty) {
      slopes.add(SlopeInfo(
        name: nearestSlope.ref,
        type: nearestSlope.type,
        startTime: DateTime.now(),
      ));
    } else {
      if (slopes.last.name == nearestSlope.ref &&
          slopes.last.type == nearestSlope.type) {
        return;
      }
      slopes.last.endTime = DateTime.now();
      /// Check if last slope was longer then 30s otherwise delete the slope
      if (slopes.last.endTime.difference(slopes.last.startTime).inSeconds < 5) {
        slopes.removeLast();
      }
      /// Check if its now the same slope
      if (slopes.last.name == nearestSlope.ref &&
          slopes.last.type == nearestSlope.type) {
        return;
      }
      /// Set the end time of the last slope and add a new slope
      slopes.last.endTime = DateTime.now();
      slopes.add(SlopeInfo(
        name: nearestSlope.ref,
        type: nearestSlope.type,
        startTime: DateTime.now(),
      ));
    }
  }

  /// Adds coordinates to the list of route coordinates.
  ///
  /// @param list A list of coordinates to add.
  void addCoordinates(List<double> list) {
    coordinates.add(list);
  }
}
