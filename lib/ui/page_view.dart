import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/ui/statistics/statistics.dart';

import 'activity/activity_page.dart';
import 'controller.dart';
import 'history/history.dart';

/// Class for the main page view (activity and history)
class MainPageView extends StatefulWidget {
  const MainPageView({super.key, required this.controller});

  /// Custom page and scroll controller
  final CustomController controller;

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

/// State for the main page view (activity and history)
class _MainPageViewState extends State<MainPageView> {
  /// The page for the activity
  late final ActivityPage activity =
      ActivityPage(customPageController: widget.controller);

  /// The page for the history
  final HistoryPage history = const HistoryPage();
  
  /// The page for statistics
  final StatisticsPage statistics = const StatisticsPage();

  @override
  Widget build(BuildContext context) {
    /// Return the expandable page view because the pages have different sizes
    return PageView(
      controller: widget.controller.pageController,
      scrollDirection: Axis.horizontal,
      onPageChanged: (int page) {
        widget.controller.pageIndex = page;
        widget.controller.updateState();
      },
      children: [
        activity,
        statistics,
        history,
      ],
    );
  }
}
