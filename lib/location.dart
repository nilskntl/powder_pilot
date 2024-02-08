import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:powder_pilot/string_pool.dart';
import 'package:powder_pilot/theme/color.dart';

import 'main.dart';

/// Enum to represent GPS accuracy levels.
enum GpsAccuracy {
  none,
  low,
  medium,
  high,
}

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

  /// Current position.
  double _latitude = 0.0;
  double _longitude = 0.0;

  /// Current GPS accuracy.
  GpsAccuracy _gpsAccuracy = GpsAccuracy.none;

  /// Constructor to initialize the LocationService.
  init() async {
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
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: StringPool.NOTIFICATION_TITLE,
          notificationText: StringPool.NOTIFICATION_TEXT,
          enableWakeLock: true,
          notificationIcon: const AndroidResource(
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
    /// Notify external listeners
    for (var listener in _externalListeners) {
      listener(position);
    }
  }

  /// Starts the stream of active location updates.
  void startActiveLocationStream() {
    _stopLocationStream();

    /// Simulate location updates
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

    /// Simulate location updates
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
    _updatePosition(position);
    _updateGpsAccuracy(position);
    _updateArea(position);
    _numOfLocations++;
  }

  /// Updates the current position.
  ///
  /// @param position The new position.
  void _updatePosition(Position position) {
    _latitude = position.latitude;
    _longitude = position.longitude;
    PowderPilot.dataProvider.updatePosition(
      newLatitude: position.latitude,
      newLongitude: position.longitude,
    );
  }

  /// Updates the GPS accuracy.
  ///
  /// @param position The new position.
  void _updateGpsAccuracy(Position position) {
    if (position.accuracy < 10) {
      _gpsAccuracy = GpsAccuracy.high;
    } else if (position.accuracy < 25) {
      _gpsAccuracy = GpsAccuracy.medium;
    } else {
      _gpsAccuracy = GpsAccuracy.low;
    }
    PowderPilot.dataProvider.updateGpsAccuracy(
      newGpsAccuracy: _gpsAccuracy,
    );
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
        PowderPilot.dataProvider.updateArea(
          newArea: _areaName,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error while trying to fetch address data $e');
        }
      }
    }

    if (_numOfLocations % 15 == 0) {
      if (PowderPilot.connectivityController.status == true ||
          _numOfLocations == 0) {
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

  /// Gets the current latitude and longitude.
  double get latitude => _latitude;

  double get longitude => _longitude;

  /// Gets the current GPS accuracy.
  GpsAccuracy get gpsAccuracy => _gpsAccuracy;

  /// Checks if location permission is granted either always or while in use.
  bool get isLocationPermissionGranted {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
