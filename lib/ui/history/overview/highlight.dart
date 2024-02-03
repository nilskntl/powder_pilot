import 'package:flutter/material.dart';
import 'package:powder_pilot/ui/history/delete.dart';
import 'package:powder_pilot/ui/history/page/summary_page.dart';

import '../../../activity/database.dart';
import '../../../string_pool.dart';
import '../../../theme.dart';
import '../../../utils/general_utils.dart';
import 'history.dart';

/// Shows an overview over the most important data of an activity
class Highlight extends StatefulWidget {
  const Highlight({super.key, required this.activity});

  /// The activity to display
  final ActivityDatabase activity;

  @override
  State<Highlight> createState() => _HighlightState();
}

/// The state for the HistoryOverview widget.
class _HighlightState extends State<Highlight> {
  /// Flag to track if the activity is deleted
  bool _deleted = false;

  /// Check if the activity is deleted
  void _checkIfActivityIsDeleted() async {
    if (!(await ActivityDatabaseHelper.containsActivity(widget.activity.id))) {
      /// Update the state of the History Page if the activity is deleted
      /// and set the value of _deleted to true
      setState(() {
        _deleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        /// Show a dialog to confirm the deletion of the activity
        DeleteActivity.showDeleteConfirmationDialog(
            context: context,
            activity: widget.activity,
            onPressed: () {
              /// Check if the activity is deleted
              _checkIfActivityIsDeleted();
            });
      },
      onTap: () {
        /// Go to the detailed [SummaryPage] of the activity
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryPage(
              activityDatabase: widget.activity,
              onDelete: _checkIfActivityIsDeleted,
            ),
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(height: _deleted ? 0.0 : 8.0),
          WidgetTheme.animatedContainer(
              height: _deleted ? 0.0 : 156.0,
              onEnd: () {
                if (_deleted) {
                  History.reload();
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(0.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLocation(
                      location: widget.activity.areaName != ''
                          ? widget.activity.areaName
                          : StringPool.UNKNOWN_AREA),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      _buildIcon(),
                      const SizedBox(width: 8.0),
                      _buildDataTime(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      /// Build the highlight value for total distance, duration and max speed
                      _buildHighlightValue(StringPool.DISTANCE,
                          '${(widget.activity.distance * Measurement.distanceFactor / 1000).toStringAsFixed(1)} ${Measurement.unitDistance}'),
                      _buildHighlightValue(StringPool.DURATION,
                          '${widget.activity.elapsedTime.substring(0, 4)} ${Measurement.unitTime}'),
                      _buildHighlightValue(StringPool.SPEED,
                          '${(widget.activity.maxSpeed * Measurement.speedFactor).toStringAsFixed(1)} ${Measurement.unitSpeed}'),
                    ],
                  ),
                ],
              )),
          SizedBox(height: _deleted ? 0.0 : 8.0),
        ],
      ),
    );
  }

  /// Shows the location of the activity
  ///
  /// @param location The location of the activity [Country, City]
  Widget _buildLocation({required String location}) {
    const double iconHeight = 20;

    return Row(
      children: [
        Icon(
          LogoTheme.gps,
          color: ColorTheme.primary,
          size: iconHeight,
        ),
        const SizedBox(width: 4.0),
        Utils.buildText(
            text: location,
            fontSize: FontTheme.size,
            fontWeight: FontWeight.bold,
            color: ColorTheme.primary),
      ],
    );
  }

  /// Build the icon for the activity
  Widget _buildIcon() {
    const double iconHeight = 24;

    return WidgetTheme.container(
      width: iconHeight * 2,
      height: iconHeight * 2,
      color: ColorTheme.primary,
      child: Icon(
        LogoTheme.activity,
        color: ColorTheme.secondary,
        size: iconHeight,
      ),
    );
  }

  /// Build the text for the start and end time of the activity
  Widget _buildDataTime() {
    /// Build the text for the start and end time of the activity
    ///
    /// @param text The text to display
    Widget buildTextTime({required String text}) {
      return Utils.buildText(
          text: text,
          fontSize: FontTheme.size,
          fontWeight: FontWeight.bold,
          color: ColorTheme.grey);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Date of Activity
          Utils.buildText(
              text: Utils.durationStringToString(widget.activity.startTime)[0],
              fontSize: FontTheme.sizeSubHeader,
              fontWeight: FontWeight.bold,
              color: ColorTheme.contrast),
          Row(
            children: [
              /// Start time [hh:mm] of Activity
              buildTextTime(
                  text: Utils.durationStringToString(
                      widget.activity.startTime)[1]),
              const SizedBox(width: 4.0),
              buildTextTime(text: '-'),
              const SizedBox(width: 4.0),

              /// End time [hh:mm] of Activity
              buildTextTime(
                  text:
                      Utils.durationStringToString(widget.activity.endTime)[1]),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the highlight value (total distance, duration and max speed)
  ///
  /// @param text The name of the value
  /// @param value The value to display
  Widget _buildHighlightValue(String text, String value) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils.buildText(
            text: value,
            fontSize: FontTheme.size + 4,
            fontWeight: FontWeight.bold,
            color: ColorTheme.contrast,
            caps: false),
        Utils.buildText(
            text: text,
            fontSize: FontTheme.size - 4,
            fontWeight: FontWeight.bold,
            color: ColorTheme.grey),
      ],
    ));
  }
}
