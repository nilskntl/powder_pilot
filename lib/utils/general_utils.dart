import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../main.dart';

class Utils {
  static Widget buildText(
      {required String text,
      double fontSize = FontTheme.size,
      Color color = ColorTheme.contrast,
      bool softWrap = false,
      FontWeight fontWeight = FontWeight.normal,
      bool caps = true, TextAlign align = TextAlign.center, TextOverflow overflow = TextOverflow.visible}) {
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

  static double calculateFontSizeByContext({required String text, double paddingLeftRight = 0.0, double standardFontSize = FontTheme.size, required BuildContext context, fontWeight = FontWeight.normal}) {
    // Berechnung der maximalen verfügbaren Breite unter Berücksichtigung des linken und rechten Randes
    double maxWidth = MediaQuery
        .of(context)
        .size
        .width - paddingLeftRight;

    if(maxWidth < 0) {
      maxWidth = 0;
    }

    double fontSize = standardFontSize + 0.5;

    while (fontSize > 1) {
      fontSize = fontSize - 0.5;
      // Hier können Sie je nach Bedarf die Textelemente anpassen, um die optimale Größe zu finden
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
      )
        ..layout(maxWidth: maxWidth);

      // Überprüfen, ob der Text zu breit ist und die Schriftgröße anpassen
      if (textPainter.width < maxWidth) {
        break;
      }
    }
    return fontSize;
  }

  static double calculateHaversineDistance(
      LatLng pos1, LatLng pos2) {
    double toRadians(double degree) {
      return degree * (math.pi / 180.0);
    }

    double lat1 = pos1.latitude;
    double lat2 = pos2.latitude;
    double lon1 = pos1.longitude;
    double lon2 = pos2.longitude;

    const R = 6371000.0; // Earth radius in meters

    final dLat = toRadians(lat2 - lat1);
    final dLon = toRadians(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRadians(lat1)) *
            math.cos(toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  static List<String> durationStringToString(String activity) {
    String year = DateTime.parse(
        activity)
        .year
        .toString();
    String month = DateTime.parse(
        activity)
        .month
        .toString();
    if(month.length == 1) {
      month = '0$month';
    }
    String day = DateTime.parse(
        activity).day.toString();
    if(day.length == 1) {
      day = '0$day';
    }

    String hour = DateTime.parse(
        activity).hour.toString();
    if(hour.length == 1) {
      hour = '0$hour';
    }

    String minute = DateTime.parse(
        activity).minute.toString();
    if(minute.length == 1) {
      minute = '0$minute';
    }

    String date =
        '$month/$day/$year';

    String time =
        '$hour:$minute';

    return [date, time];

  }

  static formatDuration(Duration difference) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = difference.inMinutes.toString();
    String twoDigitSeconds = twoDigits(difference.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

}

class DrawDottedHorizontalLine extends CustomPainter {
  final Paint _paint = Paint();
  DrawDottedHorizontalLine() {
    _paint.color = Colors.black; //dots color
    _paint.strokeWidth = 2; //dots thickness
    _paint.strokeCap = StrokeCap.square; //dots corner edges
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (double i = -300; i < 300; i = i + 15) {
      // 15 is space between dots
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
