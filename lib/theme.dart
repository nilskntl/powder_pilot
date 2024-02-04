import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/utils/general_utils.dart';
import 'package:powder_pilot/utils/shared_preferences.dart';

import 'main.dart';

/// Class to encapsulate the logo theme of the app.
class LogoTheme {
  /// Icons used in the app bar.
  static const String logo256 = 'assets/images/icon_256.png';
  static const String logo1024 = 'assets/images/icon_1024.png';

  /// Icons used to display different kind of status elements both in
  /// the UI and on the map (e.g. start, end, pause, resume, etc.).
  static const IconData start = Icons.play_arrow_sharp;
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
  static const IconData duration = Icons.timer_rounded;
  static const IconData runs = Icons.directions_run;

  /// Icons used to display different kinds of connections.
  static const IconData noInternet =
      Icons.signal_cellular_connected_no_internet_0_bar_rounded;
  static const IconData gps = Icons.location_on_rounded;

  /// Icons used to display different kinds of gps connection status.
  static const IconData gpsLow = Icons.signal_cellular_alt_1_bar_rounded;
  static const IconData gpsMedium = Icons.signal_cellular_alt_2_bar_rounded;
  static const IconData gpsHigh = Icons.signal_cellular_alt_rounded;
}

/// Class to encapsulate the color theme of the app.
class ColorTheme {
  /// Color palette used in the app.
  static Color primary = const Color(0xff019bbd);
  static Color secondary = const Color(0xfffefefd);
  static Color contrast = const Color(0xff2f436b);

  /// Background colors used in the app.
  static Color background = const Color(0xfff7f8fa);

  /// Specific colors used in the app.
  static Color grey = const Color(0xffb8b8b8);
  static Color red = const Color(0xffe74c3c);
  static Color green = const Color(0xff2ecc71);
  static const Color yellow = Color(0xfff1c40f);
  static const Color blue = Color(0xff3498db);
  static const Color black = Color(0xff000000);
  static const Color darkGrey = Color(0xff2f2f2f);
}

/// Class to encapsulate the font theme of the app.
class FontTheme {
  static const double size = 14;
  static const double sizeHeader = 28;
  static const double sizeSubHeader = 21;
  static const String fontFamily = 'Roboto';
}

/// Class to encapsulate properties of animations used in the app.
class AnimationTheme {
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration fastAnimationDuration = Duration(milliseconds: 350);
}

/// Class to encapsulate a theme of the app.
class AppThemeData {
  /// The name of the theme.
  final String name;

  /// The colors used in the theme.
  final List<Color> colors;

  /// The dark mode of the theme.
  final bool darkMode;

  /// Getter for the primary color of the theme.
  Color get primary => colors[0];

  Color get secondary => colors[1];

  Color get contrast => colors[2];

  Color get background => colors[3];

  Color get grey => colors[4];

  Color get red => colors[5];

  Color get green => colors[6];

  const AppThemeData(
      {required this.name, required this.colors, this.darkMode = false});
}

/// Class to handle the Theme of the app.
class ThemeChanger {
  /// The default theme of the app.
  static const String defaultTheme = 'Modern';

  /// The theme currently used
  static AppThemeData currentTheme =
      availableThemes[_indexOfTheme(defaultTheme)];

  /// Check if the theme is available.
  ///
  /// @param theme The theme to check.
  static bool _containsTheme(String theme) {
    for (AppThemeData data in availableThemes) {
      if (data.name == theme) {
        return true;
      }
    }
    return false;
  }

  /// Get the index of the theme.
  ///
  /// @param theme The theme to get the index of.
  static int _indexOfTheme(String theme) {
    for (int i = 0; i < availableThemes.length; i++) {
      if (availableThemes[i].name == theme) {
        return i;
      }
    }
    return 0;
  }

