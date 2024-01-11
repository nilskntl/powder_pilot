import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ski_tracker/utils/custom_app_bar.dart';
import 'package:ski_tracker/utils/shared_preferences.dart';

import 'activity/activity_display.dart';
import 'main.dart';

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
      appBar: CustomAppBarDesign.appBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Measurement"),
              subtitle: Text("Current system: ${Info.unitSpeed}"),
              onTap: () {
                _showLanguageSelectionDialog();
              },
            ),
            const SizedBox(height: 8.0),
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
            height: 150,// Hier die gewünschte Breite setzen
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

  Widget _buildLanguageOption(String unit) {
    return ListTile(
      title: Text(unit),
      onTap: () {
        setState(() {
          Info.setUnits(unit.contains("Metric") ? 'metric' : 'imperial');
          SharedPref.saveString('units', unit.contains("Metric") ? 'metric' : 'imperial');
        });
        Navigator.pop(context); // Close the dialog
      },
    );
  }

}