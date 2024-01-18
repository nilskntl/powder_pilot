import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../main.dart';
import '../pages/activity_display.dart';
import '../pages/activity_summary.dart';
import '../utils/app_bar.dart';
import '../utils/fetch_slope_data.dart';
import '../utils/general_utils.dart';
import '../utils/shared_preferences.dart';
import 'activity_database.dart';
import 'route.dart';
import 'slopes.dart';

enum ActivityType {
  ski,
  snowboard,
}

enum LocationType {
  gps,
  network,
}

enum ActivityStatus {
  running,
  paused,
  stopped,
  inactive,
}

enum GpsAccuracy {
  none,
  low,
  medium,
  high,
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({super.key, required this.activityDatabase});

  final ActivityDatabase activityDatabase;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CustomMaterialAppBar.appBar(title: 'Summary'),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: ColorTheme.background,
              ),
              child: ActivitySummary(
                activityDatabase: widget.activityDatabase,
                small: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Activity extends ActivityLocation {
  final int id;

  Activity(
      {required this.id,
      String areaName = '',
      LatLng currentPosition = const LatLng(0.0, 0.0),
      bool mapDownloaded = false}) {
    currentLatitude = currentPosition.latitude;
    currentLongitude = currentPosition.longitude;
    _mapDownloaded = mapDownloaded;
    if (mapDownloaded) {
      _latitudeWhenDownloaded = currentLatitude;
      _longitudeWhenDownloaded = currentLongitude;
    }
    if (areaName != '' || areaName != 'Unknown') {
      this.areaName = areaName;
    }
  }

  void init() {
    if (kDebugMode) {
      print('Activity $id initialized');
    }
    _requestPermission();
    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );
    location.enableBackgroundMode(enable: false);
    _activityInitialized = true;
    _locationStream();
  }

  void startActivity() {
    if (_active) {
      return;
    }
    _running = true;
    _active = true;
    startTime = DateTime.now();
    _startStopwatch(callback: () {
      _setNotification();
    });
    if (Utils.calculateHaversineDistance(
            LatLng(currentLatitude, currentLongitude),
            LatLng(_latitudeWhenDownloaded, _longitudeWhenDownloaded)) >
        4000) {
      _mapDownloaded = false;
      _downloadMap();
    }
    updateData();
    _locationSettings();
  }

  void stopActivity(BuildContext context) {
    if (!_active) {
      return;
    }
    speed = 0.0;
    slope = 0.0;
    activityLocations =
        activityLocations.setEndLocation([currentLongitude, currentLatitude]);
    _running = false;
    endTime = DateTime.now();
    _active = false;
    _statusDownhill = false;
    _statusUphill = false;
    _statusPause = true;
    _stopStopwatch();
    _locationSubscription?.cancel();
    _activityInitialized = false;
    if (route.slopes.isNotEmpty) {
      route.slopes.last.endTime = DateTime.now();
    }
    updateData();
    if (_locationInitialized) {
      ActivityDatabase activityDatabase = saveActivity();
      _locationInitialized = false;
      _showCustomDialog(context, activityDatabase);
      _addActivityToList();
    }

    _elapsedTime = Duration.zero;

    PowderPilot.createNewActivity(
        areaName: areaName,
        currentPosition: LatLng(currentLatitude, currentLongitude),
        mapDownloaded: _mapDownloaded);
  }

  void _showCustomDialog(
      BuildContext context, ActivityDatabase activityDatabase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          activityDatabase: activityDatabase,
        );
      },
    );
  }

  void _addActivityToList() async {
    int numActivities = await SharedPref.readInt('numActivities');
    SharedPref.saveInt('numActivities', numActivities + 1);
  }

  void pauseActivity() {
    if (!_active) {
      return;
    }
    speed = 0.0;
    slope = 0.0;
    _running = false;
    _statusDownhill = false;
    _statusUphill = false;
    _statusPause = true;
    _altitudeBuffer.clear();
    _pauseStopwatch();
  }

  void resumeActivity() {
    if (!_active) {
      return;
    }
    _running = true;
    if (Utils.calculateHaversineDistance(
            LatLng(currentLatitude, currentLongitude),
            LatLng(_latitudeWhenDownloaded, _longitudeWhenDownloaded)) >
        4000) {
      _mapDownloaded = false;
      _downloadMap();
    }
    _resumeStopwatch(callback: () {
      _setNotification();
    });
    updateData();
  }
}

