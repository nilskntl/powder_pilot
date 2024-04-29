import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/utils/shared_preferences.dart';

import '../main.dart';

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
  static const Color white = Color(0xfffefefd);
  static const Color yellow = Color(0xfff1c40f);
  static const Color blue = Color(0xff3498db);
  static const Color black = Color(0xff000000);
  static const Color darkGrey = Color(0xff2f2f2f);
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
    SharedPref.saveString(PowderPilot.keyColorTheme, theme);
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
