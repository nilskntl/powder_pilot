import 'package:flutter/material.dart';
import 'package:powder_pilot/pages/welcome_pages/pages/legal.dart';

import '../main.dart';
import '../utils/app_bar.dart';
import '../utils/general_utils.dart';
import '../utils/shared_preferences.dart';
import 'activity_display.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomMaterialAppBar.appBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Measurement"),
              subtitle: Text("Current system: ${Info.unitSpeed}"),
              onTap: () {
                _showLanguageSelectionDialog();
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _showDialog(
                        context: context,
                        asset: 'assets/legal/privacy_policy.txt');
                  },
                  child: Utils.buildText(
                      text: 'Privacy Policy',
                      color: ColorTheme.grey,
                      caps: false,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16.0),
                TextButton(
                    onPressed: () {
                      _showDialog(
                          context: context,
                          asset: 'assets/legal/terms_of_service.txt');
                    },
                    child: Utils.buildText(
                        text: 'Terms of Service',
                        color: ColorTheme.grey,
                        caps: false,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            height: 150, // Hier die gewünschte Breite setzen
            child: ListView(
              children: [
                _buildLanguageOption("Metric (km/h)"),
                _buildLanguageOption("Imperial (mph)"),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog({required BuildContext context, required String asset}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LegalDialog(asset: asset);
      },
    );
  }

  Widget _buildLanguageOption(String unit) {
    return ListTile(
      title: Text(unit),
      onTap: () {
        setState(() {
          Info.setUnits(unit.contains("Metric") ? 'metric' : 'imperial');
          SharedPref.saveString(
              'units', unit.contains("Metric") ? 'metric' : 'imperial');
        });
        Navigator.pop(context); // Close the dialog
      },
    );
  }
}
