import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../string_pool.dart';
import '../../../theme.dart';
import '../../../utils/general_utils.dart';
import '../../history/overview/history.dart';
import '../settings.dart';

class AppThemeSetting extends StatefulWidget {
  const AppThemeSetting({super.key});

  @override
  State<AppThemeSetting> createState() => _AppThemeSettingState();
}

class _AppThemeSettingState extends State<AppThemeSetting> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WidgetTheme.settingsListTile(
          title: StringPool.APP_THEME,
          subtitle: Utils.buildText(
            text: StringPool.CHANGE_APP_THEME,
            caps: false,
            align: TextAlign.left,
          ),
          onTap: () {
            WidgetTheme.settingsDialog(
                height: MediaQuery.of(context).size.height / 2,
                children: ThemeChanger.availableThemes
                    .map((theme) => WidgetTheme.settingsOption(
                        title: theme.name,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: _buildSchema(
                              primary: theme.colors[0],
                              secondary: theme.colors[1],
                              tertiary: theme.colors[2]),
                        ),
                        context: context,
                        onTap: () {
                          ThemeChanger.changeTheme(theme.name);
                          SettingsPage.reload();
                          PowderPilot.reload();
                          History.reload();
                          setState(() {});
                        }))
                    .toList(),
                context: context);
          },
          leading: Icon(
            Icons.brush_rounded,
            color: ColorTheme.contrast,
            size: SettingsPage.leadingWidget,
          ),
        ),
        Positioned(
            top: 0,
            bottom: 0,
            right: 8,
            child: _buildSchema(
                primary: ColorTheme.primary,
                secondary: ColorTheme.secondary,
                tertiary: ColorTheme.contrast)),
      ],
    );
  }

  Widget _buildSchema(
      {required Color primary,
      required Color secondary,
      required Color tertiary}) {
    const double size = 25;

    return MaterialButton(
      onPressed: () {
        //ThemeChanger.of(context)!.setTheme(ThemeData(primaryColor: primary, accentColor: secondary));
      },
      minWidth: size + 8,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
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
            )),
      ),
    );
  }
}