class ActivityLocation extends ActivityUtils {
  Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  int _numberOfDistanceUpdates = 0;
  int _numberOfSpeedUpdates = 0;
  int _numberOfSlopeUpdates = 0;
  int _numberOfAltitudeUpdates = 0;
  int _numberOfLocationUpdates = 0;

  Future<bool> _requestPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Service enabled: $serviceEnabled');
        }
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    return permissionGranted == PermissionStatus.granted;
  }

  void _locationStream() {
    double currentRunLength = 0.0;

    void updateSpeed(LocationData location) {
      if (location.speed! < 55) {
        speed = location.speed!;

        if (speed > maxSpeed) {
          activityLocations = activityLocations
              .setFastestLocation([currentLongitude, currentLatitude]);
          maxSpeed = speed;
        }

        if (speed < 0.6) {
          speed = 0.0;
        } else {
          _numberOfSpeedUpdates++;
          _statusPause = false;
          totalSpeed += speed;
          avgSpeed = totalSpeed / _numberOfSpeedUpdates;
        }

        speeds.add([
          elapsedTime.inSeconds.toDouble(),
          double.parse(speed.toStringAsFixed(1))
        ]);
      }
    }

    void updateAltitude(LocationData location) {
      _numberOfAltitudeUpdates++;

      altitude = _smoothAltitude(location.altitude!);
      maxAltitude = altitude > maxAltitude ? altitude : maxAltitude;
      if (minAltitude == 0.0) {
        minAltitude = altitude;
      }
      minAltitude = altitude < minAltitude ? altitude : minAltitude;
      totalAltitude += altitude;
      avgAltitude = totalAltitude / _numberOfAltitudeUpdates;

      altitudes.add([elapsedTime.inSeconds, altitude.round()]);
    }

    void updateDistance(LocationData location) {
      // Update distance
      double calculatedDistance = Utils.calculateHaversineDistance(
          LatLng(_lastLocation.latitude!, _lastLocation.longitude!),
          LatLng(location.latitude!, location.longitude!));

      _numberOfDistanceUpdates++;

      if (_numberOfDistanceUpdates % 5 == 0 && calculatedDistance > 2) {
        if (calculatedDistance > 400) {
          calculatedDistance = 0.0;
        }
        route.addCoordinates([currentLongitude, currentLatitude]);
        distance += calculatedDistance;
        _tempDistance += calculatedDistance;
        _lastLocation = location;
      }

      // Update uphill & downhill distance
      if (!_statusUphill && !_statusDownhill) {
        if (altitude - _currentExtrema > 5) {
          _statusUphill = true;
          _statusDownhill = false;
          currentRunLength = 0.0;
        } else if (altitude - _currentExtrema < -5) {
          _statusUphill = false;
          _statusDownhill = true;
          currentRunLength = 0.0;
          totalRuns++;
        }
      } else {
        if (altitude - _currentExtrema > 15) {
          _statusUphill = true;
          _statusDownhill = false;
          currentRunLength = 0.0;
        } else if (altitude - _currentExtrema < -15) {
          _statusUphill = false;
          _statusDownhill = true;
          currentRunLength = 0.0;
          totalRuns++;
        }
      }

      if (_statusUphill && altitude - _currentExtrema > 0) {
        _currentExtrema = altitude;
        distanceUphill += _tempDistance;
        _tempDistance = 0.0;
      } else if (_statusDownhill && altitude - _currentExtrema < 0) {
        _currentExtrema = altitude;
        distanceDownhill += _tempDistance;
        currentRunLength += _tempDistance;
        longestRun =
            currentRunLength > longestRun ? currentRunLength : longestRun;
        _tempDistance = 0.0;
      }
    }

    void updateSlope(LocationData location) {
      // Update slope
      if (!_statusPause) {
        double difference = (_tempAltitude - altitude).abs();
        if (difference > 125) {
          _tempAltitude = altitude;
          _tempLocation = location;
          difference = 0.0;
        }
        if (difference > 10) {
          if (_tempLocation.latitude == location.latitude &&
              _tempLocation.longitude == location.longitude) {
            return;
          }
          if (_tempAltitude - altitude > 0) {
            double horizontalDistance = Utils.calculateHaversineDistance(
                LatLng(_tempLocation.latitude!, _tempLocation.longitude!),
                LatLng(location.latitude!, location.longitude!));

            double verticalDistance = _tempAltitude - altitude;

            slope = verticalDistance / horizontalDistance * 100;
            _numberOfSlopeUpdates++;
            maxSlope = slope > maxSlope ? slope : maxSlope;
            totalSlope += slope;
            avgSlope = totalSlope / _numberOfSlopeUpdates;
          } else {
            slope = 0.0;
          }
          _tempAltitude = altitude;
          _tempLocation = location;
        }
      }
    }

    void initializeLocation(LocationData location) {
      _lastLocation = location;
      altitude = location.altitude!;
      _currentExtrema = altitude;
      _tempAltitude = altitude;
      _tempLocation = location;
      activityLocations = activityLocations
          .setStartLocation([currentLongitude, currentLatitude]);
      if ((route.slopes.isEmpty || route.slopes.last.name == 'Unknown') &&
          _mapDownloaded == true) {
        _updateNearestSlope();
      }
    }

    _locationSubscription =
        location.onLocationChanged.listen((LocationData location) {
      currentLatitude = location.latitude!;
      currentLongitude = location.longitude!;
      if (_running) {
        if (location.accuracy! < 10) {
          gpsAccuracy = GpsAccuracy.high;
        } else if (location.accuracy! < 25) {
          gpsAccuracy = GpsAccuracy.medium;
        } else {
          gpsAccuracy = GpsAccuracy.low;
        }

        if (gpsAccuracy == GpsAccuracy.high ||
            gpsAccuracy == GpsAccuracy.medium) {
          if (!_locationInitialized) {
            initializeLocation(location);
            route.addCoordinates([currentLongitude, currentLatitude]);
          }

          // Update speed
          updateSpeed(location);

          // Update altitude
          updateAltitude(location);

          // Update distance
          updateDistance(location);

          // Update slope
          updateSlope(location);

          if (_numberOfLocationUpdates % 5 == 0) {
            _updateNearestSlope();
          }

          if (!_locationInitialized) {
            _locationInitialized = true;
          }
        } else {
          // Set values to 0 if GPS accuracy is low
          speed = 0.0;
          slope = 0.0;
        }
      }
      if (_activityInitialized) {
        if (PowderPilot.connectionStatus == true && !_mapDownloaded) {
          _downloadMap();
        }

        updateData();
      }
      _numberOfLocationUpdates++;
      if (_numberOfLocationUpdates % 15 == 0) {
        if (PowderPilot.connectionStatus == true) {
          if (areaName == '' || areaName == 'Unknown') {
            _updateAddress();
          }
          if (_numberOfLocationUpdates % 120 == 0) {
            _updateAddress();
          }
          if (!_mapDownloaded) {
            _downloadMap();
          }
        }
      }

      /*
       if(_numberOfLocationUpdates % 100 == 0) {
        _updateAddress();
      }
       */
    });
  }

  Future<void> _updateNearestSlope() async {
    if (_mapDownloaded == true) {
      if (_statusUphill) {
        route.addSlope(SlopeMap.findNearestSlope(
            latitude: currentLatitude,
            longitude: currentLongitude,
            lift: true));
      } else if (_statusDownhill) {
        route.addSlope(SlopeMap.findNearestSlope(
            latitude: currentLatitude,
            longitude: currentLongitude,
            lift: false));
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
      if (_mapDownloaded == true) {
        return;
      }
      await SlopeFetcher.fetchData(currentLatitude, currentLongitude);
      if (SlopeMap.slopes.isNotEmpty) {
        _latitudeWhenDownloaded = currentLatitude;
        _longitudeWhenDownloaded = currentLongitude;
        _mapDownloaded = true;
      }
    }
    _isDownloadRunning = false;
  }

  Future<void> _updateAddress() async {
    if (kDebugMode) {}
    try {
      var address = await GeoCode().reverseGeocoding(
          latitude: currentLatitude, longitude: currentLongitude);
      areaName = '${address.countryName!}, ${address.city!}';
      updateData();
    } catch (e) {
      if (kDebugMode) {
        print('Error while trying to fetch Adress Data $e');
      }
    }
  }

  void _setNotification() {
    location.changeNotificationOptions(
      title: 'Activity is running',
      subtitle: elapsedTime.toString().substring(0, 7),
      onTapBringToFront: true,
      color: ColorTheme.secondary,
      description: 'Distance: ${(distance / 1000).toStringAsFixed(1)} km\n'
          'Speed: ${(maxSpeed * Info.speedFactor).toStringAsFixed(1)} km/h\n'
          'Altitude: ${altitude.toStringAsFixed(0)} m\n'
          'Runs: $totalRuns\n',
      iconName: 'assets/images/icon_256.png',
    );
  }

  void _locationSettings() {
    location.enableBackgroundMode(enable: true);
    _setNotification();
  }
}

