import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/activity/data_provider.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/widgets/single_graph.dart';

import '../../../../activity/state.dart';
import '../../../../string_pool.dart';
import '../../../../theme.dart';
import '../../../../utils/general_utils.dart';
import 'category.dart';

class Run extends StatefulWidget {
  const Run({super.key, required this.dataProvider, this.summary = false});

  final ActivityDataProvider dataProvider;
  final bool summary;

  @override
  State<Run> createState() => _RunState();
}

class _RunState extends State<Run> {
  @override
  Widget build(BuildContext context) {
    return WidgetTheme.container(
      padding: Category.paddingInside,
      alignment: Alignment.topLeft,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment:
                PowderPilot.dataProvider.status == ActivityStatus.inactive &&
                        !widget.summary
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
            children: [
              Category.buildHeader(title: StringPool.RUNS),
              const SizedBox(width: 12),
              Category.buildIcon(
                  icon: LogoTheme.runs, targetHeight: Category.iconHeight * 2),
            ],
          ),
          if (PowderPilot.dataProvider.status != ActivityStatus.inactive ||
              widget.summary)
            const SizedBox(height: 8.0),
          if (PowderPilot.dataProvider.status != ActivityStatus.inactive ||
              widget.summary)
            Row(
              children: [
                Utils.buildText(
                    text: widget.dataProvider.runs.totalRuns.toString(),
                    fontSize: FontTheme.sizeHeader * 2,
                    fontWeight: FontWeight.bold),
                const Spacer(),
                Category.buildSecondaryValueColumn(
                  value: (widget.dataProvider.runs.longestRun / 1000 * Measurement.distanceFactor).toStringAsFixed(1),
                  title: StringPool.LONGEST,
                  unit: Measurement.unitDistance,
                ),
              ],
            ),
          if (PowderPilot.dataProvider.status != ActivityStatus.inactive ||
              widget.summary)
            const SizedBox(height: 8.0),
          if (PowderPilot.dataProvider.status != ActivityStatus.inactive ||
              widget.summary)
            SingleGraph(
              data: widget.dataProvider.distance.distances,
              factor: 0.001 * Measurement.distanceFactor,
              unit: Measurement.unitDistance,
              color: ColorTheme.primary,
              dummy: true,
            ),
        ],
      ),
    );
  }
}
