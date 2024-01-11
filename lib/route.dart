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
    if(slopes.isEmpty) {
      slopes.add(SlopeInfo(
        name: nearestSlope.name,
        difficulty: nearestSlope.difficulty,
        startTime: DateTime.now(),
      ));
    } else {
      if(slopes.last.name == nearestSlope.name && slopes.last.difficulty == nearestSlope.difficulty) {
        return;
      }
      slopes.last.endTime = DateTime.now();
      // Check if last slope was longer then 30s otherwise delete the slope
      if(slopes.last.endTime.difference(slopes.last.startTime).inSeconds < 5) {
        slopes.removeLast();
      }
      // Check if its now the same slope
      if(slopes.last.name == nearestSlope.name && slopes.last.difficulty == nearestSlope.difficulty) {
        return;
      }
      slopes.last.endTime = DateTime.now();
      slopes.add(SlopeInfo(
        name: nearestSlope.name,
        difficulty: nearestSlope.difficulty,
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
  late String _difficulty;
  late DateTime _startTime;
  late DateTime endTime;

  SlopeInfo({
    required String name,
    required String difficulty,
    required DateTime startTime,
  }) {
    _name = name;
    _difficulty = difficulty;
    _startTime = startTime;
  }

  String get name => _name;

  String get difficulty => _difficulty;

  DateTime get startTime => _startTime;

  // from Json
  factory SlopeInfo.fromString(String jsonString) {
    return SlopeInfo.fromJson(jsonDecode(jsonString));
  }

  // Factory-Methode zum Erstellen eines Objekts aus einer Map
  factory SlopeInfo.fromJson(Map<String, dynamic> json) {
    SlopeInfo slopeInfo = SlopeInfo(
      name: json['name'],
      difficulty: json['difficulty'],
      startTime: DateTime.parse(json['endTime']),
    );
    slopeInfo.endTime = DateTime.parse(json['endTime']);
    return slopeInfo;
  }

  // Methode zum Konvertieren des Objekts in eine Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'difficulty': difficulty,
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
      name: slope.name,
      difficulty: slope.difficulty,
      startTime: DateTime.now(),
    );
  }

  // toString Method
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}