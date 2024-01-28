import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'route.dart';
import 'state.dart';
import 'timer.dart';

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
  ///
  /// This method is called by the [Activity] class.
  /// It updates the current activity data with the provided data and
  /// notifies the listeners about the data changes.
  ///
  /// @param newSpeed The new speed data.
  /// @param newDistance The new distance data.
  /// @param newAltitude The new altitude data.
  /// @param newSlope The new slope data.
  /// @param newElapsedDuration The new elapsed duration data.
  /// @param newLatitude The new latitude data.
  /// @param newLongitude The new longitude data.
  /// @param newGpsAccuracy The new GPS accuracy data.
  /// @param newRuns The new run data.
  /// @param newRoute The new route data.
  /// @param newStatus The new status data.
  /// @param newArea The new area data.
  /// @param newActivityLocations The new activity locations data.
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
  ///
  /// @param newInternetStatus The new internet status.
  void updateInternetStatus({required bool newInternetStatus}) {
    internetStatus = newInternetStatus;

    /// Notify listeners about the internet status change
    notifyListeners();
  }
}
