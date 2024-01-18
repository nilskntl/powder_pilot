import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../main.dart';
import '../../utils/general_utils.dart';

class LocationButton extends StatefulWidget {
  const LocationButton(
      {super.key, required this.pageController, required this.currentPage});

  final PageController pageController;
  final int currentPage;

  @override
  State<LocationButton> createState() => _LocationPageButtonState();
}

class _LocationPageButtonState extends State<LocationButton> {
  String buttonText = 'Enable Location';
  bool _isLocationEnabled = false;
  bool _alreadyAskedForPermission = false;

  PermissionStatus permissionStatus = PermissionStatus.denied;

  Future<PermissionStatus> _requestPermission() async {
    Location location = Location();

    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    _isLocationEnabled = permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited;
    setState(() {
      if (_isLocationEnabled) {
        buttonText = 'Next';
        widget.pageController.animateToPage(
          widget.currentPage + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      } else {
        buttonText = 'Settings';
      }
    });
    return permissionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(buttonText == 'Settings')
          Utils.buildText(text: 'Please enable location in the settings', fontSize: FontTheme.size - 2, fontWeight: FontWeight.normal, color: ColorTheme.contrast),
        if(buttonText == 'Settings')
          const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 64.0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              if ((permissionStatus == PermissionStatus.denied ||
                  permissionStatus == PermissionStatus.deniedForever) && _alreadyAskedForPermission) {
                AppSettings.openAppSettings(type: AppSettingsType.location);
              } else if (_isLocationEnabled) {
                widget.pageController.animateToPage(
                  widget.currentPage + 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              } else {
                _requestPermission();
                _alreadyAskedForPermission = true;
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: ColorTheme.contrast,
              backgroundColor:
              _isLocationEnabled ? ColorTheme.primary : ColorTheme.grey,
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