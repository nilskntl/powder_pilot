import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

import '../main.dart';

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
  void startActivity() {
    _running = true;
    _active = true;
    _startStopwatch(callback: () {
      onStopwatchCallback();
    });
    updateData();
    _requestPermission();
    _locationSettings();
    _locationStream();
  }

  void stopActivity() {
    _running = false;
    _active = false;
    _stopStopwatch();
    _locationSubscription?.cancel();
  }

  void pauseActivity() {
    _locationSubscription?.cancel();
    speed = 0.0;
    slope = 0.0;
    _running = false;
    _statusDownhill = false;
    _statusUphill = false;
    _statusPause = true;
    _pauseStopwatch();
  }

  void resumeActivity() {
    _running = true;
    _resumeStopwatch(callback: () {
      onStopwatchCallback();
    });
    _locationStream();
  }

  void onStopwatchCallback() {
    _notificationSettings();
  }
}

class ActivityLocation extends ActivityUtils {
  Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  int _numberOfLocationUpdates = 0;
  int _numberOfSpeedUpdates = 0;
  int _numberOfSlopeUpdates = 0;

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
    DateTime tempTime = DateTime.now();

    void updateSpeed(LocationData location) {
      if (location.speed! < 55) {
        speed = location.speed!;
        maxSpeed = speed > maxSpeed ? speed : maxSpeed;

        if (speed < 0.6) {
          speed = 0.0;
          if (!_statusPause) {
            if (DateTime.now().millisecond - tempTime.millisecond >= 5000) {
              _statusPause = true;
              if (_statusDownhill) {
                _elapsedDownhillTime -= const Duration(seconds: 5);
              } else if (_statusUphill) {
                _elapsedUphillTime -= const Duration(seconds: 5);
              } else {
                _elapsedPauseTime += const Duration(seconds: 5);
              }
            }
          }
        } else {
          _numberOfSpeedUpdates++;
          _statusPause = false;
          tempTime = DateTime.now();
          totalSpeed += speed;
          avgSpeed = totalSpeed / _numberOfSpeedUpdates;
        }
      }
    }

    void updateAltitude(LocationData location) {
      altitude = _smoothAltitude(location.altitude!);
      maxAltitude = altitude > maxAltitude ? altitude : maxAltitude;
      minAltitude = altitude < minAltitude ? altitude : minAltitude;
      totalAltitude += altitude;
      avgAltitude = totalAltitude / _numberOfLocationUpdates;
    }

    void updateDistance(LocationData location) {
      // Update distance
      double calculatedDistance =
          _calculateHaversineDistance(_lastLocation, location);

      if (_numberOfLocationUpdates % 5 == 0 && calculatedDistance > 2) {
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
      void updateSlopeHelper(LocationData tempLoc, double tempAlt) {
        if (tempLoc.latitude == location.latitude &&
            tempLoc.longitude == location.longitude) {
          return;
        }
        if (tempAlt - altitude > 0) {
          double horizontalDistance =
              _calculateHaversineDistance(tempLoc, location);

          double verticalDistance = tempAlt - altitude;

          slope = verticalDistance / horizontalDistance;
          _numberOfSlopeUpdates++;
          maxSlope = slope > maxSlope ? slope : maxSlope;
          totalSlope += slope;
          avgSlope = totalSlope / _numberOfSlopeUpdates;
        } else {
          slope = 0.0;
        }
      }

      // Update slope
      if (!_statusPause) {
        double firstDifference = (_tempAltitude - altitude).abs();
        if(firstDifference > 125) {
          _tempAltitude = altitude;
          _tempLocation = location;
          firstDifference = 0.0;
        }
        double secondDifference = (_secondTempAltitude - altitude).abs();
        if(secondDifference > 125) {
          _secondTempAltitude = altitude;
          _secondTempLocation = location;
          secondDifference = 0.0;
        }
        if (firstDifference > 15) {
          updateSlopeHelper(_tempLocation, _tempAltitude);
          _tempAltitude = altitude;
          _tempLocation = location;
        } else if (firstDifference > 7.5 &&
            secondDifference > 15) {
          updateSlopeHelper(_secondTempLocation, _secondTempAltitude);
          _secondTempAltitude = altitude;
          _secondTempLocation = location;
        }
      }
    }

    void initializeLocation(LocationData location) {
      _lastLocation = location;
      altitude = location.altitude!;
      _currentExtrema = altitude;
      _tempAltitude = altitude;
      _secondTempAltitude = altitude;
      _tempLocation = location;
      _secondTempLocation = location;
    }

    bool initialized = false;

    _locationSubscription =
        location.onLocationChanged.listen((LocationData location) {
      _numberOfLocationUpdates++;

      if (location.accuracy! < 10) {
        gpsAccuracy = GpsAccuracy.high;
      } else if (location.accuracy! < 25) {
        gpsAccuracy = GpsAccuracy.medium;
      } else {
        gpsAccuracy = GpsAccuracy.low;
      }

      if (gpsAccuracy == GpsAccuracy.high ||
          gpsAccuracy == GpsAccuracy.medium) {
        if (!initialized) {
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

        if (!initialized) {
          initialized = true;
        }
      } else {
        // Set values to 0 if GPS accuracy is low
        speed = 0.0;
        slope = 0.0;
      }
    });
  }

  void _notificationSettings() {
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

    _notificationSettings();

    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );
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

  void _startStopwatch({required Function() callback}) {
    _stopwatch.start();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        _elapsedTime = _stopwatch.elapsed;
        if (_stopwatch.elapsed >= const Duration(seconds: 1)) {
          if (!_statusPause && _statusDownhill) {
            _elapsedDownhillTime += const Duration(seconds: 1);
          } else if (!_statusPause && _statusUphill) {
            _elapsedUphillTime += const Duration(seconds: 1);
          } else {
            _elapsedPauseTime += const Duration(seconds: 1);
          }
        }
        callback();
        // Update UI periodically
        updateData();
      }
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _elapsedTime = _stopwatch.elapsed;
    updateData();
  }

  void _pauseStopwatch() {
    _stopwatch.stop();
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
    );
  }
}

class ActivityDataTemp {
  double _currentExtrema = 0.0;
  double _tempDistance = 0.0;

  late LocationData _lastLocation;

  double _tempAltitude = 0.0;
  double _secondTempAltitude = 0.0;

  late LocationData _secondTempLocation;
  late LocationData _tempLocation;
}
