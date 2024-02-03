import 'package:flutter/material.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/settings/settings.dart';

import '../../../string_pool.dart';
import '../../../theme.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/shared_preferences.dart';
import '../../activity/activity_page.dart';
import '../../history/overview/history.dart';

class MeasurementSetting extends StatefulWidget {
  const MeasurementSetting({super.key});

  @override
  State<MeasurementSetting> createState() => _MeasurementSettingState();
}

class _MeasurementSettingState extends State<MeasurementSetting> {
  @override
  Widget build(BuildContext context) {
    return WidgetTheme.settingsListTile(
        title: StringPool.MEASUREMENT,
        leading: Icon(
          Icons.speed,
          color: ColorTheme.contrast,
          size: SettingsPage.leadingWidget,
        ),
        subtitle: Utils.buildText(
            text: '${StringPool.CURRENT_MEASUREMENT} ${Measurement.unitSpeed}',
            caps: false,
            align: TextAlign.left),
        onTap: () {
          WidgetTheme.settingsDialog(children: [
            WidgetTheme.settingsOption(
                title: '${StringPool.MEASUREMENT_METRIC} (km/h)',
                context: context,
                onTap: () {
                  setState(() {
                    Measurement.setUnits('metric');
                    SharedPref.saveString('units', 'metric');
                    PowderPilot.reload();
                    History.reload();
                    ActivityPage.reload();
                  });
                }),
            WidgetTheme.settingsOption(
                title: '${StringPool.MEASUREMENT_IMPERIAL} (mph)',
                context: context,
                onTap: () {
                  setState(() {
                    Measurement.setUnits('imperial');
                    SharedPref.saveString('units', 'imperial');
                    PowderPilot.reload();
                    History.reload();
                    ActivityPage.reload();
                  });
                }),
          ], context: context);
        });
  }
}
