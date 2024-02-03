import 'package:flutter/cupertino.dart';

import '../../../activity/database.dart';
import '../../../string_pool.dart';
import '../../../theme.dart';
import '../../../utils/general_utils.dart';

/// Shows an overview over the most important data of the history
/// (e.g. number of activities, earliest and latest activity)
class HistoryHeader extends StatefulWidget {
  const HistoryHeader({super.key, required this.activities});

  /// List of activities
  final List<ActivityDatabase>? activities;

  /// Height of the calender icon
  final double iconHeight = 64.0;

  @override
  State<HistoryHeader> createState() => _HistoryHeaderState();
}

class _HistoryHeaderState extends State<HistoryHeader> {
  @override
  Widget build(BuildContext context) {
    if (widget.activities == null || widget.activities!.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 8.0),
          _buildIcon(),
          const SizedBox(width: 24.0),
          Expanded(
            child: _buildOverview(
                title: StringPool.ACTIVITIES,
                value: '0',
                fontSize: FontTheme.size + 4),
          ),
          const SizedBox(width: 8.0),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 8.0),
        _buildIcon(),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOverview(
                      title: StringPool.ACTIVITIES,
                      value: widget.activities!.length.toString()),
                  _buildOverview(
                      title: StringPool.LATEST,
                      value: Utils.durationStringToString(
                          widget.activities!.first.startTime)[0]),
                  _buildOverview(
                      title: StringPool.EARLIEST,
                      value: Utils.durationStringToString(
                          widget.activities!.last.startTime)[0]),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
      ],
    );
  }

  /// Build the icon for the history
  Widget _buildIcon() {
    return Container(
      width: widget.iconHeight,
      height: widget.iconHeight,
      decoration: BoxDecoration(
        color: ColorTheme.primary,
        borderRadius: BorderRadius.all(
          Radius.circular(widget.iconHeight / 4),
        ),
      ),
      child: Icon(
        LogoTheme.history,
        color: ColorTheme.secondary,
        size: widget.iconHeight - 24,
      ),
    );
  }

  /// Build the overview for the history (e.g. number of activities, earliest
  /// and latest activity)
  ///
  /// @param title The title of the overview
  /// @param value The value of the overview
  /// @param fontSize The font size
  Widget _buildOverview(
      {required String title,
      required String value,
      double fontSize = FontTheme.size}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Utils.buildText(
            text: value,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: ColorTheme.contrast),
        Utils.buildText(
            text: title,
            fontSize: fontSize - 4,
            fontWeight: FontWeight.bold,
            color: ColorTheme.grey),
      ],
    );
  }
}
