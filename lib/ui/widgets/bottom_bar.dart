import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/ui/controller.dart';

import '../../string_pool.dart';
import '../../theme/color.dart';
import '../../theme/animation.dart';
import '../../theme/icon.dart';

/// Class for the custom bottom bar (activity and history)
class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key, required this.controller});

  final CustomController controller;

  final double height = 52;
  final double iconHeight = 28;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

/// State for the custom bottom bar
class _CustomBottomBarState extends State<CustomBottomBar> {
  /// Function to get the height of the bottom bar (height + height of the
  /// system navigation bar)
  double get fullHeight =>
      widget.height + MediaQuery.of(context).padding.bottom;

  @override
  void initState() {
    super.initState();

    /// Update the state of the bottom bar when the page changes
    widget.controller.updateState = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      /// Set the height of the bottom bar
      height: fullHeight,

      /// Set the padding of the bottom bar to avoid the system navigation bar
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),

      /// Set the background color of the bottom bar to the background color
      decoration: BoxDecoration(
        color: ColorTheme.background,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              _buildItem(
                  iconData: LogoTheme.activity,
                  text: StringPool.ACTIVITY,
                  page: 0),
              _buildItem(
                  iconData: LogoTheme.statistics,
                  text: StringPool.STATISTICS,
                  page: 1),
              _buildItem(
                  iconData: LogoTheme.history,
                  text: StringPool.HISTORY,
                  page: 2),
            ],
          ),
          AnimatedPositioned(
            duration: AnimationTheme.fastAnimationDuration,
            top: 0,
            left: (MediaQuery.of(context).size.width /
                    widget.controller.numberOfPages) *
                (widget.controller.pageIndex),
            child: Container(
              width: MediaQuery.of(context).size.width /
                  widget.controller.numberOfPages,
              height: 4,
              color: ColorTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build an item of the bottom bar
  ///
  /// @param iconData The icon data of the item
  /// @param text The text of the item
  /// @param page The page to go to when the item is pressed
  Widget _buildItem(
      {required IconData iconData, required String text, required int page}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.controller.pageIndex = page;
          widget.controller.pageController.animateToPage(
            page,
            duration: AnimationTheme.fastAnimationDuration,
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          alignment: Alignment.center,
          child: Icon(
            iconData,
            size: widget.iconHeight,
            color: widget.controller.pageIndex == page
                ? ColorTheme.primary
                : ColorTheme.grey,
          ),
        ),
      ),
    );
  }
}
