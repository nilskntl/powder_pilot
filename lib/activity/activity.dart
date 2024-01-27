import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:powder_pilot/location.dart';

import '../main.dart';
import '../pages/activity_summary.dart';
import '../utils/general_utils.dart';
import '../utils/shared_preferences.dart';
import '../utils/slope_data.dart';
import 'data.dart';
import 'database.dart';
import 'state.dart';
import 'slopes.dart';

/// Enum to represent the type of location service used.
enum LocationType {
  gps,
  network,
}

/// Class representing an activity, extending LocationHandler for location-related functionality.
class Activity extends LocationHandler {
  final int id;

  /// Constructor for Activity.
  ///
  /// @param id: Activity ID.
  /// @param currentPosition: Initial geographical coordinates.
  /// @param mapDownloaded: Flag indicating whether the map is downloaded.
  Activity({
    required this.id,
    LatLng currentPosition = const LatLng(0.0, 0.0),
    bool mapDownloaded = false,
  }) {
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    mapData.mapDownloaded = mapDownloaded;
    if (mapDownloaded) {
      mapData.latitudeWhenDownloaded = latitude;
      mapData.longitudeWhenDownloaded = longitude;
    }
    areaName = PowderPilot.locationService.areaName;
  }

  /// Initialization method for the Activity.
  void init() {
    if (kDebugMode) {
      print('Activity $id initialized');
    }

    /// Start the location stream in LocationHandler
    _locationStream();
  }

  /// Method to start the activity.
  void startActivity() {
    /// Check if the activity is already active
    if (state.isActive) {
      return;
    }

    /// Set the activity to active
    state.startActivity();

    /// Set the start time to the current time
    activityTimer.startTime = DateTime.now();

    /// Start the stopwatch
    activityTimer.startStopwatch(callback: () {});

    /// Check if the user moved more than 4km from the last downloaded map
    /// If so, download a new map
    if (Utils.calculateHaversineDistance(
            LatLng(latitude, longitude),
            LatLng(mapData.latitudeWhenDownloaded,
                mapData.longitudeWhenDownloaded)) >
        4000) {
      mapData.mapDownloaded = false;
      _downloadMap();
    }

    /// Start the location stream in active mode
    PowderPilot.locationService.startActiveLocationStream();

    /// Update the UI
    updateData();
  }

  /// Method to stop the activity.
  void stopActivity(BuildContext context) {
    /// Method to show the summary dialog after the activity is stopped
    void showCustomDialog(
        BuildContext context, ActivityDatabase activityDatabase) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SummaryDialog(
            activityDatabase: activityDatabase,
          );
        },
      );
    }

    /// Check if the activity is already inactive
    if (!state.isActive) {
      return;
    }

    /// Set the end location to the current location
    activityLocations = activityLocations.setEndLocation([longitude, latitude]);

    /// Add the end location to the route
    route.addCoordinates([longitude, latitude]);

    /// Set the end time to the current time
    activityTimer.endTime = DateTime.now();

    /// Stop the stopwatch
    activityTimer.stopStopwatch();
    if (route.slopes.isNotEmpty) {
      route.slopes.last.endTime = DateTime.now();
    }
    if (_locationInitialized) {
      ActivityDatabase activityDatabase = saveActivity();
      _locationInitialized = false;
      showCustomDialog(context, activityDatabase);
      _addActivityToList();
    }

    /// Set the activity to inactive
    state.stopActivity();

    /// Reset values to 0 and update UI
    activityTimer.resetTimer();
    speed.currentSpeed = 0.0;
    slope.currentSlope = 0.0;
    updateData();

    /// Start the location stream in passive mode
    PowderPilot.locationService.startPassiveLocationStream();

    /// Remove the location callback
    PowderPilot.locationService.removeListener(locationCallback);

    /// Create a new activity
    PowderPilot.createNewActivity(
        currentPosition: LatLng(latitude, longitude),
        mapDownloaded: mapData.mapDownloaded);
  }

  /// Method to add the activity to the list.
  void _addActivityToList() async {
    /// Get the number of total activities
    int numActivities = await SharedPref.readInt(PowderPilot.numActivitiesKey);

    /// Save the incremented number of total activities to shared preferences
    SharedPref.saveInt(PowderPilot.numActivitiesKey, numActivities + 1);
  }

  /// Method to pause the activity.
  void pauseActivity() {
    /// Check if the activity is already paused
    if (!state.isActive) {
      return;
    }

    /// Set the activity to paused
    state.pauseActivity();

    /// Reset values to 0 and update UI
    speed.currentSpeed = 0.0;
    slope.currentSlope = 0.0;
    _altitudeBuffer.clear();
    updateData();

    /// Pause the stopwatch
    activityTimer.pauseStopwatch();

    /// Start the location stream in passive mode
    PowderPilot.locationService.startPassiveLocationStream();
  }

  /// Method to resume the activity.
  void resumeActivity() {
    /// Check if the activity is already active
    if (!state.isActive) {
      return;
    }

    /// Set the activity to active
    state.resumeActivity();

    /// Check if the user moved more than 4km from the last downloaded map
    /// If so, download a new map
    if (Utils.calculateHaversineDistance(
            LatLng(latitude, longitude),
            LatLng(mapData.latitudeWhenDownloaded,
                mapData.longitudeWhenDownloaded)) >
        4000) {
      mapData.mapDownloaded = false;
      _downloadMap();
    }

    /// Resume the stopwatch
    activityTimer.resumeStopwatch(callback: () {});

    /// Start the location stream in active mode
    PowderPilot.locationService.startActiveLocationStream();

    /// Update the UI
    updateData();
  }
}

