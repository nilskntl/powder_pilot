import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ski_tracker/activity/activity_bar.dart';
import 'package:ski_tracker/page.dart';

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
  static const double size = 16;
  static const double sizeHeader = 32;
  static const double sizeSubHeader = 24;
  static const String fontFamily = 'Roboto';
}

class SkiTracker extends StatelessWidget {
  const SkiTracker({super.key});

  static Activity _activity = Activity();

  static late ActivityDataProvider _activityData;

  static final PageController _pageController = PageController();

  static int currentPage = 1;
  static int numberPages = 2;

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

  static PageController getPageController() {
    return _pageController;
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: getStatusBarHeight(context),
            width: double.infinity,
            color: ColorTheme.primaryColor,
          ),
          const Bar(),
          const SizedBox(height: 64),
          const MainWidget(),
          const Spacer(),
          const ActivityBar(),
          const SizedBox(height: 32),
          const SelectPage(),
        ],
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final ActivityInfo _activity = const ActivityInfo();
  final History _history = const History();

  @override
  void initState() {
    super.initState();
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandablePageView(
      scrollDirection: Axis.horizontal,
      controller: SkiTracker.getPageController(),
      onPageChanged: (int page) {
        setState(() {});
      },
      children: [
        _activity,
        _history,
      ],
    );
  }
}
