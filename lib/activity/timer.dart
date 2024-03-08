import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:powder_pilot/main.dart';

import 'data.dart';
import 'state.dart';

/// Class representing a timer for tracking activity duration.
class ActivityTimer {
  late final Stopwatch _stopwatch = Stopwatch();

  late Timer _timer;

  late final ActivityData _activity;

  late final ActivityState _state;

  final ElapsedDuration _duration = ElapsedDuration();

  /// Getter for the elapsed duration.
  ElapsedDuration get duration => _duration;

  /// Timestamp
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  /// Constructor to initialize the ActivityTimer with the associated activity and state.
  ActivityTimer(
      {required ActivityData activity, required ActivityState state}) {
    _activity = activity;
    _state = state;
  }

  /// Start or stop the stopwatch based on its current state and execute a callback function.
  ///
  /// Stops the stopwatch if it is already running, then starts it and sets up a periodic timer to update the elapsed duration.
  ///
  /// @param callback Function to be executed periodically.
  void startStopwatch({required Function() callback}) {
    try {
      /// Cancel any existing timer and stop the stopwatch.
      _timer.cancel();
      _stopwatch.stop();
    } catch (e) {
      /// Handle errors if debugging mode is enabled.
      if (kDebugMode) {
        print(e);
      }
    }

    /// Start the stopwatch.
    _stopwatch.start();

    /// Initialize pause time.
    Duration pauseTime = const Duration(seconds: 0);

    /// Start a timer that fires every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      /// Update total duration.
      duration.total = _stopwatch.elapsed;
      PowderPilot.statistics.timeTotal += const Duration(seconds: 1);

      /// Update downhill or uphill duration based on the running status.
      if (_state.runningStatus == RunningStatus.downhill) {
        duration.downhill += const Duration(seconds: 1);
        PowderPilot.statistics.timeDownhill += const Duration(seconds: 1);
      } else if (_state.runningStatus == RunningStatus.uphill) {
        duration.uphill += const Duration(seconds: 1);
        PowderPilot.statistics.timeUphill += const Duration(seconds: 1);
      } else {
        duration.pause += const Duration(seconds: 1);
      }

      /// Handle pause conditions.
      if (_state.runningStatus != RunningStatus.pause) {
        if (_activity.speed.currentSpeed < 0.6) {
          pauseTime += const Duration(seconds: 1);
        } else {
          pauseTime = const Duration(seconds: 0);
        }

        /// If pause time exceeds 5 seconds, set running status to 'pause'.
        if (pauseTime > const Duration(seconds: 5)) {
          if (_state.runningStatus == RunningStatus.downhill) {
            duration.downhill -= pauseTime;
          } else if (_state.runningStatus == RunningStatus.uphill) {
            duration.uphill -= pauseTime;
          }
          _state.runningStatus = RunningStatus.pause;
          pauseTime = const Duration(seconds: 0);
        }
      }

      /// Execute the provided callback function.
      callback();

      /// Update UI periodically.
      _activity.updateData();
    });
  }

  /// Stop the stopwatch and cancel the periodic timer.
  void stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
    duration.total = _stopwatch.elapsed;
    _activity.updateData();
  }

  /// Pause the stopwatch and cancel the periodic timer.
  void pauseStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
    duration.total = _stopwatch.elapsed;
    _activity.updateData();
  }

  /// Resume the stopwatch and restart the periodic timer.
  ///
  /// @param callback Function to be executed periodically.
  void resumeStopwatch({required Function() callback}) {
    startStopwatch(callback: callback);
  }

  /// Reset the elapsed duration to zero.
  void resetTimer() {
    duration.total = Duration.zero;
    duration.pause = Duration.zero;
    duration.downhill = Duration.zero;
    duration.uphill = Duration.zero;
  }
}

/// Helper class to store the elapsed duration.
class ElapsedDuration {
  Duration total = Duration.zero;
  Duration pause = Duration.zero;
  Duration uphill = Duration.zero;
  Duration downhill = Duration.zero;
}
