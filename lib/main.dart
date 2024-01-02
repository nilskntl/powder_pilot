import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ski_tracker/utils.dart';

import 'activity/activity.dart';
import 'activity/activity_data_provider.dart';
import 'activity/activity_display.dart';
import 'bar.dart';
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
  static const Color primaryColor = Color(0xffa5b7c1);
  static const Color secondaryColor = Color(0xff535d55);
  static const Color contrastColor = Color(0xff514644);
  static const Color backgroundColor = Color(0xffdbdbe5);
}

class FontTheme {
  static const double size = 14;
  static const double sizeHeader = 28;
  static const double sizeSubHeader = 21;
  static const String fontFamily = 'Roboto';
}

class SkiTracker extends StatelessWidget {
  const SkiTracker({super.key});

  static Activity _activity = Activity();

  static int _activityId = 0;

  static late ActivityDataProvider _activityData;

  @override
  Widget build(BuildContext context) {
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

  static void setActivity(Activity activity) {
    _activity = activity;
  }

  static int getActivityId() {
    return _activityId;
  }

  static void setActivityId(int activityId) {
    _activityId = activityId;
  }

  static ActivityDataProvider getActivityDataProvider() {
    return _activityData;
  }

  static void setActivityDataProvider(ActivityDataProvider activityData) {
    _activityData = activityData;
  }

  static void startActivity() {
    _activity.startActivity();
  }

  static void stopActivity() {
    _activity.stopActivity();
  }

  static void createNewActivity() {
    _activity = Activity();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }


  final ActivityDisplay _activity = const ActivityDisplay();
  final History _history = const History();

  final PageController _pageController = PageController();
  final int _numberOfPages = 2;
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: Bar.barHeight,
          backgroundColor: ColorTheme.primaryColor,
          flexibleSpace: Column(
            children: [
              Container(
                height: getStatusBarHeight(context),
                width: double.infinity,
                color: ColorTheme.primaryColor,
              ),
              const Bar(),
            ],
          )),
      body: PageView(
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
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return SizedBox(
      height: 75,
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
                      text: 'Activity'),
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
                      iconData: Icons.calendar_month_rounded, text: 'History'),
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 0,
            left: (MediaQuery.of(context).size.width / _numberOfPages) *
                (_pageIndex),
            child: Container(
              width: MediaQuery.of(context).size.width / _numberOfPages,
              height: 4,
              color: ColorTheme.contrastColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarContainer(
      {required IconData iconData, required String text}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: ColorTheme.primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            iconData,
            size: 32,
            color: ColorTheme.contrastColor,
          ),
          Utils.buildText(text: text),
        ],
      ),
    );
  }
}
