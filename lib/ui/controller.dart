import 'package:flutter/cupertino.dart';

class CustomController {
  /// Page Controller
  final PageController pageController = PageController();
  final int numberOfPages = 3;
  int pageIndex = 0;

  /// Scroll Controller
  final ScrollController scrollController = ScrollController();

  // Update Bottom Bar State
  void Function() updateState = () {};
}
