import 'dart:io';

import 'package:flutter/material.dart';
import 'package:powder_pilot/pages/welcome_pages/pages/background.dart';
import 'package:powder_pilot/pages/welcome_pages/pages/legal.dart';
import 'package:powder_pilot/pages/welcome_pages/pages/location.dart';
import 'package:powder_pilot/pages/welcome_pages/pages/one.dart';

import '../../main.dart';
import '../../utils/general_utils.dart';
import '../../utils/shared_preferences.dart';

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
            flex: 2,
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
          Expanded(
            flex: 3,
            child: widget.currentPage == 0
                ? const PageOneWidget()
                : Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.currentPage == 1)
                  LocationButton(
                      pageController: widget.pageController,
                      currentPage: widget.currentPage),
                if (widget.currentPage == 2 && Platform.isAndroid)
                  BackgroundLocationButton(
                      pageController: widget.pageController,
                      currentPage: widget.currentPage),
                if ((widget.currentPage == 2 && Platform.isIOS) ||
                    (widget.currentPage == 3 && Platform.isAndroid))
                  LegalPageButton(
                      pageController: widget.pageController,
                      currentPage: widget.currentPage),
                if (widget.currentPage == 0)
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
                                  builder: (context) => const PowderPilot()));
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
                        '${(widget.currentPage + 1).toString().substring(0, 1)} / ${Platform.isAndroid ? '4' : '3'}',
                    fontSize: FontTheme.size,
                    fontWeight: FontWeight.normal,
                    color: ColorTheme.contrast),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
