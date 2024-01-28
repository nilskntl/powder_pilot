import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:powder_pilot/theme.dart';

import 'main.dart';

/// A callback function to handle location updates.
typedef LocationCallback = void Function(Position);

/// Manages location-related functionality, including location updates and permissions.
class LocationService {
  /// Active location settings for continuous updates.
  late LocationSettings _activeSettings;

  /// Passive location settings for intermittent updates.
  late LocationSettings _passiveSettings;

  /// Stores the current location permission status.
  static LocationPermission _permission = LocationPermission.denied;

  /// Subscription to the location stream.
  late StreamSubscription<Position> _locationSubscription;

  /// List of external listeners to be notified about location updates.
  final List<LocationCallback> _externalListeners = [];

  /// Stores the current area name based on location.
  String _areaName = '';

  /// Number of location updates received.
  int _numOfLocations = 0;

  /// Constructor to initialize the LocationService.
  LocationService() {
    _initSettings();
    askForPermission();
    startPassiveLocationStream();
  }

  /// Initializes location settings based on the platform.
  void _initSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      /// Android settings for active location updates
      _activeSettings = AndroidSettings(
        intervalDuration: const Duration(seconds: 1),
        forceLocationManager: false,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
          "Your ski journey is being tracked in the background. Enjoy the ride!",
          notificationTitle: "Activity in progress",
          enableWakeLock: true,
          notificationIcon: AndroidResource(
            name: 'splash',
            defType: 'drawable',
          ),
          color: ColorTheme.primary,
        ),
        useMSLAltitude: true,
      );
      /// Android settings for passive location updates
      _passiveSettings = AndroidSettings(
        intervalDuration: const Duration(seconds: 1),
        useMSLAltitude: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      /// iOS settings for active location updates
      _activeSettings = AppleSettings(
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
      /// iOS settings for passive location updates
      _passiveSettings = AppleSettings(
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
        allowBackgroundLocationUpdates: false,
      );
    } else {
      /// Fallback settings for active location updates
      _activeSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      /// Fallback settings for passive location updates
      _passiveSettings = const LocationSettings();
    }
  }

  /// Opens the location permission settings for the app.
  static void openSettings() {
    Geolocator.openLocationSettings();
  }

  /// Checks the current location permission status.
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Performs a permission check and asks for location services.
  static Future<bool> askForPermission() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    _permission = await checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
      }
    }

    return _permission == LocationPermission.always ||
        _permission == LocationPermission.whileInUse;
  }

  /// Adds an external listener for location updates.
  ///
  /// @param listener The listener to add.
  void addListener(LocationCallback listener) {
    _externalListeners.add(listener);
  }

  /// Removes an external listener for location updates.
  ///
  /// @param listener The listener to remove.
  void removeListener(LocationCallback listener) {
    try {
      _externalListeners.remove(listener);
    } catch (e) {
      if (kDebugMode) {
        print('Error while trying to remove listener: $e');
      }
    }
  }

  /// Notifies all external listeners about a location update.
  ///
  /// @param position The position to notify about.
  void _notifyListeners(Position position) {
    // Notify external listeners
    for (var listener in _externalListeners) {
      listener(position);
    }
  }

  /// Starts the stream of active location updates.
  void startActiveLocationStream() {
    _stopLocationStream();
    // Simulate location updates
    _locationSubscription =
        Geolocator.getPositionStream(locationSettings: _activeSettings).listen(
                (Position position) {
              _handleLocationUpdate(position);
              _notifyListeners(position);
            }, onError: (error) {
          if (kDebugMode) {
            print('Error in location stream: $error');
          }
        });
  }

  /// Starts the stream of passive location updates.
  void startPassiveLocationStream() {
    _stopLocationStream();
    // Simulate location updates
    _locationSubscription =
        Geolocator.getPositionStream(locationSettings: _passiveSettings).listen(
                (Position position) {
              _handleLocationUpdate(position);
              _notifyListeners(position);
            }, onError: (error) {
          if (kDebugMode) {
            print('Error in location stream: $error');
          }
        });
  }

  /// Stops the current location stream.
  void _stopLocationStream() {
    try {
      _locationSubscription.cancel();
    } catch (e) {
      if (kDebugMode) {
        print('_locationSubscription has not been initialized yet, Error: $e');
      }
    }
  }

  /// Handles a location update by updating area information and incrementing the location count.
  ///
  /// @param position The position to handle.
  void _handleLocationUpdate(Position position) {
    _updateArea(position);
    _numOfLocations++;
  }

  /// Flag to track if the locality is found.
  bool _localityFound = false;

  /// Updates the area information based on the provided position.
  ///
  /// @param position The position to update the area information with.
  void _updateArea(Position position) {
    Future<void> update() async {
      try {
        /// Make location inaccurate for privacy reasons (+- 100m)
        double lat = position.latitude + Random().nextDouble() * 0.001;
        double lon = position.longitude + Random().nextDouble() * 0.001;
        List<Placemark> places = await placemarkFromCoordinates(lat, lon);

        Placemark place = places[0];
        if (place.locality! == '' && !_localityFound) {
          _areaName = place.country!;
        } else {
          if (place.locality! != '') {
            _areaName = '${place.country!}, ${place.locality!}';
            _localityFound = true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error while trying to fetch address data $e');
        }
      }
    }

    if (_numOfLocations % 15 == 0) {
      if (PowderPilot.connectionStatus == true || _numOfLocations == 0) {
        if (areaName == '' || areaName == 'Unknown') {
          update();
        } else {
          if (!areaName.contains(',')) {
            update();
          }
          if (_numOfLocations % 100 == 0) {
            update();
          }
        }
      }
    }
  }

  /// Gets the active location settings.
  LocationSettings get activeSettings => _activeSettings;

  /// Gets the passive location settings.
  LocationSettings get passiveSettings => _passiveSettings;

  /// Gets the current location permission status.
  LocationPermission get permission => _permission;

  /// Gets the current area name based on the last location update.
  String get areaName => _areaName;

  /// Checks if location permission is granted either always or while in use.
  bool get isLocationPermissionGranted {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