class ActivityTimer extends ActivityData {
  late final Stopwatch _stopwatch = Stopwatch();

  late Timer _timer;

  void _startStopwatch({required Function() callback}) {
    _stopwatch.start();
    Duration pauseTime = const Duration(seconds: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime = _stopwatch.elapsed;
      if (_statusDownhill && !_statusPause) {
        _elapsedDownhillTime += const Duration(seconds: 1);
      } else if (_statusUphill && !_statusPause) {
        _elapsedUphillTime += const Duration(seconds: 1);
      } else {
        _elapsedPauseTime += const Duration(seconds: 1);
      }
      if (!_statusPause) {
        if (speed == 0.0) {
          pauseTime += const Duration(seconds: 1);
        } else {
          pauseTime = const Duration(seconds: 0);
        }
        if (pauseTime > const Duration(seconds: 5)) {
          _statusPause = true;
          if (_statusDownhill) {
            _elapsedDownhillTime -= pauseTime;
          } else if (_statusUphill) {
            _elapsedUphillTime -= pauseTime;
          }
          pauseTime = const Duration(seconds: 0);
        }
      }
      callback();
      // Update UI periodically
      updateData();
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
    _elapsedTime = _stopwatch.elapsed;
    updateData();
  }

  void _pauseStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
    _elapsedTime = _stopwatch.elapsed;
    updateData();
  }

