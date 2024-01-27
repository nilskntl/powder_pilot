import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../theme.dart';

/// A utility class containing various helper methods and widgets.
class Utils {
  /// Builds a text widget with specified properties.
  ///
  /// @param text The text to display.
  /// @param fontSize The font size of the text.
  /// @param color The color of the text.
  /// @param softWrap Whether the text should wrap to the next line.
  /// @param fontWeight The font weight of the text.
  /// @param caps Whether the text should be in uppercase.
  /// @param align The alignment of the text.
  /// @param overflow How overflowing text should be handled.
  /// @return A Text widget with the specified properties.
  static Widget buildText({
    required String text,
    double fontSize = FontTheme.size,
    Color color = ColorTheme.contrast,
    bool softWrap = false,
    FontWeight fontWeight = FontWeight.normal,
    bool caps = true,
    TextAlign align = TextAlign.center,
    TextOverflow overflow = TextOverflow.visible,
  }) {
    return Text(
      caps ? text.toUpperCase() : text,
      overflow: overflow,
      textAlign: align,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontFamily: FontTheme.fontFamily,
        fontWeight: fontWeight,
      ),
    );
  }

  /// Calculates the font size based on the available width and other parameters.
  ///
  /// @param text The text for which the font size is calculated.
  /// @param paddingLeftRight The padding on the left and right sides.
  /// @param standardFontSize The standard font size to start with.
  /// @param context The build context.
  /// @param fontWeight The font weight of the text.
  /// @return The calculated font size.
  static double calculateFontSizeByContext({
    required String text,
    double paddingLeftRight = 0.0,
    double standardFontSize = FontTheme.size,
    required BuildContext context,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    double maxWidth = MediaQuery.of(context).size.width - paddingLeftRight;

    if (maxWidth < 0) {
      maxWidth = 0;
    }

    double fontSize = standardFontSize + 0.5;

    while (fontSize > 1) {
      fontSize = fontSize - 0.5;
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);

      if (textPainter.width < maxWidth) {
        break;
      }
    }
    return fontSize;
  }

  /// Calculates the Haversine distance between two geographical positions.
  ///
  /// @param pos1 The first geographical position.
  /// @param pos2 The second geographical position.
  /// @return The Haversine distance between the two positions.
  static double calculateHaversineDistance(LatLng pos1, LatLng pos2) {
    double toRadians(double degree) {
      return degree * (math.pi / 180.0);
    }

    double lat1 = pos1.latitude;
    double lat2 = pos2.latitude;
    double lon1 = pos1.longitude;
    double lon2 = pos2.longitude;

    const R = 6371000.0;

    /// Earth radius in meters

    final dLat = toRadians(lat2 - lat1);
    final dLon = toRadians(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRadians(lat1)) *
            math.cos(toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  /// Converts the activity timestamp to a formatted date and time string.
  ///
  /// @param activity The timestamp of the activity.
  /// @return A list containing the formatted date and time strings.
  static List<String> durationStringToString(String activity) {
    String year = DateTime.parse(activity).year.toString();
    String month = DateTime.parse(activity).month.toString().padLeft(2, '0');
    String day = DateTime.parse(activity).day.toString().padLeft(2, '0');
    String hour = DateTime.parse(activity).hour.toString().padLeft(2, '0');
    String minute = DateTime.parse(activity).minute.toString().padLeft(2, '0');

    String date = '$month/$day/$year';
    String time = '$hour:$minute';

    return [date, time];
  }

  /// Formats a duration object into a string (MM:SS).
  ///
  /// @param difference The duration to format.
  /// @return A formatted duration string.
  static formatDuration(Duration difference) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = difference.inMinutes.toString();
    String twoDigitSeconds = twoDigits(difference.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

/// A custom painter to draw a dotted horizontal line.
class DrawDottedHorizontalLine extends CustomPainter {
  final Paint _paint = Paint();

  DrawDottedHorizontalLine() {
    _paint.color = Colors.black;

    ///dots color
    _paint.strokeWidth = 2;

    ///dots thickness
    _paint.strokeCap = StrokeCap.square;

    ///dots corner edges
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (double i = -300; i < 300; i = i + 15) {
      /// 15 is space between dots
      if (i % 3 == 0) {
        canvas.drawLine(Offset(i, 0.0), Offset(i + 10, 0.0), _paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
