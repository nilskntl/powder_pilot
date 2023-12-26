import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../main.dart';
import '../utils.dart';

class StartActivity extends StatefulWidget {
  @override
  _StartActivityState createState() => _StartActivityState();

  Future<void> startActivity() async {
    bool accepted = await checkLocationPermission();
    if (accepted) {
      SkiTracker.getActivity().startActivity();
    }
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}

class _StartActivityState extends State<StartActivity> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.startActivity();
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: ColorTheme.primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.play_arrow_rounded,
              size: 64,
              color: ColorTheme.contrastColor,
            ),
            Utils.buildText(text: 'Start Activity'),
          ],
        ),
      ),
    );
  }

}
