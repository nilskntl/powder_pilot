import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:powder_pilot/location.dart';
import 'package:powder_pilot/pages/welcome_pages/welcome_pages.dart';
import 'package:powder_pilot/theme.dart';
import 'package:powder_pilot/utils/connectivity_controller.dart';
import 'package:powder_pilot/utils/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'activity/activity.dart';
import 'activity/data_provider.dart';
import 'pages/activity_page.dart';
import 'pages/history.dart';
import 'utils/app_bar.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  init();
}

void init() async {
  bool welcome = await SharedPref.readBool(PowderPilot.startKey);
  String units = await SharedPref.readString(PowderPilot.unitsKey);
  if (units == '') {
    units = 'metric';
    SharedPref.saveString(PowderPilot.unitsKey, units);
  } else if (units == 'imperial') {
    Info.setUnits(units);
  } else if (units != 'metric') {
    SharedPref.saveString(PowderPilot.unitsKey, 'metric');
  }

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

class PowderPilot extends StatelessWidget {
  const PowderPilot({super.key});

  /// Key names
  static const String numActivitiesKey = 'numActivities';
  static const String activityKey = 'activity';
  static const String startKey = 'start';
  static const String unitsKey = 'units';

  static const String appName = 'Powder Pilot';

  static final LocationService _locationService = LocationService();

  static int _activityId = 0;
  static Activity _activity = Activity(id: _activityId);

  static late ActivityDataProvider _activityData;

  static final ConnectivityController _connectivityController =
      ConnectivityController();

  @override
  Widget build(BuildContext context) {
    _activity.init();
    return const MyHomePage(title: 'Flutter Demo Home Page');
  }

  static Activity get activity => _activity;

  static LocationService get locationService => _locationService;

  static ConnectivityController get connectivityController =>
      _connectivityController;

  static ActivityDataProvider getActivityDataProvider() {
    return _activityData;
  }

  static void setActivityDataProvider(ActivityDataProvider activityData) {
    _activityData = activityData;
  }

  static void createNewActivity(
      {String areaName = '',
      LatLng currentPosition = const LatLng(0, 0),
      bool mapDownloaded = false}) {
    _activity = Activity(
        id: ++_activityId,
        currentPosition: currentPosition,
        mapDownloaded: mapDownloaded);
    _activity.init();
  }

  static bool get connectionStatus => _connectivityController.isConnected.value;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  static const double bottomBarHeight = 50.0;
  static const Duration animationDuration = Duration(milliseconds: 200);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ActivityPage _activity = const ActivityPage();
  final History _history = const History();

  final PageController _pageController = PageController();
  final int _numberOfPages = 2;
  int _pageIndex = 0;

  double getBottomBarHeight() {
    return MyHomePage.bottomBarHeight + MediaQuery.of(context).padding.bottom;
  }

  @override
  Widget build(BuildContext context) {
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

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.bottom]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (int page) {
              setState(() {});
              _pageIndex = page;
            },
            children: [
              _activity,
              _history,
            ],
          ),
          const CustomAppBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: getBottomBarHeight(),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: ColorTheme.background,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _pageIndex = 0;
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: _buildBottomBarContainer(
                      iconData: Icons.downhill_skiing_rounded,
                      text: 'Activity',
                      page: 0),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _pageIndex = 1;
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: _buildBottomBarContainer(
                      iconData: Icons.calendar_month_rounded,
                      text: 'History',
                      page: 1),
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: MyHomePage.animationDuration,
            top: 0,
            left: (MediaQuery.of(context).size.width / _numberOfPages) *
                (_pageIndex),
            child: Container(
              width: MediaQuery.of(context).size.width / _numberOfPages,
              height: 4,
              color: ColorTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarContainer(
      {required IconData iconData, required String text, required int page}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            iconData,
            size: 32,
            color: _pageIndex == page ? ColorTheme.primary : ColorTheme.grey,
          ),
        ],
      ),
    );
  }
}
