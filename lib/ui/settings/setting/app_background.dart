import 'package:flutter/material.dart';
import 'package:powder_pilot/theme/animation.dart';
import 'package:powder_pilot/ui/activity/activity_page.dart';

import '../../../main.dart';
import '../../../theme/background.dart';
import '../../../theme/color.dart';
import '../../../theme/widget.dart';
import '../../../utils/general_utils.dart';
import '../../history/history.dart';
import '../../statistics/statistics.dart';
import '../settings.dart';

/// The app theme setting allows the user to change the (color) app theme.
class AppBackgroundSetting extends StatefulWidget {
  const AppBackgroundSetting({super.key});

  @override
  State<AppBackgroundSetting> createState() => _AppBackgroundSettingState();
}

/// The state of the app theme setting
class _AppBackgroundSettingState extends State<AppBackgroundSetting> {
  /// Changes the background of the app
  ///
  /// @param background The background to switch to (e.g. 'background')
  void _changeBackground(String background) {
    BackgroundTheme.changeBackground(background);
    setState(() {
      SettingsPage.reload();
      PowderPilot.reload();
      HistoryPage.reload();
      ActivityPage.reload();
      StatisticsPage.reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetTheme.container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: BackgroundTheme.backgrounds
              .map((background) => _buildPreview(
                    name: background[0],
                    asset: background[1],
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Build a preview of the background image
  ///
  /// @param name The name of the background image
  /// @param asset The asset of the background image
  Widget _buildPreview({required String name, required String asset}) {
    const double width = 128;
    return GestureDetector(
      onTap: () {
        _changeBackground(name);
      },
      child: Column(
        children: [
          Container(
            width: width,
            height: width * 1.39,
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedContainer(
                    duration: AnimationTheme.fastAnimationDuration,
                    decoration: BoxDecoration(
                      color: (BackgroundTheme.currentBackgroundKey == name)
                          ? ColorTheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: (BackgroundTheme.currentBackgroundKey == name)
                            ? ColorTheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        asset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Utils.buildText(
            text: name,
            color: ColorTheme.contrast,
            caps: false,
          ),
        ],
      ),
    );
  }
}
