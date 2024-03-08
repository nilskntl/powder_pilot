import 'package:powder_pilot/activity/route.dart';

import '../main.dart';
import 'database.dart';
import 'state.dart';
import 'timer.dart';

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

  /// Object to store specific locations during the activity.
  ActivityLocations activityLocations = const ActivityLocations();

  /// Save the activity data to a database and return the database entry.
  ActivityDatabase saveActivity() {
    ActivityDatabase activityDatabase = ActivityDatabase(
      id: DateTime.now().millisecondsSinceEpoch,
      areaName: PowderPilot.locationService.areaName,
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
      distances: distance.distances.toString(),
      speedLocation: activityLocations.fastestLocation.toString(),
      startLocation: activityLocations.startLocation.toString(),
      endLocation: activityLocations.endLocation.toString(),
    );

    /// Save the activity
    PowderPilot.pastActivities.addActivity(activityDatabase);
    return activityDatabase;
  }

  /// Update the user interface with the latest activity data.
  void updateData() {
    PowderPilot.dataProvider.updateData(
      newSpeed: speed,
      newDistance: distance,
      newAltitude: altitude,
      newSlope: slope,
      newElapsedDuration: _activityTimer.duration,
      newRuns: runs,
      newRoute: route,
      newStatus: _state.activityStatus,
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

  /// Constructor for the ActivityMapData class.
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

  /// Constructor for the ActivityLocations class.
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

  /// Constructor for the ActivitySpeed class.
  ActivitySpeed({
    this.currentSpeed = 0.0,
    this.maxSpeed = 0.0,
    this.avgSpeed = 0.0,
    this.totalSpeed = 0.0,
  });

  /// Add a speed to the list.
  ///
  /// @param timestamp The timestamp of the speed.
  /// @param speed The speed to add.
  void addSpeed(double timestamp, double speed) {
    speeds = _addToList(speeds, timestamp, speed);
  }

  /// Reduce the number of entries in the list.
  /// This is done to reduce the number of entries to a minimum.
  /// It's called when the activity gets saved to the database.
  void reduceSpeeds() {
    speeds = _reduceToMinEntries(speeds);
  }
}

/// Class to encapsulate distance-related data for an activity.
class ActivityDistance {
  double totalDistance;
  double distanceUphill;
  double distanceDownhill;

  /// List of distances and timestamps. The third entry is a weight to
  /// calculate the average distance.
  List<List<double>> _distances = [];

  /// Getter for the list of distances.
  List<List<double>> get distances => _distances;

  /// Constructor for the ActivityDistance class.
  ActivityDistance({
    this.totalDistance = 0.0,
    this.distanceUphill = 0.0,
    this.distanceDownhill = 0.0,
  });

  /// Set the list of distances.
  ///
  /// @param newDistances The new list of distances.
  void setDistances(List<List<double>> newDistances) {
    _distances = newDistances;
  }

  /// Add a distance to the list.
  ///
  /// @param timestamp The timestamp of the distance.
  /// @param distance The distance to add.
  void addDistance(double timestamp, double distance) {
    _distances = _addToList(_distances, timestamp, distance);
  }

  /// Reduce the number of entries in the list.
  /// This is done to reduce the number of entries to a minimum.
  /// It's called when the activity gets saved to the database.
  void reduceDistances() {
    _distances = _reduceToMinEntries(_distances);
  }
}

/// Class to encapsulate altitude-related data for an activity.
class ActivityAltitude {
  double currentAltitude;
  double maxAltitude;
  double minAltitude;
  double avgAltitude;
  double totalAltitude;

  double currentExtrema;

  List<List<double>> altitudes = [];

  /// Constructor for the ActivityAltitude class.
  ActivityAltitude({
    this.currentAltitude = 0.0,
    this.maxAltitude = 0.0,
    this.minAltitude = 0.0,
    this.avgAltitude = 0.0,
    this.totalAltitude = 0.0,
    this.currentExtrema = 0.0,
  });

  /// Add an altitude to the list.
  ///
  /// @param timestamp The timestamp of the altitude.
  /// @param altitude The altitude to add.
  void addAltitude(double timestamp, double altitude) {
    altitudes = _addToList(altitudes, timestamp, altitude);
  }

  /// Reduce the number of entries in the list.
  /// This is done to reduce the number of entries to a minimum.
  /// It's called when the activity gets saved to the database.
  void reduceAltitudes() {
    altitudes = _reduceToMinEntries(altitudes);
  }
}

/// Class to encapsulate slope-related data for an activity.
class ActivitySlope {
  double currentSlope;
  double maxSlope;
  double avgSlope;
  double totalSlope;

  /// Constructor for the ActivitySlope class.
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

  /// Constructor for the ActivityRun class.
  ActivityRun({
    this.totalRuns = 0,
    this.longestRun = 0.0,
  });
}

/// Add a list of values to a list of lists.
///
/// @param list The list of lists to add the values to.
/// @param timestamp The timestamp of the value.
/// @param value The value to add.
List<List<double>> _addToList(
    List<List<double>> list, double timestamp, double value) {
  /// The maximum number of entries in the list.
  const int maxEntries = 400;

  /// Add the value to the list.
  list.add([timestamp, value, 1.0]);

  /// If the list is too long, reduce the number of entries.
  if (list.length > maxEntries) {
    list = _reduceToMinEntries(list);
  }

  return list;
}

/// Reduce the number of entries in the list.
///
/// @param list The list to reduce.
List<List<double>> _reduceToMinEntries(List<List<double>> list) {
  /// The number to which the list should be reduced.
  const int minEntries = 200;

  /// If the list is empty or has fewer entries than the minimum, return.
  if (list.isEmpty || list.length <= minEntries) {
    return list;
  }

  /// Calculate the difference between each timestamp the new reduced
  /// list should have.
  int timestampDiff = list.last[0].toInt() ~/ minEntries;

  /// Track the current timestamp.
  int currentTimeStamp = 0;

  /// The new list of lists to store the reduced values.
  List<List<double>> tempList = [];

  /// Track the current sum of values, weights, and timestamps to calculate
  /// the average values which should be added to the new list.
  double sumValues = 0;
  double sumWeights = 0;
  double sumTimeStamps = 0;

  /// Iterate through the list of lists.
  /// Calculate the average values and add them to the new list as soon as
  /// the timestamp difference is reached.
  for (int i = 0; i < list.length; i++) {
    /// If the timestamp of the current list is greater than the current
    /// timestamp plus the timestamp difference, calculate the average
    /// values and add them to the new list.
    if (list[i][0] > currentTimeStamp + timestampDiff) {
      if (sumWeights > 0) {
        tempList.add(
            [sumTimeStamps / sumWeights, sumValues / sumWeights, sumWeights]);
      }

      /// Set the current timestamp to the timestamp of the current list.
      currentTimeStamp += timestampDiff;

      /// Reset the sum of values, weights, and timestamps.
      sumValues = 0;
      sumWeights = 0;
      sumTimeStamps = 0;
    }

    /// Add the values of the current list to the sum of values, weights,
    sumTimeStamps += list[i][0] * list[i][2];
    sumValues += list[i][1] * list[i][2];
    sumWeights += list[i][2];
  }

  /// Add the last average values to the new list.
  if (sumWeights > 0) {
    tempList
        .add([sumTimeStamps / sumWeights, sumValues / sumWeights, sumWeights]);
  }

  /// Set the new list as the list of lists.
  return tempList;
}
