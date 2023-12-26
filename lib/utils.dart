import 'package:flutter/cupertino.dart';

import 'main.dart';

class Utils {
  static Widget buildText({required String text, double fontSize = FontTheme.size, Color color = ColorTheme.contrastColor, bool softWrap = false, FontWeight fontWeight = FontWeight.normal}) {
    return Text(
      text,
      softWrap: softWrap,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        overflow: TextOverflow.ellipsis,
        fontFamily: FontTheme.fontFamily,
        fontWeight: fontWeight,
      ),
    );
  }
}