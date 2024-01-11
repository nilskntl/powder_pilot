import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ski_tracker/weather.dart';

class WeatherDisplay extends StatefulWidget {
  const WeatherDisplay({super.key, required this.weatherManager});

  final WeatherManager weatherManager;

  @override
  State<WeatherDisplay> createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {
  double height = 200.0;
  late final Timer _timer;

  double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  @override
  void initState() {
    super.initState();
    // _startTimer();
    if (kDebugMode) {
      print('Weather init state');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      height: height *3,
      child: Stack (
        children: [
          Image.asset(
            'assets/images/background_image.png',
            width: double.infinity, // Bildbreite auf Bildschirmbreite strecken
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ],
      )
    );
  }
/*
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (SkiTracker.weatherManager.locationLoaded) {
        if (SkiTracker.getActivity().initializedMap) {
          setState(() {
          });
        }
        if (SkiTracker.weatherManager.weatherLoaded) {
          setState(() {
          });
        }
        if(SkiTracker.weatherManager.weatherLoaded && SkiTracker.weatherManager.locationLoaded) {
          _timer.cancel();
          print('Ich erst danach :(');
        }
      }
    });
    print('Bin schon hier lol');
    String currentWeatherString = SkiTracker.weatherManager.toString();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (SkiTracker.weatherManager.toString() != currentWeatherString) {
        setState(() {
        });
        currentWeatherString = SkiTracker.weatherManager.toString();
      }
    });*/

  @override
  void dispose() {
    super.dispose();
  }
}