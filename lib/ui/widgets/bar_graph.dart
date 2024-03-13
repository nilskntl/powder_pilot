import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../theme/animation.dart';
import '../../../../theme/color.dart';
import '../../../../theme/font.dart';
import '../../../../theme/widget.dart';
import '../../utils/general_utils.dart';

class BarGraph extends StatefulWidget {
  const BarGraph({
    super.key,
    required this.map,
    required this.titleColor,
    required this.barColor,
    this.barWidth = 18,
  });

  final Map<String, int> map;
  final Color titleColor;
  final Color barColor;
  final double barWidth;

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  @override
  Widget build(BuildContext context) {
    return WidgetTheme.container(
      child: BarChart(
        swapAnimationDuration: AnimationTheme.fastAnimationDuration,
        BarChartData(
          gridData: const FlGridData(
            show: true,
          ),
          alignment: BarChartAlignment.spaceEvenly,
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
            /// Create one entry for each element in the map
            for (var i = 0; i < widget.map.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  _data(
                    toY: widget.map.values.elementAt(i).toDouble(),
                    color: widget.barColor,
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
      width: widget.barWidth,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    );
  }

  Widget _getTitles(double value, TitleMeta meta) {
    /// Get the title from the map
    String title = widget.map.keys.elementAt(value.toInt());
    return Utils.buildText(
      text: title,
      fontSize: FontTheme.size - 4,
      color: widget.titleColor,
    );
  }

  BarTooltipItem _getTouchData({required int index}) {
    /// The touch data should be the value from the map
    int value = widget.map.values.elementAt(index);

    return BarTooltipItem(
      value.round().toString(),
      TextStyle(
        color: ColorTheme.secondary,
        fontWeight: FontWeight.bold,
        fontSize: FontTheme.size,
      ),
    );
  }
}
