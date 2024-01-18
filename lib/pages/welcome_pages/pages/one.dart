import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../utils/general_utils.dart';

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
    return PageView(
      clipBehavior: Clip.hardEdge,
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
    );
  }
}
