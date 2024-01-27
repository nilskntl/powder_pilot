import 'package:flutter/material.dart';

/// Class to encapsulate the logo theme of the app.
class LogoTheme {
  /// Icons used in the app bar.
  static const String logo256 = 'assets/images/icon_256.png';
  static const String logo1024 = 'assets/images/icon_1024.png';

  /// Icons used to display different kind of status elements both in
  /// the UI and on the map (e.g. start, end, pause, resume, etc.).
  static const IconData start = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData end = Icons.flag_rounded;

  /// Icons used to display different kind of UI elements.
  static const IconData activity = Icons.downhill_skiing_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData history = Icons.calendar_month_rounded;
  static const IconData click = Icons.touch_app_rounded;

  /// Icons used to display different kinds of data from activity.
  static const IconData distance = Icons.linear_scale;
  static const IconData speed = Icons.speed_rounded;
  static const IconData altitude = Icons.terrain_rounded;
  static const IconData slope = Icons.trending_up_rounded;

  /// Icons used to display different kinds of connections.
  static const IconData noInternet = Icons.signal_cellular_connected_no_internet_0_bar_rounded;
  static const IconData gps = Icons.location_on_rounded;

  /// Icons used to display different kinds of gps connection status.
  static const IconData gpsLow = Icons.signal_cellular_alt_1_bar_rounded;
  static const IconData gpsMedium = Icons.signal_cellular_alt_2_bar_rounded;
  static const IconData gpsHigh = Icons.signal_cellular_alt_rounded;
}

/// Class to encapsulate the color theme of the app.
class ColorTheme {
  static const Color primary = Color(0xff019bbd);
  static const Color secondary = Color(0xfffefefd);
  static const Color background = Color(0xfff7f8fa);
  static const Color contrast = Color(0xff2f436b);
  static const Color grey = Color(0xffb8b8b8);
  static const Color red = Color(0xffe74c3c);
  static const Color green = Color(0xff2ecc71);
  static const Color yellow = Color(0xfff1c40f);
  static const Color blue = Color(0xff3498db);
  static const Color black = Color(0xff000000);
  static const Color darkGrey = Color(0xff2f2f2f);

  static const Color backgroundGradient1 = Color(0xffcddcf7);
  static const Color backgroundGradient2 = Color(0xff9bc9f6);
}

/// Class to encapsulate the font theme of the app.
class FontTheme {
  static const double size = 14;
  static const double sizeHeader = 28;
  static const double sizeSubHeader = 21;
  static const String fontFamily = 'Roboto';
}