import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ski_tracker/activity/activity.dart';

class ActivityDataProvider extends ChangeNotifier {

  // Speed
  double speed = 0.0;
  double maxSpeed = 0.0;
  double avgSpeed = 0.0;

  // Distance
  double distance = 0.0;
  double distanceUphill = 0.0;
  double distanceDownhill = 0.0;

  // Runs
  int totalRuns = 0;
  double longestRun = 0.0;

  // Altitude
  double altitude = 0.0;
  double maxAltitude = 0.0;
  double minAltitude = 0.0;
  double avgAltitude = 0.0;

  // Slope
  double slope = 0.0;
  double maxSlope = 0.0;
  double avgSlope = 0.0;

  // Duration
  Duration elapsedTime = Duration.zero;
  Duration elapsedPauseTime = Duration.zero;
  Duration elapsedUphillTime = Duration.zero;
  Duration elapsedDownhillTime = Duration.zero;

  // Current location
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;

  // Current address
  String area = '';

  // GPS accuracy
  GpsAccuracy gpsAccuracy = GpsAccuracy.none;

  // Location loaded
  bool locationLoaded = false;

  // Full route
  FullRoute fullRoute = FullRoute(routes: []);

  // Current route
  SingleRoute currentRoute = SingleRoute(type: 'Unknown', coordinates: []);

  // Status
  ActivityStatus status = ActivityStatus.inactive;
  bool initializedMap = false;

  // Internet status
  bool internetStatus = false;

  // List of altitudes
  List<int> altitudes = [];

  void updateData({
    required double newSpeed,
    required double newMaxSpeed,
    required double newAvgSpeed,
    required double newDistance,
    required double newDistanceUphill,
    required double newDistanceDownhill,
    required double newAltitude,
    required double newMaxAltitude,
    required double newMinAltitude,
    required double newAvgAltitude,
    required double newSlope,
    required double newMaxSlope,
    required double newAvgSlope,
    required Duration newElapsedTime,
    required Duration newElapsedPauseTime,
    required Duration newElapsedUphillTime,
    required Duration newElapsedDownhillTime,
    required double newCurrentLatitude,
    required double newCurrentLongitude,
    required GpsAccuracy newGpsAccuracy,
    required bool newLocationLoaded,
    required int newTotalRuns,
    required double newLongestRun,
    required FullRoute newFullRoute,
    required SingleRoute newCurrentRoute,
    required ActivityStatus newStatus,
    required String newArea,
    required bool newInitializedMap,
    required List<int> newAltitudes,
  }) {
    speed = newSpeed;
    maxSpeed = newMaxSpeed;
    avgSpeed = newAvgSpeed;
    distance = newDistance;
    distanceUphill = newDistanceUphill;
    distanceDownhill = newDistanceDownhill;
    altitude = newAltitude;
    maxAltitude = newMaxAltitude;
    minAltitude = newMinAltitude;
    avgAltitude = newAvgAltitude;
    slope = newSlope;
    maxSlope = newMaxSlope;
    avgSlope = newAvgSlope;
    elapsedTime = newElapsedTime;
    elapsedPauseTime = newElapsedPauseTime;
    elapsedUphillTime = newElapsedUphillTime;
    elapsedDownhillTime = newElapsedDownhillTime;
    currentLatitude = newCurrentLatitude;
    currentLongitude = newCurrentLongitude;
    gpsAccuracy = newGpsAccuracy;
    locationLoaded = newLocationLoaded;
    totalRuns = newTotalRuns;
    longestRun = newLongestRun;
    fullRoute = newFullRoute;
    currentRoute = newCurrentRoute;
    status = newStatus;
    area = newArea;
    initializedMap = newInitializedMap;
    altitudes = newAltitudes;

    notifyListeners();
  }

  void updateInternetStatus({required bool newInternetStatus}) {
    internetStatus = newInternetStatus;
    notifyListeners();
  }
}
