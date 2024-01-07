import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ski_tracker/utils/activity_database.dart';
import 'package:ski_tracker/utils/connectivity_controller.dart';
import 'package:ski_tracker/utils/general_utils.dart';

import 'activity/activity.dart';
import 'activity/activity_data_provider.dart';
import 'activity/activity_display.dart';
import 'app_bar.dart';
import 'history.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ActivityDataProvider(),
      child: const SkiTracker(),
    ),
  );
}

class ColorTheme {
  static const Color primaryColor = Color(0xff019bbd);
  static const Color secondaryColor = Color(0xfffefefd);
  static const Color secondaryBackgroundColor = Color(0xfff7f8fa);
  static const Color contrastColor = Color(0xff2f436b);
  static const Color backgroundColor = Color(0xffb8d2f5);
  static const Color grey = Color(0xffb8b8b8);
  static const Color red = Color(0xffe74c3c);
}

class FontTheme {
  static const double size = 14;
  static const double sizeHeader = 28;
  static const double sizeSubHeader = 21;
  static const String fontFamily = 'Roboto';
}

class SkiTracker extends StatelessWidget {
  const SkiTracker({super.key});

  static int _activityId = 0;
  static Activity _activity = Activity(_activityId);

  static late ActivityDataProvider _activityData;

  static final ConnectivityController _connectivityController =
      ConnectivityController();

  // static final WeatherManager _weatherManager = WeatherManager();

  @override
  Widget build(BuildContext context) {
    _activity.init();
    return MaterialApp(
      title: 'Ski Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: ColorTheme.primaryColor,
            background: ColorTheme.backgroundColor),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

  static Activity getActivity() {
    return _activity;
  }

  // static WeatherManager get weatherManager => _weatherManager;

  static ConnectivityController get connectivityController =>
      _connectivityController;

  static ActivityDataProvider getActivityDataProvider() {
    return _activityData;
  }

  static void setActivityDataProvider(ActivityDataProvider activityData) {
    _activityData = activityData;
  }

  static void createNewActivity() {
    _activity = Activity(++_activityId);
    _activity.init();
  }

  static bool get connectionStatus => _connectivityController.isConnected.value;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  static const double bottomBarHeight = 75.0;
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
          const CustomAppBar(),
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
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return SizedBox(
      height: MyHomePage.bottomBarHeight,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              color: ColorTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarContainer(
      {required IconData iconData, required String text, required int page}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: ColorTheme.secondaryBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            iconData,
            size: 32,
            color: _pageIndex == page ? ColorTheme.primaryColor : ColorTheme.grey,
          ),
          Utils.buildText(text: text, color: _pageIndex == page ? ColorTheme.primaryColor : ColorTheme.grey),
        ],
      ),
    );
  }
}
