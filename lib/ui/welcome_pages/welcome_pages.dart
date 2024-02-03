import 'dart:io';

import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/welcome_pages/welcome_page.dart';

import '../../string_pool.dart';
import '../../theme.dart';

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
            title: StringPool.WELCOME_TITLE,
            subtitle: StringPool.WELCOME_SUBTITLE_1,
            image: 'assets/images/welcome_pages/activity.png',
            pageController: _pageController,
            currentPage: _currentPage,
            imageAlignment: Alignment.topCenter,
            buttonText: StringPool.BUTTON_TEXT,
          ),
          WelcomePage(
            title: StringPool.WELCOME_TITLE,
            subtitle: StringPool.WELCOME_SUBTITLE_2,
            image: 'assets/images/welcome_pages/stats.png',
            pageController: _pageController,
            currentPage: _currentPage,
            buttonText: StringPool.BUTTON_TEXT,
          ),
          WelcomePage(
            title: StringPool.WELCOME_TITLE,
            subtitle: StringPool.WELCOME_SUBTITLE_3,
            image: 'assets/images/welcome_pages/slope_info.png',
            pageController: _pageController,
            currentPage: _currentPage,
            buttonText: StringPool.BUTTON_TEXT,
          ),
          WelcomePage(
            title: StringPool.LOCATION_ACCESS_TITLE,
            subtitle: StringPool.LOCATION_ACCESS_SUBTITLE,
            image: 'assets/images/welcome_pages/location.png',
            buttonText: StringPool.ENABLE_LOCATION,
            pageController: _pageController,
            currentPage: _currentPage,
          ),
          if (Platform.isAndroid)
            WelcomePage(
              title: StringPool.BATTERY_OPTIMIZATION_TITLE,
              subtitle: StringPool.BATTERY_OPTIMIZATION_SUBTITLE,
              image: 'assets/images/welcome_pages/battery_optimization.png',
              buttonText: StringPool.OPEN_SETTINGS,
              pageController: _pageController,
              currentPage: _currentPage,
              isLastPage: false,
            ),
          WelcomePage(
            title: StringPool.LAST_TITLE,
            subtitle: StringPool.LAST_SUBTITLE,
            image: 'assets/images/welcome_pages/finish.png',
            buttonText: StringPool.GET_STARTED,
            pageController: _pageController,
            currentPage: _currentPage,
            isLastPage: true,
          ),
        ],
      ),
    );
  }
}
