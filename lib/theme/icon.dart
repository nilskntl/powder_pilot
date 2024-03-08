import 'package:flutter/material.dart';

/// Class to encapsulate the logo theme of the app.
class LogoTheme {
  /// Icons used in the app bar.
  static const String logo256 = 'assets/images/icon_256.png';
  static const String logo1024 = 'assets/images/icon_1024.png';

  /// Icons used to display different kind of status elements both in
  /// the UI and on the map (e.g. start, end, pause, resume, etc.).
  static const IconData start = Icons.play_arrow_sharp;
  static const IconData pause = Icons.pause_sharp;
  static const IconData end = Icons.flag_sharp;

  /// Icons used to display different kind of UI elements.
  static const IconData activity = Icons.downhill_skiing_sharp;
  static const IconData statistics = Icons.bar_chart_sharp;
  static const IconData settings = Icons.settings_sharp;
  static const IconData history = Icons.calendar_month_sharp;
  static const IconData click = Icons.touch_app_sharp;

  /// Icons used to display different kinds of data from activity.
  static const IconData distance = Icons.linear_scale_sharp;
  static const IconData speed = Icons.speed_sharp;
  static const IconData altitude = Icons.terrain_sharp;
  static const IconData slope = Icons.trending_up_sharp;
  static const IconData duration = Icons.timer_sharp;
  static const IconData runs = Icons.directions_run_sharp;
  static const IconData downhill = Icons.arrow_downward_sharp;
  static const IconData uphill = Icons.arrow_upward_sharp;

  /// Icons used to display different kinds of connections.
  static const IconData noInternet =
      Icons.wifi_off_sharp;
  static const IconData gps = Icons.location_on_sharp;

  /// Icons used to display different kinds of gps connection status.
  static const IconData gpsLow = Icons.signal_cellular_alt_1_bar_sharp;
  static const IconData gpsMedium = Icons.signal_cellular_alt_2_bar_sharp;
  static const IconData gpsHigh = Icons.signal_cellular_alt_sharp;

  /// Icons used to display things in the settings.
  static const IconData measurement = Icons.speed_sharp;
  static const IconData language = Icons.language_sharp;
  static const IconData theme = Icons.brush_sharp;
  static const IconData darkMode = Icons.dark_mode_sharp;
  static const IconData lightMode = Icons.light_mode_sharp;
}