  /// Changes a theme of the app.
  ///
  /// @param theme The theme to change to.
  static changeTheme(String theme) {
    if (kDebugMode) {
      print('Switching theme to $theme');
    }
    if (!_containsTheme(theme)) {
      theme = defaultTheme;
    }
    ColorTheme.primary = availableThemes[_indexOfTheme(theme)].colors[0];
    ColorTheme.secondary = availableThemes[_indexOfTheme(theme)].colors[1];
    ColorTheme.contrast = availableThemes[_indexOfTheme(theme)].colors[2];
    ColorTheme.background = availableThemes[_indexOfTheme(theme)].colors[3];
    ColorTheme.grey = availableThemes[_indexOfTheme(theme)].colors[4];
    ColorTheme.red = availableThemes[_indexOfTheme(theme)].colors[5];
    ColorTheme.green = availableThemes[_indexOfTheme(theme)].colors[6];
    SharedPref.saveString(PowderPilot.themeKey, theme);
    ThemeChanger.currentTheme = availableThemes[_indexOfTheme(theme)];
  }

  /// The available themes of the app.
  /// Format [name, [primary, secondary, contrast, background, grey, red, green]]
  static List<AppThemeData> availableThemes = [
    const AppThemeData(name: 'Snowy', colors: [
      Color(0xff019bbd),
      Color(0xfffefefd),
      Color(0xff2f436b),
      Color(0xfff7f8fa),
      Color(0xffb8b8b8),
      Color(0xffe74c3c),
      Color(0xff2ecc71),
    ]),
    const AppThemeData(name: 'Calm', colors: [
      Color(0xff75a2cc),
      Color(0xfff5fbff),
      Color(0xff0f1527),
      Color(0xffe2f0fd),
      Color(0xff7a7e84),
      Color(0xffe74c3c),
      Color(0xff44f1a6),
    ]),
    const AppThemeData(name: 'Forest', colors: [
      Color(0xff1a434e),
      Color(0xfff5f6fa),
      Color(0xff000000),
      Color(0xffffffff),
      Color(0xff888788),
      Color(0xffe74c3c),
      Color(0xff61d384),
    ]),
    const AppThemeData(name: 'Sunset', colors: [
      Color(0xfffea125),
      Color(0xfff9f9f9),
      Color(0xff171616),
      Color(0xffffffff),
      Color(0xff717278),
      Color(0xffff4700),
      Color(0xff85a51b),
    ]),
    const AppThemeData(
      name: 'Grey',
      colors: [
        Color(0xfffcfbf8),
        Color(0xff22272c),
        Color(0xfffcfbf8),
        Color(0xff22272c),
        Color(0xff86888a),
        Color(0xfff57873),
        Color(0xff77c952),
      ],
      darkMode: true,
    ),
    const AppThemeData(
      name: 'Bloody',
      colors: [
        Color(0xffe74c3c),
        Color(0xff2f0f1c),
        Color(0xffe6e0e2),
        Color(0xff211018),
        Color(0xffac97a0),
        Color(0xffe74c3c),
        Color(0xff2ecc71),
      ],
      darkMode: true,
    ),
    const AppThemeData(
      name: 'Modern',
      colors: [
        Color(0xff17d1e0),
        Color(0xff353766),
        Color(0xffffffff),
        Color(0xff292b4d),
        Color(0xff939ac3),
        Color(0xfff57873),
        Color(0xff77c952),
      ],
      darkMode: true,
    ),
    const AppThemeData(
      name: 'Midnight',
      colors: [
        Color(0xff3658d7),
        Color(0xff1c2755),
        Color(0xfffcfeff),
        Color(0xff151d3d),
        Color(0xff777ea4),
        Color(0xffdc4d4c),
        Color(0xff09d0a3),
      ],
      darkMode: true,
    ),
  ];
}

class Measurement {
  static String unitSpeed = 'km/h';
  static String unitDistance = 'km';
  static String unitAltitude = 'm';
  static String unitSlope = '%';
  static String unitTime = 'h';

  static double speedFactor = 3.6;
  static double distanceFactor = 1;
  static double altitudeFactor = 1;

  static void setUnits(String units) {
    if (units == 'imperial') {
      unitSpeed = 'mph';
      unitDistance = 'mi';
      unitAltitude = 'ft';
      speedFactor = 2.236936;
      distanceFactor = 0.621371;
      altitudeFactor = 3.28084;
    } else {
      unitSpeed = 'km/h';
      unitDistance = 'km';
      unitAltitude = 'm';
      speedFactor = 3.6;
      distanceFactor = 1;
      altitudeFactor = 1;
    }
  }
}

