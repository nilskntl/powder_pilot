// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/settings/setting/app_background.dart';
import 'package:powder_pilot/ui/settings/setting/measurement.dart';
import 'package:powder_pilot/ui/settings/setting/app_theme.dart';

import '../../string_pool.dart';
import '../../theme/color.dart';
import '../../utils/general_utils.dart';
import '../widgets/app_bar.dart';
import 'info/legal.dart';
import 'setting/language.dart';

/// Widget representing the settings page.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  static const double leadingWidget = 36;

  static void Function() reload = () {};

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// The state for the SettingsPage widget.
class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    SettingsPage.reload = () {
      if(mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMaterialAppBar.appBar(title: StringPool.SETTINGS),
      backgroundColor: ColorTheme.background,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 112 - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Utils.buildText(
                    text: StringPool.SETTINGS,
                    fontWeight: FontWeight.bold,
                    align: TextAlign.left,
                    color: ColorTheme.grey,
                    caps: false,
                  ),
                  const SizedBox(height: 8),
                  MeasurementSetting(),
                  const SizedBox(height: 16),
                  LanguageSetting(),
                  const SizedBox(height: 16),
                  Utils.buildText(
                    text: StringPool.THEME,
                    fontWeight: FontWeight.bold,
                    align: TextAlign.left,
                    color: ColorTheme.grey,
                    caps: false,
                  ),
                  const SizedBox(height: 8),
                  AppThemeSetting(),
                  const SizedBox(height: 8),
                  AppBackgroundSetting(),
                ],
              ),
            ),
            const Spacer(),
            LegalSetting(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
