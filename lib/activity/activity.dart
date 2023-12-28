import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../main.dart';

class ActivityData extends ChangeNotifier {
  // Speed
  double speed = 0.0;
  double maxSpeed = 0.0;
  double avgSpeed = 0.0;

  // Distance
  double totalDistance = 0.0;
  double uphillDistance = 0.0;
  double downhillDistance = 0.0;

  // Altitude
  double altitude = 0.0;
  double maxAltitude = 0.0;
  double minAltitude = 0.0;
  double avgAltitude = 0.0;

  // Vertical
  double vertical = 0.0;
  double uphillVertical = 0.0;
  double downhillVertical = 0.0;

  // Slope
  double slope = 0.0;
  double maxSlope = 0.0;
  double avgSlope = 0.0;

  bool running = false;

  void updateData({
    required double newSpeed,
    required double newMaxSpeed,
    required double newAvgSpeed,
    required double newTotalDistance,
    required double newUphillDistance,
    required double newDownhillDistance,
    required double newAltitude,
    required double newMaxAltitude,
    required double newMinAltitude,
    required double newAvgAltitude,
    required double newVertical,
    required double newUphillVertical,
    required double newDownhillVertical,
    required double newSlope,
    required double newMaxSlope,
    required double newAvgSlope,
    required bool newRunning,
  }) {
    speed = newSpeed;
    maxSpeed = newMaxSpeed;
    avgSpeed = newAvgSpeed;
    totalDistance = newTotalDistance;
    uphillDistance = newUphillDistance;
    downhillDistance = newDownhillDistance;
    altitude = newAltitude;
    maxAltitude = newMaxAltitude;
    minAltitude = newMinAltitude;
    avgAltitude = newAvgAltitude;
    vertical = newVertical;
    uphillVertical = newUphillVertical;
    downhillVertical = newDownhillVertical;
    slope = newSlope;
    maxSlope = newMaxSlope;
    avgSlope = newAvgSlope;

    running = newRunning;

    notifyListeners();
  }
}

class Activity {
  Location location = Location();

  late LocationData _currentLocation;

  StreamSubscription<LocationData>? _locationSubscription;

  // Speed
  double _speed = 0.0;
  double _maxSpeed = 0.0;
  double _avgSpeed = 0.0;
  double _totalSpeed = 0.0;

  // Distance
  double _totalDistance = 0.0;
  double _uphillDistance = 0.0;
  double _downhillDistance = 0.0;

  // Altitude
  double _altitude = 0.0;
  double _maxAltitude = 0.0;
  double _minAltitude = 0.0;
  double _avgAltitude = 0.0;
  double _totalAltitude = 0.0;

  // Vertical
  double _vertical = 0.0;
  double _uphillVertical = 0.0;
  double _downhillVertical = 0.0;

  // Slope
  double _slope = 0.0;
  double _maxSlope = 0.0;
  double _avgSlope = 0.0;
  double _totalSlope = 0.0;

  bool _locationLoaded = false;
  bool _running = false;
  int _numberOfUpdates = 0;
  int _numberOfSlopeUpdates = 0;

  final double _speedFactor = 3.6;

  void startActivity() {
    _running = true;
    _updateData();
    _requestPermission();
    _locationStream();
  }

  void stopActivity() {
    _running = false;
    _locationSubscription?.cancel();
  }

