import 'package:flutter/material.dart';
import 'package:powder_pilot/activity/data_provider.dart';

import '../../../activity/state.dart';
import '../../../main.dart';
import '../../../string_pool.dart';
import '../../../theme/color.dart';
import '../../../theme/animation.dart';
import '../../../theme/font.dart';
import '../../../theme/icon.dart';
import '../../../utils/general_utils.dart';
import '../../controller.dart';
import 'widgets/stop_button.dart';

/// The status bar shows the current status of the activity
/// and allows the user to start, pause and resume the activity.
class StatusBar extends StatefulWidget {
  const StatusBar(
      {super.key,
      required this.dataProvider,
      required this.customPageController});

  /// The data provider for the activity
  final ActivityDataProvider dataProvider;

  /// The custom page controller for the app
  final CustomController customPageController;

  @override
  State<StatusBar> createState() => _StatusBarState();
}

/// The state of the status bar
class _StatusBarState extends State<StatusBar> {
  /// Handles the start, pause and resume of the activity
  void _onStartButton() {
    /// If the activity is inactive, start the activity
    /// and scroll to a fixed position
    if (widget.dataProvider.status == ActivityStatus.inactive) {
      PowderPilot.activity.startActivity();
      double targetPosition = MediaQuery.of(context).size.height - 200;
      widget.customPageController.scrollController.animateTo(
        targetPosition,
        curve: Curves.easeOut,
        duration: AnimationTheme.animationDuration,
      );
    }

    /// If the activity is paused, resume the activity
    else if (widget.dataProvider.status == ActivityStatus.paused) {
      PowderPilot.activity.resumeActivity();
    }

    /// If the activity is running, pause the activity
    else if (widget.dataProvider.status == ActivityStatus.running) {
      PowderPilot.activity.pauseActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: MaterialButton(
            onPressed: () {
              _onStartButton();
            },
            height: 32,
            color: ColorTheme.secondary,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: ColorTheme.primary, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatus(),
                _buildStartButton(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildElapsedTime(),
        const SizedBox(width: 8),
        StopButton(dataProvider: widget.dataProvider),
      ],
    );
  }

  /// Shows the current status of the activity (inactive, running, paused)
  Widget _buildStatus() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.dataProvider.status == ActivityStatus.inactive
                ? ColorTheme.background
                : widget.dataProvider.status == ActivityStatus.running
                    ? ColorTheme.primary
                    : widget.dataProvider.status == ActivityStatus.paused
                        ? ColorTheme.grey
                        : ColorTheme.grey,
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        const SizedBox(width: 4),
        Utils.buildText(
          text: widget.dataProvider.status == ActivityStatus.inactive
              ? StringPool.INACTIVE
              : widget.dataProvider.status == ActivityStatus.running
                  ? StringPool.RUNNING
                  : widget.dataProvider.status == ActivityStatus.paused
                      ? StringPool.PAUSED
                      : '',
          fontWeight: FontWeight.bold,
          color: ColorTheme.primary,
          fontSize: FontTheme.size - 4,
        ),
      ],
    );
  }

  /// Build the button for managing the activity (start, pause, resume)
  Widget _buildStartButton() {
    return Row(
      children: [
        Utils.buildText(
            text: widget.dataProvider.status == ActivityStatus.running
                ? StringPool.PAUSE
                : widget.dataProvider.status == ActivityStatus.paused
                    ? StringPool.RESUME
                    : StringPool.START,
            fontSize: 12,
            color: ColorTheme.primary,
            fontWeight: FontWeight.bold),
        Icon(
          widget.dataProvider.status == ActivityStatus.running
              ? LogoTheme.pause
              : LogoTheme.start,
          color: ColorTheme.primary,
        ),
      ],
    );
  }

  /// Build the elapsed time of the current activity
  Widget _buildElapsedTime() {
    return Row(
      children: [
        const SizedBox(width: 4),
        Utils.buildText(
            text: widget.dataProvider.duration.total.toString().substring(0, 7),
            fontSize: FontTheme.sizeSubHeader,
            color: widget.dataProvider.status == ActivityStatus.running ||
                    widget.dataProvider.status == ActivityStatus.paused
                ? ColorTheme.primary
                : ColorTheme.grey,
            fontWeight: FontWeight.bold,
            caps: false),
      ],
    );
  }
}
