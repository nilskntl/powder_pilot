import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../theme.dart';

/// Widget to display a single graph
class SingleGraph<T> extends StatefulWidget {
  const SingleGraph(
      {super.key,
      required this.data,
      this.factor = 1.0,
      required this.color,
      this.unit = '',
      this.dummy = false});

  /// The data of the altitude
  final List<List<T>> data;

  /// The height of the graph if there are different entries
  final double heightExpanded = 64;

  /// The height of the graph if there are the same entries
  final double heightSameEntries = 24;

  /// The factor to multiply the values with
  final double factor;

  /// The unit of the values
  final String unit;

  /// The color of the line
  final Color color;

  /// Flag to display a dummy graph
  final bool dummy;

  @override
  State<SingleGraph> createState() => _SingleGraphState();
}

class _SingleGraphState extends State<SingleGraph> {
  /// Dummy data for the graph
  final List<FlSpot> dummyData = const [
    FlSpot(0, 0),
    FlSpot(1, 0),
    FlSpot(2, 1),
    FlSpot(3, 3),
    FlSpot(4, 2),
    FlSpot(5, 3),
    FlSpot(6, 4),
    FlSpot(7, 3),
    FlSpot(8, 4),
    FlSpot(9, 5),
    FlSpot(10, 5),
    FlSpot(11, 4),
    FlSpot(12, 6),
    FlSpot(13, 7),
    FlSpot(14, 4),
    FlSpot(15, 3),
    FlSpot(16, 1),
    FlSpot(17, 0),
  ];

  @override
  void initState() {
    super.initState();
    _differentEntries = hasDifferentEntry(widget.data);
  }

  /// Convert a list of generic lists to FlSpots
  ///
  /// @param dataList The list of generic lists (T can be int or double)
  /// @param factor The factor to multiply the values with
  List<FlSpot> _convertToFlSpots<T>({required List<List<T>> list}) {
    _differentEntries = hasDifferentEntry(list);

    List<FlSpot> flSpots = [];

    /// Iterate through the list of T
    for (List<T> data in list) {
      /// Only add the FlSpot if the list has two elements
      if (data.length == 2) {
        /// Get the values of the list (x, y)
        double x =
            data[0] is int ? (data[0] as int).toDouble() : data[0] as double;
        double y =
            data[1] is int ? (data[1] as int).toDouble() : data[1] as double;

        /// Try to add the FlSpot to the list of FlSpots
        /// If the value is not a double, the value is not added
        /// If the value is a double, the value is rounded to one decimal place
        try {
          flSpots.add(FlSpot(x, y * widget.factor));
        } catch (e) {
          if (kDebugMode) {
            print('Cant add FlSpot: $e');
          }
        }
      }
    }

    return flSpots;
  }

  /// Flag to check if the list has different entries at position 2
  bool _differentEntries = false;

  /// Check if one of the list has different entries at position 2 to
  /// change the size of the graph dynamically
  ///
  /// @param list The list of lists
  bool hasDifferentEntry<T>(List<List<T>> list) {
    /// Check if the list has at least one element
    if (list.isEmpty) {
      return false;
    }

    /// Get the value at position 2 of the first list
    T referenceValue = list[0][1];

    /// Iterate through the rest of the lists and check if the value at position 2 is different
    for (int i = 1; i < list.length; i++) {
      if (list[i][1] != referenceValue) {
        /// Found a different entry at position 2
        return true;
      }
    }

    /// All entries at position 2 are the same
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: AnimationTheme.fastAnimationDuration,
          height: (widget.data.length > 1 && _differentEntries) || widget.dummy
              ? 8
              : 0,
        ),
        AnimatedContainer(
          duration: AnimationTheme.fastAnimationDuration,
          height: widget.data.length > 1 || widget.dummy
              ? _differentEntries || widget.dummy
                  ? widget.heightExpanded
                  : widget.heightSameEntries
              : 0,
          child: widget.data.length > 1
              ? _buildLineChart(
                  list: widget.data,
                  color: widget.color,
                )
              : widget.dummy
                  ? _buildDummyChart(flSpots: dummyData)
                  : const SizedBox(),
        ),
      ],
    );
  }

  /// Build the line chart
  ///
  /// @param color The color of the line
  /// @param list The list of lists with the data (T can be int or double)
  Widget _buildLineChart<T>({
    required List<List<T>> list,
    required Color color,
  }) {
    /// Convert the list to FlSpots
    List<FlSpot> flSpots = _convertToFlSpots(list: list);

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: ColorTheme.contrast.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
              return lineBarsSpot.map((LineBarSpot lineBarSpot) {
                return LineTooltipItem(
                  '${lineBarSpot.y.toStringAsFixed(1)} ${widget.unit}',
                  TextStyle(
                    color: ColorTheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.4),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                      0.0,
                      0.8,
                      1.0
                    ],
                    colors: [
                      color.withOpacity(0.5),
                      color.withOpacity(0.4),
                      color.withOpacity(0.0)
                    ])),
            spots: flSpots,
            curveSmoothness: 0.01,
          ),
        ],
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }

  /// Build a dummy chart
  ///
  /// @param flSpots The list of FlSpots
  Widget _buildDummyChart({required List<FlSpot> flSpots}) {
    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            showOnTopOfTheChartBoxArea: false,
          ),
          handleBuiltInTouches: false,
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: ColorTheme.grey.withOpacity(0.6),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: false,
            ),
            spots: flSpots,
            curveSmoothness: 0.01,
          ),
        ],
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }
}
