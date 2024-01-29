import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:powder_pilot/location.dart';

import '../../main.dart';
import '../../theme.dart';
import '../../utils/general_utils.dart';
import '../../utils/shared_preferences.dart';

/// Widget representing an individual welcome page in the onboarding process.
class WelcomePage extends StatefulWidget {
  const WelcomePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.pageController,
    required this.currentPage,
    this.isLastPage = false,
    this.buttonText = standardButtonText,
    this.imageAlignment = Alignment.bottomCenter,
  });

  static const String standardButtonText = 'Next';

  final String title;
  final String subtitle;
  final String buttonText;
  final String image;
  final PageController pageController;
  final int currentPage;
  final bool isLastPage;
  final Alignment imageAlignment;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

/// The state for the WelcomePage widget.
class _WelcomePageState extends State<WelcomePage> {
  late final double _imageHeight = MediaQuery.of(context).size.height * 0.39;
  final int _pages = Platform.isAndroid ? 6 : 5;
  final Color _smartphoneColor = ColorTheme.black;
  late String _buttonText = widget.buttonText;
  bool _accepted = true;

  /// Checks the location permission and updates the UI accordingly.
  void _checkLocationPermission() async {
    LocationPermission status = await LocationService.checkPermission();
    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      setState(() {
        _buttonText = WelcomePage.standardButtonText;
        _accepted = true;
      });
    }
  }

  /// Asks for location permission and updates the UI accordingly.
  void _askForLocation() async {
    _accepted = await LocationService.askForPermission();
    if (_accepted) {
      _buttonText = WelcomePage.standardButtonText;
      widget.pageController.animateToPage(
        widget.currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _buttonText = 'Open Settings';
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// Opens battery optimization settings on Android.
  void _openBatterySettings() async {
    try {
      AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    sleep(const Duration(milliseconds: 250));
    setState(() {
      _buttonText = 'Next';
      _accepted = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.buttonText != WelcomePage.standardButtonText) {
      _accepted = false;
      if (widget.currentPage == 2) {
        /// Should be 3 but somehow it's 2
        _checkLocationPermission();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorTheme.backgroundGradient1,
                ColorTheme.background,
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 64),
                    Utils.buildText(
                      text: widget.title,
                      fontSize: Utils.calculateFontSizeByContext(
                          text: widget.title.toUpperCase(),
                          context: context,
                          paddingLeftRight: 72,
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
                      caps: false,
                    ),
                  ],
                ),
              ),
              Stack(children: [
                Container(
                  height: _imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                        bottomLeft: Radius.circular(4.0),
                        bottomRight: Radius.circular(4.0)),
                    color: _smartphoneColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.only(left: 6.0, right: 6.0, top: 6.0),
                  height: _imageHeight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                        bottomLeft: Radius.circular(4.0),
                        bottomRight: Radius.circular(4.0)),
                    child: Image.asset(
                      alignment: widget.imageAlignment,
                      widget.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Center(
                    child: Container(
                  width: 96,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0)),
                    color: _smartphoneColor,
                  ),
                ))
              ]),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.isLastPage) _buildTermsWidget(),
                    if (widget.isLastPage) const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 64.0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_accepted) {
                            if (widget.isLastPage) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PowderPilot()));
                              SharedPref.saveBool(PowderPilot.startKey, true);
                            } else {
                              widget.pageController.animateToPage(
                                widget.currentPage + 1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            }
                          } else {
                            if (widget.currentPage == 3) {
                              if (_buttonText != 'Open Settings') {
                                _askForLocation();
                              } else {
                                LocationService.openSettings();
                              }
                            } else if (widget.currentPage == 4 &&
                                Platform.isAndroid) {
                              _openBatterySettings();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                              width: 2.0, color: ColorTheme.primary),
                          foregroundColor: ColorTheme.secondary,
                          backgroundColor: _accepted
                              ? ColorTheme.primary
                              : Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          shadowColor:
                              _accepted ? ColorTheme.grey : Colors.transparent,
                          elevation: 4.0,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Utils.buildText(
                          text: _buttonText,
                          fontSize: FontTheme.size,
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.contrast,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Utils.buildText(
                        text:
                            '${(widget.currentPage + 1).toString().substring(0, 1)} / $_pages',
                        fontSize: FontTheme.size,
                        fontWeight: FontWeight.normal,
                        color: ColorTheme.contrast),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the terms widget for the last page.
  Widget _buildTermsWidget() {
    return Row(
      children: [
        Checkbox(
          side: const BorderSide(width: 2.0, color: ColorTheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          value: _accepted,
          onChanged: (value) {
            setState(() {
              _accepted = value ?? false;
            });
          },
        ),
        const SizedBox(width: 4),
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'I agree to the',
                  style: TextStyle(
                      color: ColorTheme.contrast, fontSize: FontTheme.size),
                ),
                TextSpan(
                  text: ' Terms of Service',
                  style: const TextStyle(
                      color: ColorTheme.blue, fontSize: FontTheme.size),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showDialog(
                          context: context,
                          asset: 'assets/legal/terms_of_service.txt');
                    },
                ),
                const TextSpan(
                  text: ' and',
                  style: TextStyle(
                      color: ColorTheme.contrast, fontSize: FontTheme.size),
                ),
                TextSpan(
                  text: ' Privacy Policy',
                  style: const TextStyle(
                      color: ColorTheme.blue, fontSize: FontTheme.size),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showDialog(
                          context: context,
                          asset: 'assets/legal/privacy_policy.txt');
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a dialog with legal text.
  void _showDialog({required BuildContext context, required String asset}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LegalDialog(asset: asset);
      },
    );
  }
}

/// Dialog widget to display legal text.
class LegalDialog extends StatefulWidget {
  const LegalDialog({super.key, required this.asset});

  final String asset;

  @override
  State<LegalDialog> createState() => _LegalDialogState();
}

/// The state for the LegalDialog widget.
class _LegalDialogState extends State<LegalDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  List<String> arr = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  /// Loads text from assets.
  Future<void> loadTextFromAssets() async {
    try {
      /// Load the text from the asset bundle in bytes.
      ByteData data = await rootBundle.load(widget.asset);

      /// Convert the bytes to a string.
      String text = utf8.decode(data.buffer.asUint8List());
      List<String> paragraphs =
          text.split('\n').where((paragraph) => paragraph.isNotEmpty).toList();

      setState(() {
        arr = paragraphs;
      });
    } catch (e) {
      setState(() {
        arr = ['Error while trying to load text from assets: $e'];
      });
      if (kDebugMode) {
        print('Error while trying to load text from assets: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Load it here and not in initState because setState() might be called
    /// before the widget is mounted.
    loadTextFromAssets();
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        backgroundColor: ColorTheme.background,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  iconSize: 32,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: ColorTheme.contrast,
                  ),
                ),
              ),
              if (arr.isNotEmpty)
                _buildDialogText(
                  text: arr.first,
                  fontWeight: FontWeight.bold,
                ),
              const SizedBox(height: 12),
              if (arr.length > 1)
                ...arr.skip(1).map(
                      (paragraph) => _buildDialogText(
                        text: paragraph,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the text for the dialog.
  Widget _buildDialogText({
    required String text,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils.buildText(
          text: text,
          fontSize: FontTheme.size,
          fontWeight: fontWeight,
          color: ColorTheme.contrast,
          align: TextAlign.left,
          caps: false,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
