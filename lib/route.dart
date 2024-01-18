import 'dart:convert';

import 'package:ski_tracker/slopes.dart';

class ActivityRoute {
  final List<List<double>> coordinates;
  final List<SlopeInfo> slopes;

  const ActivityRoute({
    required this.coordinates,
    required this.slopes,
  });

  // from Json
  factory ActivityRoute.fromString(String jsonString) {
    return ActivityRoute.fromJson(jsonDecode(jsonString));
  }

  // Factory-Methode zum Erstellen eines Objekts aus einer Map
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

  // Methode zum Konvertieren des Objekts in eine Map
  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates.map((coord) => coord.toList()).toList(),
      'slopes': slopes.map((slope) => slope.toJson()).toList(),
    };
  }

  // Convert List of SlopeInfo to String
  static String listToString(List<ActivityRoute> list) {
    return jsonEncode(list.map((route) => route.toJson()).toList());
  }

  // toString Method
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  // String to Route
  static ActivityRoute stringToRoute(String jsonString) {
    return ActivityRoute.fromJson(jsonDecode(jsonString));
  }

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
      // Check if last slope was longer then 30s otherwise delete the slope
      if (slopes.last.endTime.difference(slopes.last.startTime).inSeconds < 5) {
        slopes.removeLast();
      }
      // Check if its now the same slope
      if (slopes.last.name == nearestSlope.ref &&
          slopes.last.type == nearestSlope.type) {
        return;
      }
      slopes.last.endTime = DateTime.now();
      slopes.add(SlopeInfo(
        name: nearestSlope.ref,
        type: nearestSlope.type,
        startTime: DateTime.now(),
      ));
    }
  }

  void addCoordinates(List<double> list) {
    coordinates.add(list);
  }
}

class SlopeInfo {
  late String _name;
  late String _type;
  late DateTime _startTime;
  late DateTime endTime;

  SlopeInfo({
    required String name,
    required String type,
    required DateTime startTime,
  }) {
    _name = name;
    _type = type;
    _startTime = startTime;
  }

  String get name => _name;

  String get type => _type;

  DateTime get startTime => _startTime;

  // from Json
  factory SlopeInfo.fromString(String jsonString) {
    return SlopeInfo.fromJson(jsonDecode(jsonString));
  }

  // Factory-Methode zum Erstellen eines Objekts aus einer Map
  factory SlopeInfo.fromJson(Map<String, dynamic> json) {
    SlopeInfo slopeInfo = SlopeInfo(
      name: json['name'],
      type: json['type'],
      startTime: DateTime.parse(json['endTime']),
    );
    slopeInfo.endTime = DateTime.parse(json['endTime']);
    return slopeInfo;
  }

  // Methode zum Konvertieren des Objekts in eine Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
    };
  }

  // Convert List of SlopeInfo to String
  static String listToString(List<SlopeInfo> list) {
    return jsonEncode(list.map((slopeInfo) => slopeInfo.toJson()).toList());
  }

  static SlopeInfo slopeToSlopeInfo(Slope slope) {
    return SlopeInfo(
      name: slope.ref,
      type: slope.type,
      startTime: DateTime.now(),
    );
  }

  // toString Method
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
