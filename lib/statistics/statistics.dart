import '../main.dart';
import '../utils/shared_preferences.dart';

class Statistics {
  /// Flag to indicate if the statistics are already loaded
  bool _loaded = false;

  /// Number of activities
  int numActivities = 0;

  /// Total distance
  double distanceTotal = 0.0;

  /// Total downhill distance
  double distanceDownhill = 0.0;

  /// Total uphill distance
  double distanceUphill = 0.0;

  /// Highest altitude
  double maxAltitude = 0.0;

  /// Total duration
  Duration timeTotal = const Duration(seconds: 0);

  /// Total downhill duration
  Duration timeDownhill = const Duration(seconds: 0);

  /// Total uphill duration
  Duration timeUphill = const Duration(seconds: 0);

  /// Initial downhill and uphill duration
  Duration _initialDownhillAndUphillTime = const Duration(seconds: 0);

  /// Longest run (in km)
  double longestRun = 0.0;

  /// Number of downhill runs
  int numRuns = 0;

  /// Fastest speed
  double maxSpeed = 0.0;

  /// Average speed
  double avgSpeed = 0.0;

  /// Initial average speed
  double _initialAvgSpeed = 0.0;

  void reset() {
    distanceTotal = 0.0;
    distanceDownhill = 0.0;
    distanceUphill = 0.0;
    maxAltitude = 0.0;
    timeTotal = const Duration(seconds: 0);
    timeDownhill = const Duration(seconds: 0);
    timeUphill = const Duration(seconds: 0);
    longestRun = 0.0;
    numRuns = 0;
    maxSpeed = 0.0;
    avgSpeed = 0.0;
  }

  /// Flag to indicate if the statistics are being loaded
  bool _isLoading = false;

  /// Load the statistics from the shared preferences
  void loadFromSharedPref() async {
    /// If the statistics are already being loaded, return
    if (_isLoading) {
      return;
    }

    /// Set the flag to indicate that the statistics are being loaded
    _isLoading = true;

    /// Read the statistics from the shared preferences
    numActivities = await SharedPref.readInt(PowderPilot.numActivitiesKey);
    distanceTotal = await SharedPref.readDouble(PowderPilot.allTimeDistance);
    distanceDownhill =
        await SharedPref.readDouble(PowderPilot.allTimeDistanceDownhill);
    distanceUphill =
        await SharedPref.readDouble(PowderPilot.allTimeDistanceUphill);
    maxAltitude = await SharedPref.readDouble(PowderPilot.highestAltitude);
    timeTotal = Duration(
        seconds: await SharedPref.readInt(PowderPilot.allTimeDuration));
    timeDownhill = Duration(
        seconds: await SharedPref.readInt(PowderPilot.allTimeDurationDownhill));
    timeUphill = Duration(
        seconds: await SharedPref.readInt(PowderPilot.allTimeDurationUphill));
    _initialDownhillAndUphillTime = timeDownhill + timeUphill;
    longestRun = await SharedPref.readDouble(PowderPilot.longestRun);
    numRuns = await SharedPref.readInt(PowderPilot.numberRuns);
    maxSpeed = await SharedPref.readDouble(PowderPilot.fastestSpeed);
    avgSpeed = await SharedPref.readDouble(PowderPilot.allTimeAverageSpeed);
    _initialAvgSpeed = avgSpeed;

    /// Set the flag to indicate that the statistics are no longer being loaded
    _isLoading = false;

    /// Set the flag to indicate that the statistics are loaded
    /// and can be used
    _loaded = true;
  }

  /// Save the statistics to the shared preferences
  void saveToSharedPref() {
    SharedPref.saveInt(PowderPilot.numActivitiesKey, numActivities);
    SharedPref.saveDouble(PowderPilot.allTimeDistance, distanceTotal);
    SharedPref.saveDouble(
        PowderPilot.allTimeDistanceDownhill, distanceDownhill);
    SharedPref.saveDouble(PowderPilot.allTimeDistanceUphill, distanceUphill);
    SharedPref.saveDouble(PowderPilot.highestAltitude, maxAltitude);
    SharedPref.saveInt(PowderPilot.allTimeDuration, timeTotal.inSeconds);
    SharedPref.saveInt(
        PowderPilot.allTimeDurationDownhill, timeDownhill.inSeconds);
    SharedPref.saveInt(PowderPilot.allTimeDurationUphill, timeUphill.inSeconds);
    SharedPref.saveDouble(PowderPilot.longestRun, longestRun);
    SharedPref.saveInt(PowderPilot.numberRuns, numRuns);
    SharedPref.saveDouble(PowderPilot.fastestSpeed, maxSpeed);
    SharedPref.saveDouble(PowderPilot.allTimeAverageSpeed, avgSpeed);
    _initialAvgSpeed = avgSpeed;
    _initialDownhillAndUphillTime = timeDownhill + timeUphill;
  }

  /// Update average speed
  ///
  /// @param avgSpeed The average speed from the current activity
  void updateAvgSpeed(double avgSpeed) {
    int timeDiff =
        (timeDownhill + timeUphill - _initialDownhillAndUphillTime).inSeconds;
    if (timeDiff <= 0) {
      return;
    }
    avgSpeed = ((_initialDownhillAndUphillTime.inSeconds * _initialAvgSpeed) +
            (timeDiff * avgSpeed)) /
        (timeDiff + _initialDownhillAndUphillTime.inSeconds);
  }

  /// Getter for the flag to indicate if the statistics are loaded
  bool get loaded => _loaded;
}
