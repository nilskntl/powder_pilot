import 'dart:math';

import 'package:flutter/material.dart';

class MountainPainter extends CustomPainter {
  MountainPainter({this.color = Colors.black});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color.withOpacity(0.75)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height);

    int peaks = 9;
    double segmentWidth = size.width / (peaks - 1);

    List<double> peakHeights = [];
    peakHeights.add(0);
    peakHeights.add(size.height * 0.7);
    peakHeights.add(size.height * 0.4);
    peakHeights.add(size.height * 0.3);
    peakHeights.add(size.height * 1.0);
    peakHeights.add(size.height * 0.5);
    peakHeights.add(size.height * 0.8);
    peakHeights.add(size.height * 0.2);
    peakHeights.add(0);

    for (int i = 0; i < peaks; i++) {
      double peakX = i * segmentWidth;
      path.lineTo(peakX, size.height - peakHeights[i]);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
