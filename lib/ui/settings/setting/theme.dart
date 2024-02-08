import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/theme/icon.dart';
import 'package:powder_pilot/ui/activity/activity_page.dart';

import '../../../main.dart';
import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../theme/widget.dart';
import '../../../utils/general_utils.dart';
import '../../history/overview/history.dart';
import '../settings.dart';

/// The app theme setting allows the user to change the (color) app theme.
class AppThemeSetting extends StatefulWidget {
  const AppThemeSetting({super.key});

  @override
  State<AppThemeSetting> createState() => _AppThemeSettingState();
}

/// The state of the app theme setting
class _AppThemeSettingState extends State<AppThemeSetting> {
  /// Changes the theme of the app
  ///
  /// @param theme The theme to switch to (e.g. 'modern')
  void _changeTheme(String theme) {
    if (kDebugMode) {
      print('Changing theme to $theme');
    }
    setState(() {
      ThemeChanger.changeTheme(theme);
      SettingsPage.reload();
      PowderPilot.reload();
      History.reload();
      ActivityPage.reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WidgetTheme.settingsListTile(
          title: StringPool.APP_THEME,
          subtitle: Utils.buildText(
            text: ThemeChanger.currentTheme.name,
            caps: false,
            align: TextAlign.left,
          ),
          onTap: () {
            WidgetTheme.settingsDialog(
              height: MediaQuery.of(context).size.height / 2,
              children: ThemeChanger.availableThemes
                  .map(
                    (theme) => Column(
                      children: [
                        WidgetTheme.settingsOption(
                          title: theme.name,
                          leading: _buildSchema(
                            primary: theme.colors[0],
                            secondary: theme.colors[1],
                            tertiary: theme.colors[2],
                          ),
                          trailing: Icon(
                            theme.darkMode ? LogoTheme.darkMode : LogoTheme.lightMode,
                            color: ColorTheme.contrast,
                            size: 14,
                          ),
                          context: context,
                          onTap: () {
                            _changeTheme(theme.name);
                          },
                        ),
                        Divider(
                          color: ThemeChanger.currentTheme.darkMode
                              ? ColorTheme.background
                              : ColorTheme.grey,
                        ),
                      ],
                    ),
                  )
                  .toList(),
              context: context,
            );
          },
          leading: Icon(
            LogoTheme.theme,
            color: ColorTheme.contrast,
            size: SettingsPage.leadingWidget,
          ),
        ),
        Positioned(
          right: 8,
          top: 24,
          child: _buildSchema(
            primary: ColorTheme.primary,
            secondary: ColorTheme.secondary,
            tertiary: ColorTheme.contrast,
          ),
        ),
      ],
    );
  }

  /// Build a schema with three colors
  ///
  /// @param primary The primary color
  /// @param secondary The secondary color
  /// @param tertiary The tertiary (contrast) color
  Widget _buildSchema(
      {required Color primary,
      required Color secondary,
      required Color tertiary}) {
    const double size = 24;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 3),
      child: SizedBox(
        width: size * 3,
        height: size,
        child: Row(
          children: [
            Container(
              width: size,
              height: size,
              color: primary,
            ),
            Container(
              width: size,
              height: size,
              color: secondary,
            ),
            Container(
              width: size,
              height: size,
              color: tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
