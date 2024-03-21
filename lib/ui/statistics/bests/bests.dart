import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/statistics/utils/material_text_button.dart';

import '../../../main.dart';
import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../theme/font.dart';
import '../../../theme/icon.dart';
import '../../../theme/measurement.dart';
import '../../../utils/general_utils.dart';
import '../utils/single_value.dart';

class Bests extends StatelessWidget {
  const Bests({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaterialTextButton(
          text: StringPool.BESTS,
          color: ColorTheme.secondary,
        ),
        const SizedBox(height: 16),
        Row(children: [
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleValue(
                title: StringPool.SPEED,
                value: PowderPilot.statistics.maxSpeed.toStringAsFixed(1),
                unit: Measurement.unitSpeed,
                fontHeight: FontTheme.size,
                colorTitle: ColorTheme.grey,
                colorValue: ColorTheme.primary,
                icon: LogoTheme.speed,
              ),
              const SizedBox(height: 16),
              SingleValue(
                title: StringPool.ALTITUDE,
                value: PowderPilot.statistics.maxAltitude.round().toString(),
                unit: Measurement.unitAltitude,
                fontHeight: FontTheme.size,
                colorTitle: ColorTheme.grey,
                colorValue: ColorTheme.primary,
                icon: LogoTheme.altitude,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleValue(
                title: StringPool.RUNS,
                value: PowderPilot.statistics.numRuns.toString(),
                fontHeight: FontTheme.size,
                colorTitle: ColorTheme.grey,
                colorValue: ColorTheme.primary,
                icon: LogoTheme.runs,
              ),
              const SizedBox(height: 16),
              SingleValue(
                title: StringPool.LONGEST,
                value: PowderPilot.statistics.longestRun.toString(),
                unit: Measurement.unitDistance,
                fontHeight: FontTheme.size,
                colorTitle: ColorTheme.grey,
                colorValue: ColorTheme.primary,
                icon: LogoTheme.runs,
              ),
            ],
          ),
          const SizedBox(width: 16),
        ])
      ],
    );
  }
}
