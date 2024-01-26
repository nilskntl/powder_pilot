import 'dart:io';

import 'package:flutter/material.dart';
import 'package:powder_pilot/pages/welcome_pages/welcome_page.dart';

import '../../main.dart';

/// A widget representing a set of welcome pages for onboarding.
class WelcomePages extends StatefulWidget {
  const WelcomePages({super.key});

  @override
  State<WelcomePages> createState() => _WelcomePagesState();
}

/// The state for the WelcomePages widget.
class _WelcomePagesState extends State<WelcomePages> {
  /// Controller for the page view.
  final PageController _pageController = PageController(initialPage: 0);

  /// The index of the current page.
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          WelcomePage(
            title: 'Welcome to ${PowderPilot.appName}',
            subtitle: 'Track your skiing activity with ${PowderPilot.appName}',
            image: 'assets/images/welcome_pages/activity.png',
            pageController: _pageController,
            currentPage: _currentPage,
            imageAlignment: Alignment.topCenter,
          ),
          WelcomePage(
            title: 'Welcome to ${PowderPilot.appName}',
            subtitle: 'See your stats and improve your skiing',
            image: 'assets/images/welcome_pages/stats.png',
            pageController: _pageController,
            currentPage: _currentPage,
          ),
          WelcomePage(
            title: 'Welcome to ${PowderPilot.appName}',
            subtitle: 'Analyse your ski day',
            image: 'assets/images/welcome_pages/slope_info.png',
            pageController: _pageController,
            currentPage: _currentPage,
          ),
          WelcomePage(
            title: 'Location Access',
            subtitle:
                'To track your activity ${PowderPilot.appName} needs access to your GPS location',
            image: 'assets/images/welcome_pages/location.png',
            buttonText: 'Enable Location',
            pageController: _pageController,
            currentPage: _currentPage,
          ),
          if (Platform.isAndroid)
            WelcomePage(
              title: 'Enable Background Mode',
              subtitle:
                  'Enable background mode of your device to allow proper work of ${PowderPilot.appName} when the screen is switched off.',
              image: 'assets/images/welcome_pages/battery_optimization.png',
              buttonText: 'Open Settings',
              pageController: _pageController,
              currentPage: _currentPage,
              isLastPage: false,
            ),
          WelcomePage(
            title: 'Last steps to go',
            subtitle: 'Finish your setup and start tracking your activity',
            image: 'assets/images/welcome_pages/finish.png',
            buttonText: 'Get started',
            pageController: _pageController,
            currentPage: _currentPage,
            isLastPage: true,
          ),
        ],
      ),
    );
  }
}
