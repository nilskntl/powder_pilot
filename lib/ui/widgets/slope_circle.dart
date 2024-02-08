import 'package:flutter/cupertino.dart';

import '../../activity/slopes.dart';
import '../../string_pool.dart';
import '../../theme/color.dart';
import '../../theme/font.dart';
import '../../theme/icon.dart';
import '../../utils/general_utils.dart';

/// Class to display a circle with a slope or lift
class SlopeCircle extends StatefulWidget {
  const SlopeCircle(
      {super.key, required this.slope, this.size = 48, this.animated = false});

  /// The size of the circle
  final double size;

  /// Flag to animate the circle
  final bool animated;

  /// The slope or lift to display
  final SlopeInfo slope;

  /// Get the name of the slope
  ///
  /// @param slope The slope to get the name from
  /// @param size The size of the text
  /// @return The name of the slope
  static Widget buildSlopeName(
      {required SlopeInfo slope, double size = FontTheme.sizeSubHeader}) {
    if (slope.type == 'gondola' ||
        slope.type == 'chair_lift' ||
        slope.type == 'drag_lift' ||
        slope.type == 'platter' ||
        slope.type == 't-bar') {
      return Utils.buildText(
          text: slope.name,
          color: ColorTheme.contrast,
          fontSize: size,
          caps: false,
          fontWeight: FontWeight.bold);
    } else if (slope.name != 'Unknown' && slope.name != '') {
      return Utils.buildText(
          text: '${StringPool.SLOPE_PISTE}: ${slope.name}',
          color: ColorTheme.contrast,
          fontSize: size,
          caps: false,
          fontWeight: FontWeight.bold);
    } else {
      return Utils.buildText(
          text: StringPool.FREE_RIDE,
          color: ColorTheme.contrast,
          fontSize: size,
          caps: false,
          fontWeight: FontWeight.bold);
    }
  }

  @override
  State<SlopeCircle> createState() => _SlopeCircleState();
}

/// State for the slope circle
class _SlopeCircleState extends State<SlopeCircle> {
  /// Get the color for the circle
  /// In case of a lift, the color is always black. Intermediate slopes are
  /// red, easy slopes are blue, advanced slopes are black
  /// Free Ride Slopes are dark grey
  ///
  /// @param difficulty The difficulty of the slope
  Color _getColor(String difficulty) {
    if (widget.slope.name == 'Unknown') {
      return ColorTheme.black;
    }
    if (difficulty == 'easy') {
      return ColorTheme.blue;
    } else if (difficulty == 'intermediate') {
      return ColorTheme.red;
    } else if (difficulty == 'advanced') {
      return ColorTheme.black;
    } else {
      return ColorTheme.darkGrey;
    }
  }

  @override
  void initState() {
    super.initState();

    /// Schedule a callback after the first frame is rendered
    /// to start the animation if the flag is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized && widget.animated) {
        setState(() {
          transparent = !transparent;
          _initialized = true;
        });
      }
    });
  }

  /// Flag to animate the circle (switch between transparent and opaque)
  bool transparent = true;

  /// Flag to check if the widget is initialized
  bool _initialized = false;

  /// Get the icon for a lift
  ///
  /// @param type The type of the lift (e.g. gondola, chair_lift)
  String getIconString(String type) {
    if (type == 'gondola') {
      return 'assets/images/lift/gondola.png';
    } else {
      return 'assets/images/lift/chair_lift.png';
    }
  }

  /// Build the inside of the circle
  Widget _buildInside() {
    if (widget.slope.type == 'intermediate' ||
        widget.slope.type == 'easy' ||
        widget.slope.type == 'advanced') {
      return Utils.buildText(
          text: widget.slope.name,
          fontSize: widget.size / 3,
          color: ColorTheme.white,
          fontWeight: FontWeight.bold,
          caps: false);
    } else if (widget.slope.type == 'gondola' ||
        widget.slope.type == 'chair_lift' ||
        widget.slope.type == 'drag_lift' ||
        widget.slope.type == 'platter' ||
        widget.slope.type == 't-bar') {
      return Image.asset(getIconString(widget.slope.type),
          width: widget.size / 3 * 2, height: widget.size / 3 * 2);
    } else {
      return Icon(
        LogoTheme.activity,
        color: ColorTheme.white,
        size: widget.size / 3 * 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = _getColor(widget.slope.type);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 2000),
          width: widget.size + 8,
          height: widget.size + 8,
          decoration: transparent
              ? BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular((widget.size + 8) / 2),
                )
              : BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular((widget.size + 8) / 2),
                ),
          onEnd: () {
            if (widget.animated) {
              setState(() {
                transparent = !transparent;
              });
            }
          },
        ),
        // Position Container in the center
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2000),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(widget.size / 2),
              ),
              alignment: Alignment.center,
              child: _buildInside(),
            ),
          ),
        ),
      ],
    );
  }
}
