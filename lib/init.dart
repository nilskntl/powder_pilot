import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:powder_pilot/theme/background.dart';
import 'package:powder_pilot/theme/color.dart';
import 'package:powder_pilot/theme/measurement.dart';
import 'package:powder_pilot/utils/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'activity/data_provider.dart';
import 'l10n/messages_all_locales.dart';
import 'main.dart';

/// Initialize the app
Future<void> init() async {

  /// Set the error handlers
  _setErrorHandlers();

  /// Ensure that that WidgetsBinding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Set the UI settings
  _setUiSettings();

  /// Read the welcome key from shared preferences
  Future<bool> startTemp = SharedPref.readBool(PowderPilot.keyStart);

  /// Load the all-time statistics from the shared preferences
  PowderPilot.statistics.loadFromSharedPref();

  /// Load the past activities from the database
  PowderPilot.pastActivities.loadActivities();

  /// Set the language
  Future<void> language =  _setLanguage();

  /// Set the app settings
  Future<void> appSettings = _setAppSettings();

  bool start = await startTemp;

  if (start) {
    PowderPilot.locationService.init();
  }
  PowderPilot.connectivityController.init();

  /// Wait for the language and app settings to be set
  await language;
  await appSettings;

  /// After everything is set, run the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => ActivityDataProvider(),
      child: Start(
        welcome: start,
      ),
    ),
  );
}

/// Set the error handler
void _setErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
}

/// Set the UI settings
void _setUiSettings() {
  /// Set the orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// Set the system UI overlay style
  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  /// Set the system UI mode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.bottom]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

/// Set the language
Future<void> _setLanguage() async {
  /// Read the language key from the shared preferences
  String language = await SharedPref.readString(PowderPilot.keyLanguage);

  /// Set the language to the system language
  /// If the system language is not available, set it to English
  Future<void> setLocaleLanguage() async {
    /// Check if the system language is available
    bool containsSystemLanguage(String l) {
      for (List<String> lang in PowderPilot.availableLanguages) {
        if (lang[0] == l) {
          return true;
        }
      }
      return false;
    }

    // ignore: deprecated_member_use
    String locale = ui.window.locale.toString();
    if (locale.contains('_')) {
      locale = locale.split('_').first;
    }
    if (containsSystemLanguage(locale)) {
      language = locale;
    } else {
      if (locale == 'at' || locale == 'ch' || locale == 'de') {
        language = 'de';
      } else {
        language = 'en';
      }
    }
    SharedPref.saveString(PowderPilot.keyLanguage, language);
  }

  /// Check if the language defined in the shared preferences is available
  bool containsLanguage() {
    for (List<String> lang in PowderPilot.availableLanguages) {
      if (language == lang[0]) {
        return true;
      }
    }
    return false;
  }

  /// If language was not set or is unavailable, set it to the system language
  if (language == '' || !containsLanguage()) {
    await setLocaleLanguage();
  }

  // Set the default locale
  Intl.defaultLocale = language;
  PowderPilot.setLanguage(language);
  await initializeMessages(language);
}

/// Set app settings
Future<void> _setAppSettings() async{
  /// Read the theme key from shared preferences and set the theme
  String theme = await SharedPref.readString(PowderPilot.keyColorTheme);
  if (theme == '') {
    theme = ThemeChanger.defaultTheme;
  }
  ThemeChanger.changeTheme(theme);

  /// Load the background image
  BackgroundTheme.loadBackground();

  /// Read the units key from shared preferences and set the units
  String units = await SharedPref.readString(PowderPilot.keyUnits);

  /// If units was not set, set it to metric
  if (units == '') {
    units = 'metric';
    SharedPref.saveString(PowderPilot.keyUnits, units);
  } else if (units == 'imperial') {
    Measurement.setUnits(units);
  } else if (units != 'metric') {
    SharedPref.saveString(PowderPilot.keyUnits, 'metric');
  }
}
