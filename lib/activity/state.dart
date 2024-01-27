enum RunningStatus {
  uphill,
  downhill,
  pause,
}

enum ActivityStatus {
  running,
  paused,
  stopped,
  inactive,
}

class ActivityState {
  bool _running = false;
  bool _active = false;

  bool _statusUphill = false;
  bool _statusDownhill = false;
  bool _statusPause = false;

  void startActivity() {
    _running = true;
    _active = true;
  }

  void stopActivity() {
    _running = false;
    _active = false;
    runningStatus = RunningStatus.pause;
  }

  void pauseActivity() {
    _running = false;
    _statusDownhill = false;
    _statusUphill = false;
    _statusPause = true;
  }

  void resumeActivity() {
    _running = true;
  }

  bool get isRunning => _running;

  bool get isActive => _active;

  bool get isUphill => _statusUphill;

  bool get isDownhill => _statusDownhill;

  ActivityStatus get activityStatus {
    if (_running && _active) {
      return ActivityStatus.running;
    } else if (_active) {
      return ActivityStatus.paused;
    } else {
      return ActivityStatus.inactive;
    }
  }

  RunningStatus get runningStatus {
    if (_statusPause) {
      return RunningStatus.pause;
    } else if (_statusUphill) {
      return RunningStatus.uphill;
    } else if (_statusDownhill) {
      return RunningStatus.downhill;
    } else {
      return RunningStatus.pause;
    }
  }

  set runningStatus(RunningStatus statusType) {
    if (statusType == RunningStatus.pause) {
      _statusPause = true;
    } else if (statusType == RunningStatus.uphill) {
      _statusUphill = true;
      _statusDownhill = false;
      _statusPause = false;
    } else if (statusType == RunningStatus.downhill) {
      _statusDownhill = true;
      _statusUphill = false;
      _statusPause = false;
    }
  }

  void resumeDownhillOrUphill() {
    _statusPause = false;
  }
}