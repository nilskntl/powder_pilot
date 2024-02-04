import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Draw the location mark
class LocationMark extends CustomPainter {
  /// Size of the marker
  final double markerSize = 32.0;

  /// Width of the border
  final int markerBorderWidth = 4;

  /// Color of the location mark inner circle
  final Color locationMark = const Color(0xFF007aff);

  /// Color of the location mark arrow (compass)
  final Color locationMarkArrow = const Color(0xFF007aff);

  /// Color of the location mark border
  final Color locationMarkBorder = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    drawCircle(canvas, size, locationMarkBorder, size.width / 2);
    drawCircle(canvas, size, locationMark, size.width / 2 - markerBorderWidth);
  }

  /// Draw the arrow (currently not used)
  ///
  /// @param canvas The canvas
  /// @param size The size of the canvas
  void drawArrow(Canvas canvas, Size size) {
    /// Calculate the offset of the arrow
    Offset calculateOffset(Size size, double angle) {
      return Offset(size.width / 2 + (size.width / 2 * cos(angle)),
          size.height / 2 + (size.width / 2 * sin(angle)));
    }

    var arrow = Paint()
      ..color = locationMarkArrow
      ..style = PaintingStyle.fill;

    double arrowAngle = 270 * (pi / 180);
    double arrowLength = size.width;

    Offset arrowTip = Offset(size.width / 2 + arrowLength * cos(arrowAngle),
        size.height / 2 + arrowLength * sin(arrowAngle));
    Offset arrowBase1 = calculateOffset(size, arrowAngle - pi / 2);
    Offset arrowBase2 = calculateOffset(size, arrowAngle + pi / 2);

    ui.Path path = ui.Path();
    path.moveTo(arrowBase1.dx, arrowBase1.dy);
    path.lineTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(arrowBase2.dx, arrowBase2.dy);
    path.arcTo(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2),
        arrowAngle + pi / 2,
        pi,
        false);
    path.close();

    canvas.drawPath(path, arrow);
  }

  /// Draw the circle (inner and border)
  ///
  /// @param canvas The canvas
  /// @param size The size of the canvas
  /// @param color The color of the circle
  /// @param radius The radius of the circle
  void drawCircle(Canvas canvas, Size size, Color color, double radius) {
    var circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), radius, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
