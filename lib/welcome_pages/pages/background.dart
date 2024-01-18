import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../main.dart';
import '../../utils/general_utils.dart';

class BackgroundLocationButton extends StatefulWidget {
  const BackgroundLocationButton(
      {super.key, required this.pageController, required this.currentPage});

  final PageController pageController;
  final int currentPage;

  @override
  State<BackgroundLocationButton> createState() =>
      _BackgroundLocationButtonState();
}

class _BackgroundLocationButtonState extends State<BackgroundLocationButton> {
  String buttonText = 'Open Location Settings';

  Future<void> _requestLocationPermission() async {
    try {
      Location location = Location();
      location.enableBackgroundMode(enable: true);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() {
      buttonText = 'Open Battery Settings';
    });
  }

  void _openBatterySettings() {
    try {
      AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() {
      buttonText = 'Next';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(buttonText != 'Next')
          Utils.buildText(text: 'Step ${buttonText == 'Open Location Settings' ? '1' : '2'}/2', fontSize: FontTheme.size - 2, fontWeight: FontWeight.normal, color: ColorTheme.contrast),
        if(buttonText != 'Next')
          const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 64.0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              if(buttonText == 'Open Location Settings') {
                _requestLocationPermission();
              } else if (buttonText == 'Open Battery Settings') {
                _openBatterySettings();
              } else {
                widget.pageController.animateToPage(
                  widget.currentPage + 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: ColorTheme.contrast,
              backgroundColor:
              buttonText == 'Next' ? ColorTheme.primary : ColorTheme.grey,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Utils.buildText(
              text: buttonText,
              fontSize: FontTheme.size,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}