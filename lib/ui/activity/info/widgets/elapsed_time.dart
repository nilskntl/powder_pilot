import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/activity/info/widgets/duration_graph.dart';

import '../../../../activity/state.dart';
import '../../../../string_pool.dart';
import '../../../../theme/icon.dart';
import '../../../../theme/widget.dart';
import 'category.dart';

class ElapsedTime extends StatefulWidget {
  const ElapsedTime(
      {super.key,
      required this.downhillTime,
      required this.uphillTime,
      required this.pauseTime,
      required this.totalTime,
      this.active = false,
      this.summary = false});

  final Duration downhillTime;
  final Duration uphillTime;
  final Duration pauseTime;
  final Duration totalTime;
  final bool active;
  final bool summary;

  @override
  State<ElapsedTime> createState() => _ElapsedTimeState();
}

class _ElapsedTimeState extends State<ElapsedTime> {
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: WidgetTheme.animatedContainer(
        padding: Category.paddingInside,
        alignment: Alignment.topLeft,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          children: [
            Row(
              crossAxisAlignment:
                  PowderPilot.dataProvider.status == ActivityStatus.inactive &&
                          !widget.summary
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
              children: [
                Category.buildIcon(
                    icon: LogoTheme.duration,
                    targetHeight: Category.iconHeight * 2),
                const SizedBox(width: 12),
                Category.buildHeader(title: StringPool.DURATION),
              ],
            ),
            if (PowderPilot.dataProvider.status != ActivityStatus.inactive ||
                widget.summary)
              const SizedBox(height: 32),
            if (PowderPilot.dataProvider.status != ActivityStatus.inactive ||
                widget.summary)
              SizedBox(
                  height: 144,
                  child: DurationGraph(
                    downhill: widget.downhillTime,
                    uphill: widget.uphillTime,
                    pause: widget.pauseTime,
                    total: widget.totalTime,
                    small: widget.summary,
                  )),
          ],
        ),
      ),
    );
  }
}
