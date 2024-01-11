import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ski_tracker/welcome_pages/welcome_page.dart';

import '../main.dart';

class WelcomePages extends StatefulWidget {
  const WelcomePages({super.key});

  @override
  State<WelcomePages> createState() => _WelcomePagesState();
}

class _WelcomePagesState extends State<WelcomePages> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int numPages = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          WelcomePage(
            title: 'Welcome to ${SkiTracker.appName}',
            subtitle: 'The best app to track your skiing activity',
            image: 'assets/images/background.png',
            pageController: _pageController,
            currentPage: _currentPage,
            isLastPage: false,
          ),
          WelcomePage(
            title: 'Location Access',
            subtitle: '${SkiTracker.appName} needs access to your location to track your activity',
            image: 'assets/images/welcome_pages/location.png',
            buttonText: 'Enable Location',
            pageController: _pageController,
            currentPage: _currentPage,
            isLastPage: false,
          ),
          WelcomePage(
            title: 'Enable Background Mode',
            subtitle: 'In order for ${SkiTracker.appName} to work properly when the screen is switched off, the background restriction must be disabled.',
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
