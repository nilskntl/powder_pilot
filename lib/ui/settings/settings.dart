// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/settings/setting/measurement.dart';
import 'package:powder_pilot/ui/settings/setting/theme.dart';

import '../../string_pool.dart';
import '../../theme.dart';
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
          children: [
            MeasurementSetting(),
            const SizedBox(height: 16),
            LanguageSetting(),
            const SizedBox(height: 16),
            AppThemeSetting(),
            const Spacer(),
            LegalSetting(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
