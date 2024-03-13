import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/general_utils.dart';

/// Displays a single number with a title.
class SingleValue extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color colorTitle;
  final Color colorValue;
  final double fontHeight;
  final IconData icon;

  const SingleValue(
      {required this.title,
      required this.value,
      required this.colorTitle,
      required this.colorValue,
      required this.icon,
      this.unit = '',
      this.fontHeight = 18,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Utils.buildText(
          text: title,
          fontSize: fontHeight,
          fontWeight: FontWeight.bold,
          color: colorTitle,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorValue,
              size: fontHeight * 1.5,
            ),
            const SizedBox(width: 8),
            Utils.buildText(
              text: '$value $unit',
              fontSize: fontHeight,
              fontWeight: FontWeight.bold,
              caps: false,
              color: colorValue,
            ),
          ],
        )
      ],
    );
  }
}
