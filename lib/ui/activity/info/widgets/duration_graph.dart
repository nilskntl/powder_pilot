import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../string_pool.dart';
import '../../../../theme.dart';

class DurationGraph extends StatefulWidget {
  const DurationGraph(
      {super.key,
      required this.downhill,
      required this.uphill,
      required this.pause,
      required this.total,
      this.active = false,
      this.small = false});

  final Duration downhill;
  final Duration uphill;
  final Duration pause;
  final Duration total;

  final bool active;
  final bool small;

  @override
  State<DurationGraph> createState() => _DurationGraphState();
}

class _DurationGraphState extends State<DurationGraph> {
  @override
  Widget build(BuildContext context) {
    return WidgetTheme.container(
      child: BarChart(
        swapAnimationDuration: AnimationTheme.fastAnimationDuration,
        BarChartData(
          gridData: const FlGridData(
            show: true,
          ),
          alignment: BarChartAlignment.spaceBetween,
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: ColorTheme.grey,
                width: 1,
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: ColorTheme.contrast.withOpacity(0.8),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return _getTouchData(index: groupIndex);
              },
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 28,
                showTitles: true,
                getTitlesWidget: _getTitles,
              ),
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                _data(
                  toY: widget.pause.inSeconds.toDouble(),
                  color: ColorTheme.grey,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                _data(
                  toY: widget.downhill.inSeconds.toDouble(),
                  color: ColorTheme.primary,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                _data(
                  toY: widget.uphill.inSeconds.toDouble(),
                  color: ColorTheme.contrast,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartRodData _data({required double toY, required Color color}) {
    return BarChartRodData(
      toY: toY,
      color: color,
      width: 16,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    );
  }

  Widget _getTitles(double value, TitleMeta meta) {
    Widget buildIcon({required IconData icon}) {
      return Column(
        children: [
          const SizedBox(height: 4),
          Icon(
            icon,
            color: ColorTheme.primary,
            size: 24,
          ),
        ],
      );
    }

    Widget icon;
    switch (value.toInt()) {
      case 0:
        icon = buildIcon(icon: Icons.pause);
        break;
      case 1:
        icon = buildIcon(icon: Icons.arrow_downward);
        break;
      case 2:
        icon = buildIcon(icon: Icons.arrow_upward);
        break;
      default:
        icon = const SizedBox();
        break;
    }
    return icon;
  }

  BarTooltipItem _getTouchData({required int index}) {
    String text;
    String value;
    switch (index) {
      case 0:
        text = StringPool.PAUSE;
        value = widget.pause.toString().substring(0, 7);
        break;
      case 1:
        text = StringPool.DOWNHILL;
        value = widget.downhill.toString().substring(0, 7);
        break;
      case 2:
        text = StringPool.UPHILL;
        value = widget.uphill.toString().substring(0, 7);
        break;
      default:
        text = '';
        value = '';
        break;
    }

    return BarTooltipItem(
      '$text\n$value',
      TextStyle(
        color: ColorTheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: FontTheme.size,
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
        value: widget.total.inSeconds.toDouble() > 0
            ? widget.pause.inSeconds.toDouble() /
                widget.total.inSeconds.toDouble() *
                100
            : 0,
        title: '',
        radius: radius,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        color: ColorTheme.primary,
        value: widget.total.inSeconds.toDouble() > 0
            ? widget.downhill.inSeconds.toDouble() /
                widget.total.inSeconds.toDouble() *
                100
            : 0,
        title: '',
        radius: radius,
        titleStyle: titleStyle,
      ),
      PieChartSectionData(
        color: ColorTheme.contrast,
        value: widget.total.inSeconds.toDouble() > 0
            ? widget.uphill.inSeconds.toDouble() /
                widget.total.inSeconds.toDouble() *
                100
            : 0,
        title: '',
        radius: radius,
        titleStyle: titleStyle,
      ),
    ];
  }
}
