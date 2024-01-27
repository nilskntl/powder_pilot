import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'activity.dart';
import 'activity_data.dart';
import 'activity_state.dart';
import 'activity_timer.dart';
import 'route.dart';

/// A provider class responsible for managing and updating activity data.
class ActivityDataProvider extends ChangeNotifier {
  /// Speed
  ActivitySpeed speed = ActivitySpeed();

  /// Distance
  ActivityDistance distance = ActivityDistance();

  /// Run
  ActivityRun runs = ActivityRun();

  /// Altitude
  ActivityAltitude altitude = ActivityAltitude();

  /// Slope
  ActivitySlope slope = ActivitySlope();

  /// Duration
  ElapsedDuration duration = ElapsedDuration();

  /// Current location
  double latitude = 0.0;
  double longitude = 0.0;

  /// Current address
  String area = '';

  /// GPS accuracy
  GpsAccuracy gpsAccuracy = GpsAccuracy.none;

  /// Status
  ActivityStatus status = ActivityStatus.inactive;

  /// Internet status
  bool internetStatus = false;

  /// Route
  ActivityRoute route = const ActivityRoute(coordinates: [], slopes: []);

  /// Activity Locations
  late final ActivityLocations activityLocations;
  bool _activityLocationsLoaded = false;

  /// Method to update the activity data.
  void updateData({
    required ActivitySpeed newSpeed,
    required ActivityDistance newDistance,
    required ActivityAltitude newAltitude,
    required ActivitySlope newSlope,
    required ElapsedDuration newElapsedDuration,
    required double newLatitude,
    required double newLongitude,
    required GpsAccuracy newGpsAccuracy,
    required ActivityRun newRuns,
    required ActivityRoute newRoute,
    required ActivityStatus newStatus,
    required String newArea,
    required ActivityLocations newActivityLocations,
  }) {
    speed = newSpeed;
    distance = newDistance;
    altitude = newAltitude;
    slope = newSlope;
    duration = newElapsedDuration;
    latitude = newLatitude;
    longitude = newLongitude;
    gpsAccuracy = newGpsAccuracy;
    runs = newRuns;
    route = newRoute;
    status = newStatus;
    area = newArea;
    if (!_activityLocationsLoaded) {
      activityLocations = newActivityLocations;
      _activityLocationsLoaded = true;
    }
    /// Notify listeners about the data changes
    notifyListeners();
  }

  /// Method to update the internet status.
  void updateInternetStatus({required bool newInternetStatus}) {
    internetStatus = newInternetStatus;

    /// Notify listeners about the internet status change
    notifyListeners();
  }
}
