import 'package:flutter/cupertino.dart';

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

  // Vertical
  double vertical = 0.0;
  double uphillVertical = 0.0;
  double downhillVertical = 0.0;

  // Slope
  double slope = 0.0;
  double maxSlope = 0.0;
  double avgSlope = 0.0;

  // Duration
  Duration elapsedTime = Duration.zero;

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
    required double newVertical,
    required double newUphillVertical,
    required double newDownhillVertical,
    required double newSlope,
    required double newMaxSlope,
    required double newAvgSlope,
    required Duration newElapsedTime,
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
    vertical = newVertical;
    uphillVertical = newUphillVertical;
    downhillVertical = newDownhillVertical;
    slope = newSlope;
    maxSlope = newMaxSlope;
    avgSlope = newAvgSlope;
    elapsedTime = newElapsedTime;

    notifyListeners();
  }
}
