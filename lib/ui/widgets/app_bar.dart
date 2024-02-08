import 'package:flutter/material.dart';

import '../../main.dart';
import '../../theme/color.dart';
import '../../theme/font.dart';
import '../../theme/icon.dart';
import '../../utils/general_utils.dart';
import '../settings/settings.dart';

/// A utility class for creating custom Material app bars.
class CustomMaterialAppBar {
  /// Generates a custom Material AppBar with a specified title and optional
  ///  child widget.
  ///
  /// @param title The title to be displayed in the AppBar.
  /// @param child An optional widget to be displayed as a child in the AppBar.
  /// @return An AppBar with the specified properties.
  static AppBar appBar(
      {required String title, Widget child = const SizedBox()}) {
    /// Flag to check if the current theme is dark.
    bool dark = ThemeChanger.currentTheme.darkMode;
    return AppBar(
      backgroundColor: dark ? ColorTheme.secondary : ColorTheme.contrast,
      foregroundColor: dark ? ColorTheme.contrast : ColorTheme.secondary,
      title: Utils.buildText(
          text: title,
          color: dark ? ColorTheme.contrast : ColorTheme.secondary,
          fontSize: FontTheme.sizeSubHeader - 4),
      actions: [child],
    );
  }
}

/// A custom stateless widget for the app bar that is used in the main screen.
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  /// The height of the app bar.
  static const barHeight = 64.0;

  /// The size of the items in the app bar.
  static const itemsSize = 40.0;

  /// Gets the status bar height for the current device.
  ///
  /// @param context The build context.
  /// @return The height of the status bar.
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: getStatusBarHeight(context),
        ),
        Container(
          height: barHeight,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/images/icon_256.png",
                    width: itemsSize,
                    height: itemsSize,
                  ),
                  const SizedBox(width: itemsSize),
                ],
              ),
              Utils.buildText(
                text: PowderPilot.appName,
                fontSize: FontTheme.size,
                fontWeight: FontWeight.bold,
                color: ColorTheme.secondary,
              ),
              Row(
                children: [
                  /*
                  GestureDetector(
                    onTap: () {},
                    child: const SizedBox(
                      width: itemsSize,
                      height: itemsSize,
                      child: Icon(
                        Icons.person_rounded,
                        color: ColorTheme.contrast,
                      ),
                    ),
                  ),*/
                  const SizedBox(width: itemsSize),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage()));
                    },
                    child: SizedBox(
                      width: itemsSize,
                      height: itemsSize,
                      child: Icon(
                        LogoTheme.settings,
                        color: ColorTheme.secondary,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
