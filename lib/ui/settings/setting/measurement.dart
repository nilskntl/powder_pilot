import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/theme/icon.dart';
import 'package:powder_pilot/ui/settings/settings.dart';

import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../theme/measurement.dart';
import '../../../theme/widget.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/shared_preferences.dart';
import '../../activity/activity_page.dart';
import '../../history/history.dart';

/// The measurement setting allows the user to change the measurement units of the app.
class MeasurementSetting extends StatefulWidget {
  const MeasurementSetting({super.key});

  @override
  State<MeasurementSetting> createState() => _MeasurementSettingState();
}

/// The state of the measurement setting
class _MeasurementSettingState extends State<MeasurementSetting> {
  /// Switches the measurement units of the app
  ///
  /// @param measurement The measurement to switch to (e.g. 'metric')
  void _switchMeasurement(String measurement) {
    if (kDebugMode) {
      print('Switching measurement to $measurement');
    }

    /// Set the measurement units of the app
    setState(() {
      Measurement.setUnits(measurement);
      SharedPref.saveString('units', measurement);
      PowderPilot.reload();
      HistoryPage.reload();
      ActivityPage.reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetTheme.settingsListTile(
      title: StringPool.MEASUREMENT,
      leading: Icon(
        LogoTheme.measurement,
        color: ColorTheme.contrast,
        size: SettingsPage.leadingWidget,
      ),
      subtitle: Utils.buildText(
        text: '${StringPool.CURRENT_MEASUREMENT} ${Measurement.unitSpeed}',
        caps: false,
        align: TextAlign.left,
      ),
      onTap: () {
        WidgetTheme.settingsDialog(children: [
          WidgetTheme.settingsOption(
              title: '${StringPool.MEASUREMENT_METRIC} (km/h)',
              context: context,
              onTap: () {
                _switchMeasurement('metric');
              }),
          Divider(
            color: ThemeChanger.currentTheme.darkMode
                ? ColorTheme.background
                : ColorTheme.grey,
          ),
          WidgetTheme.settingsOption(
            title: '${StringPool.MEASUREMENT_IMPERIAL} (mph)',
            context: context,
            onTap: () {
              _switchMeasurement('imperial');
            },
          ),
          Divider(
            color: ThemeChanger.currentTheme.darkMode
                ? ColorTheme.background
                : ColorTheme.grey,
          ),
        ], context: context);
      },
    );
  }
}
