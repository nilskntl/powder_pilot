import 'package:flutter/material.dart';
import 'package:ski_tracker/activity/activity_bar.dart';
import 'package:ski_tracker/select_page.dart';
import 'package:ski_tracker/utils.dart';

import 'activity/activity.dart';
import 'activity/activity_info.dart';
import 'history.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ActivityData(),
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

  static late ActivityData _activityData;

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

  static ActivityData getActivityData() {
    return _activityData;
  }

  static void setActivityData(ActivityData activityData) {
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

  static GlobalKey<MainWidgetState> getMainWidgetState() {
    return MainWidgetState.mainWidgetState;
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
          _bar(),
          const SizedBox(height: 64),
          const MainWidget(),
          const Spacer(),
          ActivityBar(),
          const SizedBox(height: 32),
          const SelectPage(),
        ],
      ),
    );
  }

  Widget _bar() {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Utils.buildText(
            text: 'Simple Ski Tracker',
            fontSize: FontTheme.sizeSubHeader,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  // Global Key erstellen
  static GlobalKey<MainWidgetState> mainWidgetState =
      GlobalKey<MainWidgetState>();

  final ActivityInfo _activity = const ActivityInfo();
  final History _history = const History();

  @override
  void initState() {
    super.initState();
  }

  void updateState() {
    print(mounted);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mainWidget();
  }

  Widget _mainWidget() {
    if (SkiTracker.currentPage == 1) {
      return _activity;
    } else if (SkiTracker.currentPage == 2) {
      return _history;
    } else {
      return Container();
    }
  }
}
