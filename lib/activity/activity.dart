import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_barometer_plugin/flutter_barometer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';

import '../main.dart';

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
    _running = false;
    _pauseStopwatch();
    _locationSubscription?.pause();
  }

  void resumeActivity() {
    _running = true;
    _resumeStopwatch(callback: () {
      onStopwatchCallback();
    });
    _locationSubscription?.resume();
  }

  void onStopwatchCallback() {
    _notificationSettings();
  }

  void _locationStream() {
    _barometerStream();
    _locationSubscription =
        location.onLocationChanged.listen((LocationData location) {
      _handleLocationUpdate(location);
    });
  }

  void _handleLocationUpdate(LocationData location) {
    _numberOfLocationUpdates++;

    if (!_locationLoaded) {
      _lastLocation = location;
    }

    // Update speed
    speed = location.speed!;
    maxSpeed = speed > maxSpeed ? speed : maxSpeed;
    totalSpeed += speed;
    avgSpeed = totalSpeed / _numberOfLocationUpdates;

    if (speed < 0.25) {
      speed = 0.0;
    }

    // Update altitude
    gpsAltitude = _smoothAltitude(location.altitude!);
    if (_numberOfLocationUpdates >= 5) {
      altitude = _updateBarometricAltitude();
    } else {
      altitude = gpsAltitude;
    }
    maxAltitude = altitude > maxAltitude ? altitude : maxAltitude;
    minAltitude = altitude < minAltitude ? altitude : minAltitude;
    totalAltitude += altitude;
    avgAltitude = totalAltitude / _numberOfLocationUpdates;

    // Update distance
    double calculatedDistance = _calculateDistance(_lastLocation, location);

    if (calculatedDistance < 500) {
      if (calculatedDistance > 2) {
        totalDistance += calculatedDistance;
        if (_lastLocation.altitude! < location.altitude!) {
          uphillDistance += calculatedDistance;
        } else {
          downhillDistance += calculatedDistance;
        }

        // Update slope
        double horizontalDistanceInMeters =
            _calculateHaversineDistance(_lastLocation, location);

        double slopeTemp = (_lastLocation.altitude! - gpsAltitude) /
            horizontalDistanceInMeters;
        if (slopeTemp > 0.1) {
          _numberOfSlopeUpdates++;
          slope = slopeTemp.abs();
          maxSlope = slope > maxSlope ? slope : maxSlope;
          totalSlope += slope;
          avgSlope = totalSlope / _numberOfSlopeUpdates;
        }
        _lastLocation = location;
      }
    } else {
      _lastLocation = location;
    }

    // Update vertical
    vertical += gpsAltitude - _lastLocation.altitude!;
    if (_lastLocation.altitude! < location.altitude!) {
      uphillVertical += gpsAltitude - _lastLocation.altitude!;
    } else {
      downhillVertical += gpsAltitude - _lastLocation.altitude!;
    }

    if (!_locationLoaded) {
      _locationLoaded = true;
    }

    updateData();
  }
}

class ActivityLocation extends ActivityBarometer {
  Location location = Location();
  late LocationData _lastLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  int _numberOfLocationUpdates = 0;
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

  void _notificationSettings() {
    location.changeNotificationOptions(
      title: 'Activity is running',
      subtitle: elapsedTime.toString().substring(0, 7),
      onTapBringToFront: true,
      color: ColorTheme.primaryColor,
      iconName: 'mipmap/ic_launcher',
    );
  }

  void _locationSettings() {
    location.enableBackgroundMode(enable: true);

    _notificationSettings();

    location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      distanceFilter: 1,
      interval: 1000,
    );
  }
}

class ActivityBarometer extends ActivityUtils {
  BarometerValue _currentPressure = BarometerValue(0.0);

  bool _barometerCalibrated = false;
  DateTime _lastCalibrationTime = DateTime.now();
  late double _lastCalibrationPressure;
  late double _lastGpsAltitude;
  late double _barometricAltitude;

  void _barometerStream() {
    FlutterBarometer.currentPressureEvent.listen((event) {
      _currentPressure = event;
    });
  }

