import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:powder_pilot/init.dart';
import 'package:powder_pilot/location.dart';
import 'package:powder_pilot/statistics/statistics.dart';
import 'package:powder_pilot/theme/background.dart';
import 'package:powder_pilot/theme/color.dart';
import 'package:powder_pilot/ui/controller.dart';
import 'package:powder_pilot/ui/scroll_view.dart';
import 'package:powder_pilot/ui/welcome_pages/welcome_pages.dart';
import 'package:powder_pilot/ui/widgets/bottom_bar.dart';
import 'package:powder_pilot/utils/connectivity_controller.dart';
import 'package:powder_pilot/utils/shared_preferences.dart';

import 'activity/activity.dart';
import 'activity/data_provider.dart';
import 'history/past_activities.dart';
import 'ui/widgets/app_bar.dart';

void main() {
  init();
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
  static const String keyNumActivities = 'numActivities';
  static const String keyAllTimeDistance = 'allTimeDistance';
  static const String keyAllTimeDistanceDownhill = 'allTimeDistanceDownhill';
  static const String keyAllTimeDistanceUphill = 'allTimeDistanceUphill';
  static const String keyAllTimeDuration = 'allTimeDuration';
  static const String keyAllTimeDurationDownhill = 'allTimeDurationDownhill';
  static const String keyAllTimeDurationUphill = 'allTimeDurationUphill';
  static const String keyFastestSpeed = 'fastestSpeed';
  static const String keyHighestAltitude = 'highestAltitude';
  static const String keyLongestRun = 'longestRun';
  static const String keyNumberRuns = 'numberRuns';
  static const String keyAllTimeAverageSpeed = 'allTimeAverageSpeed';

  static const String keyActivity = 'activity';
  static const String keyStart = 'start';
  static const String keyUnits = 'units';
  static const String keyLanguage = 'language';
  static const String keyColorTheme = 'theme';
  static const String keyBackground = 'background';

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
        SharedPref.saveString(keyLanguage, lang);
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

  /// The past activities
  static PastActivities pastActivities = PastActivities();

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
              BackgroundTheme.currentBackgroundAsset,
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
