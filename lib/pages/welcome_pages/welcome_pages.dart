import 'dart:io';

import 'package:flutter/material.dart';
import 'package:powder_pilot/pages/welcome_pages/welcome_page.dart';

import '../../main.dart';

class WelcomePages extends StatefulWidget {
  const WelcomePages({super.key});

  @override
  State<WelcomePages> createState() => _WelcomePagesState();
}

class _WelcomePagesState extends State<WelcomePages> {
  final PageController _pageController = PageController(initialPage: 0);
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
            subtitle: 'The best app to track your skiing activity',
            image: 'assets/images/background.png',
            pageController: _pageController,
            currentPage: _currentPage,
            isLastPage: false,
          ),
          WelcomePage(
            title: 'Location Access',
            subtitle:
                '${PowderPilot.appName} needs access to your location to track your activity',
            image: 'assets/images/welcome_pages/location.png',
            buttonText: 'Enable Location',
            pageController: _pageController,
            currentPage: _currentPage,
            isLastPage: false,
          ),
          if (Platform.isAndroid)
            WelcomePage(
              title: 'Enable Background Mode',
              subtitle:
                  'Enable background mode of your device to allow proper work of ${PowderPilot.appName} when screen is switched off.',
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