  Future<bool> _requestPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Service enabled: $serviceEnabled');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    return permissionGranted == PermissionStatus.granted;
  }

  void _locationStream() {
    location.enableBackgroundMode(enable: true);

    location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );

    _locationSubscription =
        location.onLocationChanged.listen((LocationData location) {
      _handleLocationUpdate(location);
    });
  }

  void _handleLocationUpdate(LocationData location) {

    _numberOfUpdates++;

    if (!_locationLoaded) {
      _currentLocation = location;
      _locationLoaded = true;
    }

    // Update speed
    _speed = location.speed!;
    _maxSpeed = _speed > _maxSpeed ? _speed : _maxSpeed;
    _totalSpeed += _speed;
    _avgSpeed = _totalSpeed / _numberOfUpdates;

    if (_speed < 0.25) {
      _speed = 0.0;
    }

    // Update distance
    double calculatedDistance = _calculateDistance(_currentLocation, location);

    if (calculatedDistance < 500) {
      _totalDistance += calculatedDistance;
      if (_currentLocation.altitude! < location.altitude!) {
        _uphillDistance += calculatedDistance;
      } else {
        _downhillDistance += calculatedDistance;
      }
    }

    // Update altitude
    _altitude = location.altitude!;
    _maxAltitude = _altitude > _maxAltitude ? _altitude : _maxAltitude;
    _minAltitude = _altitude < _minAltitude ? _altitude : _minAltitude;
    _totalAltitude += _altitude;
    _avgAltitude = _totalAltitude / _numberOfUpdates;

    // Update vertical
    _vertical += _altitude - _currentLocation.altitude!;
    if (_currentLocation.altitude! < location.altitude!) {
      _uphillVertical += _altitude - _currentLocation.altitude!;
    } else {
      _downhillVertical += _altitude - _currentLocation.altitude!;
    }

    double horizontalDistanceInMeters = Geolocator.distanceBetween(
        _currentLocation.latitude!, _currentLocation.longitude!, location.latitude!, location.longitude!);

    if(horizontalDistanceInMeters > 0.2) {
      double slope = (_currentLocation.altitude! - _altitude) /
          horizontalDistanceInMeters;

      if(slope > 0.1) {
        _numberOfSlopeUpdates++;
        _slope = slope;
        _maxSlope = _slope > _maxSlope ? _slope : _maxSlope;
        _totalSlope += _slope;
        _avgSlope = _totalSlope / _numberOfSlopeUpdates;
      }
    }

    _currentLocation = location;

    _updateData();
  }

  double _calculateDistance(LocationData pos1, LocationData pos2) {
    double distanceInMeters = Geolocator.distanceBetween(
        pos1.latitude!, pos1.longitude!, pos2.latitude!, pos2.longitude!);
    double altitudeChange = pos2.altitude! - pos1.altitude!;
    double distance =
        math.sqrt(math.pow(distanceInMeters, 2) + math.pow(altitudeChange, 2));
    return distance;
  }
  
  void _updateData() {
    // Update UI
    SkiTracker.getActivityData().updateData(
      newSpeed: _speed,
      newMaxSpeed: _maxSpeed,
      newAvgSpeed: _avgSpeed,
      newTotalDistance: _totalDistance,
      newUphillDistance: _uphillDistance,
      newDownhillDistance: _downhillDistance,
      newAltitude: _altitude,
      newMaxAltitude: _maxAltitude,
      newMinAltitude: _minAltitude,
      newAvgAltitude: _avgAltitude,
      newVertical: _vertical,
      newUphillVertical: _uphillVertical,
      newDownhillVertical: _downhillVertical,
      newSlope: _slope,
      newMaxSlope: _maxSlope,
      newAvgSlope: _avgSlope,
      newRunning: _running,
      
    );
  }

  /*
  Getter and Setter
   */

  bool isLocationLoaded() {
    return _locationLoaded;
  }

  bool isRunning() {
    return _running;
  }

  int getNumberOfUpdates() {
    return _numberOfUpdates;
  }

  LocationData getCurrentPosition() {
    return _currentLocation;
  }

  double getCurrentSpeed() {
    return _speed * _speedFactor;
  }

  double getMaxSpeed() {
    return _maxSpeed * _speedFactor;
  }

  double getAvgSpeed() {
    return _avgSpeed * _speedFactor;
  }

  double getTotalDistance() {
    return _totalDistance;
  }

  double getUphillDistance() {
    return _uphillDistance;
  }

  double getDownhillDistance() {
    return _downhillDistance;
  }

  double getAltitude() {
    return _altitude;
  }

  double getMaxAltitude() {
    return _maxAltitude;
  }

  double getAvgAltitude() {
    return _avgAltitude;
  }

  double getVertical() {
    return _vertical;
  }

  double getUphillVertical() {
    return _uphillVertical;
  }

  double getDownhillVertical() {
    return _downhillVertical;
  }

  double getSlope() {
    return _slope;
  }

  double getMaxSlope() {
    return _maxSlope;
  }

  double getAvgSlope() {
    return _avgSlope;
  }
}
