import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:powder_pilot/location.dart';
import 'package:powder_pilot/statistics/statistics.dart';
import 'package:powder_pilot/theme/color.dart';
import 'package:powder_pilot/theme/measurement.dart';
import 'package:powder_pilot/ui/controller.dart';
import 'package:powder_pilot/ui/scroll_view.dart';
import 'package:powder_pilot/ui/welcome_pages/welcome_pages.dart';
import 'package:powder_pilot/ui/widgets/bottom_bar.dart';
import 'package:powder_pilot/utils/connectivity_controller.dart';
import 'package:powder_pilot/utils/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'activity/activity.dart';
import 'activity/data_provider.dart';
import 'l10n/messages_all_locales.dart';
import 'ui/widgets/app_bar.dart';

void main() {
  _init();
}

void _init() async {
  /// Set the error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  /// Ensure that that WidgetsBinding is initialized
  WidgetsFlutterBinding.ensureInitialized();

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

  /// Read the welcome key from shared preferences
  bool welcome = await SharedPref.readBool(PowderPilot.startKey);

  /// Read the language key from the shared preferences
  String language = await SharedPref.readString(PowderPilot.languageKey);

  /// Load the all-time statistics from the shared preferences
  PowderPilot.statistics.loadFromSharedPref();

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
    SharedPref.saveString(PowderPilot.languageKey, language);
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

  /// Read the theme key from shared preferences and set the theme
  String theme = await SharedPref.readString(PowderPilot.themeKey);
  if (theme == '') {
    theme = ThemeChanger.defaultTheme;
  }
  ThemeChanger.changeTheme(theme);

  /// Read the units key from shared preferences and set the units
  String units = await SharedPref.readString(PowderPilot.unitsKey);

  /// If units was not set, set it to metric
  if (units == '') {
    units = 'metric';
    SharedPref.saveString(PowderPilot.unitsKey, units);
  } else if (units == 'imperial') {
    Measurement.setUnits(units);
  } else if (units != 'metric') {
    SharedPref.saveString(PowderPilot.unitsKey, 'metric');
  }

  if (welcome) {
    PowderPilot.locationService.init();
  }
  PowderPilot.connectivityController.init();

  /// Run the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => ActivityDataProvider(),
      child: Start(
        welcome: welcome,
      ),
    ),
  );
}

class Start extends StatelessWidget {
  const Start({required this.welcome, super.key});

  final bool welcome;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
      ],
      title: PowderPilot.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: ColorTheme.primary, background: ColorTheme.background),
        useMaterial3: true,
      ),
      home: welcome ? const PowderPilot() : const WelcomePages(),
    );
  }
}

class PowderPilot extends StatefulWidget {
  const PowderPilot({super.key});

  /// App name
  static const String appName = 'Powder Pilot';

  /// Key names for SharedPreferences
  static const String numActivitiesKey = 'numActivities';
  static const String allTimeDistance = 'allTimeDistance';
  static const String allTimeDistanceDownhill = 'allTimeDistanceDownhill';
  static const String allTimeDistanceUphill = 'allTimeDistanceUphill';
  static const String allTimeDuration = 'allTimeDuration';
  static const String allTimeDurationDownhill = 'allTimeDurationDownhill';
  static const String allTimeDurationUphill = 'allTimeDurationUphill';
  static const String fastestSpeed = 'fastestSpeed';
  static const String highestAltitude = 'highestAltitude';
  static const String longestRun = 'longestRun';
  static const String numberRuns = 'numberRuns';
  static const String allTimeAverageSpeed = 'allTimeAverageSpeed';

  static const String activityKey = 'activity';
  static const String startKey = 'start';
  static const String unitsKey = 'units';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  static const List<List<String>> availableLanguages = [
    ['de', 'Deutsch'],
    ['en', 'English'],
    ['es', 'Español'],
    ['fr', 'Français'],
    ['it', 'Italiano'],
    ['nl', 'Nederlands'],
    ['pl', 'Polski'],
    ['pt', 'Português'],
    ['ru', 'Русский'],
  ];

  /// Current language
  static List<String> _language = ['en', 'English'];

  static List<String> get language => _language;

  /// Set the language
  ///
  /// @param lang The language to set (e.g. 'en')
  static void setLanguage(String lang) {
    for (List<String> l in availableLanguages) {
      if (l[0] == lang) {
        _language = l;
        SharedPref.saveString(languageKey, lang);
        return;
      }
    }
  }

  /// The location service (Location Stream)
  static final LocationService _locationService = LocationService();

  /// The current activity
  static Activity _activity = Activity();

  /// The all-time statistics
  static Statistics statistics = Statistics();

  /// The data provider for the activity
  /// Initialized with a dummy to avoid null pointer exceptions
  /// (used to notify listeners of changes)
  static ActivityDataProvider dataProvider = ActivityDataProvider();

  /// The connectivity controller for internet connection
  static final ConnectivityController _connectivityController =
      ConnectivityController();

  /// The custom controller for the scroll view and page view
  static final CustomController controller = CustomController();

  /// Make a full reload of the state of the app
  static void Function() reload = () {};

  static Activity get activity => _activity;

  static LocationService get locationService => _locationService;

  static ConnectivityController get connectivityController =>
      _connectivityController;

  static void createNewActivity(
      {String areaName = '',
      LatLng currentPosition = const LatLng(0, 0),
      bool mapDownloaded = false}) {
    _activity = Activity(
        currentPosition: currentPosition, mapDownloaded: mapDownloaded);
  }

  @override
  State<PowderPilot> createState() => PowderPilotState();
}

class PowderPilotState extends State<PowderPilot> {
  @override
  void initState() {
    super.initState();
    PowderPilot.reload = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            if (ThemeChanger.currentTheme.darkMode)
              Container(
                color: ColorTheme.black.withOpacity(0.2),
              ),
            MainScrollView(controller: PowderPilot.controller),

            /// ignore: prefer_const_constructors
            CustomAppBar(),
          ],
        ),
        bottomNavigationBar:
            CustomBottomBar(controller: PowderPilot.controller));
  }
}
