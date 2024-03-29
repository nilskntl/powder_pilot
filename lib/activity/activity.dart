import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:powder_pilot/location.dart';

import '../main.dart';
import '../ui/history/dialog/summary_dialog.dart';
import '../utils/general_utils.dart';
import '../utils/slope_data.dart';
import 'data.dart';
import 'database.dart';
import 'slopes.dart';
import 'state.dart';

/// Enum to represent the type of location service used.
enum LocationType {
  gps,
  network,
}

/// Class representing an activity, extending LocationHandler for location-related functionality.
class Activity extends LocationHandler {
  /// Constructor for Activity.
  ///
  /// @param currentPosition: Initial geographical coordinates.
  /// @param mapDownloaded: Flag indicating whether the map is downloaded.
  Activity({
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

    /// Update the UI
    updateData();

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

    /// Add the final distance to distances
    distance.addDistance(
      activityTimer.duration.total.inSeconds.toDouble(),
      distance.totalDistance,
    );

    /// Reduce the list for speeds, altitudes and distances
    distance.reduceDistances();
    speed.reduceSpeeds();
    altitude.reduceAltitudes();

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

      /// Save values for all-time statistics
      PowderPilot.statistics.saveToSharedPref();
    }

    /// Set the activity to inactive
    state.stopActivity();

    /// Reset values to 0 and update UI
    activityTimer.resetTimer();
    speed.currentSpeed = 0.0;
    slope.currentSlope = 0.0;
    speed.speeds.clear();
    altitude.altitudes.clear();
    distance.distances.clear();
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

    /// Update the UI
    updateData();

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
          if (speed.maxSpeed > PowderPilot.statistics.maxSpeed) {
            PowderPilot.statistics.maxSpeed = speed.maxSpeed;
          }
        }

        /// Handle speed updates and maintain a record of speeds.
        if (speed.currentSpeed < 0.6) {
          speed.currentSpeed = 0.0;
        } else {
          _numberOfSpeedUpdates++;
          state.resumeDownhillOrUphill();
          speed.totalSpeed += speed.currentSpeed;
          speed.avgSpeed = speed.totalSpeed / _numberOfSpeedUpdates;
          PowderPilot.statistics.updateAvgSpeed(speed.avgSpeed);
        }

        speed.addSpeed(
          activityTimer.duration.total.inSeconds.toDouble(),
          speed.currentSpeed,
        );
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
      if (altitude.currentAltitude > altitude.maxAltitude) {
        PowderPilot.statistics.maxAltitude = altitude.currentAltitude;
        if (altitude.currentAltitude > PowderPilot.statistics.maxAltitude) {
          PowderPilot.statistics.maxAltitude = altitude.currentAltitude;
        }
      }
      if (altitude.minAltitude == 0.0) {
        altitude.minAltitude = altitude.currentAltitude;
      }
      if (altitude.currentAltitude < altitude.minAltitude) {
        altitude.maxAltitude = altitude.currentAltitude;
      }
      altitude.totalAltitude += altitude.currentAltitude;
      altitude.avgAltitude = altitude.totalAltitude / _numberOfAltitudeUpdates;

      altitude.addAltitude(
        activityTimer.duration.total.inSeconds.toDouble(),
        altitude.currentAltitude.round().toDouble(),
      );
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
        /// Reset calculated distance if it's unrealistically high.
        if (calculatedDistance > 400) {
          calculatedDistance = 0.0;
        }

        /// Add current location to the route.
        route.addCoordinates([longitude, latitude]);

        /// Update distance data.
        distance.totalDistance += calculatedDistance;
        PowderPilot.statistics.distanceTotal += calculatedDistance;
        distance.addDistance(
          activityTimer.duration.total.inSeconds.toDouble(),
          distance.totalDistance,
        );
        tempDistance += calculatedDistance;
        lastLocation = position;
      }

      /// If the status (downhill/uphill) changes, update the status and
      /// reset the current run length.
      ///
      /// @param status: The new status.
      void updateDistanceHelper(RunningStatus status) {
        state.runningStatus = status;
        currentRunLength = 0.0;
      }

      if (!state.isUphill && !state.isDownhill) {
        if (altitude.currentAltitude - altitude.currentExtrema > 5) {
          updateDistanceHelper(RunningStatus.uphill);
        } else if (altitude.currentAltitude - altitude.currentExtrema < -5) {
          updateDistanceHelper(RunningStatus.downhill);
        }
      } else {
        if (altitude.currentAltitude - altitude.currentExtrema > 15) {
          updateDistanceHelper(RunningStatus.uphill);
        } else if (altitude.currentAltitude - altitude.currentExtrema < -15) {
          updateDistanceHelper(RunningStatus.downhill);
          runs.totalRuns++;
          PowderPilot.statistics.numRuns++;
        }
      }

      if (state.isUphill &&
          altitude.currentAltitude - altitude.currentExtrema > 0) {
        altitude.currentExtrema = altitude.currentAltitude;
        distance.distanceUphill += tempDistance;
        PowderPilot.statistics.distanceUphill += tempDistance;
        tempDistance = 0.0;
      } else if (state.isDownhill &&
          altitude.currentAltitude - altitude.currentExtrema < 0) {
        altitude.currentExtrema = altitude.currentAltitude;
        distance.distanceDownhill += tempDistance;
        PowderPilot.statistics.distanceDownhill += tempDistance;
        currentRunLength += tempDistance;
        if (currentRunLength > runs.longestRun) {
          runs.longestRun = currentRunLength;
          if (currentRunLength > PowderPilot.statistics.longestRun) {
            PowderPilot.statistics.longestRun = currentRunLength;
          }
        }
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
      if (state.runningStatus != RunningStatus.pause || true) {
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

        /// Calculate the horizontal distance between the current location
        double horizontalDistance = Utils.calculateHaversineDistance(
            LatLng(tempLocation.latitude, tempLocation.longitude),
            LatLng(position.latitude, position.longitude));

        /// If the difference is greater than $slopeBuffer, calculate the slope.
        /// Formula: slope = (vertical distance / horizontal distance) * 100
        if (difference > slopeBuffer && horizontalDistance > slopeBuffer) {
          if (tempLocation.latitude == position.latitude &&
              tempLocation.longitude == position.longitude) {
            return;
          }
          if (tempAltitude - altitude.currentAltitude > 0) {
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
        if (PowderPilot.locationService.gpsAccuracy == GpsAccuracy.high) {
          if (!_locationInitialized) {
            initializeLocation(position);
            route.addCoordinates([longitude, latitude]);
            PowderPilot.statistics.numActivities++;
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
            (PowderPilot.connectivityController.status == true ||
                _numberOfLocationUpdates == 0)) {
          _downloadMap();
        }
      }

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
    if (PowderPilot.connectivityController.status == true) {
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
