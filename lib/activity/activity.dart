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
import 'activity_data.dart';
import 'activity_database.dart';
import 'activity_state.dart';
import 'slopes.dart';

enum LocationType {
  gps,
  network,
}

class Activity extends LocationHandler {
  final int id;

  Activity(
      {required this.id,
      LatLng currentPosition = const LatLng(0.0, 0.0),
      bool mapDownloaded = false}) {
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    mapData.mapDownloaded = mapDownloaded;
    if (mapDownloaded) {
      mapData.latitudeWhenDownloaded = latitude;
      mapData.longitudeWhenDownloaded = longitude;
    }
    areaName = PowderPilot.locationService.areaName;
  }

  void init() {
    if (kDebugMode) {
      print('Activity $id initialized');
    }
    _locationStream();
  }

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

    PowderPilot.locationService.startPassiveLocationStream();

    PowderPilot.locationService.removeListener(locationCallback);

    PowderPilot.createNewActivity(
        currentPosition: LatLng(latitude, longitude),
        mapDownloaded: mapData.mapDownloaded);
  }

  void _addActivityToList() async {
    /// Get the number of total activities
    int numActivities = await SharedPref.readInt(PowderPilot.numActivitiesKey);

    /// Save the incremented number of total activities to shared preferences
    SharedPref.saveInt(PowderPilot.numActivitiesKey, numActivities + 1);
  }

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

class LocationHandler extends ActivityData {
  int _numberOfDistanceUpdates = 0;
  int _numberOfSpeedUpdates = 0;
  int _numberOfSlopeUpdates = 0;
  int _numberOfAltitudeUpdates = 0;
  int _numberOfLocationUpdates = 0;

  /// Location callback
  late LocationCallback locationCallback;
  
  /// Altitude buffer
  /// Used to smooth the altitude
  final List<double> _altitudeBuffer = [];

  /// Flag to track if the location is initialized
  bool _locationInitialized = false;

  void _locationStream() {
    late Position lastLocation;

    double currentRunLength = 0.0;

    void updateSpeed(Position position) {
      if (position.speed < 55) {
        speed.currentSpeed = position.speed;

        if (speed.currentSpeed > speed.maxSpeed) {
          activityLocations =
              activityLocations.setFastestLocation([longitude, latitude]);
          route.addCoordinates([longitude, latitude]);
          speed.maxSpeed = speed.currentSpeed;
        }

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
          double.parse(speed.currentSpeed.toStringAsFixed(1))
        ]);
      }
    }

    void updateAltitude(Position position) {
      _numberOfAltitudeUpdates++;

      /// Generated with GPT 3.5
      /// Helper method to smooth the altitude
      double smoothAltitude(double newAltitude) {
        /// Implement a simple smoothing technique (e.g., moving average)
        /// You can customize the smoothing algorithm based on your needs.
        const int smoothingFactor = 5;

        /// Adjust this value based on your preference
        _altitudeBuffer.add(newAltitude);

        /// Remove the first element if the buffer is full
        if (_altitudeBuffer.length > smoothingFactor) {
          _altitudeBuffer.removeAt(0);
        }

        /// Calculate the average of the buffer
        double smoothedValue =
            _altitudeBuffer.reduce((a, b) => a + b) / _altitudeBuffer.length;

        /// Return the smoothed value
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
        altitude.currentAltitude.round()
      ]);
    }

    /// Temporary distance variable
    double tempDistance = 0.0;

    void updateDistance(Position position) {
      double calculatedDistance = Utils.calculateHaversineDistance(
          LatLng(lastLocation.latitude, lastLocation.longitude),
          LatLng(position.latitude, position.longitude));

      _numberOfDistanceUpdates++;

      if (_numberOfDistanceUpdates % 5 == 0 && calculatedDistance > 2) {
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

    /// Temp altitude variable for slope calculation
    double tempAltitude = 0.0;

    /// Temp location variable for slope calculation
    late Position tempLocation;
    void updateSlope(Position position) {
      if (state.runningStatus != RunningStatus.pause) {
        double difference = (tempAltitude - altitude.currentAltitude).abs();
        if (difference > 125) {
          tempAltitude = altitude.currentAltitude;
          tempLocation = position;
          difference = 0.0;
        }
        if (difference > 10) {
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
          tempAltitude = altitude.currentAltitude;
          tempLocation = position;
        }
      }
    }

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

    void onLocationUpdate(Position position) {
      latitude = position.latitude;
      longitude = position.longitude;

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

          // Update speed
          updateSpeed(position);

          // Update altitude
          updateAltitude(position);

          // Update distance
          updateDistance(position);

          // Update slope
          updateSlope(position);

          if (_numberOfLocationUpdates % 5 == 0) {
            _updateNearestSlope();
          }

          if (!_locationInitialized) {
            _locationInitialized = true;
          }
        } else {
          // Set values to 0 if GPS accuracy is low
          speed.currentSpeed = 0.0;
          slope.currentSlope = 0.0;
        }
      }
      if (PowderPilot.connectionStatus == true && !mapData.mapDownloaded) {
        _downloadMap();
      }
      updateData();

      if (_numberOfLocationUpdates % 15 == 0 &&
          (PowderPilot.connectionStatus == true ||
              _numberOfLocationUpdates == 0)) {
        if (!mapData.mapDownloaded) {
          _downloadMap();
        }
      }
      String areaNameTemp = PowderPilot.locationService.areaName;
      if (areaNameTemp != areaName) {
        areaName = areaNameTemp;
        updateData();
      }

      _numberOfLocationUpdates++;
    }

    locationCallback = onLocationUpdate;
    PowderPilot.locationService.addListener(locationCallback);
  }

  Future<void> _updateNearestSlope() async {
    if (mapData.mapDownloaded == true) {
      if (state.isDownhill || state.isUphill) {
        route.addSlope(SlopeMap.findNearestSlope(
            latitude: latitude, longitude: longitude, lift: state.isUphill));
      }
    }
  }

  static bool _isDownloadRunning = false;

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
