import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../main.dart';

class Utils {
  static Widget buildText(
      {required String text,
      double fontSize = FontTheme.size,
      Color color = ColorTheme.contrastColor,
      bool softWrap = false,
      FontWeight fontWeight = FontWeight.normal,
      bool caps = true}) {
    return Text(
      caps ? text.toUpperCase() : text,
      softWrap: softWrap,
      overflow: TextOverflow.clip,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        overflow: TextOverflow.ellipsis,
        fontFamily: FontTheme.fontFamily,
        fontWeight: fontWeight,
      ),
    );
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
