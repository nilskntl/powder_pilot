import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:ski_tracker/activity/activity.dart';

class ActivityDataProvider extends ChangeNotifier {

  // Speed
  double speed = 0.0;
  double maxSpeed = 0.0;
  double avgSpeed = 0.0;

  // Distance
  double totalDistance = 0.0;
  double uphillDistance = 0.0;
  double downhillDistance = 0.0;

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

  // GPS accuracy
  GpsAccuracy gpsAccuracy = GpsAccuracy.none;

  // Location loaded
  bool locationLoaded = false;

  void updateData({
    required double newSpeed,
    required double newMaxSpeed,
    required double newAvgSpeed,
    required double newTotalDistance,
    required double newUphillDistance,
    required double newDownhillDistance,
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
  }) {
    speed = newSpeed;
    maxSpeed = newMaxSpeed;
    avgSpeed = newAvgSpeed;
    totalDistance = newTotalDistance;
    uphillDistance = newUphillDistance;
    downhillDistance = newDownhillDistance;
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

    notifyListeners();
  }
}
