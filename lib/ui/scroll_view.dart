import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/page_view.dart';

import '../theme.dart';
import 'controller.dart';

/// Class for the main scroll view. The actual content
/// of the app is displayed inside this scroll view
class MainScrollView extends StatefulWidget {
  const MainScrollView({super.key, required this.controller});

  /// Custom page and scroll controller
  final CustomController controller;

  @override
  State<MainScrollView> createState() => _MainScrollViewState();
}

/// State for the main scroll view
class _MainScrollViewState extends State<MainScrollView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller.scrollController,
      slivers: [
        SliverAppBar(
          /// Set colors to transparent
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,

          /// Set the minimum height the scroll view can have
          collapsedHeight: MediaQuery.of(context).size.height -
              380 -
              MediaQuery.of(context).padding.bottom,

          /// Force material transparency to avoid errors when trying to
          /// interact with the UI
          forceMaterialTransparency: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _buildBar(),
              Container(
                height: MediaQuery.of(context).size.height - 240,
                color: ColorTheme.background,
                child: MainPageView(controller: widget.controller),
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(color: ColorTheme.background),
        ),
      ],
    );
  }

  /// Build the bar at the top of the scroll view
  /// This bar is used to indicate the user that the scroll view can be scrolled
  Widget _buildBar() {
    const double height = 12.0;
    const double heightBar = 4.0;
    const double widthBar = 80.0;

    return Container(
        height: height * 1.5,
        decoration: BoxDecoration(
          color: ColorTheme.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(height),
            topRight: Radius.circular(height),
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: heightBar,
              width: widthBar,
              decoration: BoxDecoration(
                color: ColorTheme.grey,
                borderRadius: BorderRadius.circular(heightBar / 2),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
          ],
        ));
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    super.dispose();
  }
}
