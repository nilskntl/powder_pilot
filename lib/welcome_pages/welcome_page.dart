import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../main.dart';
import '../utils/general_utils.dart';
import '../utils/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.pageController,
    required this.currentPage,
    required this.isLastPage,
    this.buttonText = 'Next',
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final String image;
  final PageController pageController;
  final int currentPage;
  final bool isLastPage;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorTheme.background,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                Utils.buildText(
                  text: widget.title,
                  fontSize: Utils.calculateFontSizeByContext(
                      text: widget.title.toUpperCase(),
                      context: context,
                      paddingLeftRight: 40,
                      standardFontSize: FontTheme.sizeHeader,
                      fontWeight: FontWeight.bold),
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 16),
                Utils.buildText(
                  text: widget.subtitle,
                  fontSize: Utils.calculateFontSizeByContext(
                      text: widget.subtitle
                          .substring(0, widget.subtitle.length ~/ 1.4),
                      context: context,
                      paddingLeftRight: 32,
                      standardFontSize: FontTheme.size,
                      fontWeight: FontWeight.normal),
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
          ),
          if (widget.currentPage == 0) const PageOneWidget(),
          if (widget.currentPage != 0)
            Expanded(
              flex: 2,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  height: MediaQuery.of(context).size.height * 0.30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      widget.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ]),
            ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.currentPage == 1)
                  LocationButton(
                      pageController: widget.pageController,
                      currentPage: widget.currentPage),
                if (widget.currentPage == 2)
                  BackgroundLocationButton(
                      pageController: widget.pageController,
                      currentPage: widget.currentPage),
                if (widget.currentPage != 1 && widget.currentPage != 2)
                  Container(
                    width: double.infinity,
                    height: 64.0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.isLastPage) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SkiTracker()));
                          SharedPref.saveBool('welcome', true);
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
                        backgroundColor: ColorTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Utils.buildText(
                        text: widget.buttonText,
                        fontSize: FontTheme.size,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Utils.buildText(
                    text:
                        '${(widget.currentPage + 1).toString().substring(0, 1)} / 4',
                    fontSize: FontTheme.size,
                    fontWeight: FontWeight.normal,
                    color: ColorTheme.contrast),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class PageOneWidget extends StatefulWidget {
  const PageOneWidget({super.key});

  @override
  State<PageOneWidget> createState() => _PageOneWidgetState();
}

class _PageOneWidgetState extends State<PageOneWidget> {
  final PageController _pageController = PageController(initialPage: 0);

  Widget _buildPageIcon(
      {required String image,
      required String text,
      required int pageBack,
      required int pageForward}) {
    double height = MediaQuery.of(context).size.height * 0.30;

    Widget buildButton({required int page}) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          //color: ColorTheme.grey,
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: IconButton(
            onPressed: () {
              _pageController.animateToPage(
                page,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
            icon: RotatedBox(
              quarterTurns: page == pageBack ? 2 : 0,
              child: const Icon(
                Icons.play_circle_filled_outlined,
                color: ColorTheme.primary,
                size: 48,
              ),
            )),
      );
    }

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 48.0, right: 48.0),
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
              ),
            ),
          ),
          Positioned(
            top: height / 2 - 32,
            left: 0,
            child: buildButton(page: pageBack),
          ),
          Positioned(
              top: height / 2 - 32,
              right: 0,
              child: buildButton(page: pageForward)),
        ],
      ),
      const SizedBox(height: 16),
      Utils.buildText(
        text: text,
        fontSize: FontTheme.size,
        fontWeight: FontWeight.normal,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 2,
        child: PageView(
          controller: _pageController,
          children: [
            _buildPageIcon(
                image: 'assets/images/welcome_pages/activity.png',
                text: 'Track your skiing activity with ${SkiTracker.appName}',
                pageBack: 2,
                pageForward: 1),
            _buildPageIcon(
                image: 'assets/images/welcome_pages/stats.png',
                text: 'See your stats and improve your skiing',
                pageBack: 0,
                pageForward: 2),
            _buildPageIcon(
                image: 'assets/images/welcome_pages/slope_info.png',
                text: 'Analyse your ski day',
                pageBack: 1,
                pageForward: 0),
          ],
        ));
  }
}