class WidgetTheme {
  /// Builds a ListTile used for the settings.
  static ListTile settingsListTile(
      {required String title,
      required Widget subtitle,
      Widget leading = const SizedBox(),
      required Function() onTap}) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Utils.buildText(
          text: title,
          caps: false,
          fontWeight: FontWeight.bold,
          align: TextAlign.left),
      subtitle: subtitle,
      leading: leading,
      onTap: () {
        onTap();
      },
    );
  }

  /// Builds a Dialog for the settings.
  static void settingsDialog(
      {required List<Widget> children,
      double height = 150,
      required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAnimatedWidget(
          child: Dialog(
            backgroundColor: ColorTheme.secondary,
            child: Container(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              height: height,
              child: ListView(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }

  static ListTile settingsOption(
      {required String title,
      Widget subtitle = const SizedBox(),
      Widget leading = const SizedBox(),
      Widget trailing = const SizedBox(),
      required BuildContext context,
      required Function() onTap}) {
    if (subtitle is SizedBox && leading is SizedBox && trailing is SizedBox) {
      return ListTile(
          title:
              Utils.buildText(text: title, caps: false, align: TextAlign.left),
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (leading is SizedBox && trailing is SizedBox) {
      return ListTile(
          title:
              Utils.buildText(text: title, caps: false, align: TextAlign.left),
          subtitle: subtitle,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (subtitle is SizedBox && trailing is SizedBox) {
      return ListTile(
          title:
              Utils.buildText(text: title, caps: false, align: TextAlign.left),
          leading: leading,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (leading is SizedBox) {
      return ListTile(
          title:
              Utils.buildText(text: title, caps: false, align: TextAlign.left),
          subtitle: subtitle,
          trailing: trailing,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else if (subtitle is SizedBox) {
      return ListTile(
          title:
              Utils.buildText(text: title, caps: false, align: TextAlign.left),
          leading: leading,
          trailing: trailing,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    } else {
      return ListTile(
          title:
              Utils.buildText(text: title, caps: false, align: TextAlign.left),
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          dense: true,
          onTap: () {
            onTap();
            Navigator.pop(context);
          });
    }
  }

  /// Build the container used throughout widgets in the app.
  static Container container(
      {double height = -1.0,
      double width = -1.0,
      Color color = const Color(0xff000001),
      Alignment alignment = Alignment.center,
      BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16.0)),
      Widget child = const SizedBox(),
      EdgeInsets padding = const EdgeInsets.all(8.0)}) {
    if (color == const Color(0xff000001)) {
      color = ColorTheme.secondary;
    }
    if (height >= 0 && width >= 0) {
      return Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (height >= 0) {
      return Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (width >= 0) {
      return Container(
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    }
  }

  /// Build the animated container used throughout widgets in the app.
  static AnimatedContainer animatedContainer(
      {double height = -1.0,
      double width = -1.0,
      Duration duration = AnimationTheme.fastAnimationDuration,
      Curve curve = Curves.easeInOut,
      Color color = const Color(0xff000001),
      Alignment alignment = Alignment.center,
      BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16.0)),
      Widget child = const SizedBox(),
      EdgeInsets padding = const EdgeInsets.all(8.0),
      void Function()? onEnd}) {
    if (color == const Color(0xff000001)) {
      color = ColorTheme.secondary;
    }
    onEnd ??= () {};
    if (height >= 0 && width >= 0) {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        height: height,
        width: width,
        padding: padding,
        onEnd: onEnd,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (height >= 0) {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        height: height,
        onEnd: onEnd,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else if (width >= 0) {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        width: width,
        padding: padding,
        onEnd: onEnd,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    } else {
      return AnimatedContainer(
        duration: duration,
        curve: curve,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        alignment: alignment,
        child: child,
      );
    }
  }
}

class CustomAnimatedWidget extends StatefulWidget {
  const CustomAnimatedWidget({super.key, required this.child});

  final Widget child;

  @override
  State<CustomAnimatedWidget> createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