  void _calibrateBarometer() {
    // Calibrate the barometer with GPS altitude
    _lastGpsAltitude = gpsAltitude;
    _lastCalibrationPressure = _currentPressure.hectpascal;
    _lastCalibrationTime = DateTime.now();
    _barometerCalibrated = true;
  }

  double _updateBarometricAltitude() {
    // Check if the barometer needs to be calibrated
    if (DateTime.now().difference(_lastCalibrationTime).inMinutes >= 10 ||
        !_barometerCalibrated) {
      _calibrateBarometer();
    }
    double currentPressure = _currentPressure.hectpascal;
    double altitudeChange =
        _calculateAltitudeChange(currentPressure, _lastCalibrationPressure);
    // Calculate barometric altitude
    _barometricAltitude = _lastGpsAltitude + altitudeChange;
    return _barometricAltitude;
  }

  /*
  Generated with GPT 3.5
  Altitude change based on the barometric formula
   */
  double _calculateAltitudeChange(
      double currentPressure, double lastCalibrationPressure) {
    // Constants
    const double standardTemperatureSeaLevel = 288.15; // Kelvin
    const double lapseRate = 0.0065; // Temperature lapse rate
    const double gravitationalAcceleration = 9.80665; // m/s^2
    const double molarMassAir = 0.0289644; // kg/mol
    const double universalGasConstant = 8.31447; // J/(mol·K)
    const double seaLevelPressure = 101325.0; // Pascal

    // Calculate altitude change
    double altitudeChange = (standardTemperatureSeaLevel / lapseRate) *
        (1 -
            math.pow(
                (currentPressure / seaLevelPressure),
                (universalGasConstant * lapseRate) /
                    (gravitationalAcceleration * molarMassAir)));

    // Calculate the change in altitude compared to the last calibration
    double referenceAltitudeChange = altitudeChange - _lastGpsAltitude;

    return referenceAltitudeChange;
  }
}

class ActivityStatus extends ActivityData {
  bool _locationLoaded = false;
  bool _running = false;
  bool _active = false;

  bool get isLocationLoaded => _locationLoaded;

  bool get isRunning => _running;

  bool get isActive => _active;
}

class ActivityUtils extends ActivityStatus {
  late final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime = Duration.zero;

  final List<double> _altitudeBuffer = [];

  final double _speedFactor = 3.6;

  double _calculateDistance(LocationData pos1, LocationData pos2) {
    double distanceInMeters = Geolocator.distanceBetween(
        pos1.latitude!, pos1.longitude!, pos2.latitude!, pos2.longitude!);
    double altitudeChange = pos2.altitude! - pos1.altitude!;
    double distance =
        math.sqrt(math.pow(distanceInMeters, 2) + math.pow(altitudeChange, 2));
    return distance;
  }

  double _calculateHaversineDistance(LocationData pos1, LocationData pos2) {
    double lat1 = pos1.latitude!;
    double lat2 = pos2.latitude!;
    double lon1 = pos1.longitude!;
    double lon2 = pos2.longitude!;

    const R = 6371000.0; // Earth radius in meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
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

  double _toRadians(double degree) {
    return degree * (math.pi / 180.0);
  }

  void _startStopwatch({required Function() callback}) {
    _stopwatch.start();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_running) {
        _elapsedTime = _stopwatch.elapsed;
        callback();
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

  double get speedFactor => _speedFactor;

  Duration get elapsedTime => _elapsedTime;
}

class ActivityData extends ChangeNotifier {
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
  double gpsAltitude = 0.0;
  double altitude = 0.0;
  double maxAltitude = 0.0;
  double minAltitude = 0.0;
  double avgAltitude = 0.0;
  double totalAltitude = 0.0;

  // Vertical
  double vertical = 0.0;
  double uphillVertical = 0.0;
  double downhillVertical = 0.0;

  // Slope
  double slope = 0.0;
  double maxSlope = 0.0;
  double avgSlope = 0.0;
  double totalSlope = 0.0;

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
      newVertical: vertical,
      newUphillVertical: uphillVertical,
      newDownhillVertical: downhillVertical,
      newSlope: slope,
      newMaxSlope: maxSlope,
      newAvgSlope: avgSlope,
      newElapsedTime: SkiTracker.getActivity().elapsedTime,
    );
  }
}
