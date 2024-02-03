import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:powder_pilot/main.dart';
import 'package:powder_pilot/ui/activity/info/widgets/duration_graph.dart';

import '../../../../activity/state.dart';
import '../../../../string_pool.dart';
import '../../../../theme.dart';
import '../../../../utils/general_utils.dart';
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

  Widget _buildTimeBar(Duration downhill, Duration uphill, Duration pause) {
    int flexDownhill = downhill.inSeconds;
    int flexUphill = uphill.inSeconds;
    int flexPause = pause.inSeconds;

    if (flexPause == 0 && flexDownhill == 0 && flexUphill == 0) {
      flexPause = 1;
      flexDownhill = 0;
      flexUphill = 0;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: flexDownhill,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: ColorTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(4.0),
                  bottomLeft: const Radius.circular(4.0),
                  topRight: (flexPause == 0 && flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  bottomRight: (flexPause == 0 && flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                ),
              ),
            )),
        Expanded(
            flex: flexPause,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: ColorTheme.grey,
                borderRadius: BorderRadius.only(
                  topRight: (flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  bottomRight: (flexUphill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  topLeft: (flexDownhill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                  bottomLeft: (flexDownhill == 0)
                      ? const Radius.circular(4.0)
                      : const Radius.circular(0.0),
                ),
              ),
            )),
        Expanded(
          flex: flexUphill,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: ColorTheme.contrast,
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(4.0),
                bottomRight: const Radius.circular(4.0),
                topLeft: (flexPause == 0 && flexDownhill == 0)
                    ? const Radius.circular(4.0)
                    : const Radius.circular(0.0),
                bottomLeft: (flexPause == 0 && flexDownhill == 0)
                    ? const Radius.circular(4.0)
                    : const Radius.circular(0.0),
              ),
            ),
          ),
        ),
      ],
    );
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

  List<PieChartSectionData> showingSections() {
    const double fontSize = FontTheme.size;
    const double radius = 20.0;
    TextStyle titleStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: ColorTheme.contrast,
    );

    return [
      PieChartSectionData(
        color: ColorTheme.grey,
        value: widget.totalTime.inSeconds.toDouble() > 0
            ? widget.pauseTime.inSeconds.toDouble() /
                widget.totalTime.inSeconds.toDouble() *
                100
            : 0,
        title: '',
        radius: radius,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        color: ColorTheme.primary,
        value: widget.totalTime.inSeconds.toDouble() > 0
            ? widget.downhillTime.inSeconds.toDouble() /
                widget.totalTime.inSeconds.toDouble() *
                100
            : 0,
        title: '',
        radius: radius,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        color: ColorTheme.contrast,
        value: widget.totalTime.inSeconds.toDouble() > 0
            ? widget.uphillTime.inSeconds.toDouble() /
                widget.totalTime.inSeconds.toDouble() *
                100
            : 0,
        title: '',
        radius: radius,
        titleStyle: titleStyle,
      ),
    ];
  }

  Widget test() {
    return Column(
      children: [
        _buildNames(),
        const SizedBox(height: 4),
        _buildTimeBar(widget.downhillTime, widget.uphillTime, widget.pauseTime),
        const SizedBox(height: 4),
        _buildTimes(),
      ],
    );
  }

  Row _buildNames() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              const SizedBox(width: 4),
              _buildText(text: StringPool.DOWNHILL),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: _buildText(text: StringPool.PAUSE),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildText(text: StringPool.UPHILL),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildTimes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              const SizedBox(width: 4),
              _buildText(text: widget.downhillTime.toString().substring(0, 7)),
            ],
          ),
        ),
        Expanded(
          child: _buildText(text: widget.pauseTime.toString().substring(0, 7)),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildText(text: widget.uphillTime.toString().substring(0, 7)),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildText({required String text}) {
    return Utils.buildText(
      text: text,
      fontSize: widget.summary ? FontTheme.size - 2 : FontTheme.size,
      color: ColorTheme.contrast,
      fontWeight: FontWeight.bold,
      caps: false,
    );
  }
}