/// Class to handle location-related updates and calculations for an activity.
class LocationHandler extends ActivityData {
  int _numberOfDistanceUpdates = 0;
  int _numberOfSpeedUpdates = 0;
  int _numberOfSlopeUpdates = 0;
  int _numberOfAltitudeUpdates = 0;
  int _numberOfLocationUpdates = 0;

  /// Callback to be invoked when a location update is received.
  late LocationCallback locationCallback;

  /// Altitude buffer used to smooth altitude data.
  final List<double> _altitudeBuffer = [];

  /// Flag to track if the location is initialized.
  bool _locationInitialized = false;

  /// Method to start handling location updates.
  void _locationStream() {
    /// Temporary variable to store the current run length.
    double currentRunLength = 0.0;

    /// Update speed based on the received location data.
    ///
    /// @param position: The current position.
    void updateSpeed(Position position) {
      /// Filter out unrealistic speed values.
      if (position.speed < 55) {
        speed.currentSpeed = position.speed;

        /// Update fastest location and route if the current speed is a new maximum.
        if (speed.currentSpeed > speed.maxSpeed) {
          activityLocations =
              activityLocations.setFastestLocation([longitude, latitude]);
          route.addCoordinates([longitude, latitude]);
          speed.maxSpeed = speed.currentSpeed;
        }

        /// Handle speed updates and maintain a record of speeds.
        if (speed.currentSpeed < 0.6) {
          speed.currentSpeed = 0.0;
        } else {
          _numberOfSpeedUpdates++;
          state.resumeDownhillOrUphill();
          speed.totalSpeed += speed.currentSpeed;
          speed.avgSpeed = speed.totalSpeed / _numberOfSpeedUpdates;
        }

        speed.speeds.add([
          activityTimer.duration.total.inSeconds.toDouble(),
          double.parse(speed.currentSpeed.toStringAsFixed(1)),
        ]);
      }
    }

    /// Update altitude based on the received location data.
    ///
    /// @param position: The current position.
    void updateAltitude(Position position) {
      _numberOfAltitudeUpdates++;

      /// Helper method to smooth altitude using a moving average technique.
      ///
      /// @param newAltitude: The new altitude.
      double smoothAltitude(double newAltitude) {
        const int smoothingFactor = 5;

        _altitudeBuffer.add(newAltitude);

        if (_altitudeBuffer.length > smoothingFactor) {
          _altitudeBuffer.removeAt(0);
        }

        double smoothedValue =
            _altitudeBuffer.reduce((a, b) => a + b) / _altitudeBuffer.length;

        return smoothedValue;
      }

      altitude.currentAltitude = smoothAltitude(position.altitude);
      altitude.maxAltitude = altitude.currentAltitude > altitude.maxAltitude
          ? altitude.currentAltitude
          : altitude.maxAltitude;
      if (altitude.minAltitude == 0.0) {
        altitude.minAltitude = altitude.currentAltitude;
      }
      altitude.minAltitude = altitude.currentAltitude < altitude.minAltitude
          ? altitude.currentAltitude
          : altitude.minAltitude;
      altitude.totalAltitude += altitude.currentAltitude;
      altitude.avgAltitude = altitude.totalAltitude / _numberOfAltitudeUpdates;

      altitude.altitudes.add([
        activityTimer.duration.total.inSeconds,
        altitude.currentAltitude.round(),
      ]);
    }

    /// Temporary distance variable.
    /// Used to calculate distance.
    double tempDistance = 0.0;

    /// Temporary location variable to store the last location.
    /// Used to calculate distance.
    /// Initialized to 0, 0 to prevent errors.
    Position lastLocation = Position(
        longitude: 0.0,
        latitude: 0.0,
        accuracy: 0.0,
        altitude: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        heading: 0.0,
        altitudeAccuracy: 0.0,
        timestamp: DateTime.now(),
        isMocked: false,
        headingAccuracy: 0.0,
        floor: 0);

    /// Update distance based on the received location data.
    ///
    /// @param position: The current position.
    void updateDistance(Position position) {
      double calculatedDistance = Utils.calculateHaversineDistance(
          LatLng(lastLocation.latitude, lastLocation.longitude),
          LatLng(position.latitude, position.longitude));

      _numberOfDistanceUpdates++;

      if (_numberOfDistanceUpdates % 5 == 0 && calculatedDistance > 2) {
        // Reset calculated distance if it's unrealistically high.
        if (calculatedDistance > 400) {
          calculatedDistance = 0.0;
        }
        route.addCoordinates([longitude, latitude]);
        distance.totalDistance += calculatedDistance;
        tempDistance += calculatedDistance;
        lastLocation = position;
      }

      void updateDistanceHelper(RunningStatus status) {
        state.runningStatus = status;
        currentRunLength = 0.0;
      }

      if (!state.isUphill && !state.isDownhill) {
        if (altitude.currentAltitude - altitude.currentExtrema > 5) {
          updateDistanceHelper(RunningStatus.uphill);
        } else if (altitude.currentAltitude - altitude.currentExtrema < -5) {
          updateDistanceHelper(RunningStatus.downhill);
          runs.totalRuns++;
        }
      } else {
        if (altitude.currentAltitude - altitude.currentExtrema > 15) {
          updateDistanceHelper(RunningStatus.uphill);
        } else if (altitude.currentAltitude - altitude.currentExtrema < -15) {
          updateDistanceHelper(RunningStatus.downhill);
          runs.totalRuns++;
        }
      }

      if (!state.isUphill &&
          altitude.currentAltitude - altitude.currentExtrema > 0) {
        altitude.currentExtrema = altitude.currentAltitude;
        distance.distanceUphill += tempDistance;
        tempDistance = 0.0;
      } else if (!state.isDownhill &&
          altitude.currentAltitude - altitude.currentExtrema < 0) {
        altitude.currentExtrema = altitude.currentAltitude;
        distance.distanceDownhill += tempDistance;
        currentRunLength += tempDistance;
        runs.longestRun = currentRunLength > runs.longestRun
            ? currentRunLength
            : runs.longestRun;
        tempDistance = 0.0;
      }
    }

    /// Temporary altitude variable for slope calculation.
    double tempAltitude = 0.0;

    /// Temporary location variable for slope calculation.
    late Position tempLocation;

    /// Update slope based on the received location data.
    ///
    /// @param position: The current position.
    void updateSlope(Position position) {
      /// Buffer to prevent slope from updating too frequently and to
      /// ensure that the calculated slope is realistic.
      double slopeBuffer = 10;

      /// Buffer to prevent unrealistic differences in altitude from
      double unrealisticallyHighDifference = 125;

      /// Handle slope updates only if the activity is in
      /// downhill or uphill mode.
      if (state.runningStatus != RunningStatus.pause) {
        /// Calculate the difference between the current altitude and the
        /// previous saved altitude.
        double difference = (tempAltitude - altitude.currentAltitude).abs();

        /// If the difference is greater than $unrealisticallyHighDifference,
        /// set the temporary altitude and location to the current altitude
        /// and location because its too large to be realistic.
        if (difference > unrealisticallyHighDifference) {
          tempAltitude = altitude.currentAltitude;
          tempLocation = position;
          difference = 0.0;
        }

        /// If the difference is greater than $slopeBuffer, calculate the slope.
        /// Formula: slope = (vertical distance / horizontal distance) * 100
        if (difference > slopeBuffer) {
          if (tempLocation.latitude == position.latitude &&
              tempLocation.longitude == position.longitude) {
            return;
          }
          if (tempAltitude - altitude.currentAltitude > 0) {
            double horizontalDistance = Utils.calculateHaversineDistance(
                LatLng(tempLocation.latitude, tempLocation.longitude),
                LatLng(position.latitude, position.longitude));
            double verticalDistance = tempAltitude - altitude.currentAltitude;
            slope.currentSlope = verticalDistance / horizontalDistance * 100;
            _numberOfSlopeUpdates++;
            slope.maxSlope = slope.currentSlope > slope.maxSlope
                ? slope.currentSlope
                : slope.maxSlope;
            slope.totalSlope += slope.currentSlope;
            slope.avgSlope = slope.totalSlope / _numberOfSlopeUpdates;
          } else {
            slope.currentSlope = 0.0;
          }

          /// Update the temporary altitude and location to the current
          /// altitude and location.
          tempAltitude = altitude.currentAltitude;
          tempLocation = position;
        }
      }
    }

    /// Method to initialize location data when starting the activity.
    /// This method is only invoked once per activity.
    ///
    /// @param position: The current position.
    void initializeLocation(Position position) {
      lastLocation = position;
      altitude.currentAltitude = position.altitude;
      altitude.currentExtrema = altitude.currentAltitude;
      tempAltitude = altitude.currentAltitude;
      tempLocation = position;
      activityLocations =
          activityLocations.setStartLocation([longitude, latitude]);
      route.addCoordinates([longitude, latitude]);
      if ((route.slopes.isEmpty || route.slopes.last.name == 'Unknown') &&
          mapData.mapDownloaded == true) {
        _updateNearestSlope();
      }
    }

    /// Method to be invoked when a location update is received.
    /// This method is invoked every time a location update is received.
    ///
    /// @param position: The current position.
    void onLocationUpdate(Position position) {
      /// Update location data
      latitude = position.latitude;
      longitude = position.longitude;

      /// Handle location updates only if the activity is active.
      if (state.isRunning) {
        if (position.accuracy < 10) {
          gpsAccuracy = GpsAccuracy.high;
        } else if (position.accuracy < 25) {
          gpsAccuracy = GpsAccuracy.medium;
        } else {
          gpsAccuracy = GpsAccuracy.low;
        }

        if (gpsAccuracy == GpsAccuracy.high ||
            gpsAccuracy == GpsAccuracy.medium) {
          if (!_locationInitialized) {
            initializeLocation(position);
            route.addCoordinates([longitude, latitude]);
          }

          /// Update speed
          updateSpeed(position);

          /// Update altitude
          updateAltitude(position);

          /// Update distance
          updateDistance(position);

          /// Update slope
          updateSlope(position);

          /// Update nearest slope every 5 location updates.
          if (_numberOfLocationUpdates % 5 == 0) {
            _updateNearestSlope();
          }

          if (!_locationInitialized) {
            _locationInitialized = true;
          }
        } else {
          /// Set values to 0 if GPS accuracy is low
          speed.currentSpeed = 0.0;
          slope.currentSlope = 0.0;
        }
      }

      /// Download the slope map if not already downloaded.
      if (!mapData.mapDownloaded) {
        if (_numberOfLocationUpdates % 15 == 0 &&
            (PowderPilot.connectionStatus == true ||
                _numberOfLocationUpdates == 0)) {
          _downloadMap();
        }
      }

      /// Update area name if it has changed.
      areaName = PowderPilot.locationService.areaName;

      /// Update UI
      updateData();

      /// Increment the number of location updates each time a location update is received.
      _numberOfLocationUpdates++;
    }

    /// Set the location callback.
    locationCallback = onLocationUpdate;

    /// Add the location callback to the location service.
    PowderPilot.locationService.addListener(locationCallback);
  }

  /// Method to update the nearest slope based on the current location.
  Future<void> _updateNearestSlope() async {
    if (mapData.mapDownloaded == true) {
      if (state.isDownhill || state.isUphill) {
        route.addSlope(SlopeMap.findNearestSlope(
            latitude: latitude, longitude: longitude, lift: state.isUphill));
      }
    }
  }

  static bool _isDownloadRunning = false;

  /// Method to download map data if not already downloaded.
  Future<void> _downloadMap() async {
    if (_isDownloadRunning) {
      return;
    }
    _isDownloadRunning = true;
    if (PowderPilot.connectionStatus == true) {
      if (mapData.mapDownloaded == true) {
        return;
      }
      await SlopeFetcher.fetchData(latitude, longitude);
      if (SlopeMap.slopes.isNotEmpty) {
        mapData.latitudeWhenDownloaded = latitude;
        mapData.longitudeWhenDownloaded = longitude;
        mapData.mapDownloaded = true;
      }
    }
    _isDownloadRunning = false;
  }
}
