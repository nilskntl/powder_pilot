import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../activity/data_provider.dart';
import '../../../../activity/state.dart';
import '../../../../main.dart';
import '../../../../theme/color.dart';

/// The stop button allows the user to stop the activity.
/// The button is red and animated when the activity is running.
/// When the activity is inactive, the button is grey and not animated.
class StopButton extends StatefulWidget {
  const StopButton({super.key, required this.dataProvider});

  /// The data provider for the activity
  final ActivityDataProvider dataProvider;

  /// The size of the button
  final double size = 32.0;

  @override
  State<StopButton> createState() => _StopButtonState();
}

/// The state of the stop button
class _StopButtonState extends State<StopButton> {
  bool transparent = false;

  /// Updates the state of the button
  void update() {
    setState(() {
      widget.dataProvider.status != ActivityStatus.inactive
          ? transparent = !transparent
          : transparent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.size / 2),
      child: MaterialButton(
        onPressed: () {
          if (widget.dataProvider.status != ActivityStatus.inactive) {
            PowderPilot.activity.stopActivity(context);
          }
        },
        minWidth: widget.size + 4,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            _outerCircle(),
            _innerCircle(),
          ],
        ),
      ),
    );
  }

  /// The inner circle of the button. The circle animates the color from
  /// grey to red when the activity starts.
  Widget _innerCircle() {
    return Positioned(
      top: 3,
      left: 3,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 2000),
        curve: Curves.easeInOut,
        width: widget.size - 6,
        height: widget.size - 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size / 2 - 3),
          color: widget.dataProvider.status != ActivityStatus.inactive
              ? ColorTheme.red
              : ColorTheme.grey,
        ),
      ),
    );
  }

  /// The outer circle of the button
  /// The circle is animated when the activity is running.
  Widget _outerCircle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
      width: widget.size,
      height: widget.size,
      decoration: transparent
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size / 2),
        color: widget.dataProvider.status != ActivityStatus.inactive
            ? ColorTheme.red.withOpacity(0.1)
            : ColorTheme.grey.withOpacity(0.5),
      )
          : BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size / 2),
        color: widget.dataProvider.status != ActivityStatus.inactive
            ? ColorTheme.red.withOpacity(0.5)
            : ColorTheme.grey.withOpacity(0.5),
      ),
      onEnd: () {
        update();
      },
    );
  }

}
