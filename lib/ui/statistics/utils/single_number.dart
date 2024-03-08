import 'package:flutter/cupertino.dart';

import '../../../theme/font.dart';
import '../../../utils/general_utils.dart';

/// Displays a single number with a title.
class SingleNumber extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double height;

  const SingleNumber(
      {required this.title,
      required this.value,
      required this.color,
      this.height = 52,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Utils.buildText(
          text: value,
          fontSize: FontTheme.size,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        Utils.buildText(
          text: title,
          fontSize: height,
          color: color,
        ),
      ],
    );
  }
}
