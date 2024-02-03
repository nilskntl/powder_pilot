import 'package:flutter/cupertino.dart';
import 'package:powder_pilot/ui/activity/info/widgets/category.dart';
import 'package:powder_pilot/ui/activity/info/widgets/run.dart';
import 'package:powder_pilot/ui/widgets/single_graph.dart';

import '../../../activity/data_provider.dart';
import '../../../activity/state.dart';
import '../../../string_pool.dart';
import '../../../theme.dart';
import 'widgets/elapsed_time.dart';

class Info extends StatefulWidget {
  const Info({super.key, required this.dataProvider});

  final ActivityDataProvider dataProvider;

  static const double height = 120.0;

  static const EdgeInsets padding = EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0);
  static const double iconSize = 40.0;

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.background,
        // Linear gradient
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 488,
        child: ListView(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          children: [
            Category(
              icon: LogoTheme.speed,
              title: StringPool.SPEED,
              unit: Measurement.unitSpeed,
              primaryValue: (widget.dataProvider.speed.currentSpeed *
                      Measurement.speedFactor)
                  .toStringAsFixed(1),
              secondaryValue1:
                  (widget.dataProvider.speed.maxSpeed * Measurement.speedFactor)
                      .toStringAsFixed(1),
              secondaryValue2:
                  (widget.dataProvider.speed.avgSpeed * Measurement.speedFactor)
                      .toStringAsFixed(1),
              primaryTitle: StringPool.CURRENT,
              secondaryTitle: StringPool.MAX,
              secondaryTitle2: StringPool.AVERAGE,
              child: SingleGraph(
                data: widget.dataProvider.speed.speeds,
                factor: Measurement.speedFactor,
                unit: Measurement.unitSpeed,
                color: ColorTheme.primary,
              ),
            ),
            Category(
              icon: LogoTheme.distance,
              title: StringPool.DISTANCE,
              unit: Measurement.unitDistance,
              primaryValue: (widget.dataProvider.distance.totalDistance *
                      Measurement.distanceFactor /
                      1000)
                  .toStringAsFixed(1),
              secondaryValue1: (widget.dataProvider.distance.distanceDownhill *
                      Measurement.distanceFactor /
                      1000)
                  .toStringAsFixed(1),
              secondaryValue2: (widget.dataProvider.distance.distanceUphill *
                      Measurement.distanceFactor /
                      1000)
                  .toStringAsFixed(1),
              primaryTitle: StringPool.TOTAL,
              secondaryTitle: StringPool.DOWNHILL,
              secondaryTitle2: StringPool.UPHILL,
            ),
            Category(
              icon: LogoTheme.altitude,
              title: StringPool.ALTITUDE,
              unit: Measurement.unitAltitude,
              primaryValue: (widget.dataProvider.altitude.currentAltitude *
                      Measurement.altitudeFactor)
                  .round()
                  .toString(),
              secondaryValue1: (widget.dataProvider.altitude.maxAltitude *
                      Measurement.altitudeFactor)
                  .round()
                  .toString(),
              secondaryValue2: (widget.dataProvider.altitude.minAltitude *
                      Measurement.altitudeFactor)
                  .round()
                  .toString(),
              primaryTitle: StringPool.CURRENT,
              secondaryTitle: StringPool.MAX,
              secondaryTitle2: StringPool.MIN,
              child: SingleGraph(
                data: widget.dataProvider.altitude.altitudes,
                factor: Measurement.altitudeFactor,
                unit: Measurement.unitAltitude,
                color: ColorTheme.primary,
              ),
            ),
            Category(
              icon: LogoTheme.slope,
              title: StringPool.DOWNWARD_SLOPE,
              unit: Measurement.unitSlope,
              primaryValue:
                  widget.dataProvider.slope.currentSlope.round().toString(),
              secondaryValue1:
                  widget.dataProvider.slope.maxSlope.round().toString(),
              secondaryValue2:
                  widget.dataProvider.slope.avgSlope.round().toString(),
              primaryTitle: StringPool.CURRENT,
              secondaryTitle: StringPool.MAX,
              secondaryTitle2: StringPool.AVERAGE,
            ),
            WidgetTheme.animatedContainer(
              color: ColorTheme.background,
              padding: Category.paddingOutside,
              height: widget.dataProvider.status == ActivityStatus.inactive
                  ? Category.iconHeight * 2 +
                      32 +
                      Category.paddingOutside.top +
                      Category.paddingOutside.bottom
                  : 264,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElapsedTime(
                    downhillTime: widget.dataProvider.duration.downhill,
                    uphillTime: widget.dataProvider.duration.uphill,
                    pauseTime: widget.dataProvider.duration.pause,
                    totalTime: widget.dataProvider.duration.total,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Run(dataProvider: widget.dataProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
