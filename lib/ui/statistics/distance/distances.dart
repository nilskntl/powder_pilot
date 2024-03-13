import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/theme/measurement.dart';
import 'package:powder_pilot/theme/widget.dart';
import 'package:powder_pilot/ui/statistics/utils/single_number.dart';

import '../../../string_pool.dart';
import '../../../theme/color.dart';

class Distances extends StatelessWidget {
  const Distances({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetTheme.container(
      margin: const EdgeInsets.only(right: 8.0, left: 8.0),
      padding: const EdgeInsets.all(1.0),
      color: ColorTheme.primary,
      child: WidgetTheme.container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SingleNumber(
                title: StringPool.DOWNHILL,
                value: (PowderPilot.statistics.distanceDownhill /
                        1000 *
                        Measurement.distanceFactor)
                    .toStringAsFixed(0),
                color: ColorTheme.grey,
                unit: Measurement.unitDistance,
              ),
            ),
            Expanded(
              child: SingleNumber(
                title: StringPool.TOTAL,
                value: (PowderPilot.statistics.distanceTotal /
                        1000 *
                        Measurement.distanceFactor)
                    .toStringAsFixed(0),
                unit: Measurement.unitDistance,
                color: ColorTheme.grey,
                height: 48,
              ),
            ),
            Expanded(
              child: SingleNumber(
                title: StringPool.UPHILL,
                value: (PowderPilot.statistics.distanceUphill /
                        1000 *
                        Measurement.distanceFactor)
                    .toStringAsFixed(0),
                unit: Measurement.unitDistance,
                color: ColorTheme.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
