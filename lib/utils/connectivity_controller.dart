/*
https://github.com/Bivek10/flutter_network_connectiviy/blob/main/lib/connectivity_controller.dart
 */

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ConnectivityController {
  ValueNotifier<bool> isConnected = ValueNotifier(false);

  ConnectivityController() {
    init();
  }

  _updateStatus(bool isConnected) {
    SkiTracker.getActivityDataProvider().updateInternetStatus(
      newInternetStatus: isConnected,
    );
  }

  Future<void> init() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    isInternetConnected(result);
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      isInternetConnected(result);
      _updateStatus(isConnected.value);
    });
  }

  bool isInternetConnected(ConnectivityResult? result) {
    if (result == ConnectivityResult.none) {
      isConnected.value = false;
      return false;
    } else if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      isConnected.value = true;
      return true;
    }
    return false;
  }
}