  void _resumeStopwatch({required Function() callback}) {
    _startStopwatch(callback: callback);
  }

  Duration get elapsedTime => _elapsedTime;

  Duration get elapsedPauseTime => _elapsedPauseTime;

  Duration get elapsedDownhillTime => _elapsedDownhillTime;

  Duration get elapsedUphillTime => _elapsedUphillTime;
}

class ActivityUtils extends ActivityTimer {
  final List<double> _altitudeBuffer = [];

  /*
  Generated with GPT 3.5
   */
  double _smoothAltitude(double newAltitude) {
    // Implement a simple smoothing technique (e.g., moving average)
    // You can customize the smoothing algorithm based on your needs.
    const int smoothingFactor = 5; // Adjust this value based on your preference
    _altitudeBuffer.add(newAltitude);

    if (_altitudeBuffer.length > smoothingFactor) {
      _altitudeBuffer.removeAt(0);
    }

    double smoothedValue =
        _altitudeBuffer.reduce((a, b) => a + b) / _altitudeBuffer.length;
    return smoothedValue;
  }
}

class ActivityData extends ActivityDataTemp {
  String areaName = '';

  // Timestamp
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  // Speed
  double speed = 0.0;
  double maxSpeed = 0.0;
  double avgSpeed = 0.0;
  double totalSpeed = 0.0;

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
  double totalAltitude = 0.0;

  // Slope
  double slope = 0.0;
  double maxSlope = 0.0;
  double avgSlope = 0.0;
  double totalSlope = 0.0;

  // Duration
  Duration _elapsedTime = Duration.zero;
  Duration _elapsedPauseTime = Duration.zero;
  Duration _elapsedDownhillTime = Duration.zero;
  Duration _elapsedUphillTime = Duration.zero;

  // Current location
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;

  // GPS Accuracy
  GpsAccuracy gpsAccuracy = GpsAccuracy.none;

  // Route
  // ignore: prefer_const_constructors
  final ActivityRoute route =
      ActivityRoute(slopes: [], coordinates: []); // Don't define as const

  // List of altitudes
  List<List<int>> altitudes = [];

  // List of speeds
  List<List<double>> speeds = [];

  // Important locations
  ActivityLocations activityLocations = const ActivityLocations();

