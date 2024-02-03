/// https://github.com/Bivek10/flutter_network_connectiviy/blob/main/lib/connectivity_controller.dart
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// A controller class for handling connectivity status.
class ConnectivityController {
  /// Notifier to observe the internet connectivity status.
  ValueNotifier<bool> isConnected = ValueNotifier(false);

  /// Updates the internet status in the app's data provider.
  ///
  /// @param isConnected The new internet connectivity status.
  void _updateStatus(bool isConnected) {
    PowderPilot.dataProvider.updateInternetStatus(
      newInternetStatus: isConnected,
    );
  }

  /// Initializes the connectivity controller by checking the initial connectivity status
  /// and setting up a listener for changes in connectivity.
  ///
  /// @return A Future that completes once the initialization is done.
  Future<void> init() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    isInternetConnected(result);
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      isInternetConnected(result);
      _updateStatus(isConnected.value);
    });
  }

  /// Determines the internet connectivity status based on the ConnectivityResult.
  ///
  /// @param result The result of the connectivity check.
  /// @return true if internet is connected (mobile or wifi), false otherwise.
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

  /// Getter for the internet connectivity status.
  ///
  /// @return true if internet is connected (mobile or wifi), false otherwise.
  bool get status => isConnected.value;
}
