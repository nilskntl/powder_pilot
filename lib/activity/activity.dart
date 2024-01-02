import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart';

import '../main.dart';
import 'activity_map.dart';

enum ActivityType {
  ski,
  snowboard,
}

enum LocationType {
  gps,
  network,
}

enum GpsAccuracy {
  none,
  low,
  medium,
  high,
}

class Activity extends ActivityLocation {

  static int id = -1;

  Activity() {
    id++;
    _requestPermission();
    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );
    location.enableBackgroundMode(enable: false);
    _locationStream();
  }

  void startActivity() {
    _running = true;
    _active = true;
    _startStopwatch(callback: () {
      _setNotification();
    });
    updateData();
    _locationSettings();
  }

  void stopActivity() {
    speed = 0.0;
    slope = 0.0;
    _running = false;
    _active = false;
    _statusDownhill = false;
    _statusUphill = false;
    _statusPause = true;
    _stopStopwatch();
    _locationSubscription?.cancel();
    _locationInitialized = false;
    initializedMap = false;
    updateData();
    SkiTracker.setActivity(Activity());
  }

  void pauseActivity() {
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
    _running = true;
    _resumeStopwatch(callback: () {
      _setNotification();
    });
  }

  ActivityMap get activityMap => _activityMap;
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

    void updateSpeed(LocationData location) {
      if (location.speed! < 55) {
        speed = location.speed!;
        maxSpeed = speed > maxSpeed ? speed : maxSpeed;

        if (speed < 0.6) {
          speed = 0.0;
        } else {
          _numberOfSpeedUpdates++;
          _statusPause = false;
          totalSpeed += speed;
          avgSpeed = totalSpeed / _numberOfSpeedUpdates;
        }
      }
    }

    void updateAltitude(LocationData location) {

      _numberOfAltitudeUpdates++;

      altitude = _smoothAltitude(location.altitude!);
      maxAltitude = altitude > maxAltitude ? altitude : maxAltitude;
      minAltitude = altitude < minAltitude ? altitude : minAltitude;
      totalAltitude += altitude;
      avgAltitude = totalAltitude / _numberOfAltitudeUpdates;
    }

    void updateDistance(LocationData location) {
      // Update distance
      double calculatedDistance =
          _calculateHaversineDistance(_lastLocation, location);

      _numberOfDistanceUpdates++;

      if (_numberOfDistanceUpdates % 5 == 0 && calculatedDistance > 2) {
        if (calculatedDistance > 200) {
          calculatedDistance = 0.0;
        }
        totalDistance += calculatedDistance;
        _tempDistance += calculatedDistance;
        _lastLocation = location;
      }

      // Update uphill & downhill distance
      if (!_statusUphill && !_statusDownhill) {
        if (altitude - _currentExtrema > 5) {
          _statusUphill = true;
          _statusDownhill = false;
        } else if (altitude - _currentExtrema < -5) {
          _statusUphill = false;
          _statusDownhill = true;
        }
      } else {
        if (altitude - _currentExtrema > 25) {
          _statusUphill = true;
          _statusDownhill = false;
        } else if (altitude - _currentExtrema < -25) {
          _statusUphill = false;
          _statusDownhill = true;
        }
      }

      if (_statusUphill && altitude - _currentExtrema > 0) {
        _currentExtrema = altitude;
        uphillDistance += _tempDistance;
        _tempDistance = 0.0;
      } else if (_statusDownhill && altitude - _currentExtrema < 0) {
        _currentExtrema = altitude;
        downhillDistance += _tempDistance;
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
            double horizontalDistance =
            _calculateHaversineDistance(_tempLocation, location);

            double verticalDistance = _tempAltitude - altitude;

            slope = verticalDistance / horizontalDistance;
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
    }

    _locationSubscription =
        location.onLocationChanged.listen((LocationData location) {
      _numberOfLocationUpdates++;
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
          }

          // Update speed
          updateSpeed(location);

          // Update altitude
          updateAltitude(location);

          // Update distance
          updateDistance(location);

          // Update slope
          updateSlope(location);

          if (!_locationInitialized) {
            _locationInitialized = true;
          }
        } else {
          // Set values to 0 if GPS accuracy is low
          speed = 0.0;
          slope = 0.0;
        }
      }

      currentLatitude = location.latitude!;
      currentLongitude = location.longitude!;
      if(!initializedMap) {
        _activityMap = ActivityMap();
        _updateAddress();
        initializedMap = true;
      }
      if(_numberOfLocationUpdates % 100 == 0) {
        _updateAddress();
      }
    });
  }

  Future<void> _updateAddress() async {
    if (kDebugMode) {
      print('Updating address');
    }
    try {
      var address = await GeoCode().reverseGeocoding(latitude: currentLatitude, longitude: currentLongitude);
      city = address.city!;
      country = address.countryName!;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _setNotification() {
    location.changeNotificationOptions(
      title: 'Activity is running',
      subtitle: elapsedTime.toString().substring(0, 7),
      onTapBringToFront: true,
      color: ColorTheme.primaryColor,
      iconName: 'assets/images/icon_256.png',
    );
  }

  void _locationSettings() {
    location.enableBackgroundMode(enable: true);
    _setNotification();
  }
}

class ActivityStatus extends ActivityData {
  bool _running = false;
  bool _active = false;

  bool _statusUphill = false;
  bool _statusDownhill = false;
  bool _statusPause = true;

  bool get isRunning => _running;

  bool get isActive => _active;
}

class ActivityTimer extends ActivityStatus {
  late final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime = Duration.zero;
  Duration _elapsedPauseTime = Duration.zero;
  Duration _elapsedDownhillTime = Duration.zero;
  Duration _elapsedUphillTime = Duration.zero;
  
  late Timer _timer;

  void _startStopwatch({required Function() callback}) {
    _stopwatch.start();
    Duration pauseTime = const Duration(seconds: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _elapsedTime = _stopwatch.elapsed;
        if(_statusDownhill && !_statusPause) {
          _elapsedDownhillTime += const Duration(seconds: 1);
        } else if(_statusUphill && !_statusPause) {
          _elapsedUphillTime += const Duration(seconds: 1);
        } else {
          _elapsedPauseTime += const Duration(seconds: 1);
        }
        if(!_statusPause) {
          if(speed == 0.0) {
            pauseTime += const Duration(seconds: 1);
          } else {
            pauseTime = const Duration(seconds: 0);
          }
          if(pauseTime > const Duration(seconds: 5)) {
            _statusPause = true;
            if(_statusDownhill) {
              _elapsedDownhillTime -= pauseTime;
            } else if(_statusUphill) {
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

  double _calculateHaversineDistance(LocationData pos1, LocationData pos2) {
    double toRadians(double degree) {
      return degree * (math.pi / 180.0);
    }

    double lat1 = pos1.latitude!;
    double lat2 = pos2.latitude!;
    double lon1 = pos1.longitude!;
    double lon2 = pos2.longitude!;

    const R = 6371000.0; // Earth radius in meters

    final dLat = toRadians(lat2 - lat1);
    final dLon = toRadians(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRadians(lat1)) *
            math.cos(toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

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

  // Map
  late final ActivityMap _activityMap;

  // Current city
  String city = 'Unknown';

  // Current country
  String country = 'Unknown';

  // Speed
  double speed = 0.0;
  double maxSpeed = 0.0;
  double avgSpeed = 0.0;
  double totalSpeed = 0.0;

  // Distance
  double totalDistance = 0.0;
  double uphillDistance = 0.0;
  double downhillDistance = 0.0;

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

  // Current location
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;

  // GPS Accuracy
  GpsAccuracy gpsAccuracy = GpsAccuracy.none;

  // Location loaded
  bool initializedMap = false;

  void updateData() {
    // Update UI
    SkiTracker.getActivityDataProvider().updateData(
      newSpeed: speed,
      newMaxSpeed: maxSpeed,
      newAvgSpeed: avgSpeed,
      newTotalDistance: totalDistance,
      newUphillDistance: uphillDistance,
      newDownhillDistance: downhillDistance,
      newAltitude: altitude,
      newMaxAltitude: maxAltitude,
      newMinAltitude: minAltitude,
      newAvgAltitude: avgAltitude,
      newSlope: slope,
      newMaxSlope: maxSlope,
      newAvgSlope: avgSlope,
      newElapsedTime: SkiTracker.getActivity().elapsedTime,
      newElapsedPauseTime: SkiTracker.getActivity().elapsedPauseTime,
      newElapsedDownhillTime: SkiTracker.getActivity().elapsedDownhillTime,
      newElapsedUphillTime: SkiTracker.getActivity().elapsedUphillTime,
      newCurrentLatitude: currentLatitude,
      newCurrentLongitude: currentLongitude,
      newGpsAccuracy: gpsAccuracy,
      newLocationLoaded: initializedMap,
    );
  }
}

class ActivityDataTemp {

  bool _locationInitialized = false;

  bool infoMounted = false;

  double _currentExtrema = 0.0;
  double _tempDistance = 0.0;

  late LocationData _lastLocation;

  double _tempAltitude = 0.0;
  late LocationData _tempLocation;
}