  ActivityDatabase saveActivity() {
    ActivityDatabase activityDatabase = ActivityDatabase(
      areaName: areaName,
      maxSpeed: maxSpeed,
      averageSpeed: avgSpeed,
      totalRuns: totalRuns,
      longestRun: longestRun,
      maxAltitude: maxAltitude,
      minAltitude: minAltitude,
      avgAltitude: avgAltitude,
      maxSlope: maxSlope,
      avgSlope: avgSlope,
      distance: distance,
      distanceDownhill: distanceDownhill,
      distanceUphill: distanceUphill,
      elapsedTime: _elapsedTime.toString(),
      elapsedDownhillTime: _elapsedDownhillTime.toString(),
      elapsedUphillTime: _elapsedUphillTime.toString(),
      elapsedPauseTime: _elapsedPauseTime.toString(),
      route: route.toString(),
      startTime: startTime.toString(),
      endTime: endTime.toString(),
      altitudes: altitudes.toString(),
      speeds: speeds.toString(),
      speedLocation: activityLocations.fastestLocation.toString(),
      startLocation: activityLocations.startLocation.toString(),
      endLocation: activityLocations.endLocation.toString(),
    );

    ActivityDatabaseHelper.insertActivity(activityDatabase);
    return activityDatabase;
  }

  void updateData() {
    // Update UI
    PowderPilot.getActivityDataProvider().updateData(
      newSpeed: speed,
      newMaxSpeed: maxSpeed,
      newAvgSpeed: avgSpeed,
      newDistance: distance,
      newDistanceUphill: distanceUphill,
      newDistanceDownhill: distanceDownhill,
      newAltitude: altitude,
      newMaxAltitude: maxAltitude,
      newMinAltitude: minAltitude,
      newAvgAltitude: avgAltitude,
      newSlope: slope,
      newMaxSlope: maxSlope,
      newAvgSlope: avgSlope,
      newElapsedTime: _elapsedTime,
      newElapsedPauseTime: _elapsedPauseTime,
      newElapsedDownhillTime: _elapsedDownhillTime,
      newElapsedUphillTime: _elapsedUphillTime,
      newCurrentLatitude: currentLatitude,
      newCurrentLongitude: currentLongitude,
      newGpsAccuracy: gpsAccuracy,
      newTotalRuns: totalRuns,
      newLongestRun: longestRun,
      newRoute: route,
      newStatus: _running && _active
          ? ActivityStatus.running
          : _active
              ? ActivityStatus.paused
              : ActivityStatus.inactive,
      newArea: areaName,
      newAltitudes: altitudes,
      newSpeeds: speeds,
      newActivityLocations: activityLocations,
    );
  }
}

class ActivityDataTemp {
  bool _locationInitialized = false;

  double _latitudeWhenDownloaded = 0.0;
  double _longitudeWhenDownloaded = 0.0;

  double _currentExtrema = 0.0;
  double _tempDistance = 0.0;

  late LocationData _lastLocation;

  double _tempAltitude = 0.0;
  late LocationData _tempLocation;

  bool _running = false;
  bool _active = false;

  bool _statusUphill = false;
  bool _statusDownhill = false;
  bool _statusPause = true;

  bool _activityInitialized = false;

  bool _mapDownloaded = false;

  bool get isRunning => _running;

  bool get isActive => _active;
}

class ActivityLocations {
  final List<double> fastestLocation;
  final List<double> startLocation;
  final List<double> endLocation;

  const ActivityLocations(
      {this.fastestLocation = const [0.0, 0.0],
      this.startLocation = const [0.0, 0.0],
      this.endLocation = const [0.0, 0.0]});

  // Edit value of final Lists
  ActivityLocations setFastestLocation(List<double> newFastestLocation) {
    return ActivityLocations(
        fastestLocation: newFastestLocation,
        startLocation: startLocation,
        endLocation: endLocation);
  }

  ActivityLocations setStartLocation(List<double> newStartLocation) {
    return ActivityLocations(
        fastestLocation: fastestLocation,
        startLocation: newStartLocation,
        endLocation: endLocation);
  }

  ActivityLocations setEndLocation(List<double> newEndLocation) {
    return ActivityLocations(
        fastestLocation: fastestLocation,
        startLocation: startLocation,
        endLocation: newEndLocation);
  }
}
