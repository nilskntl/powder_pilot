import 'dart:async';

import 'package:flutter/foundation.dart';

import 'activity_data.dart';
import 'activity_state.dart';

class ActivityTimer {
  late final Stopwatch _stopwatch = Stopwatch();

  late Timer _timer;

  late final ActivityData _activity;

  late final ActivityState _state;

  final ElapsedDuration _duration = ElapsedDuration();

  ElapsedDuration get duration => _duration;

  // Timestamp
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  ActivityTimer(
      {required ActivityData activity, required ActivityState state}) {
    _activity = activity;
    _state = state;
  }

  void startStopwatch({required Function() callback}) {
    /// Stop the stopwatch if it is already running
    try {
      _timer.cancel();
      _stopwatch.stop();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _stopwatch.start();
    Duration pauseTime = const Duration(seconds: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      duration.total = _stopwatch.elapsed;
      if (_state.runningStatus == RunningStatus.downhill) {
        duration.downhill += const Duration(seconds: 1);
      } else if (_state.runningStatus == RunningStatus.uphill) {
        duration.uphill += const Duration(seconds: 1);
      } else {
        duration.pause += const Duration(seconds: 1);
      }
      if (_state.runningStatus != RunningStatus.pause) {
        if (_activity.speed.currentSpeed == 0.0) {
          pauseTime += const Duration(seconds: 1);
        } else {
          pauseTime = const Duration(seconds: 0);
        }
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
      callback();
      // Update UI periodically
      _activity.updateData();
    });
  }

  void stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
    duration.total = _stopwatch.elapsed;
    _activity.updateData();
  }

  void pauseStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
    duration.total = _stopwatch.elapsed;
    _activity.updateData();
  }

  void resumeStopwatch({required Function() callback}) {
    startStopwatch(callback: callback);
  }

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
