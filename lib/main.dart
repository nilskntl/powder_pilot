import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ski_tracker/utils/connectivity_controller.dart';
import 'package:ski_tracker/utils/shared_preferences.dart';
import 'package:ski_tracker/welcome_pages/welcome_pages.dart';

import 'activity/activity.dart';
import 'activity/activity_data_provider.dart';
import 'activity/activity_display.dart';
import 'app_bar.dart';
import 'history.dart';

/*
Key names

Number of total activities
'numActivities' (int)

Already did welcome screen
'welcome' (bool)

Units
'units' (String) ("metric" or "imperial")

 */

void main() {

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  init();
}

void init() async {
  bool welcome = await SharedPref.readBool('welcome');
  String units = await SharedPref.readString('units');
  if(units == '') {
    units = 'metric';
    SharedPref.saveString('units', units);
  } else if(units == 'imperial'){
    Info.setUnits(units);
  } else if(units != 'metric') {
    SharedPref.saveString('units', 'metric');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ActivityDataProvider(),
      child: Start(welcome: welcome,),
    ),
  );
}

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

}

class FontTheme {
  static const double size = 14;
  static const double sizeHeader = 28;
  static const double sizeSubHeader = 21;
  static const String fontFamily = 'Roboto';
}

class Start extends StatelessWidget {
  const Start({required this.welcome, super.key});

  final bool welcome;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ski Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: ColorTheme.primary,
            background: ColorTheme.background),
        useMaterial3: true,
      ),
      home: welcome ? const SkiTracker() : const WelcomePages(),
    );
  }

}

class SkiTracker extends StatelessWidget {
  const SkiTracker({super.key});

  static const String appName = 'Ski Tracker';

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

  static Activity getActivity() {
    return _activity;
  }

  static ConnectivityController get connectivityController =>
      _connectivityController;

  static ActivityDataProvider getActivityDataProvider() {
    return _activityData;
  }

  static void setActivityDataProvider(ActivityDataProvider activityData) {
    _activityData = activityData;
  }

  static void createNewActivity({String areaName = ''}) {
    _activity = Activity(id: ++_activityId, areaName: areaName);
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

  final ActivityDisplay _activity = const ActivityDisplay();
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

    // Verberge die Navigationsleiste
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
                      text: 'Activity', page: 0),
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
                      iconData: Icons.calendar_month_rounded, text: 'History', page: 1),
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
