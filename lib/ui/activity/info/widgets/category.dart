import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/activity/state.dart';
import 'package:powder_pilot/main.dart';

import '../../../../theme/color.dart';
import '../../../../theme/animation.dart';
import '../../../../theme/font.dart';
import '../../../../theme/widget.dart';
import '../../../../utils/general_utils.dart';

/// Class for displaying a category (e.g. speed, altitude, etc.)
/// with an icon, a title and the values.
/// The class also includes static methods to build the icon, the header
/// and the values that are used in other widgets.
class Category extends StatefulWidget {
  const Category(
      {super.key,
      required this.icon,
      required this.title,
      required this.unit,
      required this.primaryValue,
      this.child = const SizedBox(),
      this.secondaryValue1 = '',
      this.secondaryValue2 = '',
      this.primaryTitle = '',
      this.secondaryTitle = '',
      this.secondaryTitle2 = ''});

  /// The icon to display
  final IconData icon;

  /// The title of the category
  final String title;

  /// The unit of the values
  final String unit;

  /// The primary value to display
  final String primaryValue;
  final String primaryTitle;

  /// The secondary values to display
  final String secondaryValue1;
  final String secondaryValue2;
  final String secondaryTitle;
  final String secondaryTitle2;

  /// The height of the icon. The rest of the widgets will be scaled
  /// according to this value.
  static const double iconHeight = 20;

  /// The padding for the category from the side
  static const EdgeInsets paddingOutside = EdgeInsets.all(8.0);

  /// The padding for the category inside the container
  static const EdgeInsets paddingInside = EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0);

  final Widget child;

  /// Build the icon for the category
  ///
  /// @param icon The icon to display
  static Widget buildIcon({required IconData icon, targetHeight = iconHeight * 3}) {
    return WidgetTheme.animatedContainer(
      duration: AnimationTheme.animationDuration,
      width: PowderPilot.dataProvider.status == ActivityStatus.inactive
          ? iconHeight * 2
          : targetHeight,
      height: PowderPilot.dataProvider.status == ActivityStatus.inactive
          ? iconHeight * 2
          : targetHeight,
      color: ColorTheme.primary,
      child: Icon(
        icon,
        size: iconHeight,
        color: ColorTheme.secondary,
      ),
    );
  }

  /// Build the header text for the category
  ///
  /// @param title The title of the category
  static Widget buildHeader({required String title}) {
    return Utils.buildText(
        text: title,
        fontSize: FontTheme.size,
        color: ColorTheme.grey,
        fontWeight: FontWeight.bold);
  }

  /// Build the text for a value ("value" + "unit")
  ///
  /// @param value The value to display
  /// @param primary Whether the value is the primary value or not
  /// @param unit The unit of the value
  static Widget _buildValue(
      {required String value, bool primary = false, required String unit}) {
    return Row(
      children: [
        Utils.buildText(
            text: value,
            fontSize: primary ? FontTheme.sizeSubHeader : FontTheme.size,
            color: ColorTheme.contrast,
            fontWeight: FontWeight.bold),
        const SizedBox(width: 4),
        Utils.buildText(
            text: unit,
            fontSize: FontTheme.size,
            color: ColorTheme.contrast,
            fontWeight: FontWeight.bold,
            caps: false),
      ],
    );
  }

  /// Build the secondary values for the category but in a column
  ///
  /// @param value The value to display
  /// @param title The title of the value
  /// @param unit The unit of the value
  static Widget buildSecondaryValueColumn(
      {required String value, required String title, required String unit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildValue(value: value, unit: unit),
        const SizedBox(height: 4),
        Utils.buildText(
          text: title,
          fontSize: FontTheme.size,
          color: ColorTheme.grey,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  /// Build the secondary values for the category
  ///
  /// @param value The value to display
  /// @param title The title of the value
  /// @param unit The unit of the value
  /// @param spaced Whether the values should be spaced (value and title) or not
  /// @param widthTitle The width of the title
  static Widget buildSecondaryValue(
      {required String value,
      required String title,
      required String unit,
      bool spaced = false,
      double widthTitle = 84}) {
    return Row(
      mainAxisAlignment:
          spaced ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
      children: [
        _buildValue(value: value, unit: unit),
        const SizedBox(width: 4),
        Container(
          width: widthTitle,
          alignment: Alignment.centerRight,
          child: Utils.buildText(
            text: title,
            fontSize: FontTheme.size,
            color: ColorTheme.grey,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  @override
  State<Category> createState() => _CategoryState();
}

/// The state for the Category widget.
class _CategoryState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      /// Set a padding of 8 on all sides.
      padding: Category.paddingOutside,

      /// Build an animated container to scale the size of the category
      /// according to the status of the activity (inactive or active)
      child: WidgetTheme.animatedContainer(
          padding: Category.paddingInside,
          duration: AnimationTheme.animationDuration,

          /// List view to display the widgets and to not get an overflow
          /// when the content is too big while the animation is running
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Building the primary values and the icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Category.buildIcon(icon: widget.icon),
                      const SizedBox(width: 12),
                      _buildPrimaryValue(),
                    ],
                  ),

                  /// Building the secondary values
                  Column(
                    children: [
                      if (widget.secondaryValue1 != '' &&
                          PowderPilot.dataProvider.status !=
                              ActivityStatus.inactive)
                        Category.buildSecondaryValue(
                          value: widget.secondaryValue1,
                          title: widget.secondaryTitle,
                          unit: widget.unit,
                        ),
                      if (widget.secondaryValue2 != '' &&
                          widget.secondaryValue1 != '' &&
                          PowderPilot.dataProvider.status !=
                              ActivityStatus.inactive)
                        const SizedBox(height: 4),
                      if (widget.secondaryValue2 != '' &&
                          PowderPilot.dataProvider.status !=
                              ActivityStatus.inactive)
                        Category.buildSecondaryValue(
                          value: widget.secondaryValue2,
                          title: widget.secondaryTitle2,
                          unit: widget.unit,
                        ),
                    ],
                  ),
                ],
              ),
              widget.child,
            ],
          )),
    );
  }

  /// Build the primary value for the category
  Widget _buildPrimaryValue() {
    return SizedBox(
      height: PowderPilot.dataProvider.status == ActivityStatus.inactive
          ? Category.iconHeight * 2
          : Category.iconHeight * 3,
      child: Column(
        mainAxisAlignment:
            PowderPilot.dataProvider.status == ActivityStatus.inactive
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Category.buildHeader(
            title: widget.title,
          ),
          if (PowderPilot.dataProvider.status != ActivityStatus.inactive)
            Category._buildValue(
                value: widget.primaryValue, primary: true, unit: widget.unit),
        ],
      ),
    );
  }
}
