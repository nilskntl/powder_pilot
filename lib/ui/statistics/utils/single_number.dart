import 'package:flutter/cupertino.dart';

import '../../../theme/font.dart';
import '../../../utils/general_utils.dart';

/// Displays a single number with a title.
class SingleNumber extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final double height;

  const SingleNumber(
      {required this.title,
      required this.value,
      required this.color,
      required this.unit,
      this.height = 32,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Utils.buildText(
              text: value,
              fontSize: height,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            Column(children: [
              Utils.buildText(
                text: unit,
                fontSize: height / 3,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              SizedBox(height: height / 4)
            ])
          ],
        ),
        Utils.buildText(
          text: title,
          fontSize: FontTheme.size,
          color: color,
        ),
      ],
    );
  }
}
