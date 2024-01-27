import 'package:powder_pilot/activity/route.dart';

import '../main.dart';
import 'database.dart';
import 'state.dart';
import 'timer.dart';

/// Enum to represent GPS accuracy levels.
enum GpsAccuracy {
  none,
  low,
  medium,
  high,
}

/// Class to encapsulate data related to an activity.
class ActivityData {
  final ActivityState _state = ActivityState();

  /// Timer to track activity duration.
  late final ActivityTimer _activityTimer =
      ActivityTimer(activity: this, state: _state);

  /// Objects to store various activity metrics.
  final ActivitySpeed _speed = ActivitySpeed();
  final ActivityDistance _distance = ActivityDistance();
  final ActivityAltitude _altitude = ActivityAltitude();
  final ActivitySlope _slope = ActivitySlope();
  final ActivityRun _runs = ActivityRun();
  final ActivityMapData _mapData = ActivityMapData();

  /// Route of the activity.
  /// Don't define as const, because it is mutable.
  final ActivityRoute _route =
      /// ignore: prefer_const_constructors
      ActivityRoute(slopes: [], coordinates: []);

  /// Geographic coordinates and area name.
  double latitude = 0.0;
  double longitude = 0.0;
  String areaName = '';

  /// GPS accuracy level.
  GpsAccuracy gpsAccuracy = GpsAccuracy.none;

  /// Object to store specific locations during the activity.
  ActivityLocations activityLocations = const ActivityLocations();

  /// Save the activity data to a database and return the database entry.
  ActivityDatabase saveActivity() {
    ActivityDatabase activityDatabase = ActivityDatabase(
      areaName: areaName,
      maxSpeed: speed.maxSpeed,
      averageSpeed: speed.avgSpeed,
      totalRuns: runs.totalRuns,
      longestRun: runs.longestRun,
      maxAltitude: altitude.maxAltitude,
      minAltitude: altitude.minAltitude,
      avgAltitude: altitude.avgAltitude,
      altitudes: altitude.altitudes.toString(),
      maxSlope: slope.maxSlope,
      avgSlope: slope.avgSlope,
      distance: distance.totalDistance,
      distanceDownhill: distance.distanceDownhill,
      distanceUphill: distance.distanceUphill,
      elapsedTime: _activityTimer.duration.total.toString(),
      elapsedDownhillTime: _activityTimer.duration.downhill.toString(),
      elapsedUphillTime: _activityTimer.duration.uphill.toString(),
      elapsedPauseTime: _activityTimer.duration.pause.toString(),
      route: route.toString(),
      startTime: _activityTimer.startTime.toString(),
      endTime: _activityTimer.endTime.toString(),
      speeds: speed.speeds.toString(),
      speedLocation: activityLocations.fastestLocation.toString(),
      startLocation: activityLocations.startLocation.toString(),
      endLocation: activityLocations.endLocation.toString(),
    );

    /// Insert the activity into the database.
    ActivityDatabaseHelper.insertActivity(activityDatabase);
    return activityDatabase;
  }

  /// Update the user interface with the latest activity data.
  void updateData() {
    PowderPilot.getActivityDataProvider().updateData(
      newSpeed: speed,
      newDistance: distance,
      newAltitude: altitude,
      newSlope: slope,
      newElapsedDuration: _activityTimer.duration,
      newLatitude: latitude,
      newLongitude: longitude,
      newGpsAccuracy: gpsAccuracy,
      newRuns: runs,
      newRoute: route,
      newStatus: _state.activityStatus,
      newArea: areaName,
      newActivityLocations: activityLocations,
    );
  }

  /// Getters for various components of the activity data.
  ActivityTimer get activityTimer => _activityTimer;

  ActivityState get state => _state;

  ActivitySpeed get speed => _speed;

  ActivityDistance get distance => _distance;

  ActivityAltitude get altitude => _altitude;

  ActivitySlope get slope => _slope;

  ActivityRun get runs => _runs;

  ActivityMapData get mapData => _mapData;

  ActivityRoute get route => _route;
}

/// Class to encapsulate map-related data for an activity.
class ActivityMapData {
  bool mapDownloaded;
  double latitudeWhenDownloaded;
  double longitudeWhenDownloaded;

  ActivityMapData({
    this.mapDownloaded = false,
    this.latitudeWhenDownloaded = 0.0,
    this.longitudeWhenDownloaded = 0.0,
  });
}

/// Class to encapsulate specific locations during an activity.
class ActivityLocations {
  final List<double> fastestLocation;
  final List<double> startLocation;
  final List<double> endLocation;

  const ActivityLocations({
    this.fastestLocation = const [0.0, 0.0],
    this.startLocation = const [0.0, 0.0],
    this.endLocation = const [0.0, 0.0],
  });

  /// Set the fastest location and return a new instance of ActivityLocations.
  ActivityLocations setFastestLocation(List<double> newFastestLocation) {
    return ActivityLocations(
      fastestLocation: newFastestLocation,
      startLocation: startLocation,
      endLocation: endLocation,
    );
  }

  /// Set the start location and return a new instance of ActivityLocations.
  ActivityLocations setStartLocation(List<double> newStartLocation) {
    return ActivityLocations(
      fastestLocation: fastestLocation,
      startLocation: newStartLocation,
      endLocation: endLocation,
    );
  }

  /// Set the end location and return a new instance of ActivityLocations.
  ActivityLocations setEndLocation(List<double> newEndLocation) {
    return ActivityLocations(
      fastestLocation: fastestLocation,
      startLocation: startLocation,
      endLocation: newEndLocation,
    );
  }
}

/// Class to encapsulate speed-related data for an activity.
class ActivitySpeed {
  double currentSpeed;
  double maxSpeed;
  double avgSpeed;
  double totalSpeed;

  List<List<double>> speeds = [];

  ActivitySpeed({
    this.currentSpeed = 0.0,
    this.maxSpeed = 0.0,
    this.avgSpeed = 0.0,
    this.totalSpeed = 0.0,
  });
}

/// Class to encapsulate distance-related data for an activity.
class ActivityDistance {
  double totalDistance;
  double distanceUphill;
  double distanceDownhill;

  ActivityDistance({
    this.totalDistance = 0.0,
    this.distanceUphill = 0.0,
    this.distanceDownhill = 0.0,
  });
}

/// Class to encapsulate altitude-related data for an activity.
class ActivityAltitude {
  double currentAltitude;
  double maxAltitude;
  double minAltitude;
  double avgAltitude;
  double totalAltitude;

  double currentExtrema;

  List<List<int>> altitudes = [];

  ActivityAltitude({
    this.currentAltitude = 0.0,
    this.maxAltitude = 0.0,
    this.minAltitude = 0.0,
    this.avgAltitude = 0.0,
    this.totalAltitude = 0.0,
    this.currentExtrema = 0.0,
  });
}

/// Class to encapsulate slope-related data for an activity.
class ActivitySlope {
  double currentSlope;
  double maxSlope;
  double avgSlope;
  double totalSlope;

  ActivitySlope({
    this.currentSlope = 0.0,
    this.maxSlope = 0.0,
    this.avgSlope = 0.0,
    this.totalSlope = 0.0,
  });
}

/// Class to encapsulate run-related data for an activity.
class ActivityRun {
  int totalRuns;
  double longestRun;

  ActivityRun({
    this.totalRuns = 0,
    this.longestRun = 0.0,
  });
}
