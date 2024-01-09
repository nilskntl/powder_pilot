import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:ski_tracker/slopes.dart';
import 'package:ski_tracker/utils/general_utils.dart';

class SingleRoute {
  String type;
  List<List<double>> coordinates;
  List<List<double>> simplifiedCoordinates = [];
  DateTime startTime;
  DateTime endTime;
  List<Slope> slopes = [];

  bool calculatedSlopes = false;

  SingleRoute({
    required this.type,
    required this.coordinates,
    DateTime? startTime,
    DateTime? endTime,
  })  : startTime = startTime ?? DateTime.now(),
        endTime = endTime ?? DateTime.now();

  // Factory-Methode zum Erstellen eines Objekts aus einer Map
  factory SingleRoute.fromJson(Map<String, dynamic> json) {
    return SingleRoute(
      type: json['type'],
      coordinates: List<List<double>>.from(
        json['coordinates'].map((coord) => List<double>.from(coord)),
      ),
    );
  }

  // Methode zum Konvertieren des Objekts in eine Map
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates.map((coord) => coord.toList()).toList(),
    };
  }

  void addCoordinates(List<double> newCoordinate) {
    if (coordinates.isEmpty) {
      startTime = DateTime
          .now(); // Setze startTime beim Hinzufügen des ersten Koordinaten
    }
    coordinates.add(newCoordinate);
  }

  void calculatePossibleSlopes() async {
    if(!calculatedSlopes && SlopeMap.slopes.isNotEmpty) {
      simplifyCoordinates();
      List<List<Slope>> calculatePossibleSlopes = [];
      List<Slope> actualSlope = [];
      for (List<double> coordinate in simplifiedCoordinates) {
        List<Slope> possibleSlopes = SlopeMap.findPossibleSlopes(coordinate[0], coordinate[1]);
        calculatePossibleSlopes.add(possibleSlopes);
        // Every 5th time check the most common Slope
        if (calculatePossibleSlopes.length == 6) {
          List<Slope> placeHolder = [];
          for(List<Slope> slopes in calculatePossibleSlopes) {
            if(slopes.isNotEmpty) {
              placeHolder.add(slopes.first);
            }
          }
          if(placeHolder.length <= 3) {
            Slope freeRide = Slope(empty: true);
            if(actualSlope.isNotEmpty && actualSlope.last != freeRide) {
              actualSlope.add(freeRide);
            } else if(actualSlope.isEmpty) {
              actualSlope.add(freeRide);
            }
          } else {
            // Find the Slope that is in the List of Placeholders the most
            Map<Slope, int> occurrences = {};
            for (Slope slope in placeHolder) {
              if (occurrences.containsKey(slope)) {
                occurrences[slope] = occurrences[slope]! + 1;
              } else {
                occurrences[slope] = 1;
              }
            }
            Slope mostCommonSlope = occurrences.entries.reduce((l, r) => l.value > r.value ? l : r).key;
            if(actualSlope.isNotEmpty && actualSlope.last != mostCommonSlope) {
              actualSlope.add(mostCommonSlope);
            } else if(actualSlope.isEmpty) {
              actualSlope.add(mostCommonSlope);
            }
          }
          calculatePossibleSlopes.removeAt(0);
        }
      }
      slopes = actualSlope;
      calculatedSlopes = true;
    }
  }

  void simplifyCoordinates() {
    simplifiedCoordinates = [];
    // Get distance between first and last coordinate
    if (coordinates.length > 1) {
      double distance = 0.0;
      double lat1 = coordinates.first[0];
      double lon1 = coordinates.first[1];
      double lat2 = coordinates.last[0];
      double lon2 = coordinates.last[1];
      distance = Utils.calculateHaversineDistance(LatLng(lat1, lon1), LatLng(lat2, lon2));
      // You want one coordinate every 10 meters
      double distanceBuffer = 5;
      if (distance > distanceBuffer) {
        // Calculate the number of coordinates to keep
        int numberOfCoordinates = (distance / distanceBuffer).floor();
        // Only keep every numberOfCoordinates coordinate (including first and last)
        for (int i = 0; i < coordinates.length; i++) {
          if (i % numberOfCoordinates == 0) {
            simplifiedCoordinates.add(coordinates[i]);
          } else if (i == coordinates.length - 1) {
            simplifiedCoordinates.add(coordinates[i]);
          }
        }
      }
    } else {
      simplifiedCoordinates = coordinates;
    }
  }

}

class FullRoute {
  List<SingleRoute> routes;

  FullRoute({required this.routes});

  factory FullRoute.fromString(String jsonString) {
    return FullRoute.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  // Factory-Methode zum Erstellen eines Objekts aus einer Map
  factory FullRoute.fromJson(Map<String, dynamic> json) {
    return FullRoute(
      routes: List<SingleRoute>.from(
        json['routes'].map((route) => SingleRoute.fromJson(route)),
      ),
    );
  }

  // Methode zum Konvertieren des Objekts in eine Map
  Map<String, List<Map<String, dynamic>>> toJson() {
    return {
      'routes': routes.map((route) => route.toJson()).toList(),
    };
  }

  void finishActivity(){
    for (int i = 0; i < routes.length; i++) {
      routes[i].calculatePossibleSlopes();
    }
  }

  void addRoute(SingleRoute newRoute) {
    routes.add(newRoute);
    // Check lenght of routes
    if (routes.length > 1) {
      // Calculate possible pists/lifts for the route before
      routes[routes.length - 2].calculatePossibleSlopes();
      // Try to calculate all routes before
      for (int i = routes.length - 3; i >= 0; i--) {
        routes[i].calculatePossibleSlopes();
      }
    }
  }
}