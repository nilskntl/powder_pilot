import 'package:flutter/material.dart';
import 'package:ski_tracker/activity/start_activity.dart';
import 'package:ski_tracker/select_page.dart';
import 'package:ski_tracker/utils.dart';

import 'activity/activity.dart';
import 'history.dart';

void main() {
  runApp(const SkiTracker());
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

  static ActivityWidgetState _activityState = ActivityWidgetState();
  static MainWidgetState _mainWidgetState = MainWidgetState();

  static final Activity _activity = Activity();


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

  static ActivityWidgetState getActivityState() {
    return _activityState;
  }

  static void setActivityState(ActivityWidgetState activityState) {
    _activityState = activityState;
  }

  static MainWidgetState getMainWidgetState() {
    return _mainWidgetState;
  }

  static void setMainWidgetState(MainWidgetState mainWidgetState) {
    _mainWidgetState = mainWidgetState;
  }
}


class MyHomePage extends StatelessWidget{
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _bar(),
          const SizedBox(height: 64),
          const MainWidget(),
          const Spacer(),
          StartActivity(),
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
        child: Utils.buildText(text: 'Simple Ski Tracker', fontSize: FontTheme.sizeSubHeader, fontWeight: FontWeight.bold),
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
  int currentPage = 1;
  int numberPages = 2;

  final ActivityWidget _activity = const ActivityWidget();
  final History _history = const History();

  @override
  void initState() {
    super.initState();
    SkiTracker.setMainWidgetState(this);
  }

  update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _mainWidget();
  }

  Widget _mainWidget() {
    if (currentPage == 1) {
      return _activity;
    } else if (currentPage == 2) {
      return _history;
    } else {
      return Container();
    }
  }
}
